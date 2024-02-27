function [status,tide] = rws_getij_nl_get_url(varargin)
%RWS_GETIJ_NL_GET_URL retrieves tidal predictions (time series) from getij.rws.nl
%
%   rws_getij_nl retrieves tidal predictions (time series) from 
%   getij.rws.nl, writes the files to a user defined path and stores the
%   predictions also in a MATLAB struct named tide
%
%   Syntax:
%   [status,tide] = rws_getij_nl_get_url
%
%   Input:
%   locations  = cell array of strings with station names,
%                e.g. {'SCHEVNGN','HOEKVHLD'}
%   outputpath = string with output path, e.g. 'c:\tidal_predictions\',
%                default is the systems temp path
%   startdate =  string with start date for tidal prediction, e.g. '09-02-2011'
%   stopdate =   string with stop date for tidal prediction, e.g. '25-02-2011'
%   interval =   string with interval in minutes, '10', '15', '20', '30' or '60'
%   outputmatfilename = string with filename of output .mat file containing
%                       time series from all stations
%
%   Output:
%   status
%   tide = MATLAB struct with output time series from all stations
%
%   Example
%   rws_getij_nl_get_url
%
%   See also rws_waterbase_get_url

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Voorsterweg 28, Marknesse, The Netherlands
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
% Created: 21 Jun 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: rws_getij_nl_get_url.m 12713 2016-04-28 08:13:46Z bartgrasmeijer.x $
% $Date: 2016-04-28 16:13:46 +0800 (Thu, 28 Apr 2016) $
% $Author: bartgrasmeijer.x $
% $Revision: 12713 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_getij_nl_get_url.m $
% $Keywords: $

%%
OPT.locations={'DELFZL','EEMSHVN', 'HUIBGT','LAUWOG','SCHIERMNOG',...
    'WIERMGDN','NES','TERSLNZE','WESTTSLG','HARLGN','VLIELHVN',...
    'KORNWDZBTN','TEXNZE','OUDSD','DENOVBTN','DENHDR','PETTZD',...
    'IJMDBTHVN','NOORDWMPT','SCHEVNGN','HOEKVHLD','HARVT10','STELLDBTN',...
    'LICHTELGRE','BROUWHVSGT08','EURPFM','STAVNSE','WEMDGE',...
    'WESTKPLE','VLISSGN','HANSWT','BATH','CADZD','TERNZN'};
OPT.outputpath = tempdir;
OPT.outputmatfilename = 'tidal_predictions_from_rws_getij_nl';
OPT.startdate = '09-02-2011';
OPT.stopdate = '25-02-2011';
OPT.interval = '10';

OPT = setproperty(OPT,varargin{:});

% if nargin==0;
%     varargout = OPT;
%     return;
% end
%% code

for i = 1:length(OPT.locations)
    mylocation = OPT.locations{i};
    disp(['Retrieving tidal predictions for ' mylocation]);
%     urlName = ['http://live.getij.nl/export.cfm?format=txt&from=',OPT.startdate,'&to=',OPT.stopdate,'&uitvoer=1&interval=10&lunarphase=yes&location=',mylocation,'&Timezone=MET_DST&refPlane=MSL&graphRefPlane=NAP&bottom=0&keel=0'];
    urlName = ['http://getij.rws.nl/export.cfm?format=txt&from=',OPT.startdate,'&to=',OPT.stopdate,'&uitvoer=1&interval=',OPT.interval,'&lunarphase=yes&location=',mylocation,'&Timezone=MET_DST&refPlane=NAP&graphRefPlane=NAP'];
    OutputName = [OPT.outputpath,num2str(i,'%03.0f'),'_tidal_predicition_',mylocation,'_',OPT.startdate,'_to_',OPT.stopdate,'.txt'];
    [s, status] = urlwrite([urlName],OutputName);
    
    tide(i).description = 'tidal predictions from getij.rws.nl';    
    tide(i).stationname = mylocation;
    fid = fopen(OutputName);
    C = textscan(fid, '%s %s %f %s','headerlines',14);
    for j = 1:length(C{1})-1
        mydate = char(C{1}(j));
        mytime = char(C{2}(j));
        tide(i).datenum(j,1) = datenum([mydate, ' ', mytime],'dd/mm/yyyy HH:MM');
    end
    tide(i).zwl = C{3}./100;
    fclose(fid);
end

save([OPT.outputpath,OPT.outputmatfilename],'tide');

