function tc = tc_read_hurdat2_best_track(fname)
%READBESTTRACKHURDAT2  Reads the best cyclone track from a HURDAT2 file
%
%   Syntax:
%   tc = readBestTrackHURDAT2(fname)
%
%   Input:
%   fname = filename string
%
%   Output:
%   tc    = struct with date, name, meta, time, lon, lat, vmax and p
%
%   Example
%       tc_fname = 'Haiyan_track_unisys.dat'
%       readBestTrackHURDAT2(tc_fname)
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: readBestTrackUnisys.m 11277 2014-10-22 10:03:03Z bartgrasmeijer.x $
% $Date: 2014-10-22 12:03:03 +0200 (Wed, 22 Oct 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 11277 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/readBestTrackUnisys.m $
% $Keywords: $

%%
fid=fopen(fname,'r');
tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',',');
tc.name=v0{2};
tc.basin=v0{1}(1:2);
tc.number=num2str(v0{1}(3:4));
tc.year=num2str(v0{1}(5:8));
it=0;
while 1
    tx0=fgets(fid);
    if tx0==-1
        break
    end
    v0=strread(tx0,'%s','delimiter',',');
    it=it+1;

    str=[v0{1} ' ' v0{2} '00'];
    tc.time(it)=datenum(str,'yyyymmdd HHMMSS');

    tc.record_identifier{it}=v0{3};
    tc.status{it}=v0{4};
        
    if strcmpi(v0{5}(end),'n')
        tc.y(it)=str2double(v0{5}(1:end-1));
    else
        tc.y(it)=-str2double(v0{5}(1:end-1));
    end
    if strcmpi(v0{6}(end),'e')
        tc.x(it)=str2double(v0{6}(1:end-1));
    else
        tc.x(it)=-str2double(v0{6}(1:end-1));
    end
    
    tc.vmax(it)=str2double(v0{7});
    tc.pc(it)=str2double(v0{8});
    
    tc.r35ne(it)=str2double(v0{9});
    tc.r35se(it)=str2double(v0{10});
    tc.r35sw(it)=str2double(v0{11});
    tc.r35nw(it)=str2double(v0{12});

    tc.r50ne(it)=str2double(v0{13});
    tc.r50se(it)=str2double(v0{14});
    tc.r50sw(it)=str2double(v0{15});
    tc.r50nw(it)=str2double(v0{16});

    tc.r65ne(it)=str2double(v0{17});
    tc.r65se(it)=str2double(v0{18});
    tc.r65sw(it)=str2double(v0{19});
    tc.r65nw(it)=str2double(v0{20});

    tc.r100ne(it)=-999;
    tc.r100se(it)=-999;
    tc.r100sw(it)=-999;
    tc.r100nw(it)=-999;
    
end

% Get rid of 0 radius
tc.r35ne(tc.r35ne==0)=-999;
tc.r35se(tc.r35se==0)=-999;
tc.r35sw(tc.r35sw==0)=-999;
tc.r35nw(tc.r35nw==0)=-999;

tc.r50ne(tc.r50ne==0)=-999;
tc.r50se(tc.r50se==0)=-999;
tc.r50sw(tc.r50sw==0)=-999;
tc.r50nw(tc.r50nw==0)=-999;

tc.r65ne(tc.r65ne==0)=-999;
tc.r65se(tc.r65se==0)=-999;
tc.r65sw(tc.r65sw==0)=-999;
tc.r65nw(tc.r65nw==0)=-999;

tc.r100ne(tc.r100ne==0)=-999;
tc.r100se(tc.r100se==0)=-999;
tc.r100sw(tc.r100sw==0)=-999;
tc.r100nw(tc.r100nw==0)=-999;

fclose(fid);
