function generateIniFile2(flow, opt, fname)
%GENERATEINIFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   generateIniFile(flow, opt, fname)
%
%   Input:
%   flow  =
%   opt   =
%   fname =
%
%
%
%
%   Example
%   generateIniFile
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

% $Id: generateIniFile.m 8660 2013-05-22 13:36:01Z j.lencart.x $
% $Date: 2013-05-22 15:36:01 +0200 (Wed, 22 May 2013) $
% $Author: j.lencart.x $
% $Revision: 8660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateIniFile.m $
% $Keywords: $

% flow.gridXZOri=flow.gridXZ;
% flow.gridYZOri=flow.gridYZ;

flist=dir([opt.mapdir '*.nc']);

for ifile=1:length(flist)
    
    netfile=[opt.mapdir flist(ifile).name];
    copyfile(netfile,opt.outdir);
    outfile=[opt.outdir flist(ifile).name];

    zsig=nc_varget(netfile,'LayCoord_w');
    flow.KMax=length(zsig)-1;
    flow.thick=[];
    for k=1:flow.KMax
        flow.thick(k)=100*(zsig(k+1)-zsig(k));
    end
    
    xcc=nc_varget(netfile,'FlowElem_xcc');
    ycc=nc_varget(netfile,'FlowElem_ycc');
    zcc=nc_varget(netfile,'FlowElem_zcc');
    
    flowlink=nc_varget(netfile,'FlowLink');
    flowlink=min(flowlink,length(xcc));
    xu=nc_varget(netfile,'FlowLink_xu');
    yu=nc_varget(netfile,'FlowLink_yu');
    xcc1=xcc(flowlink(:,1));
    xcc2=xcc(flowlink(:,2));
    ycc1=ycc(flowlink(:,1));
    ycc2=ycc(flowlink(:,2));
    zcc1=zcc(flowlink(:,1));
    zcc2=zcc(flowlink(:,2));
    % Angle of flow link
    phi=atan2(ycc2-ycc1,xcc2-xcc1);
    cosp=repmat(cos(phi),1,flow.KMax);
    sinp=repmat(sin(phi),1,flow.KMax);
    % Bed level of flow link
    zu=0.5*(zcc1+zcc2);
    
    %% Coordinate conversion
    if isfield(flow,'coordSysType')
        if ~strcmpi(flow.coordSysType,'geographic')
            % First convert grid to WGS 84
            [xcc,ycc]=convertCoordinates(xcc,ycc,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
            [xu,yu]  =convertCoordinates(xu ,yu ,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
            %         [flow.gridXZ,flow.gridYZ]=convertCoordinates(flow.gridXZ,flow.gridYZ,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
            %         flow.gridX=mod(flow.gridX,360);
            %         flow.gridXZ=mod(flow.gridXZ,360);
        end
    end
    
    % mmax=size(flow.gridXZ,1)+1;
    % nmax=size(flow.gridYZ,2)+1;
    %
    % dp=zeros(mmax,nmax);
    % dp(dp==0)=NaN;
    % dp(1:end-1,1:end-1)=-flow.depthZ;
    
    dp=-zcc;    
    if strcmpi(flow.vertCoord,'z')
        dplayercc=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
    else
        dplayercc=getLayerDepths(dp,flow.thick);
    end
    
    dp=-zu;    
    if strcmpi(flow.vertCoord,'z')
        dplayeru=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
    else
        dplayeru=getLayerDepths(dp,flow.thick);
    end
    
    %% Water Level
    %%%%%%%%%%%%%%%%%% Changed by j.lencart@gmail.com %%%%%%%
    disp('   Water levels ...');
    % data in cell centres
    flow.gridX=xcc;
    flow.gridY=ycc;
    flow.gridZ=zcc;
    switch opt.waterLevel.IC.source
        case 4
            % Constant
            h=zeros(mmax,nmax)+opt.waterLevel.IC.constant;
            ddb_wldep('write',fname,h,'negate','n','bndopt','n');
        case 2
            % From file
            h=generateInitialConditions2(flow,opt,'waterLevel',1,dplayercc,fname);
            data0=nc_varget(netfile,'s1');
            nt=size(data0,1);
            for it=1:nt
                data2(it,:)=h;
            end
            nc_varput(outfile,'s1',data2);
            clear data0 h data2
    end
    
    % % Add water level to dplayer for sigma coordinates
    % if ~strcmpi(flow.vertCoord,'z')
    % %     D = size(dplayer);
    %     if ndims(dplayer) > 2
    %         % 3D
    % %     h = repmat(h, [1, 1, D(end)]);
    %         h=zeros(size(dplayer))+h;
    %     end
    %     dplayer = dplayer + h;
    % end
        %% Velocities
        disp('   Velocities ...');
        % data in flow links
        flow.gridX=xu;
        flow.gridY=yu;
        flow.gridZ=zu;
        flow.alpha=phi;
        [u,v]=generateInitialConditions2(flow,opt,'current',1,dplayeru,fname);
        data=cosp.*u+sinp.*v;
        data0=nc_varget(netfile,'unorm');
        nt=size(data0,1);
        for it=1:nt
            data2(it,:,:)=data;
        end
        nc_varput(outfile,'unorm',data2);
        nc_varput(outfile,'u0',data2);
        clear data0 data data2    
    %% Salinity
    if flow.salinity.include
        % data in cell centres
        flow.gridX=xcc;
        flow.gridY=ycc;
        flow.gridZ=zcc;
        disp('   Salinity ...');
        data=generateInitialConditions2(flow,opt,'salinity',1,dplayercc,fname);
        data0=nc_varget(netfile,'sa1');
        nt=size(data0,1);
        for it=1:nt
            data2(it,:,:)=data;
        end
        nc_varput(outfile,'sa1',data2);
        clear data0 data data2
    end
    
    %% Temperature
    if flow.temperature.include
        % data in cell centres
        flow.gridX=xcc;
        flow.gridY=ycc;
        flow.gridZ=zcc;
        disp('   Temperature ...');
        data=generateInitialConditions2(flow,opt,'temperature',1,dplayercc,fname);
        data0=nc_varget(netfile,'tem1');
        nt=size(data0,1);
        for it=1:nt
            data2(it,:,:)=data;
        end
        nc_varput(outfile,'tem1',data2);
        clear data0 data data2
    end
    
    %% Sediments
    for i=1:flow.nrSediments
        disp('   Sediments ...');
        data=generateInitialConditions2(flow,opt,'sediment',i,dplayercc,fname);
    end
    
    %% Tracers
    for i=1:flow.nrTracers
        disp('   Tracers ...');
        data=generateInitialConditions(flow,opt,'tracer',i,dplayercc,fname);
    end
    
end
