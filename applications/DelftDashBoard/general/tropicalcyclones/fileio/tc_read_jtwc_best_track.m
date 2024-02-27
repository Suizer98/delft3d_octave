function tc = tc_read_jtwc_best_track(fname)
%READBESTTRACKJTWC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   tc = readBestTrackJTWC(fname)
%
%   Input:
%   fname =
%
%   Output:
%   tc    =
%
%   Example
%   readBestTrackJTWC
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: readBestTrackJTWC.m 9367 2013-10-11 07:28:19Z boer_we $
% $Date: 2013-10-11 09:28:19 +0200 (Fri, 11 Oct 2013) $
% $Author: boer_we $
% $Revision: 9367 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/readBestTrackJTWC.m $
% $Keywords: $

%%
% Reads JTWC best track file and returns Matlab structure

lasttime=0;
it=0;
tc.name='not_known';

fid=fopen(fname,'r');
while 1
    s0=fgetl(fid);
    if s0==-1
        break
    end
    s=textscan(s0,'%s','delimiter',',');
    s=s{1};
    %    s=textscan(s0,'%s%f%f%s%s%f%s%s%f%f%s%f%s%f%f%f%f%f%f%f%f%f%s%f%s%f%f%s%s','delimiter',',');
    tc.basin=s{1};
    tc.storm_number=s{2};
    % Read time
    tstr=s{3};tstr=num2str(tstr);
    try
        newtime=datenum(tstr,'yyyymmddHH');
    catch
        tstr = tstr(1,:);
        newtime=datenum(tstr,'yyyymmddHH');
    end
    hrs=str2double(s{6});
    newtime=newtime+hrs/24;
    if newtime>lasttime+1/86400
        % New time point found
        it=it+1;
        lasttime=newtime;
        tc=set_default_values(tc,it);
    end
    tc.time(it)=newtime;
    % Latitude
    if strcmpi(s{7}(end),'n')
        tc.y(it)=0.1*str2double(s{7}(1:end-1));
    else
        tc.y(it)=-0.1*str2double(s{7}(1:end-1));
    end
    % Longitude
    if strcmpi(s{8}(end),'e')
        tc.x(it)=0.1*str2double(s{8}(1:end-1));
    else
        tc.x(it)=-0.1*str2double(s{8}(1:end-1));
    end
    if str2double(s{9})>0
        tc.vmax(it)=str2double(s{9});
    end
    if length(s)>9
        if str2double(s{10})>0
            tc.pc(it)=str2double(s{10});
        end
        %tc.cat=s{11};
        % Radii
        r=str2double(s{12});
        if ~isempty(r)
            switch r
                case{34,35}
                    tc.r35ne(it)=str2double(s{14});
                    tc.r35se(it)=str2double(s{15});
                    tc.r35sw(it)=str2double(s{16});
                    tc.r35nw(it)=str2double(s{17});
                case 50
                    tc.r50ne(it)=str2double(s{14});
                    tc.r50se(it)=str2double(s{15});
                    tc.r50sw(it)=str2double(s{16});
                    tc.r50nw(it)=str2double(s{17});
                case{64,65}
                    tc.r65ne(it)=str2double(s{14});
                    tc.r65se(it)=str2double(s{15});
                    tc.r65sw(it)=str2double(s{16});
                    tc.r65nw(it)=str2double(s{17});
                case 100
                    tc.r100ne(it)=str2double(s{14});
                    tc.r100se(it)=str2double(s{15});
                    tc.r100sw(it)=str2double(s{16});
                    tc.r100nw(it)=str2double(s{17});
            end
        end
        
        if length(s)>17
            if ~isempty(s{18})
                tc.pressure_last_closed_isobar(it)=str2double(s{18});
            end
            if ~isempty(s{19})
                tc.radius_last_closed_isobar(it)=str2double(s{19});
            end
            if ~isempty(s{20})
                if str2double(s{20})>0
                    tc.rmax(it)=str2double(s{20});
                end
            end
            if length(s)>=28
                if ~isempty(s{28})
                    tc.name=s{28};
                end
            end
        end
    end
    
end
fclose(fid);

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

%%
function tc=set_default_values(tc,it)

tc.vmax(it)=-999;
tc.pc(it)=-999;
tc.rmax(it)=-999;
tc.r35ne(it)=-999;
tc.r35se(it)=-999;
tc.r35sw(it)=-999;
tc.r35nw(it)=-999;
tc.r50ne(it)=-999;
tc.r50se(it)=-999;
tc.r50sw(it)=-999;
tc.r50nw(it)=-999;
tc.r65ne(it)=-999;
tc.r65se(it)=-999;
tc.r65sw(it)=-999;
tc.r65nw(it)=-999;
tc.r100ne(it)=-999;
tc.r100se(it)=-999;
tc.r100sw(it)=-999;
tc.r100nw(it)=-999;
