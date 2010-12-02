function freezeColors(h)
% freezeColors  Lock colors of an image to current colors
%
%   Problem: There is only one colormap per figure. This function provides
%       an easy solution when plots using different colomaps
%       are desired in the same figure.
%
%   Useful if you want different colormaps on same page. freezeColors will
%       freeze the colors of graphics objects in the current axis so that later
%       changes to the colormap (or caxis) will not change the colors of these
%       objects. Affected objects include images, surfaces, scattergroups,
%       bargroups, patches, etc. (any object with CData in indexed-color mode).
%
%   The original indexed color data is saved, and can be restored using
%       unfreezeColors, making the plot once again subject to change with the
%       colormap.
%
%   Usage:
%       freezeColors        applies to all objects in current axis (gca)
%       freezeColors(axh)   works on axis axh.
%
%   Example:
%       subplot(2,1,1); imagesc(X); colormap hot; freezeColors
%       subplot(2,1,2); imagesc(Y); colormap hsv; freezeColors etc...
%
%       Note: colorbars must be explicitly frozen
%           hc = colorbar; freezeColors(hc), or simply freezeColors(colorbar)
%
%       For additional examples, see freezeColors_demo.
%
%   Side Effect:
%       Changing the color mode of objects can cause matlab to automatically
%       change the figure's render mode.
%       
%       See also unfreezeColors, freezeColors_demo.
%
%   John Iversen (iversen@nsi.edu) 3/23/05
%
%   Changes:
%   JRI (iversen@nsi.edu) 4/19/06   Correctly handles scaled integer cdata
%   JRI 9/1/06  now should handle all objects with cdata: images, surfaces, 
%   scatterplots, not just images as before. 
%

%   Special handling of patches: For some reason, setting
%   cdata on patches created by bar() yields an error, 
%   so set facevertexcdata instead for patches.


% Free for all uses, but please retain the following:
%   Original Author:
%   John Iversen
%   john_iversen@post.harvard.edu

if nargin < 1,
    h = gca;
end

%gather all children with scaled or indexed CData
cdatah = getCDataHandles(h);

cmap = colormap;
cax = caxis;
nColors = size(cmap,1);

% convert object color indexes into colormap to true color data using 
%  current colormap
for hh = cdatah',
    g = get(hh);
    if ~strcmp(g.Type,'patch'),
        cdata = g.CData;
    else
        cdata = g.FaceVertexCData; %special handling for patch (see note above)
    end
    %most objects w/ cdata have cdata mapping (except scattergroup)
    if isfield(g,'CDataMapping'),
        scalemode = g.CDataMapping;
    else
        scalemode = 'scaled'; 
    end
    
    siz = size(cdata);
    %save original indexed data for use with unfreezeColors
    setappdata(hh, 'JRI_freezeColorsData', {cdata scalemode});

    %convert cdata to indexes into colormap
    if strcmp(scalemode,'scaled'),
        %4/19/06 JRI, Accommodate scaled display of integer cdata:
        %       in MATLAB, uint * double = uint, so must coerce cdata to double
        %       Thanks to O Yamashita for pointing this need out
        idx = ceil( (double(cdata) - cax(1)) / (cax(2)-cax(1)) * nColors);
    else %direct mapping
        idx = cdata;
    end
    %clamp to [1, nColors]
    idx(idx<1) = 1;
    idx(idx>nColors) = nColors;

    %handle nans
    idx(isnan(idx))=1;

    %make true-color data
    realcolor = [];
    for i = 1:3,
        c = cmap(idx,i);
        c = reshape(c,siz);
        realcolor(:,:,i) = c;
    end
    if ~strcmp(g.Type,'patch'),
        set(hh,'cdata',realcolor);
    else
        set(hh,'facevertexcdata',permute(realcolor,[1 3 2]))
    end
end %loop on CData objects

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getCDataHandles -- get handles of all descendents with indexed CData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%recursively descend object tree, finding objects with indexed CData
% An exception: don't include children of objects that themselves have CData:
%   for example scattergroups are non-standard hggroups, with CData. Changing
%   such a group's CData automatically changes the CData of its children, 
%   (as well as the children's handles), so no need to act on them as well.

function hout = getCDataHandles(h)

hout = [];
if isempty(h),return;end

ch = get(h,'children');
for hh = ch'
    g = get(hh);
    if isfield(g,'CData'),     %does object have CData?
        if ~isempty(g.CData) && isnumeric(g.CData) && size(g.CData,3)==1, %is it indexed/scaled?
            hout = [hout; hh]; %yes, add to list
        end
    else %no CData, see if object has any interesting children
            hout = [hout; getCDataHandles(hh)];
    end
end

