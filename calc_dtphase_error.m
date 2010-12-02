function [dtphase_error, dtphase_hat] = calc_dtphase_error(dtphase,avalind,w,m,p)

dtphase_hat = m.D*w;

dtphase_error=avalind.*(dtphase-dtphase_hat);
