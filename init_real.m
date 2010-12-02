function D  = init_real(N,L)

D=randn(N,L);
normD = sqrt(sum(abs(D).^2));
D=D*diag(1./normD);