function inp = ddb_read_cyclone_file(fname)
%DDB_READCYCLONEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readCycloneFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readCycloneFile
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

% $Id: ddb_readCycloneFile.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_readCycloneFile.m $
% $Keywords: $

%% DDB - reads cyclone file

try
    
    inp.track=[];
    
    fid=fopen(fname,'r');
    
    it=0;

    while 1
        f=fgetl(fid);
        if f==-1
            break
        end
        c=textscan(f,'%s');
        name=deblank(c{1}{1});
        if isnan(str2double(name))
            % Reading track info
            switch lower(name)
                case{'name'}
                    c2=textscan(f,'%s','delimiter','"');
                    inp.cyclonename=c2{1}{2};
                case{'windprofile'}
                    inp.wind_profile=c{1}{2};
                case{'windpressurerelation'}
                    inp.wind_pressure_relation=c{1}{2};
                case{'rmaxrelation'}
                    inp.rmax_relation=c{1}{2};
                case{'backgroundpressure'}
                    inp.pn=str2double(c{1}{2});
                case{'phispiral'}
                    inp.phi_spiral=str2double(c{1}{2});
                case{'windconversionfactor'}
                    inp.windconversionfactor=str2double(c{1}{2});
                case{'spiderwebradius'}
                    inp.radius=str2double(c{1}{2});
                case{'nrradialbins'}
                    inp.nrRadialBins=str2double(c{1}{2});
                case{'nrdirectionalbins'}
                    inp.nrDirectionalBins=str2double(c{1}{2});
            end
        else
            % Reading actual track data
            c=textscan(f,'%s');
            it=it+1;
            inp.track.time(it)=datenum([c{1}{1} ' ' c{1}{2}],'yyyymmdd HHMMSS');
            inp.track.y(it)=str2double(c{1}{3});
            inp.track.x(it)=str2double(c{1}{4});
            inp.track.vmax(it)=str2double(c{1}{5});
            inp.track.pc(it)=str2double(c{1}{6});
            inp.track.rmax(it)=str2double(c{1}{7});
            inp.track.r35ne(it)=str2double(c{1}{8});
            inp.track.r35se(it)=str2double(c{1}{9});
            inp.track.r35sw(it)=str2double(c{1}{10});
            inp.track.r35nw(it)=str2double(c{1}{11});
            inp.track.r50ne(it)=str2double(c{1}{12});
            inp.track.r50se(it)=str2double(c{1}{13});
            inp.track.r50sw(it)=str2double(c{1}{14});
            inp.track.r50nw(it)=str2double(c{1}{15});
            inp.track.r65ne(it)=str2double(c{1}{16});
            inp.track.r65se(it)=str2double(c{1}{17});
            inp.track.r65sw(it)=str2double(c{1}{18});
            inp.track.r65nw(it)=str2double(c{1}{19});
            inp.track.r100ne(it)=str2double(c{1}{20});
            inp.track.r100se(it)=str2double(c{1}{21});
            inp.track.r100sw(it)=str2double(c{1}{22});
            inp.track.r100nw(it)=str2double(c{1}{23});
        end
    end
    
    fclose(fid);
    
    inp.nrTrackPoints=it;
    
catch
%    ddb_giveWarning('text','An error occured while loading cyclone file! Please check the input.')
end

