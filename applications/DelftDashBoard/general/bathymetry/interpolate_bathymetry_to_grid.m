function zgnew=interpolate_bathymetry_to_grid(xg,yg,zg,datasets,cs,varargin)
%interpolate_bathymetry_to_grid interpolates data from datasets onto structured or unstructured grid
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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

global bathymetry

if isempty(bathymetry)
    error('Bathymetry database has not yet been initialized! Please run initialize_bathymetry_database first.m first.')
end

%% Defaults
overwrite=1;
modeloffset=0;
gridtype='structured';
dmin=50;
internaldiff=0;
quiet=0;
internaldiffusionrange=[-20000 -2];

% Set defaults for datasets
for ii=1:length(datasets)
    datasets=filldatasets(datasets,ii,'zmin',-100000);
    datasets=filldatasets(datasets,ii,'zmax',100000);
    datasets=filldatasets(datasets,ii,'startdates',floor(now));
    datasets=filldatasets(datasets,ii,'searchintervals',-1e5);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'internaldiff',0);
    datasets=filldatasets(datasets,ii,'internaldiffusionrange',[-20000 20000]);
end

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'gridtype'}
                gridtype=varargin{i+1};                
            case{'modeloffset'}
                modeloffset=varargin{i+1};                
            case{'dmin'}
                dmin=varargin{i+1};
            case{'internaldiffusion'}
                internaldiff=varargin{i+1};
            case{'internaldiffusionrange'}
                internaldiffusionrange=varargin{i+1};                                
            case{'quiet'}
                quiet=1;
        end
    end
end

%% Generate bathymetry

% If now input bathymetry is given, fill matrix with nans
if isempty(zg)
    zg=zeros(size(xg));
    zg(zg==0)=NaN;
end
% Copy original bathymetry matrix to zg0
zg0=zg;
% Fill matrix zg with NaN values
zg=zeros(size(zg));
zg(zg==0)=NaN;

if strcmpi(gridtype,'structured')
    % Find minimum grid resolution (in metres!) for this dataset
    [dmin,dmax]=findMinMaxGridSize(xg,yg,'cstype',cs.type);
% else
%     % TODO determine minimum and maximum grid spacing fro unstructured
%     % grids
% %     dmin=5000;
% %     dmax=5000;
%     dmin=50;
%     dmax=50;
end
%dmin=dmin/2;
xg0=xg;
yg0=yg;

for id=1:length(datasets)   

    % Loop through selected datasets    
    % Start with coarsest data! (last index in datasets structure)
    idata=length(datasets)-id+1;
    bathyset=datasets(idata).name;
    startdate=[];
    if isfield(datasets(idata),'startdates')
        startdate=datasets(idata).startdates;
    end
    searchinterval=[];
    if isfield(datasets(idata),'searchintervals')
        searchinterval=datasets(idata).searchintervals;
    end
    zmn=datasets(idata).zmin;
    zmx=datasets(idata).zmax;
    if isfield(datasets(idata),'verticaloffset')
        verticaloffset=datasets(idata).verticaloffset;
    elseif isfield(datasets(idata),'offset')
        verticaloffset=datasets(idata).offset;
    elseif isfield(datasets(idata),'vertical_offset')
        verticaloffset=datasets(idata).vertical_offset;
    else
        verticaloffset=0;
    end
        
    % Convert grid to cs of dataset
    iac=strmatch(lower(bathyset),lower(bathymetry.datasets),'exact');
    dataCoord.name=bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',cs.name,'CS1.type',cs.type,'CS2.name',dataCoord.name,'CS2.type',dataCoord.type);

    % Determine bounding box
    xl(1)=min(min(xg));
    xl(2)=max(max(xg));
    yl(1)=min(min(yg));
    yl(2)=max(max(yg));
    dbuf=(xl(2)-xl(1))/10;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;
    
    % Download bathymetry data
%     dmin=dmin/10;

    if quiet
        [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,xl,yl,'bathymetry',bathyset,'maxcellsize',dmin,'startdate',startdate,'searchinterval',searchinterval,'quiet');
    else
        [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,xl,yl,'bathymetry',bathyset,'maxcellsize',dmin,'startdate',startdate,'searchinterval',searchinterval);
    end
    
%     figure(20)
%     pcolor(xx,yy,zz);shading flat;
%     hold on
%     plot(xg,yg);plot(xg',yg');
    
    % Convert to MSL
    zz=zz+verticaloffset;

    % Remove values outside requested range
    zz(zz<zmn)=NaN;
    zz(zz>zmx)=NaN;        
    
    isn=isnan(xg);
    % Next two line are necessary in Matlab 2010b (and older?)
    xg(isn)=0;
    yg(isn)=0;
    
    if ~isempty(xx)
        
        % Interpolate data to grid
        z0=interp2(xx,yy,zz,xg,yg);
        
        z0(isn)=NaN;
        % Copy new values (that are not NaN) to new bathymetry
        zg(~isnan(z0))=z0(~isnan(z0));
        
    end
        
end

if strcmpi(gridtype,'structured')
    if internaldiff
        % Apply internal diffusion (for missing depth points)
        isn=isnan(zg);              % Missing indices in depth matrix
        mask=zeros(size(zg))+1;
        mask(isnan(xg))=0;         % Missing indices in grid matrix
%        z=internaldiffusion(zg,'mask',mask);
        zg=internaldiffusion(zg,'mask',mask);
        isn2=logical(isn.*mask);   % Matrix of values that were filled by internal diffusion
        zg(isn2)=max(zg(isn2),internaldiffusionrange(1));
        zg(isn2)=min(zg(isn2),internaldiffusionrange(2));
    end
end

% Interpolated data in MSL, now convert to model datum
zg=zg-modeloffset;

if overwrite
    zgnew=zg;
else
    % Only use fill original bathymetry matrix with new data
    zgnew=zg0;
    zgnew(isnan(zg0))=zg(isnan(zg0));
end

%% Fill datasets
function datasets=filldatasets(datasets,ii,var,val)
if ~isfield(datasets(ii),var)
    datasets(ii).(var)=val;
elseif isempty(datasets(ii).(var))
    datasets(ii).(var)=val;
end
