function ITHK_groyne_to_kml(sens)
%function ITHK_groyne_to_kml(sens)
%
% Adds groynes to the KML file
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.phases
%              .userinput.phase(idphase).GROfile
%              .userinput.phase(idphase).groids
%              .userinput.groyne(ids).start
%              .userinput.groyne(ids).stop
%              .userinput.groyne(ids).filename
%              .UB.input(sens).groyne(ids).Ngroynes
%              .PP(sens).settings.t0
%              .PP(sens).settings.x0
%              .PP(sens).settings.y0
%              .PP(sens).settings.s0
%              .PP(sens).output.kml
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).output.kml
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_groyne_to_kml.m 10973 2014-07-21 08:28:29Z boer_we $
% $Date: 2014-07-21 16:28:29 +0800 (Mon, 21 Jul 2014) $
% $Author: boer_we $
% $Revision: 10973 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/measures/ITHK_groyne_to_kml.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Adding groynes to KML\n');

global S

S.PP(sens).output.kml_groyne=[];

% if isfield(S.userinput.phase(1),'groids')
%     for ii=1:length(S.userinput.phase);groids{ii}=S.userinput.phase(ii).groids;end
%     idfirst = find(~cellfun('isempty',groids),1,'first');
% end

style = 0;
for jj = 1:length(S.userinput.phases)
    GROdata = ITHK_io_readGRO([S.settings.outputdir S.userinput.phase(jj).GROfile]);
    for ii = 1:length(GROdata)

        %% Get info from structure
        % General info
        t0 = S.PP(sens).settings.t0;
        % MDA info
        x0 = S.PP(sens).settings.x0;
        y0 = S.PP(sens).settings.y0;
        s0 = S.PP(sens).settings.s0;

        Xw = GROdata(ii).Xw;
        Yw = GROdata(ii).Yw;
        Length = GROdata(ii).Length;

        %% preparation
        % Find groyne location
        dist2 = ((x0-Xw).^2 + (y0-Yw).^2).^0.5;
        idNEAREST = find(dist2==min(dist2),1,'first');
        s1 = s0(idNEAREST);
        xgroyne1 = x0(idNEAREST);
        ygroyne1 = y0(idNEAREST);

        % Smoothed orientation of coastline
        dx                   = x0(2:end)-x0(1:end-1);
        dy                   = y0(2:end)-y0(1:end-1);
        alpha                = atan2(dy,dx); %*180/pi()
        alpha                = mod(alpha+2*pi,2*pi);
        alpha                = [alpha(1);(alpha(1:end-1)+alpha(2:end))/2;alpha(end)];
        [alpha]              = ITHK_smoothvariable(alpha,100);
        alpha                = alpha(idNEAREST);
        xgroyne2 = xgroyne1+Length*cos(alpha+pi()/2);% Length as is, include factor for enlargement
        ygroyne2 = ygroyne1+Length*sin(alpha+pi()/2);

%         % Coastal point before
%         xs1             = x0(idNEAREST-1);
%         ys1             = y0(idNEAREST-1);
% 
%         % Coastal point after
%         xn1             = x0(idNEAREST+1);
%         yn1             = y0(idNEAREST+1);
% 
%         % Polygon (5*length, since length in groyne file represents only 0.2 of actual length)
%         alpha    = atan((yn1-ys1)/(xn1-xs1));
%         if alpha>0
%             if x0(end)>x0(1)  
%                 xgroyne2 = xgroyne1+Length*cos(alpha+pi()/2);% Length as is, include factor for enlargement
%                 ygroyne2 = ygroyne1+Length*sin(alpha+pi()/2);
%             else
%                 xgroyne2 = xgroyne1+Length*cos(alpha-pi()/2);% Length as is, include factor for enlargement
%                 ygroyne2 = ygroyne1+Length*sin(alpha-pi()/2);
%             end
%         elseif alpha<=0
%             if x0(end)>x0(1)              
%                 xgroyne2 = xgroyne1+Length*cos(alpha-pi()/2);
%                 ygroyne2 = ygroyne1+Length*sin(alpha-pi()/2);
%             else
%                 xgroyne2 = xgroyne1+Length*cos(alpha+pi()/2);
%                 ygroyne2 = ygroyne1+Length*sin(alpha+pi()/2);
%             end
%         end

        xpoly = [xgroyne1 xgroyne2];
        ypoly = [ygroyne1 ygroyne2];

        % convert coordinates
        [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
        lonpoly     = lonpoly';
        latpoly     = latpoly';

        % black rectangle
        if style == 0
            S.PP(sens).output.kml_groyne = KML_stylePoly('name','groyne','fillColor',[0 0 0],'lineColor',[0 0 0],'lineWidth',8,'fillAlpha',1);
            style = 1;
        end
        % polygon to KML
        S.PP(sens).output.kml_groyne = [S.PP(sens).output.kml_groyne KML_line(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.phase(jj).start,1,1),'timeOut',datenum(t0+S.userinput.phase(jj).stop,1,1)+364,'styleName','groyne')];
        clear lonpoly latpoly

    end
end

if ~isempty(S.PP(sens).output.kml_groyne)
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_groyne'];
end