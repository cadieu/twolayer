function output = dS_phasetrans(dtphase, dtphasehat, avalind, m,p)

output = -p.phasetrans.phase_noise_factor*[diff(avalind.*sin(dtphase-dtphasehat),1,2) -avalind(:,end).*sin(dtphase(:,end)-dtphasehat(:,end))];