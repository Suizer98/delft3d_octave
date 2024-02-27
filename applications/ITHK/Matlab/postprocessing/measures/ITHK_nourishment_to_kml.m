function ITHK_nourishment_to_kml(sens)
%function ITHK_nourishment_to_kml(sens)
%
% Adds nourishments to the KML file
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .userinput.phases
%              .userinput.phase(idphase).SOSfile
%              .userinput.phase(idphase).supids
%              .userinput.nourishment(ids).volume
%              .userinput.nourishment(ids).idNEAREST
%              .userinput.nourishment(ids).idRANGE
%              .userinput.nourishment(ids).width
%              .userinput.nourishment(ids).category
%              .userinput.nourishment(ids).start
%              .userinput.nourishment(ids).stop
%              .PP(sens).settings.sVectorLength
%              .PP(sens).settings.t0
%              .PP(sens).settings.x0
%              .PP(sens).settings.y0
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

% $Id: ITHK_nourishment_to_kml.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/measures/ITHK_nourishment_to_kml.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Adding nourishments to KML\n');

global S

S.PP(sens).output.kml_nourishment=[];

if isfield(S.userinput.phase(1),'supids')
    for ii=1:length(S.userinput.phase);supids{ii}=S.userinput.phase(ii).supids;end
    idfirst = find(~cellfun('isempty',supids),1,'first');
end

for jj = 1:length(S.userinput.phases)
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
    if isfield(S.userinput.phase(jj).SOSfile,'supids')
    for ii = 1:length(S.userinput.phase(jj).supids)
        ss = S.userinput.phase(jj).supids(ii);

        %% Get info from structure
        t0 = S.PP(sens).settings.t0;
        % lat = S.userinput.nourishment(ss).lat;
        % lon = S.userinput.nourishment(ss).lon;
        mag = S.userinput.nourishment(ss).volume;
        % MDA info
        x0 = S.PP(sens).settings.x0;
        y0 = S.PP(sens).settings.y0;
        % s0 = S.PP(sens).settings.s0;
        % Grid info
        % sgridRough = S.PP(sens).settings.sgridRough; 
        % dxFine = S.PP(sens).settings.dxFine;
        sVectorLength = S.PP(sens).settings.sVectorLength;
        % idplotrough = S.PP(sens).settings.idplotrough;
        
        %% preparation
        idNEAREST = S.userinput.nourishment(ss).idNEAREST;
        idRANGE = S.userinput.nourishment(ss).idRANGE;
        width = S.userinput.nourishment(ss).width;
        
        %% nourishment to KML
        h = mag/width;
        %Only plot nourishment if extent is bigger than resolution
        if S.userinput.nourishment(ss).idRANGE(1)~=S.userinput.nourishment(ss).idRANGE(end)%x2~=x4 
            % For single or cont, plot triangle
            if ~strcmp(S.userinput.nourishment(ss).category,'distr')&&~strcmp(S.userinput.nourishment(ss).category,'distrsupp_single')
                alpha = atan((y0(idRANGE(end))-y0(idRANGE(1)))/(x0(idRANGE(end))-x0(idRANGE(1))));%alpha = atan((y4-y2)/(x4-x2));
                if alpha>0
%                    x3     = x0(idNEAREST)+0.5*sVectorLength*h*cos(alpha+pi()/2);%x1+0.5*sVectorLength*h*cos(alpha+pi()/2);
%                    y3     = y0(idNEAREST)+0.5*sVectorLength*h*sin(alpha+pi()/2);%y1+0.5*sVectorLength*h*sin(alpha+pi()/2);
                    x3     = mean(x0(idRANGE))+0.5*sVectorLength*h*cos(alpha+pi()/2);%x1+0.5*sVectorLength*h*cos(alpha+pi()/2);
                    y3     = mean(y0(idRANGE))+0.5*sVectorLength*h*sin(alpha+pi()/2);%y1+0.5*sVectorLength*h*sin(alpha+pi()/2);
                elseif alpha<=0
%                    x3     = x0(idNEAREST)+0.5*sVectorLength*h*cos(alpha-pi()/2);%x1+0.5*sVectorLength*h*cos(alpha-pi()/2);
 %                   y3     = y0(idNEAREST)+0.5*sVectorLength*h*sin(alpha-pi()/2);%y1+0.5*sVectorLength*h*sin(alpha-pi()/2);                   
                    x3     = mean(x0(idRANGE))+0.5*sVectorLength*h*cos(alpha-pi()/2);%x1+0.5*sVectorLength*h*cos(alpha-pi()/2);
                    y3     = mean(y0(idRANGE))+0.5*sVectorLength*h*sin(alpha-pi()/2);%y1+0.5*sVectorLength*h*sin(alpha-pi()/2);
                end
                xpoly=[mean(x0(idRANGE)) x0(idRANGE(1)) x3 x0(idRANGE(end)) mean(x0(idRANGE))];%[x1 x2 x3 x4 x1];
                ypoly=[mean(y0(idRANGE)) y0(idRANGE(1)) y3 y0(idRANGE(end)) mean(y0(idRANGE))];%[y1 y2 y3 y4 y1];
            % For distr, plot rectangle
            else
                idsupp = idRANGE(1:end-1);%id1:id2;
                for kk=1:length(idsupp)-1
                    alpha = atan((y0(idsupp(kk)+1)-y0(idsupp(kk)))/(x0(idsupp(kk)+1)-x0(idsupp(kk))));
                    if alpha>0
                        x2(kk)     = x0(idsupp(kk))+0.5*sVectorLength*h*cos(alpha+pi()/2);
                        y2(kk)     = y0(idsupp(kk))+0.5*sVectorLength*h*sin(alpha+pi()/2);
                    elseif alpha<=0
                        x2(kk)     = x0(idsupp(kk))+0.5*sVectorLength*h*cos(alpha-pi()/2);
                        y2(kk)     = y0(idsupp(kk))+0.5*sVectorLength*h*sin(alpha-pi()/2);
                    end
                end
                xpoly=[x0(idsupp)' fliplr(x2) x0(idsupp(1))];
                ypoly=[y0(idsupp)' fliplr(y2) y0(idsupp(1))];
            end

            % convert coordinates
            [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
            lonpoly     = lonpoly';
            latpoly     = latpoly';
        
            % yellow triangle/rectangle
            if jj==idfirst && ii==1
            S.PP(sens).output.kml_nourishment = KML_stylePoly('name','nourishment','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7);
            end
            % polygon to KML
            S.PP(sens).output.kml_nourishment = [S.PP(sens).output.kml_nourishment KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.nourishment(ss).start,1,1),'timeOut',datenum(t0+S.userinput.nourishment(ss).stop,1,1)+364,'styleName','nourishment')];
            clear lonpoly latpoly
        end
    end
    end
end        

if ~isempty(S.PP(sens).output.kml_nourishment)
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_nourishment'];
end   