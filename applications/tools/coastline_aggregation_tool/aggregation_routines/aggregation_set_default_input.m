function [coastline data settings varargout] = aggregation_set_default_input(num_of_models,plot_types,model_types)

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

coastline.ldb_file        = 'some_ldb_file_representing_the_coastline.ldb OR an [Mx2] matrix';
coastline.structure_inds  = {};
coastline.ignore_inds     = {};
coastline.EPSG            = [];

cols = lines(num_of_models);
for ii = 1:num_of_models
    data(ii).name              = ['Model/data #' num2str(ii)];
    data(ii).plot_type         = plot_types{1};
    data(ii).color             = cols(ii,:);
    data(ii).from_model        = false;
    data(ii).model_name        = '';
    data(ii).model_files       = {};
    data(ii).model_EPSG        = [];
    data(ii).most_likely_run   = [];
    data(ii).use_min_max_range = false;
    data(ii).most_likely_diff  = [];
    data(ii).min_diff          = [];
    data(ii).max_diff          = [];
end

settings.combined_fig          = true;
settings.cumulative_results    = false;
settings.filled_LDB            = false;
settings.x_lims                = [];
settings.y_lims                = [];
settings.plot_factor           = 1;
settings.background_image      = [];
settings.background_world_file = [];
settings.output_folder         = [pwd filesep 'output'];
settings.save_figures_to_file  = false;
settings.save_mat_files        = false;
settings.save_kml_files        = false;
settings.diff_indices          = [];
settings.show_splash           = false;
settings.file_suffix           = '';

% Optional keywords listed here:
varargout{1}  = {'set_model_time','set_model_vert_level'};

% function end
end