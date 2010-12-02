function [Ierror, Ihat] = calc_Ierror(I,a,phase,m,p)

Ihat = real(m.A)*(a.*cos(phase)) + imag(m.A)*(a.*sin(phase));%real(Phi(:,:,t)*conj(Z));
Ierror = I - Ihat;
