function [xpontos, ypontos] = xyrd2xypontos(xrd, yrd)
%XYRD2XYPONTOS converts Dutch RD coordinates to PonTos coordinates for
% the Dutch coast
%
%   BETA RELEASE
%
%   Syntax:
%   [xpontos, ypontos] = xyrd2xypontos(xrd, yrd)
%
%   Input:
%   xrd    = x coordinate in Dutch RD system [m]
%   yrd    = y coordinate in Dutch RD system [m]
%
%   Output:
%   xpontos = alongshore position [m]
%   ypontos = cross-shore position [m]
%
%   Example
%   xyrd2xypontos
%
%   See also: jarkus_rsp2xy

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oettemplate.m 688 2009-07-15 11:46:33Z damsma $
% $Date: 2009-07-15 13:46:33 +0200 (Wed, 15 Jul 2009) $
% $Author: damsma $
% $Revision: 688 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/oet_template/oettemplate.m $
% $Keywords: $

%%

Y0_H = 545000;
R_H = 150000;
X0_H = 110000 - R_H;

X0_B = -156777;
Y0_B = 569645;
R_B = 250000;

X0_D1 = 0;
Y0_D1  = 372867.966;
D_D = 45;
X_Ref_01 = 0;

X0_D2 = 20000;
Y0_D2  = 392867.966;
X_Ref_02 = 28284.27;

Y0_Ww = 545000;
X0_Ww = 169865.80;
R_Ww  = X0_Ww - 110000;

D_W = 8;

X0_We = X0_Ww;
Y0_We = 754866;
R_We = 150000;

if yrd < Y0_H
    if (xrd-X0_H)/(Y0_H-yrd) < 1
        if (xrd-X0_B)/(Y0_B-yrsp) < 1
            refline = -1;                                                   % Belgian coast
        else
            refline = 1;                                                    % Dutch Delta coast
        end
    else
        refline = 2;                                                        % Central Dutch coast (Holland coast)
    end
else
    if xrd <= X0_Ww
        refline = 3;                                                        % Western Wadden coast
    else
        refline = 4;                                                        % Eastern Wadden coast
    end
end

if refline == 1
    X0_D = X0_D1;
    Y0_D = Y0_D1;
    X_Ref_0 = X_Ref_01;
else
    X0_D = X0_D2;
    Y0_D = Y0_D2;
    X_Ref_0 = X_Ref_02;
end

switch refline
    case -1
        xpontos = X_Ref_02 - (atan((Y0_B-yrd)./(xrd-X0_B))-(0.25.*pi)) .* R_B;
        R_RSP = sqrt((xrd-X0_B).^2+(yrd-Y0_B).^2);
        ypontos = R_B - R_RSP;
    case 1
        a = tand(D_D);
        b = Y0_D - a.*X0_D;
        B1 = Y0_D-(a.*X0_D);
        B2 = yrd+((1/a).*xrd);
        X_cross = (B2-B1)./(a+1/a);
        Y_cross = a.*X_cross + B1;
        
        xpontos = X_Ref_0 + sqrt((X0_D-X_cross).^2+(Y0_D-Y_cross).^2);
        ypontos = sqrt((xrd-X_cross).^2+(yrd-Y_cross).^2);
        if Y_cross > yrd
            ypontos = ypontos.*-1;
        end
    case 2
        xpontos = 211241.18 - atan((Y0_H-yrd)./(xrd-X0_H)) .* R_H;
        R_RSP = sqrt((xrd-X0_H).^2+(yrd-Y0_H).^2);
        ypontos = R_H - R_RSP;
    case 3
        xpontos = 211241.18 + atan((Y0_Ww-yrd)./(xrd-X0_Ww)) .* R_Ww;
        R_RSP = sqrt((xrd-X0_Ww).^2+(yrd-Y0_Ww).^2);
        ypontos = R_RSP - R_Ww;
    case 4
        xpontos = 305278. + atan((xrd-X0_We)./(Y0_We-yrd)) .* R_We;
		R_RSP = SQRT((xrd-X0_We).^2+(yrd-Y0_We).^2);
		ypontos = R_We - R_RSP;
end






