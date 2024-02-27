function PRN2kml(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG,colours,linewidth,xoffset_landwardlimit,varargin)
%function PRN2kml : Converts a UNIBEST PRN-file into a KML-file with coastlines and KML-file with bars
%
%   Syntax:
%     PRN2kml(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG)
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
%     PRN2kml(PRNfile,MDAfile,timesteps,reftime,vectorscale,segments,KMLfile,EPSGcode,EPSG)
%
%   See also 

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

% $Id: PRN2kml.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/postprocess/PRN2kml.m $
% $Keywords: $

    %% process varargin
    OPT.lineWidth = 2;
    OPT.lineAlpha = 1;
    OPT.zdata = [];
    OPT.KMLlabels = 0;
    OPT.KMLlabeltext = {};
    OPT.KMLheader = '';
    OPT.KMLlineplot = 1;
    OPT.KMLbarplot = 1;
    BARsign=-1;
    
    if ~isempty(varargin) 
       OPT = setproperty(OPT, varargin{:});
    end
    if nargin>=10
        OPT.lineColours = colours;
    end
    if nargin>=11
        OPT.lineWidth = linewidth;
    end
    if nargin<12
        xoffset_landwardlimit=0;
    end
    
    %% load data
    %PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile
    if ~isstruct(PRNfile)
        PRNdata = readPRN(PRNfile);
        [pthnm,filnm,extnm]=fileparts(PRNfile);
    else
        PRNdata = PRNfile;
        [pthnm,filnm,extnm] = fileparts(PRNdata.files{1});
    end
    [pthnm2,filnm2,extnm2] = fileparts(KMLfile);
    if ~isempty(MDAfile);    MDAdata=readMDA(MDAfile);end
    if isempty(vectorscale); vectorscale=10; end
    if isempty(segments);    segments=100; end
    if isempty(EPSG);        EPSG=load('EPSG'); end
    if isempty(EPSGcode);    EPSGcode=28992; end
    if isempty(KMLfile);     KMLfile = [filnm,'.kml']; end
    if isempty(OPT.KMLheader);OPT.KMLheader = filnm2; end

    %% reference time
    reftimenum = 0;
    DT=1000;
    if ~isempty(reftime);reftimenum = datenum(reftime,'yyyy-mm-dd');end
    if isempty(timesteps);timesteps=[1:PRNdata.year];end
    if length(timesteps)>1;DT = PRNdata.year(2)-PRNdata.year(1);end
    IDT=find(timesteps<=length(PRNdata.year));
    timesteps=timesteps(IDT);
    
    %% coast angle
    try
        ANGLEcoast = mean(PRNdata.alfa(:,timesteps),2);
        smoothvar(ANGLEcoast,10);
    catch
        ANGLEcoast = zeros(size(PRNdata.x,1),1);
    end
    if ~isempty(MDAdata)
        ANGLEcoast = MDAdata.ANGLEcoast;
    end

    %%-------------------------------------------------------------------------
    %% write coastlines to KML file
    %%-------------------------------------------------------------------------
    if isfield(OPT,'lineColours')
        colours     = repmat(OPT.lineColours,[length(timesteps),1]);
    else
        colours     = jet(length(timesteps));
    end
    if OPT.KMLlineplot
        fid         = fopen(KMLfile,'wt');
        kml         = KML_header('kmlName',OPT.KMLheader);
        for tt=1:length(timesteps)
            S.name      = ['col',num2str(timesteps(tt))];
            x = PRNdata.x(:,timesteps(tt));
            y = PRNdata.y(:,timesteps(tt));
            %z = PRNdata.zminz0(:,timesteps(tt));
            if PRNdata.year(1)>1500
                t1 = PRNdata.year(timesteps(tt))*365.25;
            else
                t1 = PRNdata.year(timesteps(tt))*365.25+reftimenum; 
            end
            if tt==1;t1=t1-0.5;end
            if tt<length(timesteps)
                if PRNdata.year(1)>1500
                    t2 = PRNdata.year(timesteps(tt)+1)*365.25;
                else
                    t2 = PRNdata.year(timesteps(tt)+1)*365.25+reftimenum;
                end
            else
                if PRNdata.year(1)>1500
                    t2 = PRNdata.year(timesteps(tt))*365.25+DT*365.25;
                else
                    t2 = PRNdata.year(timesteps(tt))*365.25+reftimenum+DT*365.25;
                end
            end
                       
            tstart = datestr(t1,'yyyy-mm-ddTHH:MM:SS');
            tend   = datestr(t2,'yyyy-mm-ddTHH:MM:SS');
            S.lineColor = colours(tt,:);  % color of the lines in RGB
            S.lineAlpha = OPT.lineAlpha ;     % transparency of the line, (0..1) with 0 transparent
            S.lineWidth = OPT.lineWidth;        % line width, can be a fraction     
            S0 = S; 
            S0.name      = ['col0'];
            S0.lineColor = [0.0 0.0 1];

            [lon,lat] = convertCoordinates(x,y,EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
            
            if tt==1
            kml         = [kml KML_style(S)];
            kml         = [kml KML_line(lat,lon,'styleName',S0.name)];
            end 
            kml         = [kml KML_style(S)];
            kml         = [kml KML_line(lat,lon,'styleName',S.name,'timeIn',tstart,'timeOut',tend)];

            if xoffset_landwardlimit~=0
                if length(x)>length(ANGLEcoast)
                    ANGLEcoast2=[ANGLEcoast(1);(ANGLEcoast(1:end-1)+ANGLEcoast(2:end))/2;ANGLEcoast(end)];
                else
                    ANGLEcoast2=(ANGLEcoast(1:end-1)+ANGLEcoast(2:end))/2;
                end
                if length(xoffset_landwardlimit)==1
                    xoffset_landwardlimit=repmat(xoffset_landwardlimit,size(ANGLEcoast2));
                end
                xland   = x + xoffset_landwardlimit.*sin(ANGLEcoast2*pi/180);
                yland   = y + xoffset_landwardlimit.*cos(ANGLEcoast2*pi/180);
                
                S2 = S;
                S2.name=['landwardlimit',num2str(xoffset_landwardlimit(1),'%1.0f')];
                S2.lineAlpha=0.3;
                S2.lineWidth = OPT.lineWidth*2;
                [lon2,lat2] = convertCoordinates(xland,yland,EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
                kml         = [kml KML_style(S2)];
                kml         = [kml KML_line(lat2,lon2,'styleName',S2.name,'timeIn',tstart,'timeOut',tend)];
            end
        end
        kml         = [kml KML_footer];
        fprintf(fid,kml);
        fclose all;
    end
    
    
    %%-------------------------------------------------------------------------
    % make bar polygons
    %%-------------------------------------------------------------------------
    if OPT.KMLbarplot
        lonpoly={};
        latpoly={};
        xpoly={};
        ypoly={};
        for tt=1:length(timesteps)
            x = PRNdata.x(:,1);
            y = PRNdata.y(:,1);
            if isempty(OPT.zdata)   %Default is zminz0
                z = -BARsign*PRNdata.zminz0(:,timesteps(tt));     % changed sign here!
            else                    %Optional user defined (for example wrt reference scenario)
                z = OPT.zdata(:,timesteps(tt));
            end
            dx = diff(PRNdata.xdist);

            if isempty(segments);segments=100;end
            ID = unique(round([length(x)/segments/2:length(x)/segments:length(x)-length(x)/segments/2]));ID=setdiff(ID,0);
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
                xtext{tt}(jj,:)  = xtip;
                ytext{tt}(jj,:)  = ytip;
                ztext{tt}{jj}  = num2str(round(z1));

        %         %% convert coordinates to lat-lon
        %         
        %         lonpoly{tt}{jj}      = lonpoly{tt}{jj}';
        %         latpoly{tt}{jj}      = latpoly{tt}{jj}';
               % figure(1);clf;plot(xpoly{tt}(jj,:),ypoly{tt}(jj,:),'k');hold on;plot(x1,y1,'r*');plot(xtip,ytip,'g*');
            end
            [lonpoly{tt},latpoly{tt}] = convertCoordinates(xpoly{tt},ypoly{tt},EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
            [lontext{tt},lattext{tt}] = convertCoordinates(xtext{tt},ytext{tt},EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
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
        kml2        = KML_header('kmlName',[OPT.KMLheader,'BAR']);
        for tt=1:length(timesteps)
            t1       = PRNdata.year(timesteps(tt))*365.25+reftimenum; 
            if tt==1;t1=t1-0.5;end
            if tt<length(timesteps)
            t2 = PRNdata.year(timesteps(tt)+1)*365.25+reftimenum;
            else
            t2 = PRNdata.year(timesteps(tt))*365.25+reftimenum+DT*365.25;
            end
            tstart   = datestr(t1,'yyyy-mm-ddTHH:MM:SS');
            tend     = datestr(t2,'yyyy-mm-ddTHH:MM:SS');
            IDneg            = find(z2{tt}<0); % red
            IDpos            = find(z2{tt}>=0);
            kmlpoly2         = [];

            for ii=1:length(IDpos) %length(S.PP(sens).settings.sgridRough)
                kmlpoly2     = [kmlpoly2,barstyle1];
                kmlpoly2     = [kmlpoly2 KMLpolytext(t1,t2,latpoly{tt}(IDpos(ii),:),lonpoly{tt}(IDpos(ii),:))];
                if OPT.KMLlabels == 1
                    if isempty(OPT.KMLlabeltext)% Default zminz0
                        kmlpoly2 = [kmlpoly2 KML_text(lattext{tt}(IDpos(ii),:),lontext{tt}(IDpos(ii),:),ztext{tt}{IDpos(ii)},'visible',1,'timeIn',tstart,'timeOut',tend)];
                    else % User specified
                    end
                end            
            end
            for ii=1:length(IDneg) %length(S.PP(sens).settings.sgridRough)
                kmlpoly2     = [kmlpoly2,barstyle2];
                kmlpoly2     = [kmlpoly2 KMLpolytext(t1,t2,latpoly{tt}(IDneg(ii),:),lonpoly{tt}(IDneg(ii),:))];
                if OPT.KMLlabels == 1
                    if isempty(OPT.KMLlabeltext)% Default zminz0
                        kmlpoly2 = [kmlpoly2 KML_text(lattext{tt}(IDneg(ii),:),lontext{tt}(IDneg(ii),:),ztext{tt}{IDneg(ii)},'visible',1,'timeIn',tstart,'timeOut',tend)];
                    else % User specified
                    end
                end
            end
            kml2 = [kml2 kmlpoly2];
        end
        kml2         = [kml2 KML_footer];
        fprintf(fid,kml2);
        fclose all;
    end
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
