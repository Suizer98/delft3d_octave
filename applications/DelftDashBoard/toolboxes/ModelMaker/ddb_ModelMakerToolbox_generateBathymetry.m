function [xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,varargin)
%DDB_MODELMAKERTOOLBOX_GENERATEBATHYMETRY creates actuall bathmetry for DDB
%
%   This routines can be called by specific model bathy routines
%   Bathy is interpolated with the use of ddb_interpolateBathymetry2

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

%% Defaults
overwrite=1;
modeloffset=0;
gridtype='structured';
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
        end
    end
end

%% Interpolate onto grid
zg=ddb_interpolateBathymetry2(handles.bathymetry,datasets,xg,yg,zg,modeloffset,overwrite,gridtype, ...
    handles.toolbox.modelmaker.bathymetry.internalDiffusion,handles.screenParameters.coordinateSystem);


%% Fill datasets
function datasets=filldatasets(datasets,ii,var,val)
if ~isfield(datasets(ii),var)
    datasets(ii).(var)=val;
elseif isempty(datasets(ii).(var))
    datasets(ii).(var)=val;
end

