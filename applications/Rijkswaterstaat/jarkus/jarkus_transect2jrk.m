function varargout=jarkus_transect2jrk(fname,time,dist,transid,altitude,areaid,origin,varargin)
%jarkus_transect2jrk Writes transect data to .jrk file format
%
%   Writes transect data (altitude, distance) from matrices to JarKus file
%   format (.jrk). This is the original file format to store Dutch JarKus
%   profiles. This file-format is however still used by MorphAn and
%   possibly other software.
%
%   Documentation on the format can be found in the MorpAn manual, appendix A2:
%   https://www.helpdeskwater.nl/onderwerpen/applicaties-modellen/applicaties-per/aanleg-onderhoud/aanleg-onderhoud/morphan/
%
%   NOTE: This script currently cannot handle repeated distance-values!
%   E.g. both topo- and bathy-altitude at the same position.
%
%   Syntax:
%   varargout = jarkus_transect2jrk(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_transect2jrk() 
%          without arguments.
%       fname: filename or full path to file <string.jrk>
%
%       time: vector with survey date per transect [datenum] 
%             size: [time 1] or [time transects]
%       dist: vector with distance from transect origin [m+ref_line]
%             size: [dist 1] or [dist transects]
%       altitude: matrix with altitude-values of transects [m+vertical_datum]
%                 size: [time transects dist]
%       origin: type of survey per altitude point [1=topo, 3=interp, 5=bathy]
%               size: [time transects dist]
%       varargin: 
%           'time_b': 2nd time vector, used for bathymetry survey date. If
%                     omitted time is used for both topo and bathy
%                     size: [time 1] or [time transects]  
%           'keepaltunits' [true|FALSE] if true numbers are used as is.
%                          Otherwise metres are expected, which are
%                          converted to cm.
%           'append' [true|FALSE] append data to existing file.
%
%   Output:
%   	file: <filename>.jrk
%
%   Example:
%       dist=[-20:5:225];
%       time=datenum(2019,01,01);
%       altitude=linspace(15,-16,length(dist));
%       areacode=99;
%       jarkus_transect2jrk('./test.jrk',time,dist,altitude,areacode);
%       !test.jrk %Open this file in your favourite text editor.
%
%
%   See also: JARKUS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%
%       Spoorwegstraat 12, 8200 Brugge, Belgium
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
% Created: 09 Dec 2018
% Created with Matlab version: 9.5.0.944444 (R2018b)

% $Id: jarkus_transect2jrk.m 16286 2020-03-04 13:21:20Z l.w.m.roest.x $
% $Date: 2020-03-04 21:21:20 +0800 (Wed, 04 Mar 2020) $
% $Author: l.w.m.roest.x $
% $Revision: 16286 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_transect2jrk.m $
% $Keywords: $

%%
OPT.time_b=time;
OPT.keepaltunits=false;
OPT.append=false;
% return defaults (aka introspection)
if nargin==0
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
%% Check input
if length(size(altitude))<3 %Make sure altitude is a 3D [time transect dist] matrix
    altitude(1,:,:)=altitude;
end

% Check time
if isscalar(time) && size(altitude,1)~=1
    time=time.*ones(size(altitude,1),1);
end

if isscalar(OPT.time_b) && size(altitude,1)~=1
    time_b=OPT.time_b.*ones(size(altitude,1),1);
else
    time_b=OPT.time_b;
end

%Check dist
if isscalar(dist) || size(dist,1)~=size(altitude,3)
    error('number of entries in dist must match number of points on transect. \n');
end

%Check areaid
if isscalar(areaid)
    areaid=areaid.*ones(size(altitude,2),1);
elseif length(areaid)~=size(altitude,2)
    error('number of entries in areaid must match number of transects. \n');
end

%Check transid
if isscalar(transid) || length(transid)~=size(altitude,2)
    error('number of entries in transid must match number of transects. \n');
end

%Check origin
if nargin <=5 || isscalar(origin)
    origin=3*ones(size(altitude));
elseif size(origin)~=size(altitude)
    error('size(origin)~=size(altitude). Entries of origin and altitude must correspond.\n');
end

%% Convert altitudes from m+NAP to cm+NAP.
if ~OPT.keepaltunits
    altitude=altitude.*100; %convert to cm+NAP
end
%% Open file
if ~strncmpi(fname(end-3:end),'.jrk',4) %check for correct file-ext.
    fname=[fname,'.jrk'];
end    
if OPT.append
    fid=fopen(fname,'a+'); %Append data
elseif ~exist(fname,'file')
    fid=fopen(fname,'w+'); %Create & open file
else
    ovr=input(['Filename ',filename,' already exists. Overwrite? [y|N] '],'s');
    if strcmpi(ovr,'y')
        fid=fopen(fname,'w+'); %Create & open file
    end
end
fprintf(1,'File %s opened for writing \n',fname);

%% Write contents

% Loop over time
for t=1:length(time)
    %Loop over transects (alongshore)
    for n=1:size(altitude,2)
        mask=~isnan(altitude(t,n,:)); %Determine positions of data
        if sum(mask)>0 %Only write when transect contains data!
            d=dist(mask); %Distance from transect-origin.
            z=squeeze(altitude(t,n,mask)); %Transect altitude
            st=squeeze(origin(t,n,mask)); %Survey type (topo=1, interpol=3, bathy=5)

            nop=ceil(length(z)/5)*5; %number of points
            if length(z)~=nop %Patch trailing empty values with FillValue.
                d(end+1:nop)=99999.00;
                z(end+1:nop)=999999;
                st(end+1:nop)=9;
            end

            %Transect header line consists of:
            %AreaID (kustvaknummer)
            %Survey year (jaar van opname)
            %TransectID (raainummer)
            %Transect type (raaitype)
            %Survey date topo (datum van de hoogtemeting (ddmm))
            %Survey date bathy (datum van de dieptemeting (ddmm))
            %Number of values (aantal meetwaarden)
            fprintf(fid,'%6.0f%+6s%6.0f%6.0f%+6s%+6s%6.0f\n',...
                        areaid(n),...
                        datestr(time(t),('yyyy')),...
                        transid(n),...
                        0,...
                        datestr(time(t),('ddmm')),...
                        datestr(time_b(t),('ddmm')),...
                        sum(mask)); %Header-line

            for i=1:5:ceil(length(z)/5)*5
                %Altitude data in [Dist  AltitudeSuveyType] pairs.m   
                fprintf(fid,'%8.2f%7.0f%1.0f  %8.2f%7.0f%1.0f  %8.2f%7.0f%1.0f  %8.2f%7.0f%1.0f  %8.2f%7.0f%1.0f   \n',...
                    d(i+0),z(i+0),st(i+0),...
                    d(i+1),z(i+1),st(i+1),...
                    d(i+2),z(i+2),st(i+2),...
                    d(i+3),z(i+3),st(i+3),...
                    d(i+4),z(i+4),st(i+4)); 
            end
        end
    end
end

%% Close file & wrap up
st=fclose(fid);
fsiz=dir(fname);
if st==0
    fprintf(1,'Data successfully written to %s, %8.2f MB\n',fname,fsiz.bytes./1024./1024);
else
    fprintf(2,'Writing data unssuccessful!\n');
end
%EOF