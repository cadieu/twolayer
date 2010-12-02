function display_D(m,fig)

if ~ isfield(m,'Acoords')
    m = fit_Acoords(m);
end

display_secondlayer(m.D,m,fig);
sfigure(fig);
title('Phase Transformation Components (m.D) - Space Domain')
sfigure(fig+1);
title('Phase Transformation Components (m.D) - Frequency Domain')
