function [Cequi]=computeEQUI(equi,c1,c2,hoek,QSoffset)
%% SUBFUNCTION computeEQUI
%  INPUT:
%    equi      Relative angle of eq. coastline with only waves [°]
%    c1        S-Phi parameter 1
%    c2        S-Phi parameter 2
%    hoek      Current coastline angle
%    QSoffset  Sediment transport for angles rota [m3/yr]
%  
%  OUTPUT:
%    Cequi   Equilibrium coastline angle [°N]
%
% Copyright Deltares, 2021
% Author : B.J.A. Huisman

    Cangle    = [(hoek-equi)-70:0.1:(hoek-equi)+70];
    phi_r     = Cangle-(hoek-equi);
    QS        = -c1.*phi_r.*exp(-((c2.*phi_r).^2)) +QSoffset/1000;
    if max(QS)>=0 && min(QS)<=0
        id        = find(abs(QS)==min(abs(QS)));
    elseif max(QS)<0
        id        = find(QS==max(QS));
    elseif min(QS)>0
        id        = find(QS==min(QS));
    end
    Cequi     = Cangle(id(1));
    Cequi     = Cequi(:);
end