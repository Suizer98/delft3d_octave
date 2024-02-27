function ddb_findShorelines
%DDB_FINDSHORELINES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_findShorelines
%
%   Input:

%
%
%
%
%   Example
%   ddb_findShorelines
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_findShorelines.m 12691 2016-04-20 11:42:02Z crautenbach.x $
% $Date: 2016-04-20 19:42:02 +0800 (Wed, 20 Apr 2016) $
% $Author: crautenbach.x $
% $Revision: 12691 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_findShorelines.m $
% $Keywords: $

%%
handles=getHandles;

handles=ddb_readShorelines(handles);

for i=1:handles.shorelines.nrShorelines
    
    handles.shorelines.shoreline(i).isAvailable=1;
    
    switch lower(handles.shorelines.shoreline(i).type)
        case{'netcdftiles'}
            localdir = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep];
            % Check if data needs to be updated, because there is a new
            % version, or because the metadata file does not exist
            if handles.shorelines.shoreline(i).update == 1 || ~exist([localdir handles.shorelines.shoreline(i).name '.nc'],'file')            
                if strcmpi(handles.shorelines.shoreline(i).URL(1:4),'http')
                    % OpenDAP
                    fname=[handles.shorelines.shoreline(i).URL '/' handles.shorelines.shoreline(i).name '.nc'];
                    if handles.shorelines.shoreline(i).useCache
                        % First copy meta data file to local cache
                        if exist([localdir 'temp.nc'],'file')
                            try
                                delete([localdir 'temp.nc']);
                            end
                        end
                        try
                            if ~exist(localdir,'dir')
                                mkdir(localdir);
                            end
                            % Try to copy nc meta file
                            ddb_urlwrite(fname,[localdir 'temp.nc']);
                            if exist([localdir 'temp.nc'],'file')
                                x0=nc_varget([localdir 'temp.nc'],'origin_x');
                                movefile([localdir 'temp.nc'],[localdir handles.shorelines.shoreline(i).name '.nc']);
                            end
                            fname = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep handles.shorelines.shoreline(i).name '.nc'];
                        catch
                            % If no access to openDAP server possible, check
                            % whether meta data file is already available in
                            % cache
                            if exist([localdir 'temp.nc'],'file')
                                try
                                    delete([localdir 'temp.nc']);
                                end
                            end
                            disp(['Connection to OpenDAP server could not be made for shoreline ' handles.shorelines.shoreline(i).longName ' - try using cached data instead']);
                            fname = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep handles.shorelines.shoreline(i).name '.nc'];
                            if exist(fname,'file')
                                % File already exists, continue
                            else
                                % File does not exist, this should produce a
                                % warning
                                disp(['Shoreline ' handles.shorelines.shoreline(i).longName ' not available!']);
                                handles.shorelines.shoreline(i).isAvailable=0;
                            end
                        end
                    else
                        % Read meta data from openDAP server
                    end
                else
                    % Local
                    fname=[handles.shorelines.shoreline(i).URL filesep handles.shorelines.shoreline(i).name '.nc'];
                    if exist(fname,'file')
                        % File already exists, continue
                    else
                        % File does not exist, this should produce a
                        % warning
                        disp(['Bathymetry dataset ' handles.shorelines.shoreline(i).longName ' not available!']);
                        handles.shorelines.shoreline(i).isAvailable=0;
                    end
                end
            else
                fname = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep handles.shorelines.shoreline(i).name '.nc'];
            end
            
            if handles.shorelines.shoreline(i).isAvailable
                
                x0=nc_varget(fname,'origin_x');
                y0=nc_varget(fname,'origin_y');
                ntilesx=nc_varget(fname,'number_of_tiles_x');
                ntilesy=nc_varget(fname,'number_of_tiles_y');
                dx=nc_varget(fname,'tile_size_x');
                dy=nc_varget(fname,'tile_size_y');
                scale=nc_varget(fname,'scale');
                try
                zoomstrings=nc_varget(fname,'zoom_level_string');
                catch
                zoomstrings=['f';'h';'i';'l';'c'];
                end
                
                for k=1:length(x0)
                    iav{k}=nc_varget(fname,['iavailable' num2str(k)]);
                    jav{k}=nc_varget(fname,['javailable' num2str(k)]);
                    zoomstr{k}=deblank(zoomstrings(k,:));
                end
                
                handles.shorelines.shoreline(i).horizontalCoordinateSystem.name=nc_attget(fname,'crs','coord_ref_sys_name');
                tp=nc_attget(fname,'crs','coord_ref_sys_kind');
                switch lower(tp)
                    case{'projected','proj','projection','xy','cartesian','cart'}
                        handles.shorelines.shoreline(i).horizontalCoordinateSystem.type='Cartesian';
                    case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
                        handles.shorelines.shoreline(i).horizontalCoordinateSystem.type='Geographic';
                end
                
                handles.shorelines.shoreline(i).nrZoomLevels=length(x0);
                for k=1:handles.shorelines.shoreline(i).nrZoomLevels
                    handles.shorelines.shoreline(i).zoomLevel(k).x0=double(x0(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).y0=double(y0(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).ntilesx=double(ntilesx(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).ntilesy=double(ntilesy(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).dx=double(dx(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).dy=double(dy(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).iAvailable=double(iav{k});
                    handles.shorelines.shoreline(i).zoomLevel(k).jAvailable=double(jav{k});
                    handles.shorelines.shoreline(i).zoomLevel(k).zoomString=zoomstr{k};
                    handles.shorelines.shoreline(i).scale(k)=double(scale(k));
                end
            end
    end
end

disp([num2str(handles.shorelines.nrShorelines) ' shorelines found!']);

setHandles(handles);
