function display_B(m,fig)

if ~ isfield(m,'Acoords')
    m = fit_Acoords(m);
end

display_secondlayer(m.B,m,fig)
sfigure(fig);
title('Amplitude Components (m.B) - Space Domain')
sfigure(fig+1);
title('Amplitude Components (m.B) - Frequency Domain')
