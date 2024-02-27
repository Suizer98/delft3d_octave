function obstacle=sfincs_get_obstacles(polfile,dx,w,cs,bathymetry,varargin)
% obstacle=sfincs_get_obstacles(polfile,dx,w,cs,bathymetryname,varargin);
%
% polfile     = polyline file (tekal format)
% dx          = point spacing along polylines
% w           = width over which maximum elevation is extracted
% cs          = coordinate system (EPSG)
% bathyname   = structure with bathymetry datasets in DDB database
%
% Optional:
% outputfile  = name of sfincs weir file
% par1        = parameter 1 in weir file (default 0.6)
% par2        = parameter 2 in weir file (default 0.0)
% par3        = parameter 3 in weir file (default 0.0)
%
% e.g.
% cs.name='WGS 84 / UTM zone 17N';
% cs.type='projected';
% polfile='test01.pli';
% bathy(1).name='ncei_ninth_southeast'; % first bathy dataset
% bathy(1).zmin=0.0;
% bathy(1).zmax=0.0;
% bathy(1).vertical_offset=0.0;
% bathy(1).name='ncei_ninth_southeast'; % first bathy dataset
% bathy(2).name='usgs_ned_coastal';     % second bathy dataset
% bathy(3).name='ngdc_crm';             % third bathy dataset
% obstacle=sfincs_get_obstacles(polfile,50,200,cs,bathy,'outputfile','sfincs.weir','par1',0.6);

outputfile=[];

par1=0.6; % Usually zmax unless specified otherwise
par2=0.0;
par3=0.0;

if ~isempty(varargin)
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'outputfile'}
                    outputfile=varargin{ii+1};
                case{'par1'}
                    par1=varargin{ii+1};
                case{'par2'}
                    par2=varargin{ii+1};
                case{'par3'}
                    par3=varargin{ii+1};
            end
        end
    end
end

% Read polyline file
data=tekal('read',polfile,'loaddata');
np=length(data.Field);
for ip=1:np
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    p(ip).x=x;
    p(ip).y=y;
end

for ipol=1:np
    
    xp=p(ipol).x;
    yp=p(ipol).y;
    
    [xobs,yobs,zobs]=sfincs_get_obstacle_height(xp,yp,dx,w,cs,bathymetry);
    
    obstacle(ipol).x=xobs;
    obstacle(ipol).y=yobs;
    obstacle(ipol).z=zobs;
    obstacle(ipol).par1=zeros(size(xobs))+par1;
    obstacle(ipol).par2=zeros(size(xobs))+par2;
    obstacle(ipol).par3=zeros(size(xobs))+par3;
    
end

if ~isempty(outputfile)
    sfincs_write_obstacle_file(outputfile,obstacle);
end
