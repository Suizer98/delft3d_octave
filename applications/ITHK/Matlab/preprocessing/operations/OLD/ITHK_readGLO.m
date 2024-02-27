function [GLOdata]=ITHK_readGLO(GLOfilename)
%read GLO : Reads a UNIBEST glo-file
%   
%   Syntax: 
%     function [GLOdata]=ITHK_readGLO(GLOfilename)
%   
%   Input:
%     GLOfilename         String with filename of glo-file
%   
%   Output:
%     GLOdata        struct with contents of glo-file
%   
%   Example:
%     [GLOdata]=ITHK_readGLO('test.glo')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_readGLO.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_readGLO.m $
% $Keywords: $

%% Open file
fid=fopen(GLOfilename);
frewind(fid);

%% Read LTR file data
line=fgetl(fid);
line=fgetl(fid);GLOdata.LTRfilename = line(21:end);
line=fgetl(fid);GLOdata.TransportRay = line(21:end);
line=fgetl(fid);

%% Read file data
line=fgetl(fid);GLOdata.PRO = line(41:end);
line=fgetl(fid);GLOdata.CFS = line(41:end);
line=fgetl(fid);GLOdata.CFE = line(41:end);
line=fgetl(fid);GLOdata.SCO = line(41:end);
line=fgetl(fid);

%% Read normalization factor
line=fgetl(fid);GLOdata.NormFac = line(31:end);
line=fgetl(fid);line=fgetl(fid);line=fgetl(fid);

%% Read current coastline properties
line=fgetl(fid);
part1 = str2num(line);
GLOdata.a_equi = part1(1);
GLOdata.dQs_da = part1(2);
GLOdata.v_transp = part1(3);
GLOdata.v_rotation = part1(4);
line=fgetl(fid);line=fgetl(fid);line=fgetl(fid);

%% Read S-Phi diagram properties
for ii=1:11
    part2 = str2num(fgetl(fid));
    GLOdata.rota(ii)      = part2(1);
    GLOdata.QScalc(ii)    = part2(2);
    GLOdata.QSapprox(ii)  = part2(3);
end
line=fgetl(fid);line=fgetl(fid);line=fgetl(fid);

%% Read approximation
part3 = str2num(fgetl(fid));
if length(part3)<5; part3(:,5) = 0; end
part3B=[];
part3B(:,1)=part3(4)-part3(1);
part3B(:,2)=(part3(2)*(0-part3(1))*exp(-(part3(3)*(0-part3(1)))^2))*1000000;
GLOdata.location     = GLOfilename;
GLOdata.equi         = part3(:,1);
GLOdata.c1           = part3(:,2);
GLOdata.c2           = part3(:,3);
GLOdata.hoek         = part3(:,4);
GLOdata.QSoffset     = part3(:,5);
GLOdata.Cequi        = computeEQUI(GLOdata.equi,GLOdata.c1,GLOdata.c2,GLOdata.hoek,GLOdata.QSoffset);
GLOdata.S            = round((part3B(:,2)+GLOdata.QSoffset)*100)/100;

line=fgetl(fid);line=fgetl(fid);line=fgetl(fid);

%% Read bypass functions
part4 = str2num(fgetl(fid));
GLOdata.perc2   = part4(1);
GLOdata.perc20  = part4(2);
GLOdata.perc50  = part4(3);
GLOdata.perc80  = part4(4);
GLOdata.perc100 = part4(4);
GLOdata.Xc      = part4(4);

%% Close file
fclose all;
end


%% SUBFUNCTION computeEQUI
function [Cequi]=computeEQUI(equi,c1,c2,hoek,QSoffset)
    %  INPUT:
    %    equi      Relative angle of eq. coastline with only waves [°]
    %    c1        S-Phi parameter 1
    %    c2        S-Phi parameter 2
    %    hoek      Current coastline angle
    %    QSoffset  Sediment transport for angles rota [m3/yr]
    %  
    %  OUTPUT:
    %    Cequi   Equilibrium coastline angle [°N]
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
end
% 
% %% SUBFUNCTION computeEQUI2
% function [Cequi]=computeEQUI2(rota,QS)
%     %  INPUT:
%     %    rota    Angles of coastline [°N]
%     %    QS      Sediment transport for angles rota [m3/yr]
%     %  
%     %  OUTPUT:
%     %    Cequi   Equilibrium coastline angle [°N]
% 
%     Cangle    = [min(rota):0.1:max(rota)];
%     QS2       = interp1(rota,QS,Cangle);
%     Cequi     = Cangle(QS2==min(abs(QS2)));
% end