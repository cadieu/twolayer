function A  = init_complex(M,N)
A=complex(randn(M,N),randn(M,N));
realnormA = sqrt(sum((real(A).^2)))';
imagnormA = sqrt(sum((imag(A).^2)))';
A=complex(real(A)*diag(1./realnormA'),imag(A)*diag(1./imagnormA'));
