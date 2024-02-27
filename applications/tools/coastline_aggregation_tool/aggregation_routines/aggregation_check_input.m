function [coastline,data,settings] = aggregation_check_input(coastline,data,settings,plot_types,model_types)

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

% Check the EPSG code:
load('EPSG.mat','coordinate_reference_system');
if ~isempty(coastline.EPSG)
    if isnumeric(coastline.EPSG) && min(size(coastline.EPSG)) == 1 && max(size(coastline.EPSG)) == 1
        if ~isempty(find(coordinate_reference_system.coord_ref_sys_code==coastline.EPSG))
            if ~strcmp(coordinate_reference_system.coord_ref_sys_kind(find(coordinate_reference_system.coord_ref_sys_code==coastline.EPSG)),'projected')
                error(['Coordinate system of coastline is not projected (x,y), but ''' coordinate_reference_system.coord_ref_sys_kind{find(coordinate_reference_system.coord_ref_sys_code==coastline.EPSG)} '''']);
            end
        else
            error(['EPSG code for coastline ' num2str(coastline.EPSG) ' does not exist, see the funtion help']);
        end
    else
        error('EPSG code of the coastline should be a single value, see the funtion help')
    end
else
    error('No EPSG code provided for the coastline, this is required');
end

% Check the format of the landboundary and load it:
if iscell(coastline.ldb_file)
    coastline.ldb_file = coastline.ldb_file{:};
end
if ischar(coastline.ldb_file)
    coastline.ori_ldb = landboundary('read',coastline.ldb_file);
else
    if isnumeric(coastline.ldb_file)
        if ~isempty(find(size(coastline.ldb_file) == 2))
            if size(coastline.ldb_file,2) ~= 2 && size(coastline.ldb_file,1) == 2
                coastline.ldb_file = coastline.ldb_file';
            end
            coastline.ori_ldb = coastline.ldb_file
        else
            error('Incorrect coastline.ldb_file format')
        end
    else
        error('coastline.ldb_file should be a string containing the filename of the coastline ldb');
    end
end
while isnan(coastline.ori_ldb(1,1)); coastline.ori_ldb = coastline.ori_ldb(2:end,:); end;
while isnan(coastline.ori_ldb(end,1)); coastline.ori_ldb = coastline.ori_ldb(1:end-1,:); end;
if ~isempty(find(isnan(coastline.ori_ldb))); error('The provided coastline (reference line) consists of multiple sections, please check and avoid this (should be one line, without NaN''s)'); end;

% Check the input of 'structure_inds' and 'ignore_inds'
if size(coastline.structure_inds,1) > 1 && size(coastline.structure_inds,2) == 1
    coastline.structure_inds = coastline.structure_inds';
end
if size(coastline.ignore_inds,1) > 1 && size(coastline.ignore_inds,2) == 1
    coastline.ignore_inds = coastline.ignore_inds';
end
if ~iscell(coastline.ignore_inds)
    error(['Incorrect format of ''coastline.ignore_inds'', should be a cell!']);
end
if ~iscell(coastline.structure_inds)
    error(['Incorrect format of ''coastline.structure_inds'', should be a cell!']);
end
for ii=1:length(coastline.ignore_inds)
    if min(coastline.ignore_inds{ii})<1 || max(coastline.ignore_inds{ii})>length(coastline.ori_ldb)
        error(['Indices of ''coastline.ignore_inds'' are larger than the provided ldb!']);
    end
end
for ii=1:length(coastline.structure_inds)
    if min(coastline.structure_inds{ii})<1 || max(coastline.structure_inds{ii})>length(coastline.ori_ldb)
        error(['Indices of ''coastline.structure_inds'' are larger than the provided ldb!']);
    end
end

% Refine the landboundary to a certain min. resolution where needed:
ldb_dx_min = 100;
if ~isempty(find(sqrt(sum(diff(coastline.ori_ldb).^2,2))>ldb_dx_min))
    coastline.ldb = add_equidist_points(ldb_dx_min,coastline.ori_ldb,'equi'); coastline.ldb = coastline.ldb(2:end-1,:); % Remove trailing NaN's
    % Now, we need to create new indices for the structures and ignored parts of the ldb:
    for ii=1:length(coastline.structure_inds)
        coastline.structure_inds{ii} = find(coastline.ldb(:,1) == coastline.ori_ldb(coastline.structure_inds{ii}(1),1) & coastline.ldb(:,2) == coastline.ori_ldb(coastline.structure_inds{ii}(1),2)) : find(coastline.ldb(:,1) == coastline.ori_ldb(coastline.structure_inds{ii}(end),1) & coastline.ldb(:,2) == coastline.ori_ldb(coastline.structure_inds{ii}(end),2));
    end
    for ii=1:length(coastline.ignore_inds)
        coastline.ignore_inds{ii} = find(coastline.ldb(:,1) == coastline.ori_ldb(coastline.ignore_inds{ii}(1),1) & coastline.ldb(:,2) == coastline.ori_ldb(coastline.ignore_inds{ii}(1),2)) : find(coastline.ldb(:,1) == coastline.ori_ldb(coastline.ignore_inds{ii}(end),1) & coastline.ldb(:,2) == coastline.ori_ldb(coastline.ignore_inds{ii}(end),2));
    end
end

% Check all the output data of the models:
for ii=1:length(data)
    if sum(strcmp(plot_types,data(ii).plot_type)) == 0; error(['Plot type ''' data(ii).plot_type ''' does not exist, check the help']); end
    if data(ii).from_model
        if sum(strcmp(model_types,data(ii).model_name)) == 0; error(['Model name ''' data(ii).model_name ''' does not exist, check the help']); end
        for jj=1:length(data(ii).model_files); if isempty(dir(data(ii).model_files{jj})); error(['Could not find model file: ' data(ii).model_files{jj}]); end; end;
    end
end

if ~isempty(settings.diff_indices)
    if isnumeric(settings.diff_indices)
        if size(settings.diff_indices,2) ~= 2
            error('Incorrect format for ".diff_indices", should be a 2 column matrix');
        elseif max(max(settings.diff_indices)) > length(data)
            error('Maximum indice of ".diff_indices" is larger than the number of model/datasets, please check this');
        elseif min(min(settings.diff_indices)) < 1
            error('Minimum indice of ".diff_indices" is smaller than 1, please check this');
        elseif ~isempty(find(diff(settings.diff_indices,1,2)==0))
            error('Model/data indices for difference data/plots should be different!');
        end
    else
        error('Keyword ".diff_indices" should be numeric');
    end
end

if ~isstr(settings.file_suffix)
    error(['Keyword ''settings.file_suffix'' should be a string']);
end

% function end
end