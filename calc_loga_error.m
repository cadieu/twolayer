function [loga_error, loga_hat] = calc_loga_error(loga,v,m,p)

loga_hat = m.B*v;
loga_error = loga - loga_hat;
