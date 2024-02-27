function [t0,t1]=ddb_saveCycloneFile(filename,storm,varargin)
%DDB_SAVECYCLONEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveCycloneFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%
%
%
%   Example
%   ddb_saveCycloneFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_saveCycloneFile.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_saveCycloneFile.m $
% $Keywords: $

%% DDB - Saves cyclone track to cyc file

vstr='';
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'version'}
                vstr=[' - DelftDashBoard v' varargin{ii+1}];
        end
    end
end

fid = fopen(filename,'w');

% time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# Tropical Cyclone Toolbox' vstr ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt=['Name                   "' storm.cyclonename '"'];
fprintf(fid,'%s \n',txt);

txt=['WindProfile            ' num2str(storm.wind_profile)];
fprintf(fid,'%s \n',txt);

txt=['WindPressureRelation   ' storm.wind_pressure_relation];
fprintf(fid,'%s \n',txt);

txt=['RMaxRelation           ' storm.rmax_relation];
fprintf(fid,'%s \n',txt);

txt=['Backgroundpressure     ' num2str(storm.pn)];
fprintf(fid,'%s \n',txt);

txt=['PhiSpiral              ' num2str(storm.phi_spiral)];
fprintf(fid,'%s \n',txt);

txt=['WindConversionFactor   ' num2str(storm.windconversionfactor)];
fprintf(fid,'%s \n',txt);

txt=['SpiderwebRadius        ' num2str(storm.radius)];
fprintf(fid,'%s \n',txt);

txt=['NrRadialBins           ' num2str(storm.nrRadialBins)];
fprintf(fid,'%s \n',txt);

txt=['NrDirectionalBins      ' num2str(storm.nrDirectionalBins)];
fprintf(fid,'%s \n',txt);

fprintf(fid,'%s\n','#');
txt='#   Date   Time       Lat      Lon   Vmax (kts)   Pc (hPa)  Rmax (NM)  R35(NE)  R35(SE)  R35(SW)  R35(NW)  R50(NE)  R50(SE)  R50(SW)  R50(NW)  R65(NE)  R65(SE)  R65(SW)  R65(NW) R100(NE) R100(SE) R100(SW) R100(NE)';
fprintf(fid,'%s \n',txt);
fprintf(fid,'%s\n','#');

t0=1e9;
t1=-1e9;
for it=1:storm.nrTrackPoints
    datetxt=datestr(storm.track.time(it),'yyyymmdd HHMMSS');
    fmt=['%s  %8.3f %8.3f %12.1f %10.1f %10.1f ' repmat('%8.1f ',1,16) '\n'];
    if storm.track.vmax(it)>0.0
        t0=min(t0,storm.track.time(it));
        t1=min(t1,storm.track.time(it));
        fprintf(fid,fmt,datetxt,storm.track.y(it),storm.track.x(it),storm.track.vmax(it),storm.track.pc(it),storm.track.rmax(it),storm.track.r35ne(it),storm.track.r35se(it),storm.track.r35sw(it),storm.track.r35nw(it),storm.track.r50ne(it),storm.track.r50se(it),storm.track.r50sw(it),storm.track.r50nw(it),storm.track.r65ne(it),storm.track.r65se(it),storm.track.r65sw(it),storm.track.r65nw(it),storm.track.r100ne(it),storm.track.r100se(it),storm.track.r100sw(it),storm.track.r100nw(it));
    end
end

fclose(fid);

