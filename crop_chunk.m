function X = crop_chunk(F,m,p)

psz = m.patch_sz^2;
row=p.topmargin+p.BUFF+ceil((p.imsz-m.patch_sz-(p.topmargin+2*p.BUFF))*rand);
col=p.BUFF+ceil((p.imsz-m.patch_sz-2*p.BUFF)*rand);
X=reshape(F(row:row+m.patch_sz-1,col:col+m.patch_sz-1,1:p.imszt),psz,p.imszt*p.cons_chunks);

if p.normalize_crop
    X = X-mean(X(:));
    X=X/(sqrt(10*var(X(:))));
end

if p.whiten_patches && isfield(m,'whitenMatrix')
    X = bsxfun(@minus,X,m.imageMean);
    X = m.whitenMatrix*X;
end
