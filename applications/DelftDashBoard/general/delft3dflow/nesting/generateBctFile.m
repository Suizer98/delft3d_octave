function openBoundaries = generateBctFile(flow, openBoundaries, opt)
%GENERATEBCTFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = generateBctFile(flow, openBoundaries, opt)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%
%   Output:
%   openBoundaries =
%
%   Example
%   generateBctFile
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

% $Id: generateBctFile.m 15010 2019-01-02 12:31:38Z nederhof $
% $Date: 2019-01-02 20:31:38 +0800 (Wed, 02 Jan 2019) $
% $Author: nederhof $
% $Revision: 15010 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateBctFile.m $
% $Keywords: $

%%
%opt.waterLevel.BC.corFile='c:\work\socal\tide\run01\newbnd\cor01\cor01.cor';
%opt.current.BC.corFile='c:\work\socal\tide\run01\newbnd\cor01\cor01.cor';

opt.waterLevel.BC.corFile=[];
opt.current.BC.corFile=[];

genWLAstro=0;
%genWLHarmo=0;
genWLConst=0;
genWL3D=0;

%genVelHarmo=0;
genVel4D=0;
genVelConst=0;
genVelTS=0;
genVelAstro=0;

nr=length(openBoundaries);

for i=1:nr
    dp(i,1)=-openBoundaries(i).depth(1);
    dp(i,2)=-openBoundaries(i).depth(2);
end

%% Initialize time series

% Times
t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep/1440;
times=t0:dt:t1;
nt=length(times);

% Water Levels
wlconst=0;
wlastro=zeros(nr,2,nt);
wl3d=zeros(nr,2,nt);

% Currents
velconst=0;
velastro=zeros(nr,2,flow.KMax,nt);
vel4d=zeros(nr,2,flow.KMax,nt);

% Tangential currents
tanvelconst=0;
tanvelastro=zeros(nr,2,flow.KMax,nt);
tanvel4d=zeros(nr,2,flow.KMax,nt);

%% Check which time series need to be generated

for i=1:nr
    switch lower(openBoundaries(i).type)
        case{'n'}
            % Neumann
        case{'z'}
            % Water level
            switch opt.waterLevel.BC.source
                case 1
                    genWLAstro=1;
                case 2
                    genWL3D=1;
                case 3
                    genWLAstro=1;
                    genWL3D=1;
                case 4
                    genWLConst=1;
            end
        case{'c'}
            % Current
            switch opt.current.BC.source
                case 1
                    genVelAstro=1;
                case 2
                    genVel4D=1;
                case 3
                    genVelAstro=1;
                    genVel4D=1;
                case 4
                    genVelConst=1;
            end
        case{'r','x','p'}
            % Riemann
            % Water levels
            switch opt.waterLevel.BC.source
                case 1
                    genWLAstro=1;
                case 2
                    genWL3D=1;
                case 3
                    genWLAstro=1;
                    genWL3D=1;
                case 4
                    genWLConst=1;
            end
            % Currents
            switch opt.current.BC.source
                case 1
                    genVelAstro=1;
                case 2
                    genVel4D=1;
                case 3
                    genVelAstro=1;
                    genVel4D=1;
                case 4
                    genVelConst=1;
            end
    end
end

%% Now generate the required time series

% Water level time series
if genWLAstro
    disp('   Water levels from astro ...');
    [twlastro,wlastro]=generateWaterLevelsFromAstro(flow,opt);
end
if genWLConst
    disp('   Water levels from constant ...');    
    wlconst=wlconst+opt.waterLevel.BC.constant;
end
if genWL3D
    disp('   Water levels from file ...');
    [twl3d,wl3d]=generateWaterLevelsFromFile(flow,openBoundaries,opt);
end
% if genWLHarmo
%     disp('   Water levels from harmo ...');
%     [twlharmo,wlharmo]=GenerateWaterLevelsFromHarmo(Flow);
% end

% Current time series
if genVelAstro
    disp('   Velocities from astro ...');
    [tvelastro,velastro,tanvelastro]=generateVelocitiesFromAstro(flow,opt,0);
end
if genVelConst
    disp('   Velocities from constant ...');
    velconst=velconst+opt.current.BC.constant;
end
if genVel4D
    disp('   Velocities from file ...');
    [tvel4d,vel4d,tanvel4d]=generateVelocitiesFromFile(flow,openBoundaries,opt, wl3d);
end
% if genVelTS
%     disp('   Velocities from timeseries ...');
%     [tvelts,velts]=generateVelocitiesFromTimeSeries(flow,openBoundaries,opt);
% end
% if genVelHarmo
%     disp('   Velocities from harmo ...');
%     [tvelharmo,velharmo]=generateVelocitiesFromHarmo(flow,openBoundaries,opt);
% end

%% Add time series from different sources
if opt.waterLevel.BC.constant == -999
    
    %% PART A: determine geoid-msl
    % goes from -180 to +180
    fname       = 'p:\metocean-data\open\HYCOM\surface_level\figures\original\mean.nc';
    latitude    = nc_varget(fname, 'latitude');
    longitude   = nc_varget(fname, 'longitude');
    mean        = nc_varget(fname, 'mean');
    clear fname
           
    % goes from 0 - 360
    id              = longitude < 0; 
    longitudeddb    = [longitude(~id); 360 + longitude(id)];
    meanddb         = [mean(:, ~id) mean(:, id)];
    
    % Interpolate to model domain
    nr=length(openBoundaries);

    for i=1:nr

        % End A
        x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
        y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));

        % End B
        x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
        y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));

    end

    if isfield(flow,'coordSysType')
        if ~strcmpi(flow.coordSysType,'geographic')
            % First convert grid to WGS 84
            [x,y]=convertCoordinates(x,y,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
        end
        x=mod(x,360);
    end
    x=mod(x,360);
    minx=min(min(x))-0.1;
    maxx=max(max(x))+0.1;
    miny=min(min(y))-0.1;
    maxy=max(max(y))+0.1;
    
    % Interpolate to model domain
    idlon           = find(longitudeddb >= minx & longitudeddb <= maxx);
    idlat           = find(latitude >= miny & latitude <= maxy);
    [lon_TMP, lat_TMP] = meshgrid(longitudeddb(idlon), latitude(idlat));
    figure; pcolor(lon_TMP, lat_TMP, meanddb(idlat, idlon)); shading flat;
    geoid_msl       = griddata(lon_TMP, lat_TMP, meanddb(idlat, idlon), x, y);
    for ii = 1:size(geoid_msl,1)
        for jj = 1:size(geoid_msl,2)
            wlconst(ii,jj,[1:size(wl3d,3)])         = geoid_msl(ii,jj)*-1;
        end
    end
    
    %% PART B: CORRECT HYCOM
    wl3d            = wl3d + 999;
    
end
wl=wlconst+wlastro+wl3d;

% figure; hold on;
% plot(squeeze(wlconst(1,1,:)))
% plot(squeeze(wlastro(1,1,:)))
% plot(squeeze(wl3d(1,1,:)))
% plot(squeeze(wl(1,1,:)))

% switch opt.current.BC.source
%     case 1
%         vel=velconst+velastro;
%     case 2
%         vel=velconst+velastro+vel4d;
%     case 3
%         vel=velconst+velastro+vel4d;
%     case 4
%         vel=velconst+velastro+vel4d;
% end

vel=velconst+velastro+vel4d;
tanvel=tanvelconst+tanvelastro+tanvel4d;

% for iii=70:80
%     plot(squeeze(wlastro(iii,1,:)));hold on;
%     plot(squeeze(wlastro(iii,2,:)));hold on;
% end
%
% for iii=70:80
%     plot(squeeze(velastro(iii,1,1,:)));hold on;
%     plot(squeeze(velastro(iii,2,1,:)));hold on;
% end


%% Generate time series for each boundary
for n=1:nr
    % Check if it's a time series boundary
    if openBoundaries(n).forcing=='T'
        switch lower(openBoundaries(n).type)
            
            case{'n'}
                
                % Neumann not implemented yet ...
                %                 openBoundaries(n).TimeSeriesT=[Flow.StartTime Flow.StopTime];
                %                 openBoundaries(n).TimeSeriesA=[gradient gradient];
                %                 openBoundaries(n).TimeSeriesB=[gradient gradient];
                
            case{'z'}
                
                % Water level
                openBoundaries(n).nrTimeSeries=length(times);
                openBoundaries(n).timeSeriesT=times;
                openBoundaries(n).timeSeriesA=squeeze(wl(n,1,:));
                openBoundaries(n).timeSeriesB=squeeze(wl(n,2,:));
                
            case{'r','x'}
                
                % Riemann or Riemann + parallel velocities
               
 % Include water level time series for sigma height calculation in bcc
                openBoundaries(n).timeSeriesWLA=squeeze(wl(n,1,:));
                openBoundaries(n).timeSeriesWLB=squeeze(wl(n,2,:));
                % Normal component
                               
                for k=1:flow.KMax
                    switch lower(openBoundaries(n).side)
                        case{'left','bottom'}
                            r1(:,k)=squeeze(vel(n,1,k,:)) + squeeze(wl(n,1,:))*sqrt(9.81/dp(n,1));
                            r2(:,k)=squeeze(vel(n,2,k,:)) + squeeze(wl(n,2,:))*sqrt(9.81/dp(n,2));
                        case{'top','right'}
                            r1(:,k)=squeeze(vel(n,1,k,:)) - squeeze(wl(n,1,:))*sqrt(9.81/dp(n,1));
                            r2(:,k)=squeeze(vel(n,2,k,:)) - squeeze(wl(n,2,:))*sqrt(9.81/dp(n,2));
                    end
                end
                
                openBoundaries(n).nrTimeSeries=length(times);
                %                openBoundaries(n).profile='3d-profile';
                openBoundaries(n).timeSeriesT=times;
                openBoundaries(n).timeSeriesA=r1;
                openBoundaries(n).timeSeriesB=r2;
                
                % Tangential component
                if strcmpi(openBoundaries(n).type,'x')
                    for k=1:flow.KMax
                        openBoundaries(n).timeSeriesAV(:,k)=squeeze(tanvel(n,1,k,:));
                        openBoundaries(n).timeSeriesBV(:,k)=squeeze(tanvel(n,2,k,:));
                    end
                end
                
            case{'c','p'}
                
                % Current or current + tangential
                openBoundaries(n).nrTimeSeries=length(times);
                openBoundaries(n).timeSeriesT=times;
                openBoundaries(n).timeSeriesA=squeeze(vel(n,1,:,:))';
                openBoundaries(n).timeSeriesB=squeeze(vel(n,2,:,:))';
                
                % Tangential component
                if strcmpi(openBoundaries(n).type,'x')
                    for k=1:flow.KMax
                        openBoundaries(n).timeSeriesAV(:,k)=squeeze(tanvel(n,1,k,:));
                        openBoundaries(n).timeSeriesBV(:,k)=squeeze(tanvel(n,2,k,:));
                    end
                end
                
        end
        
        if strcmpi(flow.vertCoord,'z')
            if ndims(openBoundaries(n).timeSeriesA)==2
                openBoundaries(n).timeSeriesA=flipdim(openBoundaries(n).timeSeriesA,2);
                openBoundaries(n).timeSeriesB=flipdim(openBoundaries(n).timeSeriesB,2);
                switch lower(openBoundaries(n).type)
                    case{'p','x'}
                        openBoundaries(n).timeSeriesAV=flipdim(openBoundaries(n).timeSeriesAV,2);
                        openBoundaries(n).timeSeriesBV=flipdim(openBoundaries(n).timeSeriesBV,2);
                end
            end
        end
        
    end
end

%disp('Saving bct file');
%delft3dflow_saveBctFile(flow,openBoundaries,fname);

