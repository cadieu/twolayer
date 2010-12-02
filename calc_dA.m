function dA = calc_dA(Z,I_E,m,p)

dA = bsxfun(@times,-m.I_noise_factors,complex(I_E*real(Z).',I_E*imag(Z).'));
