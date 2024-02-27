function boundary=nest2_dflowfm_in_dflowfm(hisfile,admfile,extfile,refdate,varargin)
% Nesting script to generate bc file for Delft3D-FM model nested in other Delft3D-FM model
% e.g.
% nest2_dflowfm_in_dflowfm('..\..\overall\overall_his.nc','..\..\overall\nesting.adm','detail.exe',datenum(2020,1,1),'zcor',0.1,'cstype','projected');
% cstype = coordinate system type (geographic or projected) of the detail model
% zcor   = water level correction (m)

if ~isempty(fileparts(extfile))
    pth=[fileparts(extfile) filesep];
else
    pth='.\';
end

zcor=0;
% bcfile=[];
cstype='projected';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'zcor'}
                zcor=varargin{ii+1};   % water level correction
%             case{'bcfile'}
%                 bcfile=varargin{ii+1}; % name of bc file
            case{'cstype'}
                cstype=varargin{ii+1}; % must be either projected or geographic
        end
    end                
end

% Read admin file
xml=xml2struct(admfile,'structuretype','supershort');

nb=length(xml.boundary);

% Read all boundary data
boundary = delft3dfm_read_boundaries(extfile);

% Read times
tim=nc_varget(hisfile,'time');
units=nc_attget(hisfile,'time','units');
t0=datenum(units(15:end),'yyyy-mm-dd HH:MM:SS');
tim=t0+tim/86400;

% Read stations
stat=nc_varget(hisfile,'station_name');
nstat=size(stat,1);
for istat=1:nstat
    stations{istat}=deblank2(stat(istat,:));
end

iwl=0;
ivel=0;

for ib=1:nb
    tp=boundary(ib).boundary.type;
    switch tp
        case{'water_level'}
            iwl=1;
        case{'water_level_plus_normal_velocity'}
            iwl=1;
            ivel=1;
        case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
            iwl=1;
            ivel=1;
    end
end

% Read in all data from the his file
if iwl
    wl=nc_varget(hisfile,'waterlevel');
end
if ivel
    u=nc_varget(hisfile,'x_velocity');
    v=nc_varget(hisfile,'y_velocity');
end

for ib=1:nb    
    
    np=length(xml.boundary(ib).node);
    
    tp=boundary(ib).boundary.type;
    
    boundary(ib).boundary.water_level.astronomic_components.active=0;
    boundary(ib).boundary.water_level.harmonic_components.active=0;
    boundary(ib).boundary.water_level.time_series.active=0;

    boundary(ib).boundary.normal_velocity.astronomic_components.active=0;
    boundary(ib).boundary.normal_velocity.harmonic_components.active=0;
    boundary(ib).boundary.normal_velocity.time_series.active=0;

    boundary(ib).boundary.tangential_velocity.astronomic_components.active=0;
    boundary(ib).boundary.tangential_velocity.harmonic_components.active=0;
    boundary(ib).boundary.tangential_velocity.time_series.active=0;

    % Set relevant forcing to active and set forcing files
    icompuv=0;
    switch tp
        case{'water_level'}
            boundary(ib).boundary.water_level.time_series.active=1;
%            boundary(ib).boundary.water_level.time_series.forcing_file=bcfile;            
        case{'water_level_plus_normal_velocity'}
            boundary(ib).boundary.water_level.time_series.active=1;
            boundary(ib).boundary.normal_velocity.time_series.active=1;
%            boundary(ib).boundary.water_level.time_series.forcing_file=bcfile;            
%            boundary(ib).boundary.normal_velocity.time_series.forcing_file=bcfile;            
            icompuv=1;
        case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
            boundary(ib).boundary.water_level.time_series.active=1;
            boundary(ib).boundary.normal_velocity.time_series.active=1;
            boundary(ib).boundary.tangential_velocity.time_series.active=1;
%            boundary(ib).boundary.water_level.time_series.forcing_file=bcfile;            
%            boundary(ib).boundary.normal_velocity.time_series.forcing_file=bcfile;            
%            boundary(ib).boundary.tangential_velocity.time_series.forcing_file=bcfile;
            icompuv=1;
    end
    
    % Find indices of observation stations    
    for ip=1:length(xml.boundary(ib).node)

        nsur=length(xml.boundary(ib).node(ip).obspoint);
        
        zz=0;
        uu=0;
        vv=0;
        
        % Get data and weights from surrounding point and compute weighted
        % average
        for isur=1:nsur
            iobs=strmatch(xml.boundary(ib).node(ip).obspoint(isur).name,stations,'exact');
            w=str2double(xml.boundary(ib).node(ip).obspoint(isur).weight);
            zz=zz+wl(:,iobs)*w;
            uu=uu+u(:,iobs)*w;
            vv=vv+v(:,iobs)*w;
        end
        
        zz=zz+zcor;
        
        if icompuv

            % Compute normal and tangential components
            
            % First compute angle of boundary segment
            if ip==1
                dx=boundary(ib).boundary.x(2)-boundary(ib).boundary.x(1);
                dy=boundary(ib).boundary.y(2)-boundary(ib).boundary.y(1);
            elseif ip==length(xml.boundary(ib).node)
                dx=boundary(ib).boundary.x(ip)-boundary(ib).boundary.x(ip-1);
                dy=boundary(ib).boundary.y(ip)-boundary(ib).boundary.y(ip-1);
            else
                dx=boundary(ib).boundary.x(ip+1)-boundary(ib).boundary.x(ip-1);
                dy=boundary(ib).boundary.y(ip+1)-boundary(ib).boundary.y(ip-1);
            end
            
            if strcmpi(cstype(1:3),'geo')
                % Correct dx
                dx=dx*abs(cos(boundary(ib).boundary.y(ip)*pi/180));
            end
            
            alfa=atan2(dy,dx);           % angle of the segment
            
            % Rotate velocity vector
            utan=cos(alfa)*uu-sin(alfa)*vv; 
            unor=sin(alfa)*uu+cos(alfa)*vv; 
            
        end
        
        switch tp
            
            case{'water_level'}
                boundary(ib).boundary.water_level.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.water_level.time_series.nodes(ip).value=zz;

            case{'water_level_plus_normal_velocity'}
                boundary(ib).boundary.water_level.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.water_level.time_series.nodes(ip).value=zz;
                boundary(ib).boundary.normal_velocity.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.normal_velocity.time_series.nodes(ip).value=unor;

            case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
                boundary(ib).boundary.water_level.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.water_level.time_series.nodes(ip).value=zz;
                boundary(ib).boundary.normal_velocity.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.normal_velocity.time_series.nodes(ip).value=unor;
                boundary(ib).boundary.tangential_velocity.time_series.nodes(ip).time=tim;
                boundary(ib).boundary.tangential_velocity.time_series.nodes(ip).value=utan;

        end
        
        
    end
    
end

% Save bc files
delft3dfm_write_bc_file(boundary,refdate,'path',pth);
