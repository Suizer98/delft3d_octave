function PRN2KML_bars(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG)
%function PRN2KML_bars : Converts a UNIBEST PRN-file into a KML-file with bars
%
%   Syntax:
%     PRN2kml_bars(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG)
%
%   Input:
%     PRNfile      string with PRN filename
%     MDAfile      (optional) MDA file used to compute the angle of coast
%     timesteps    timesteps for which output is generated (leave empty for all data)
%     reftime      reference time for start of model simulation ('yyyy-mm-dd' or in datenum format)
%     vectorscale  scale of the vector
%     segments     number of segments of the bar plot
%     KMLfile      output filename of KML (possible to include the path)
%     EPSGcode     code for transforming the cartesian system back to WGS84 geo (EPSGcode=28992 for RD-coordinates)
%     EPSG         matlab structure database with EPSG information
%
%   Output:
%     .sos files
% 
%   Example:
%     PRNfile = 'd:\UB7\HollandCoast_HK41\A_defaultCL2005\BWN2005REFERENCE.PRN';
%     MDAfile = 'd:\UB7\HollandCoast_HK41\A_defaultCL2005\Basis.mda';
%     timesteps=[1:40];
%     reftime='2005-01-01';
%     vectorscale =10;
%     segments=100;
%     EPSGcode=28992;
%     EPSG = load('EPSG');
%     KMLfile=''; %<- will then automatically get name of PRNfile
%     PRN2kml_bars(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG)
%
%   See also 
%     PRN2kml_lines

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

% $Id: PRN2kml_bars.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/postprocess/PRN2kml_bars.m $
% $Keywords: $


    %% load data
    %PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile
    PRNdata = readPRN(PRNfile);
    [pthnm,filnm,extnm]=fileparts(PRNfile);
    if ~isempty(MDAfile);    MDAdata=readMDA(MDAfile);end
    if isempty(vectorscale); vectorscale=10; end
    if isempty(segments);    segments=100; end
    if isempty(EPSG);        EPSG=load('EPSG'); end
    if isempty(EPSGcode);    EPSGcode=28992; end
    if isempty(KMLfile);     KMLfile = [filnm,'.kml']; end

    %% reference time
    reftimenum = 0;
    DT=1000;
    if ~isempty(reftime);reftimenum = datenum(reftime,'yyyy-mm-dd');end
    if isempty(timesteps);timesteps=[1:PRNdata.year];end
    if length(timesteps)>1;DT = PRNdata.year(2)-PRNdata.year(1);end

    %% coast angle
    ANGLEcoast = mean(PRNdata.alfa(:,timesteps),2);
    smoothvar(ANGLEcoast,10);
    if ~isempty(MDAdata)
        ANGLEcoast = MDAdata.ANGLEcoast;
    end

    %%-------------------------------------------------------------------------
    % make bar polygons
    %%-------------------------------------------------------------------------
    lonpoly={};
    latpoly={};
    xpoly={};
    ypoly={};
    for tt=timesteps
        x = PRNdata.x(:,1);
        y = PRNdata.y(:,1);
        z = PRNdata.zminz0(:,tt);
        dx = diff(PRNdata.xdist);

        ID = unique(round([length(x)/segments/2:length(x)/segments:length(x)-length(x)/segments/2]));
        ID1 = unique(round([1:length(x)/segments:length(x)-length(x)/segments+1]));
        ID2 = [ID1(2:end)-1,length(x)];
        %% construct x,y coordinates of bars on the basis of x1, xtip and barwidth (five coordinates specifying a rectangle for each bar)
        for jj=1:length(ID)
            x1 = x(ID(jj));
            y1 = y(ID(jj));
            z1 = mean(z(ID1(jj):ID2(jj)));z2{tt}(jj)=z1;
            dx2 = 0.9*sum(dx(ID1(jj):ID2(jj)));
            %dist = max(((x(ID2(jj))-x(ID1(jj))).^2+(y(ID2(jj))-y(ID1(jj))).^2).^0.5,dx2)
            xtip         = x1+z1.*vectorscale.*sin(ANGLEcoast(ID(jj))*pi/180);
            ytip         = y1+z1.*vectorscale.*cos(ANGLEcoast(ID(jj))*pi/180);
            dxbar        = -0.5*dx2*cos(ANGLEcoast(ID(jj))*pi/180);
            dybar        = 0.5*dx2*sin(ANGLEcoast(ID(jj))*pi/180);
            xpoly{tt}(jj,:)  = [x1+dxbar, xtip+dxbar, xtip-dxbar, x1-dxbar, x1+dxbar];
            ypoly{tt}(jj,:)  = [y1+dybar, ytip+dybar, ytip-dybar, y1-dybar, y1+dybar];
           % figure(1);clf;plot(xpoly{tt}(jj,:),ypoly{tt}(jj,:),'k');hold on;plot(x1,y1,'r*');plot(xtip,ytip,'g*');
        end
        [lonpoly{tt},latpoly{tt}] = convertCoordinates(xpoly{tt},ypoly{tt},EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
    end

    %%-------------------------------------------------------------------------
    % plot KML bars
    %%-------------------------------------------------------------------------
    colour={[0 1 0],[1 0 0]};
    fillalpha=0.7;
    barstyle1            = KML_stylePoly('name','default','fillColor',colour{1},'lineColor',[0 0 0],'lineWidth',0.5,'fillAlpha',fillalpha); % red bar style
    barstyle2            = KML_stylePoly('name','default','fillColor',colour{2},'lineColor',[0 0 0],'lineWidth',0.5,'fillAlpha',fillalpha); % green bar style
    barstyle3            = KML_stylePoly('name','default','lineColor',[0.8 0.8 0.8],'lineWidth',0.5,'polyFill',0); % outline of area of bar

    %% write KML bar plot
    KMLfile2 = [KMLfile(1:end-4),'_bar.kml'];
    fid         = fopen(KMLfile2,'wt');
    kml2        = KML_header('kmlName',[filnm,'BAR']);
    for tt=timesteps
        t1       = PRNdata.year(tt)*365.25+reftimenum; 
        if tt<length(timesteps)
        t2 = PRNdata.year(tt+1)*365.25+reftimenum;
        else
        t2 = PRNdata.year(tt)*365.25+reftimenum+DT*365.25;
        end
        tstart   = datestr(t1,'yyyy-mm-ddTHH:MM:SS');
        tend     = datestr(t2,'yyyy-mm-ddTHH:MM:SS');
        IDneg            = find(z2{tt}<0); % red
        IDpos            = find(z2{tt}>=0);
        kmlpoly2         = [];

        for ii=1:length(IDpos) %length(S.PP(sens).settings.sgridRough)
            kmlpoly2     = [kmlpoly2,barstyle1];
            kmlpoly2     = [kmlpoly2 KMLpolytext(t1,t2,latpoly{tt}(IDpos(ii),:),lonpoly{tt}(IDpos(ii),:))];
        end
        for ii=1:length(IDneg) %length(S.PP(sens).settings.sgridRough)
            kmlpoly2     = [kmlpoly2,barstyle2];
            kmlpoly2     = [kmlpoly2 KMLpolytext(t1,t2,latpoly{tt}(IDneg(ii),:),lonpoly{tt}(IDneg(ii),:))];
        end
        kml2 = [kml2 kmlpoly2];
    end
    kml2         = [kml2 KML_footer];
    fprintf(fid,kml2);
    fclose all;
end

%--------------------------------------------------------------------------
%% sub-functions
%--------------------------------------------------------------------------
function [kmltxt]=KMLpolytext(time1,time2,lat,lon)
%% sub-function which generates KML code for each polygon
    timetxt1 = [datestr(time1,'yyyy-mm-dd'),'T',datestr(time1,'HH:MM:SS')];  %2005-01-01T00:00:00
    timetxt2 = [datestr(time2,'yyyy-mm-dd'),'T',datestr(time2,'HH:MM:SS')];  %2005-12-31T00:00:00
    kmltxt   = ['<Placemark>' char(13) '<TimeSpan><begin>',timetxt1,'</begin><end>',timetxt2,'</end></TimeSpan><name>poly</name>' char(13) ...
               '<styleUrl>#default</styleUrl>' char(13) '<Polygon>' char(13) '<altitudeMode>clampToGround</altitudeMode>' char(13) ...
               '<outerBoundaryIs>' char(13) '<LinearRing>' char(13) '<coordinates>' char(13)];
    latlon   = [num2str(lon(:),'%10.8f') repmat(',',[5 1]) num2str(lat(:),'%11.8f') repmat([',0.000' char(13)],[5 1]) ]';
    S        = size(latlon);
    kmltxt   = [kmltxt reshape(latlon,[1 S(1)*S(2)])];  % this sentence replace the loop over the points ii below (which is much slower)
%     for ii=1:length(lon)
%         kmltxt = [kmltxt num2str(lon(ii),'%10.8f') ',' num2str(lat(ii),'%11.8f') ',0.000' char(13)];
%     end
    kmltxt   = [kmltxt,'</coordinates>' char(13) '</LinearRing>' char(13) '</outerBoundaryIs>' char(13) '</Polygon>' char(13) '</Placemark>' char(13)];
end

function smoothvar(value,iter)
    rotval=0;
    if size(value,2)>size(value,2)
        value=value';
        rotval=1;
    end
    for ii=1:iter
    value = [value(1);(value(2:end)+value(1:end-1))/2;value(end)];
    end
    if rotval==1
        value=value';
    end
end
