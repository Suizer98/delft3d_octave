function ITHK_revetment_to_kml(sens)
%function ITHK_revetment_to_kml(sens)
%
% Adds revetments to the KML file
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .userinput.phases
%              .userinput.phase(idphase).REVfile
%              .userinput.phase(idphase).revids
%              .userinput.revetment(ids).idRANGE
%              .userinput.revetment(ids).start
%              .userinput.revetment(ids).stop
%              .PP(sens).settings.MDAdata_NEW
%              .PP(sens).settings.sVectorLength
%              .PP(sens).settings.t0
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

% $Id: ITHK_revetment_to_kml.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/measures/ITHK_revetment_to_kml.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Adding revetments to KML\n');

global S

S.PP(sens).output.kml_revetment=[];

style = 0;
for jj = 1:length(S.userinput.phases)
    REVdata = ITHK_io_readREV([S.settings.outputdir S.userinput.phase(jj).REVfile]);
    for ii = 1:length(REVdata)
        if isfield(REVdata(ii),'Xw')
            % Get info from structure
            t0 = S.PP(sens).settings.t0;

        %         % MDA info
        %         MDAdata_NEW = S.PP(sens).settings.MDAdata_NEW;
        %         
        %         %Polygon for location of revetment
        %         xpoly2=MDAdata_NEW.Xcoast(S.userinput.revetment(ss).idRANGE);
        %         ypoly2=MDAdata_NEW.Ycoast(S.userinput.revetment(ss).idRANGE);

            xpoly2 = REVdata(ii).Xw; 
            ypoly2 = REVdata(ii).Yw;

            % convert coordinates
            [lonpoly2,latpoly2] = convertCoordinates(xpoly2,ypoly2,S.EPSG,'CS1.code',str2double(S.settings.EPSGcode),'CS2.name','WGS 84','CS2.type','geo');
            lonpoly2     = lonpoly2';
            latpoly2     = latpoly2';

            % orange line
            if style==0
                S.PP(sens).output.kml_revetment = KML_stylePoly('name','revetment','lineColor',[238/255 118/255 0],'lineWidth',10);
                style=1;
            end
            % polygon to KML
            S.PP(sens).output.kml_revetment = [S.PP(sens).output.kml_revetment KML_line(latpoly2 ,lonpoly2 ,'timeIn',datenum(t0+S.userinput.phase(jj).start,1,1),'timeOut',datenum(t0+S.userinput.phase(jj).stop,1,1)+364,'styleName','revetment')];
            clear lonpoly2 latpoly2
        end
    end
end

if ~isempty(S.PP(sens).output.kml_revetment)
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_revetment'];
end