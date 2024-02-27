function varargout = aggregation_of_coastline_changes_and_dynamics(coastline_user_input,data_user_input,settings_user_input)
% Aggregation of coastline changes/dynamics
%
% Function to aggregate all results of coastline changes/dynamics due to 
% various sources from different models (e.g. related to large-scale 
% coastline dynamics, (natural) beach state fluctuations, (extreme) storm 
% impact, storm erosion, structure impact, swash run-up, etc.) or other
% data. Supports the models "Delft3D 4", "Unibest CL+" and "XBeach", as
% well as data ("Data"), which is earlier saved by this script or custom
% data (which can be used for any other model) called "Landboundaries" or
% simply provided as manual input.
%
% Below a summary on how to work with the ACDC tool is provided.
% A more detailed user manual can be found in the pdf:
%
% Description_and_user_manual_ACDC_tool.pdf
%
% Which can be found in the following OET folder:
%
% .\matlab\applications\tools\coastline_aggregation_tool\
%
% The function can be called as follows:
%
% aggregation_of_coastline_changes_and_dynamics(coastline,data,settings)
%
% The user of this script is required to carefully review all the required
% information in the tab "USER INPUT" below, and provide input as such
%
%____USER INPUT____________________________________________________________
%
% User input consists of 3 structures (see function call above):
%
%   (1) coastline           (reference coastline for plotting the results)
%   (2) data                (model output or data that needs to be plotted)
%   (3) settings            (some settings related to plotting behaviour)
%
% In order to get examples for the 'coastline', 'data' and 'settings'
% input structures, simply call the script without any input:
%
%     aggregation_of_coastline_changes_and_dynamics()
%
% Below, all input fields within the input structures are listed (* required):
%
% (1) coastline: the coastline structure consists of the fields:
%
%   * coastline.ldb_file         (coastline in *.ldb format, a single line)       
%     coastline.structure_inds   (ldb-indices of structures, ignored)
%     coastline.ignore_inds      (ldb-indices of coastline parts to ignore)
%   * coastline.EPSG             (Coordinate system code (EPSG) of the ldb)
%
% (2) data: the data structure consists of the fields (* required):
%
%     data.name                  (name/identifier of provided model/data)
%     data.plot_type             (type of plot, e.g. 'lines' or 'shades')
%     data.color                 (plotting color of the model/data)
%     data.from_model            (true/false, load the data from a model?)
%     data.model_name            (model name, if from_model is true)
%     data.model_files           (model files, if from_model is true)
%     data.model_EPSG            (model EPSG, if from_model is true)
%     data.most_likely_run       (model indice, if from_model is true)
%     data.use_min_max_range     (true/false, use a custom min/max range)
%     data.most_likely_diff      (most-likely diff, if from_model is false)
%     data.min_diff              (min. diff, if use_min_max_range is true)
%     data.max_diff              (max. diff, if use_min_max_range is true)
%     data.set_model_time        (manually set model time, instead of [1 end])
%     data.set_model_vert_level  (manually set vert. level(s) of coastline)
%
%     Use data(1).keywords, data(2).keywords, etc. to add multiple models!
%
% (3) settings: the settings structure consists of the fields (* required):
%
%     settings.combined_fig          (true/false, combine into 1 fig)
%     settings.cumulative_results    (true/false, sum model results)
%     settings.filled_LDB            (true/false, filled coastline)
%     settings.x_lims                (optional, X-limits [x1 x2])
%     settings.y_lims                (optional, Y-limits [y1 y2])
%     settings.plot_factor           (difference exaggeration factor)
%     settings.background_image      (optional, background image file)
%     settings.background_world_file (optional, background world file)
%     settings.output_folder         (script output storage location)
%     settings.save_figures_to_file  (true/false, save figs to file)
%     settings.save_mat_files        (true/false, save model data to mat-files)
%     settings.save_kml_files        (true/false, save results to KML-files)
%     settings.diff_indices          (creates difference plots, data, etc.)
%     settings.show_splash           (optional, turn on the EPIC splash screen)
%     settings.file_suffix           (optional, add suffix to saved files)
%
%  DETAILED CORRECT FORMATTING OF THE INPUT BELOW
%
% (1) coastline: the coastline structure consists of the fields:
%
%   <<<coastline.ldb_file>>>
%   The ldb-file of the coastline, in *.ldb format, single line! (no NaN's)
%   (can also be a [Mx2] matrix, e.g. resulting from landboundary('read',...))
%
%   The coastline is used as a reference line, to which the different model
%   output will be linked. This must be done since different models (might)
%   have slightly different definitions for the coastline (due to different
%   gridsize, resolution, model definitions or 1D-2D-3D representations),
%   but also to be able to easily add data manually (w.r.t. this coastline)
%
%   The format of the coastline is a landboundary file containing X and Y
%   values in a certain projected (!) coordinate system (EPGS). The
%   *.ldb-file may only contain a single (1) coastline section! Be aware
%   that we assume the sea-side to be on the left size of the landboundary
%   when following the x,y indices upwards (see the sketch below):
%
%                                   +-------------------------------+
%           ~              ~        | S   E   A   -   S   I   D   E |
%               ~      4      5     +-------------------------------+
%       ~             _x------x__         ~                 ~
%               ~   _-           --__            ~             ~
%   x-----x-------x-                 -x------x------x-----------x --->
%   1     2       3               6      7      8           9
%                   
%   <<<coastline.structure_inds>>>
%   The indices of the *.ldb file that you want to draw as structures (will
%   also be ignored as dynamic coastline), in {[x1:x2],[x1:x2]} format (use
%   {} to leave it empty). You can use the function ldbTool() to find the
%   indices of structures that you want to apply.
%
%   <<<coastline.ignore_inds>>>
%   The indices of the *.ldb file ignored as a dynamic coastline, in
%   {[x1:x2],[x1:x2]} format (use {} to leave empty). You can use the
%   function ldbTool() to find the ignore indices that you want to apply.
%
%   <<<coastline.EPSG>>>
%   Coordinate system, in EPSG code, look for the EPSG code via the call:
%   load('EPSG.mat','coordinate_reference_system') or www.epsg-registry.org
%   Make sure it is a projected coordinate system! (no lon-lat support!)
%
%
% (2) data: the data structure consists of the fields:
%
%   <<<data.name>>>
%   Identifier/name for the results (will be placed in e.g. legends)
%
%   <<<data.plot_type>>>
%   Identifier for the plotting results, can be 'shades', 'lines' or 'bars'
%
%   <<<data.color>>>
%   Matlab formatted RGB color [0-1 0-1 0-1]
%
%   <<<data.from_model>>>
%   Is the data coming from a model that needs to be analysed within this
%   script? Then set this keywords to true. Are you manually providing the
%   data? Then set this keyword to false.
%   
%   Provide the following data.keywords if from_model = true:
%       - .model_name
%       - .model_files
%       - .model_EPSG
%       - .use_min_max_range (if true, also supply min_diff & max_diff, this
%                            will include the min and max values on top of
%                            the most-likely/median model result)
%       - .most_likely_run   (indice of the run (from model-files) that
%                            needs to be used as the most-likely result)
%   Provide the following .keywords if from_model = false:
%       - most_likely_diff
%       - min_diff
%       - max_diff
%
%   <<<data.model_name>>>
%   Either 'Unibest CL+', 'Delft3D 4', 'XBeach', 'Data' or 'Landboundaries'
%
%   <<<data.model_files>>>
%   Use multiple files to refer to multiple model output files that include
%   output ranges. Note that the type should be trim-*.dat for Delft3D 4,
%   *.PRN for Unibest CL+, *.??? for XBeach, *.mat for Data (max. 1 file)
%   and *.ldb for Landboundaries.
%   Note: the first landboundary is used as a reference line for the others!
%   Correct format is a cellstring: {'file_1','file_2','file_3','file_4'}.
%
%   <<<data.model_EPSG>>>
%   The coordinate system of the model, it will automatically convert the
%   output to the coastline system if needed
%
%   <<<data.most_likely_run>>>
%   Indice of the run that needs to be considered as the most-likely
%   (default) computation. Leave this empty ([]) to find just use the median
%
%   <<<data.use_min_max_range>>>
%   In case the use_min_max_range is true the most-likely model result will
%   be used, and the uncertainties added as min and max differences
%
%   <<<data.most_likely_diff>>>
%   Most-likely differences. W.r.t. the reference coastline (negative is erosion!)
%   Can also be specified in [XYZ] data, such that it will be interpolated!
%
%   <<<data.min_diff>>>
%   Min. differences. W.r.t. the most-likely result, so must be negative!
%   Can also be specified in [XYZ] data, such that it will be interpolated!
%
%   <<<data.max_diff>>>
%   Max. differences. W.r.t. the most-likely result, so must be positive!
%   Can also be specified in [XYZ] data, such that it will be interpolated!
%
%   <<<data.set_model_time>>>
%   By default, the coastline difference from model results is determined
%   by the difference between the initial (1) and last (end) indice of the
%   model results. Turning this switch to true will allow the user to
%   select a time indice from a list of time-points in the model results.
%   This option only works for model_name 'Delft3D 4' and 'Unibest' and
%   will be ignored for other models. Alternatively, one can simply set the
%   indices in this keyword, e.g. data(3).set_model_time = [1 165]; The
%   indices will be checked according to the size of the model dataset.
%
%   <<<data.set_model_vert_level>>>
%   By default, the coastline is defined at the 0-line, in case you want to
%   change this, set the vertical z-level in this keyword. This option only
%   works for the model_name 'Delft3D 4' and will be ignored for others.
%   Note that if you specify 2 values (e.g. [-1 1] or [-2 2]) the tool will
%   automatically do a MCL (Momentary Coast Line) analysis. In this
%   analysis, the sediment volume in between the 2 supplied contour lines
%   is used to determine the position of the coastline (the 'MCL')
%
% (3) settings: the settings structure consists of the fields:
%
%   <<<settings.combined_fig>>>
%   To include all different models/data in a single figure
%
%   <<<settings.cumulative_results>>>
%   Turns model results relative to earlier model results, note that the
%   model order (in data) is now relevant! Uncertainties are now
%   effectively shown cumulatively!
%
%   <<<settings.filled_LDB>>>
%   Plot the landboundary filled or not (*.ldb should fit this functionality)
%   Note that if you also provide a background image (in settings.background_image)
%   this keyword will be ignored for spatial aggregation plots. It is
%   advised (for the sake of visibility) to have this keyword set to true
%   at all times (again given that your *.ldb fits this functionality, you
%   can make sure this is the case using the function ldbTool())
%
%   <<<settings.x_lims>>>
%   X-limits of the plot, keep empty to determine automatically (result-based)
%
%   <<<settings.y_lims>>>
%   Y-limits of the plot, keep empty to determine automatically (result-based)
%
%   <<<settings.plot_factor>>>
%   Multiplies the coastline changes with a factor (only for visualisation
%   purposes in spatial plots)
%
%   <<<settings.background_image>>>
%   Provide a background image (jpg, epg, bmp, tif, png or gif)
%   Must be in the same coordinate system as the coastline!
%   Can be converted with help of e.g. QGIS, & created with DelftDashboard
%
%   <<<settings.background_world_file>>>
%   World-file associated with the background image
%   Must be in the same coordinate system as the coastline!
%   Can be converted with help of e.g. QGIS, & created with DelftDashboard
%
%   <<<settings.output_folder>>>
%   Output folder, this is where figures are stored (if save_to_file =
%   true), where output *.mat files are stored (if save_mat_files = true)
%   and where *.kml files are stored (if save_kml_files = true).
%
%   <<<settings.save_figures_to_file>>>
%   Switch to turn on exporting of figures to (*.png) files
%
%   <<<settings.save_mat_files>>>
%   Switch to turn on exporting of data (*.mat) files
%
%   <<<settings.save_kml_files>>>
%   Switch to turn on exporting of results to Google Earth (*.kml) files.
%   The results are combined in a single (*.kml) file
%
%   <<<settings.diff_indices>>>
%   Allows users to turn on the creation of both difference data & plots.
%   The data/plots to be created are based on the provided indices within
%   the keyword 'settings.diff_indices' and must obey the following format:
%      settings.diff_indices = [1 2;
%                               1 3;
%                               5 4];
%   In this case, data/model #1 is compared to #2, #2 with #3 & #5 with #4.
%   If the 2nd models feature more erosion, the resulting most-likely
%   result is negative. So if the most-likely result is positive, more
%   accretion has occured within the 2nd model, w.r.t. the 1st model.
%   The changes in differences between min and max w.r.t. the most-likely 
%   results are also provided. This means that if the min or max result is
%   positive, the uncertainty band has widened (w.r.t. the most-likely
%   result). So if the uncertainty band decreased in size (on either side),
%   the min and max values are negative.
%   This keyword is tightly coupled to:
%      settings.save_figures_to_file --> saves difference figures if true
%      settings.save_mat_files       --> saves diff data to *.mat file(s)
%   It is strongly advised to set the keyword settings.cumulative_results
%   to false when using this keyword (unless you really know what it does)
%   
%   <<<settings.show_splash>>>
%   When set to true (false by default) an EPIC splash screen is shown when
%   running this function
%
%   <<<settings.file_suffix>>>
%   When saving figures, kml's or data to a file, a default file-name is
%   used (based on the aggregation). A suffix can be added to these
%   filenames by using the keyword settings.file_suffix. By default, this
%   is '' (example: settings.file_suffix = '_run2_test').
%
% see also landboundary, readPRN, qpread

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

% TODO
%
% - Development of an interactive GUI
%


%% Handle input of the script

% Make sure that have all sub-routines available:
m_path = mfilename('fullpath'); addpath(genpath(m_path(1,1:max(strfind(m_path,filesep))-1)));

plot_types  = {'lines','shades','bars'};
model_types = {'Delft3D 4','Unibest CL+','XBeach','Data','Landboundaries'};

if nargin ~= 0 && nargin ~= 3
    error('Incorrect number of input structures, should be 3!');
elseif nargin == 0
    % We provide the user with example structures:
    
    [example_input.coastline example_input.data example_input.settings] = aggregation_set_default_input(2,plot_types,model_types);
    
    % Make some modifications for the example:
    example_input.coastline.structure_inds  = {[219:237],[264:309]};
    example_input.coastline.ignore_inds     = {[1:219],[309:321],[325:371]};
    example_input.coastline.EPSG            = 28992;

    example_input.data(1).name              = 'Long-term trends (Unibest CL+)';
    example_input.data(1).color             = [0 0 1];
    example_input.data(1).from_model        = true;
    example_input.data(1).model_name        = 'Unibest CL+';
    example_input.data(1).model_files       = {'default_model.PRN','uncertain_model_1.PRN','uncertain_model_2.PRN','uncertain_model_3.PRN','uncertain_model_4.PRN','uncertain_model_5.PRN','uncertain_model_6.PRN'};
    example_input.data(1).model_EPSG        = 28992;
    example_input.data(1).most_likely_run   = 1;

    example_input.data(2).name              = 'Natural variability due to bar dynamics (spatially varying)';
    example_input.data(2).plot_type         = plot_types{2};
    example_input.data(2).color             = [1 0 0];
    example_input.data(2).use_min_max_range = true;
    example_input.data(2).most_likely_run   = -20;
    example_input.data(2).most_likely_diff  = 0;
    example_input.data(2).min_diff          = -20; % Should be negative
    example_input.data(2).max_diff          = [123456 123456 80;
                                               234567 234567 10;
                                               345678 345678 100];

    example_input.settings.combined_fig          = true;
    example_input.settings.background_image      = 'some_image.jpg';
    example_input.settings.background_world_file = 'some_image.jgw';
    example_input.settings.output_folder         = 'some_folder';
    example_input.settings.save_figures_to_file  = true;
    example_input.settings.save_mat_files        = true;
    example_input.settings.diff_indices          = [2 1];
    example_input.settings.show_splash           = false;
    
    % Make sure the output is stored, no matter how many output variables
    % are requested (0-Inf)
    varargout{1} = example_input;
    if nargout == 2
        varargout{2} = '...';
    elseif nargout > 2
        for ii=1:nargout
            if ii == 1
                varargout{1} = example_input.coastline;
            elseif ii == 2
                varargout{2} = example_input.data;
            elseif ii == 3
                varargout{3} = example_input.settings;
            else
                varargout{ii} = '...no data...';
            end
        end
    end
    
    return
    
else
    % Now, 3 arguments are provided, let's set some defaults and fill the data:
    [coastline data settings additional_allowed_parameters] = aggregation_set_default_input(length(data_user_input),plot_types,model_types);
    for ii = ['coastline_user_input',cellstr([repmat('data_user_input(',length(data_user_input),1) num2str([1:length(data_user_input)]') repmat(')',length(data_user_input),1)])','settings_user_input'];
        for jj = fieldnames(eval(ii{:}))'
            if isfield(eval(strrep(ii{:},'_user_input','')),jj{:})
                eval([strrep(ii{:},'_user_input','') '.' jj{:} ' = ' ii{:} '.' jj{:} ';']);
            elseif ~isempty(find(cellfun(@isempty,strfind(additional_allowed_parameters,jj{:})) == 0))
                % This additional parameter is allowed:
                eval([strrep(ii{:},'_user_input','') '.' jj{:} ' = ' ii{:} '.' jj{:} ';']);
            else
                error(['Fieldname ' ii{:} '.' jj{:} ' does not exist, please check your input'])
            end
        end
    end
    
    % Check the input
    [coastline,data,settings] = aggregation_check_input(coastline,data,settings,plot_types,model_types);
    load('EPSG.mat','coordinate_reference_system');
    
end

%% Continue all the scripting that needs to be done
%

close(findall(0,'tag','ACDC_splash_screen'));
if settings.show_splash
    m_file = mfilename('fullpath'); splash_img = imread([m_file(1,1:max(strfind(m_file,filesep))) 'ACDC_tool.png']);
    splash_screen = figure; set(splash_screen,'menubar','none','toolbar','none','Tag','ACDC_splash_screen','color','w');
    axis tight;
    imshow(splash_img); set(gca,'Position',[0 0 1 1]); ss = get(0,'ScreenSize'); ss = ss(3:4);
    set(splash_screen,'position',[(ss./2)-([size(splash_img,2)./2 size(splash_img,1)./2]./2) size(splash_img,2)./2 (size(splash_img,1)./2)-18],'NumberTitle','off','Name','ACDC is running...');
    remove_figure_frame(splash_screen);
    hold on; plot([get(gca,'xlim') fliplr(get(gca,'xlim')) min(get(gca,'xlim'))],[min(get(gca,'ylim')) get(gca,'ylim') fliplr(get(gca,'ylim'))],'k'); drawnow;
end

% Now let's make a vector that we can use as the offshore direction
coastline = aggregation_coastline_orientation(coastline);

% Loop through the different sources of data/model output, and convert it
% to a relative coastline change:

loaded_diff_data = {}; % To store loaded diff data

for ii=1:length(data)
    plot_fig_inds(ii) = true;
    disp(['Handling model/data set no. ' num2str(ii) ': ' data(ii).name ':']);
    % Make sure that we have the correct format for most_likely, min and max values:
    for model_output_type = {'most_likely','min','max'}
        % true/false statements for 1 value or multiple
        eval(['tf_statement_1 = size(data(ii).' model_output_type{:} '_diff,1)==1 & size(data(ii).' model_output_type{:} '_diff,2) == 1;']);
        eval(['tf_statement_2 = size(data(ii).' model_output_type{:} '_diff,1)>1 & size(data(ii).' model_output_type{:} '_diff,2) == 3;']);
        if tf_statement_1
            % Single value for this diff type:
            eval(['coastline_changes(ii).' model_output_type{:} ' = repmat(data(ii).' model_output_type{:} '_diff,size(coastline.offshore_orientation));']);
            % Make sure the NaN values are included:
            eval(['coastline_changes(ii).' model_output_type{:} '(isnan(coastline.offshore_orientation)) = NaN;']);
        elseif tf_statement_2
            % Defined on a xy-value line
            eval(['[tmp_ldb, tmp_ldb_inds] = add_equidist_points(1,data(ii).' model_output_type{:} '_diff(:,1:2),''equi''); tmp_ldb = tmp_ldb(2:end-1,:); tmp_ldb_inds = tmp_ldb_inds-1;']);
            eval(['tmp_ldb(:,3) = interp1([0; cumsum(sqrt(sum(diff(data(ii).' model_output_type{:} '_diff(:,1:2)).^2,2)))],data(ii).' model_output_type{:} '_diff(:,3),[0; cumsum(sqrt(sum(diff(tmp_ldb(:,1:2)).^2,2)))]);']);
            eval(['tmp_ldb(tmp_ldb_inds,3) = data(ii).' model_output_type{:} '_diff(:,3);']);

            eval(['coastline_changes(ii).' model_output_type{:} ' = nan(size(coastline.offshore_orientation));']);

            for kk=find(isnan(coastline.offshore_orientation)==0)'

                % Cross-shore axis for this coastline point
                dist_dx = 1;
                dist_ax = [-1000:1000];
                dist_x = coastline.ldb(kk,1) + (dist_ax.*sind(coastline.offshore_orientation(kk)));
                dist_y = coastline.ldb(kk,2) + (dist_ax.*cosd(coastline.offshore_orientation(kk)));

                % Determine distance
                smaller  = 1; ind = ((length(dist_ax)+1)/2); addition = 1;
                old_dist = min(sqrt(((tmp_ldb(:,1) - dist_x(ind)).^2)+((tmp_ldb(:,2) - dist_y(ind)).^2)));
                ind      = ind + addition;
                new_dist = min(sqrt(((tmp_ldb(:,1) - dist_x(ind)).^2)+((tmp_ldb(:,2) - dist_y(ind)).^2)));
                if new_dist > old_dist
                    addition = -1;
                end
                while smaller == 1
                    old_dist = new_dist;
                    ind      = ind + addition;
                    if ind < 1 || ind > length(dist_x)
                        break
                    end
                    new_dist = min(sqrt(((tmp_ldb(:,1) - dist_x(ind)).^2)+((tmp_ldb(:,2) - dist_y(ind)).^2)));
                    if new_dist>old_dist
                        ind = ind - addition;
                        smaller = 0;
                    end
                end

                if old_dist < dist_dx
                    eval(['coastline_changes(ii).' model_output_type{:} '(kk) = tmp_ldb(find(sqrt(((tmp_ldb(:,1) - dist_x(ind)).^2)+((tmp_ldb(:,2) - dist_y(ind)).^2)) == min(sqrt(((tmp_ldb(:,1) - dist_x(ind)).^2)+((tmp_ldb(:,2) - dist_y(ind)).^2)))),3);']);
                end
            end
        end
    end
    
    if data(ii).use_min_max_range
        if ~isempty(find(coastline_changes(ii).min>0))
            error(['Note that the provided minimal coastline changes w.r.t. the most likely result are positive, this is not possible']);
        end
        if ~isempty(find(coastline_changes(ii).max<0))
            error(['Note that the provided maximum coastline changes w.r.t. the most likely result are negative, this is not possible']);
        end
    end
    
    if data(ii).from_model == false
        
        disp(['   Setting custom supplied ranges']);
        
        if data(ii).use_min_max_range
            coastline_changes(ii).min = coastline_changes(ii).most_likely + coastline_changes(ii).min;
            coastline_changes(ii).max = coastline_changes(ii).most_likely + coastline_changes(ii).max;
        else
            coastline_changes(ii).min = coastline_changes(ii).most_likely;
            coastline_changes(ii).max = coastline_changes(ii).most_likely;
        end
        
        if settings.save_mat_files
            % Save the data to a *.mat-file for later use:
            clear saved_data;
            saved_data.coastline         = coastline;
            saved_data.coastline_changes = coastline_changes(ii);
            saved_data.data              = data(ii);
            saved_data.settings          = settings;
            saved_data.type              = 'single_model_data_storage';
            saved_data.explanation       = {['This file contains information on the range of coastline changes for:'];
                                            [saved_data.data.name];
                                            ['It contains a most likely, min and max. result, relative to a coastline'];
                                            ['These values have been manually defined (not based on a model or datset)'];
                                            ['Min. indicates the largest retreat/least accretion and max. indicates the least retreat/largest accretion'];
                                            ['The data is mapped w.r.t. the coastline in .coastline.ldb_file, negative indicates erosion'];};
            if exist([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']) ~= 7
                mkdir([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']);
            end
            save([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files' filesep 'data_file_for_custom_range_'  datestr(now,'yyyymmdd_HHMMSS') settings.file_suffix],'saved_data','-v7.3');
        end
        
    elseif data(ii).from_model == true
        convert_cl_changes_to_coastline_changes = true;
        cl_changes = [];
        % We need to find the coastline change from a model:
        switch data(ii).model_name
            case 'Data'
                if length(data(ii).model_files)>1
                    error(['More than 1 output *.mat file is provided for the model ''' data(ii).name ''', please check this!']);
                end
                
                disp(['   Loading previously saved data file']);
                load(data(ii).model_files{1});
                
                if (length(coastline.offshore_orientation) ~= length(saved_data.coastline.offshore_orientation))
                    error(['It appears that the *.ldb coastline file has changed w.r.t. the used output mat-file, please check this!']);
                elseif ~strcmp(coastline.ldb_file(1,max(strfind(coastline.ldb_file,filesep))+1:end),saved_data.coastline.ldb_file(1,max(strfind(saved_data.coastline.ldb_file,filesep))+1:end))
                    disp(['LDB-filename changed, but number of points is still identical, please verify this!']);
                end

                convert_cl_changes_to_coastline_changes = false;
                
            case 'Delft3D 4'
                for jj=1:length(data(ii).model_files)
                    % Script that obtains the coastlines:
                    if jj == 1
                        d3d_varargin = aggregation_make_d3d_varargin_and_check_times(data(ii));
                    end
                    disp(['   Loading and handling "' data(ii).model_name '" files: ' num2str(jj) ' out of ' num2str(length(data(ii).model_files))]);
                    eval(['[c_ini c_end] = aggregation_get_coastline_Delft3D_4(data(ii).model_files{jj}' d3d_varargin ');'])
                    % Convert coordinate systems if needed:
                    for c_ind = 1:length(c_ini)
                        if ~isempty(data(ii).model_EPSG)
                            if data(ii).model_EPSG ~= coastline.EPSG
                                [c_ini{c_ind}(:,1),c_ini{c_ind}(:,2)] = convertCoordinates(c_ini{c_ind}(:,1),c_ini{c_ind}(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                                [c_end{c_ind}(:,1),c_end{c_ind}(:,2)] = convertCoordinates(c_end{c_ind}(:,1),c_end{c_ind}(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                            end
                        end
                        % Refine the data:
                        c_ini{c_ind} = add_equidist_points(1,c_ini{c_ind},'equi'); c_ini{c_ind} = c_ini{c_ind}(2:end-1,:);
                        c_end{c_ind} = add_equidist_points(1,c_end{c_ind},'equi'); c_end{c_ind} = c_end{c_ind}(2:end-1,:);
                    end
                    if length(c_ini) == 1
                        % Simple contour approach:
                        c_ini = c_ini{1};
                        c_end = c_end{1};
                    elseif length(c_ini) == 2
                        % MKL approach:
                        eval(['[c_ini c_end] = aggregation_MKL_for_Delft3D_4(data(ii).model_files{jj},c_ini,c_end,coastline.ldb,coastline.offshore_orientation' d3d_varargin ');']);
                    end
                    % Now get the differences w.r.t. the landboundary
                    [ini_dist end_dist] = aggretation_cl_change_wrt_ldb(coastline.ldb,coastline.offshore_orientation,c_ini,c_end);
                    % And make it relative:
                    cl_changes(:,jj) = end_dist - ini_dist;
                end
            case 'Unibest CL+'
                for jj=1:length(data(ii).model_files)
                    if jj == 1
                        unibest_varargin = aggregation_make_unibest_varargin_and_check_times(data(ii));
                    end
                    disp(['   Loading and handling "' data(ii).model_name '" files: ' num2str(jj) ' out of ' num2str(length(data(ii).model_files))]);
                    % Script that obtains the coastlines:
                    eval(['[c_ini c_end] = aggregation_get_coastline_Unibest_CL(data(ii).model_files{jj}' unibest_varargin ');']);
                    % Convert coordinate systems if needed:
                    if ~isempty(data(ii).model_EPSG)
                        if data(ii).model_EPSG ~= coastline.EPSG
                            [c_ini(:,1),c_ini(:,2)] = convertCoordinates(c_ini(:,1),c_ini(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                            [c_end(:,1),c_end(:,2)] = convertCoordinates(c_end(:,1),c_end(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                        end
                    end
                    % Refine the data:
                    c_ini = add_equidist_points(1,c_ini,'equi'); c_ini = c_ini(2:end-1,:);
                    c_end = add_equidist_points(1,c_end,'equi'); c_end = c_end(2:end-1,:);
                    % Now get the differences w.r.t. the landboundary
                    [ini_dist end_dist] = aggretation_cl_change_wrt_ldb(coastline.ldb,coastline.offshore_orientation,c_ini,c_end);
                    % And make it relative:
                    cl_changes(:,jj) = end_dist - ini_dist;
                end
            case 'Landboundaries'
                % The first ldb is the reference line here:
                if length(data(ii).model_files)<2
                    error('Model type ''Landboundaries'' requires at least 2 ldb''s, a reference line (1st ldb) and results w.r.t. that line');
                end
                % Correct for the fact that we're running from indice 2
                % untill end, due to the reference ldb in the first indice:
                data(ii).most_likely_run = data(ii).most_likely_run-1;
                ref_ldb = data(ii).model_files{1};
                data(ii).model_files = data(ii).model_files(2:end);
                for jj=1:length(data(ii).model_files)
                    disp(['   Loading and handling "' data(ii).model_name '" files: ' num2str(jj) ' out of ' num2str(length(data(ii).model_files))]);
                    % Obtain the 'start' and 'end' coastlines:
                    c_ini_tmp = landboundary('read',ref_ldb);
                    c_end_tmp = landboundary('read',data(ii).model_files{jj});
                    % Convert coordinate systems if needed:
                    if ~isempty(data(ii).model_EPSG)
                        if data(ii).model_EPSG ~= coastline.EPSG
                            [c_ini_tmp(:,1),c_ini_tmp(:,2)] = convertCoordinates(c_ini_tmp(:,1),c_ini_tmp(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                            [c_end_tmp(:,1),c_end_tmp(:,2)] = convertCoordinates(c_end_tmp(:,1),c_end_tmp(:,2),'CS1.code',data(ii).model_EPSG,'CS2.code',coastline.EPSG);
                        end
                    end
                    % Refine the data:
                    c_ini = add_equidist_points(1,c_ini_tmp,'equi'); c_ini = c_ini(2:end-1,:);
                    c_end = add_equidist_points(1,c_end_tmp,'equi'); c_end = c_end(2:end-1,:);
                    % Now get the differences w.r.t. the landboundary
                    [ini_dist end_dist] = aggretation_cl_change_wrt_ldb(coastline.ldb,coastline.offshore_orientation,c_ini,c_end);
                    % And make it relative:
                    cl_changes(:,jj) = end_dist - ini_dist;
                end
            case 'XBeach'
                for jj=1:length(data(ii).model_files)
                    disp(['   Loading and handling "' data(ii).model_name '" files: ' num2str(jj) ' out of ' num2str(length(data(ii).model_files))]);
                    disp('    ERROR: XBeach is not yet implemented!!!');
                    % TBD
                end
            otherwise
                error(['Unknown model: ''' data(ii).model_name ''', please read the help'])
        end
        
        if convert_cl_changes_to_coastline_changes
            % Generate the coastline changes if not already loaded:
            coastline_changes(ii).most_likely = median(cl_changes,2);
            if ~isempty(data(ii).most_likely_run)
                coastline_changes(ii).most_likely = cl_changes(:,data(ii).most_likely_run);
            end
            if data(ii).use_min_max_range
                coastline_changes(ii).min = coastline_changes(ii).most_likely + coastline_changes(ii).min;
                coastline_changes(ii).max = coastline_changes(ii).most_likely + coastline_changes(ii).max;
            else
                coastline_changes(ii).min = min(cl_changes,[],2);
                coastline_changes(ii).max = max(cl_changes,[],2);
            end
            
            if settings.save_mat_files
                % Save the data to a *.mat-file for later use:
                clear saved_data;
                saved_data.coastline         = coastline;
                saved_data.coastline_changes = coastline_changes(ii);
                saved_data.data              = data(ii);
                saved_data.settings          = settings;
                saved_data.type              = 'single_model_data_storage';
                if isempty(saved_data.data.most_likely_run)
                    ml_text = ['on the median of all results (from .data.model_files)'];
                else
                    ml_text = ['on model/data #' num2str(saved_data.data.most_likely_run) ' (from .data.model_files)'];
                end
                saved_data.explanation       = {['This file contains information on the range of coastline changes for:'];
                                                [saved_data.data.name];
                                                ['It contains a most likely, min and max. result, relative to a coastline'];
                                                ['The most likely result is based ' ml_text];
                                                ['while min. is the largest retreat/least accretion and max. is the least retreat/largest accretion'];
                                                ['The data is mapped w.r.t. the coastline in .coastline.ldb_file, negative indicates erosion'];};
                if exist([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']) ~= 7
                    mkdir([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']);
                end
                save([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files' filesep 'data_file_for_' num2str(length(data(ii).model_files)) '_' strrep(strrep([data(ii).model_name '_models_'],' ','_'),'+','') datestr(now,'yyyymmdd_HHMMSS') settings.file_suffix],'saved_data','-v7.3');
            end
            
        else
            if strcmp(saved_data.type,'single_model_data_storage')
                % Pre-loaded single model/data result:
                coastline_changes(ii) = saved_data.coastline_changes;
            elseif strcmp(saved_data.type,'difference_data_model_storage')
                % This is relative data, so we feed the default datastream
                % with zero's to avoid cumulative effects we don't want:
                coastline_changes(ii).most_likely = zeros(size(saved_data.coastline_changes.most_likely));
                coastline_changes(ii).min         = zeros(size(saved_data.coastline_changes.min));
                coastline_changes(ii).max         = zeros(size(saved_data.coastline_changes.max));
                
                plot_fig_inds(ii) = false;
                
                loaded_diff_data{end+1,1} = saved_data;
                
            end
            
        end
        
    end
    
    if settings.cumulative_results & ii>1
        coastline_changes(ii).most_likely = coastline_changes(ii).most_likely + coastline_changes(ii-1).most_likely;
        coastline_changes(ii).min         = coastline_changes(ii).min + coastline_changes(ii-1).min;
        coastline_changes(ii).max         = coastline_changes(ii).max + coastline_changes(ii-1).max;
    end
    
end
disp(' ');
disp('Done handling data');


%% Create the requested figure(s)
%

clear hand leg_text

leg_text = {}; x_lims_comb = [Inf -Inf]; y_lims_comb = [Inf -Inf];
for ii=find(plot_fig_inds)
    
    % Set your shades here, on a scale from 0 to 1 (0 is not visible, 1 is fully filled):
    shade_alpha = [0.5 0];
    
    if ii==min(find(plot_fig_inds)) || ~settings.combined_fig
        figure; set(gcf,'color','w','invertHardcopy','off','position',[9 48 1903 949],'NumberTitle','off','Tag',['Spatial plot ' num2str(find(find(plot_fig_inds) == ii))]); hold on;
        if ~isempty(settings.background_image)
            plotGeoImage(settings.background_image,settings.background_world_file); view(2);
        end
        if settings.filled_LDB && isempty(settings.background_image)
            filledLDB(coastline.ldb,'k',[34 139 34]/255);
            set(gca,'color',[198 226 255]/255);
        else
            if settings.filled_LDB && ~isempty(settings.background_image) && ii == 1
                disp(' ');
                disp('   Notification: Ignoring filled landboundary in spatial plots due to the usage of a background (satellite) image');
            end
            plot(coastline.ldb(:,1),coastline.ldb(:,2),'k');
            %plot(coastline.ldb(min(find(~isnan(coastline.offshore_orientation))):max(find(~isnan(coastline.offshore_orientation))),1),coastline.ldb(min(find(~isnan(coastline.offshore_orientation))):max(find(~isnan(coastline.offshore_orientation))),2),'k');
        end
        axis equal; hold on; box on; grid on; set(gca,'layer','top');
        for jj = 1:length(coastline.structure_inds)
            plot(coastline.ldb(coastline.structure_inds{jj},1),coastline.ldb(coastline.structure_inds{jj},2),'k','linewidth',2);
        end
        for jj = 1:length(coastline.ignore_inds)
            plot(coastline.ldb(coastline.ignore_inds{jj},1),coastline.ldb(coastline.ignore_inds{jj},2),'r:','linewidth',1);
        end
       
        if settings.combined_fig & sum(plot_fig_inds)>1
            set(gcf,'Name','Combined aggregation')
            title(['Combined aggregation of ' num2str(sum(plot_fig_inds)) ' models/datasets']);
        else
            set(gcf,'Name',['Aggregation: ' data(ii).name])
            title(['Aggregation of model/dataset: ' data(ii).name]);
        end
        
        xlabel(['X-Coordinate (metre ' coordinate_reference_system.coord_ref_sys_name{find(coordinate_reference_system.coord_ref_sys_code==coastline.EPSG)} ')']);
        ylabel(['Y-Coordinate (metre ' coordinate_reference_system.coord_ref_sys_name{find(coordinate_reference_system.coord_ref_sys_code==coastline.EPSG)} ')']);
%         view(settings.rotation,90)

        figure; set(gcf,'color','w','invertHardcopy','off','position',[9 48 1903 949],'NumberTitle','off','Tag',['Alongshore plot ' num2str(find(find(plot_fig_inds) == ii))]);
        
        part_coastline_used_inds = min(find(~isnan(coastline.offshore_orientation))):max(find(~isnan(coastline.offshore_orientation)));
        part_coastline_used_ldb  = [coastline.ldb(part_coastline_used_inds,1) coastline.ldb(part_coastline_used_inds,2)];
        part_coastline_used_orie = coastline.offshore_orientation(part_coastline_used_inds);
        part_coastline_used_dist = pathdistance(part_coastline_used_ldb(:,1),part_coastline_used_ldb(:,2));
        
        % if x-diff / y-diff:
        if (diff([min(part_coastline_used_ldb(:,1)) max(part_coastline_used_ldb(:,1))]) ./ diff([min(part_coastline_used_ldb(:,2)) max(part_coastline_used_ldb(:,2))])) < 1.5
            % Horizontal scale is much smaller than vertical one
            if settings.combined_fig
                subplot(length(find(plot_fig_inds)),4,1:4:(length(find(plot_fig_inds))*4),'Tag','Map');
                for jj = find(plot_fig_inds)
                    subplot(length(find(plot_fig_inds)),4,(find(find(plot_fig_inds) == jj).*4)+[-2 -1 0],'Tag',['ax_' num2str(find(find(plot_fig_inds) == jj))]);
                end
            else
                subplot(1,4,1,'Tag','Map');
                subplot(1,4,[2:4],'Tag','ax_1');
            end
            layout_location = 'left';
        else
            % Horitontal scale is much larger than vertical one

            if settings.combined_fig
                subplot(length(find(plot_fig_inds))+1,1,1,'Tag','Map');
                for jj = find(plot_fig_inds)
                    subplot(length(find(plot_fig_inds))+1,1,find(find(plot_fig_inds) == jj)+1,'Tag',['ax_' num2str(find(find(plot_fig_inds) == jj))]); 
                end
            else
                subplot(4,1,1,'Tag','Map');
                subplot(4,1,[2:4],'Tag','ax_1');
            end
            layout_location = 'top';
        end
        
        axes(findobj(get(gcf,'Children'),'Tag','Map'));
        
        hold on; axis equal; grid on; box on; set(gca,'layer','top');
        
        if settings.filled_LDB
            filledLDB(coastline.ldb,'k',[34 139 34]/255);
            set(gca,'color',[198 226 255]/255);
        end
        plot(part_coastline_used_ldb(:,1),part_coastline_used_ldb(:,2),'k','linewidth',2);
        
        max_no_pts = 10;
        dist_opts    = sort([1.*10.^[0:10] 2.*10.^[0:10] 5.*10.^[0:10]]);
        sel_dist_opt = dist_opts(min(find((part_coastline_used_dist(end) ./ dist_opts) < 10)));
        dist_steps   = unique([0:sel_dist_opt:part_coastline_used_dist(end) part_coastline_used_dist(end)]);
        dist_cols    = jet(size(dist_steps,2));
        [~,dist_step_inds] = closest(dist_steps,part_coastline_used_dist);
        for jj=1:size(dist_steps,2)
            dist_handle(jj) = plot(part_coastline_used_ldb(dist_step_inds(jj),1),part_coastline_used_ldb(dist_step_inds(jj),2),'o','markersize',10,'Color','k','MarkerFaceColor',dist_cols(jj,:),'linewidth',2);
        end
        leg = legend(dist_handle,[num2str(dist_steps'./1000,'%9.3f') repmat(' km',length(dist_steps),1)]);
        set(get(leg,'Title'),'String','Coastline distance');
        if strcmp(layout_location,'left')
            set(leg,'location','NorthOutside','Orientation','vertical','color','w');
        elseif strcmp(layout_location,'top')
            set(leg,'location','EastOutside','Orientation','vertical','color','w');
        end
        
        if length(coastline.structure_inds) > 0
            struc_lims_x = [min(coastline.ldb(cell2mat(coastline.structure_inds),1)) max(coastline.ldb(cell2mat(coastline.structure_inds),1))];
            struc_lims_y = [min(coastline.ldb(cell2mat(coastline.structure_inds),2)) max(coastline.ldb(cell2mat(coastline.structure_inds),1))];
        else
            struc_lims_x = [Inf -Inf];
            struc_lims_y = [Inf -Inf];
        end
        
        xlim([min([part_coastline_used_ldb(:,1); struc_lims_x(1)])-(0.05.*diff([min([part_coastline_used_ldb(:,1); struc_lims_x(1)]) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])])) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])+(0.05.*diff([min([part_coastline_used_ldb(:,1); struc_lims_x(1)]) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])]))]);
        ylim([min([part_coastline_used_ldb(:,2); struc_lims_y(1)])-(0.05.*diff([min([part_coastline_used_ldb(:,2); struc_lims_y(1)]) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])])) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])+(0.05.*diff([min([part_coastline_used_ldb(:,2); struc_lims_y(1)]) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])]))]);
        
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        
        arrow_ind = min(find(cumsum(~isnan(part_coastline_used_orie)) == round(sum(~isnan(part_coastline_used_orie))./2)));
        
        if ~settings.filled_LDB
            offshore_arrow_start = [part_coastline_used_ldb(arrow_ind,1) part_coastline_used_ldb(arrow_ind,2)];
            offshore_arrow_end   = offshore_arrow_start + ((0.1.*max(part_coastline_used_dist)) .* [cosd(part_coastline_used_orie(arrow_ind)) sind(part_coastline_used_orie(arrow_ind))]);
            land_arrow_start     = [part_coastline_used_ldb(arrow_ind,1) part_coastline_used_ldb(arrow_ind,2)];
            land_arrow_end       = land_arrow_start + ((0.1.*max(part_coastline_used_dist)) .* [cosd(part_coastline_used_orie(arrow_ind)+180) sind(part_coastline_used_orie(arrow_ind)+180)]);

            arrow_thick(offshore_arrow_start(1),offshore_arrow_start(2),offshore_arrow_end(1),offshore_arrow_end(2),'plot_color',[198 226 255]/255,'axis_equal',false,'max_arrowhead_angle',90);
            arrow_thick(land_arrow_start(1),land_arrow_start(2),land_arrow_end(1),land_arrow_end(2),'plot_color',[34 139 34]/255,'axis_equal',false,'max_arrowhead_angle',90);
            if part_coastline_used_orie(arrow_ind) < 180
                text(offshore_arrow_end(1),offshore_arrow_end(2),' Offshore direction');
                text(land_arrow_end(1),land_arrow_end(2),'Land direction ','horizontalalignment','right');
            else
                text(offshore_arrow_end(1),offshore_arrow_end(2),'Offshore direction ','horizontalalignment','right');
                text(land_arrow_end(1),land_arrow_end(2),' Land direction');
            end
        end
    end
    
    coastline_results.most_likely = [coastline.ldb(:,1) + settings.plot_factor .* (coastline_changes(ii).most_likely .* sind(coastline.offshore_orientation)) coastline.ldb(:,2) + settings.plot_factor .* (coastline_changes(ii).most_likely .* cosd(coastline.offshore_orientation))];
    coastline_results.min  = [coastline.ldb(:,1) + settings.plot_factor .* (coastline_changes(ii).min .* sind(coastline.offshore_orientation)) coastline.ldb(:,2) + settings.plot_factor .* (coastline_changes(ii).min .* cosd(coastline.offshore_orientation))];
    coastline_results.max  = [coastline.ldb(:,1) + settings.plot_factor .* (coastline_changes(ii).max .* sind(coastline.offshore_orientation)) coastline.ldb(:,2) + settings.plot_factor .* (coastline_changes(ii).max .* cosd(coastline.offshore_orientation))];
    
    if settings.combined_fig
        figure(findobj(get(0,'children'),'Tag',['Spatial plot 1']));
    else
        figure(findobj(get(0,'children'),'Tag',['Spatial plot ' num2str(find(find(plot_fig_inds) == ii))]))
    end
    
    if strcmp(data(ii).plot_type,'lines')
        hand(ii,1) = plot(coastline_results.most_likely(:,1),coastline_results.most_likely(:,2),'color',data(ii).color,'linewidth',0.5);
        plot(coastline_results.min(:,1),coastline_results.min(:,2),'k--','color',data(ii).color,'linewidth',0.5);
        plot(coastline_results.max(:,1),coastline_results.max(:,2),'k--','color',data(ii).color,'linewidth',0.5);
    elseif strcmp(data(ii).plot_type,'shades')
        nan_inds = find(isnan(coastline_results.most_likely(:,1)));
        val_inds = [nan_inds(find(diff(nan_inds)~=1))+1 nan_inds(1+find(diff(nan_inds)~=1))-1];
        for jj=1:size(val_inds,1)
            inds = val_inds(jj,1):val_inds(jj,2);
            hand(ii,jj) = patch('Faces',[1:2.*size(inds,2); 1:size(inds,2) 2.*size(inds,2)+1:3.*size(inds,2)],'Vertices',[coastline_results.most_likely(inds,:); coastline_results.max(fliplr(inds),:); coastline_results.min(fliplr(inds),:); NaN NaN],'FaceColor',data(ii).color,'FaceVertexAlphaData',[shade_alpha(1).*ones(size(inds,2),1); shade_alpha(2).*ones(2.*size(inds,2),1); 1],'FaceAlpha','interp','linestyle','none');
            plot(coastline_results.most_likely(inds,1),coastline_results.most_likely(inds,2),'color',data(ii).color,'linewidth',0.1);
            plot(coastline_results.min(inds,1),coastline_results.min(inds,2),'k--','color',data(ii).color,'linewidth',0.1);
            plot(coastline_results.max(inds,1),coastline_results.max(inds,2),'k--','color',data(ii).color,'linewidth',0.1);
        end
        
    elseif strcmp(data(ii).plot_type,'bars')
        disp('Bar plots are not yet operational, nothing plotted')
    end
    
    if settings.save_kml_files
        if ii == 1
            [wgs_cst(:,1) wgs_cst(:,2)] = convertCoordinates(coastline.ldb(:,1),coastline.ldb(:,2),'CS1.code',coastline.EPSG,'CS2.code',4326);
            kml_files = {}; kml_folders = {};
        else
            wgs_mol = []; wgs_min = []; wgs_max = [];
        end
        [wgs_mol(:,1) wgs_mol(:,2)] = convertCoordinates(coastline_results.most_likely(:,1),coastline_results.most_likely(:,2),'CS1.code',coastline.EPSG,'CS2.code',4326);
        [wgs_min(:,1) wgs_min(:,2)] = convertCoordinates(coastline_results.min(:,1),coastline_results.min(:,2),'CS1.code',coastline.EPSG,'CS2.code',4326);
        [wgs_max(:,1) wgs_max(:,2)] = convertCoordinates(coastline_results.max(:,1),coastline_results.max(:,2),'CS1.code',coastline.EPSG,'CS2.code',4326);
        
        f_name  = ['model_' num2str(ii) strrep(['_-_' strrep(matlab.lang.makeValidName(strrep([data(ii).name],' ','_')),'__','_') '_'],'__','_')];
        f_name2 = [strrep([strrep(matlab.lang.makeValidName(strrep([data(ii).name],' ','_')),'__','_') '_'],'__','_')];
        if exist([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth']) ~= 7
            mkdir([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth'])
        end
        if ii == 1
            kml_files{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep 'reference_coastline' settings.file_suffix '.kml'];
            kml_folders{end+1} = ['Reference coastline'];
            KMLline(wgs_cst(:,2),wgs_cst(:,1),'fileName',kml_files{end},'lineColor',[0 0 0],'name',kml_folders{end},'lineWidth',5);
        end
        kml_files{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name 'mol' settings.file_suffix '.kml'];
        kml_folders{end+1} = [data(ii).name ' - Most likely result'];
        KMLline(wgs_mol(:,2),wgs_mol(:,1),'fileName',kml_files{end},'lineColor',data(ii).color,'name',kml_folders{end},'lineWidth',5);
        kml_files{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name 'min' settings.file_suffix '.kml'];
        kml_folders{end+1} = [data(ii).name ' - Minimum result'];
        KMLline(wgs_min(:,2),wgs_min(:,1),'fileName',kml_files{end},'lineColor',data(ii).color,'name',kml_folders{end},'lineWidth',2);
        kml_files{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name 'max' settings.file_suffix '.kml'];
        kml_folders{end+1} = [data(ii).name ' - Maximum result'];
        KMLline(wgs_max(:,2),wgs_max(:,1),'fileName',kml_files{end},'lineColor',data(ii).color,'name',kml_folders{end},'lineWidth',2);
        
        if strcmp(data(ii).plot_type,'shades')
            
            kml_files_sh = {};
            kml_folders_sh = {};
            
            kml_files{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name2 'shades' settings.file_suffix '.kml'];
            kml_folders{end+1} = [data(ii).name ' - Shade'];
            
            nan_inds = find(isnan(wgs_mol(:,1)));
            val_inds = [nan_inds(find(diff(nan_inds)~=1))+1 nan_inds(1+find(diff(nan_inds)~=1))-1];
            
            for jj=1:size(val_inds,1)
                inds = val_inds(jj,1):val_inds(jj,2);
                
                kml_files_sh{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name 'min_shade_' num2str(jj) settings.file_suffix '.kml'];
                kml_folders_sh{end+1} = [data(ii).name ' - Minimum shade ' num2str(jj)];
                KMLpatch([wgs_mol(inds,2); wgs_min(fliplr(inds),2)],[wgs_mol(inds,1); wgs_min(fliplr(inds),1)],'fileName',kml_files_sh{end},'fillColor',data(ii).color,'name','','fillAlpha',shade_alpha(1),'timeIn',[],'timeOut',[]);
                
                kml_files_sh{end+1} = [strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep f_name 'max_shade_' num2str(jj) settings.file_suffix '.kml'];
                kml_folders_sh{end+1} = [data(ii).name ' - Maximum shade ' num2str(jj)];
                KMLpatch([wgs_mol(inds,2); wgs_max(fliplr(inds),2)],[wgs_mol(inds,1); wgs_max(fliplr(inds),1)],'fileName',kml_files_sh{end},'fillColor',data(ii).color,'name','','fillAlpha',shade_alpha(1),'timeIn',[],'timeOut',[]);
            end
            
            KMLmerge_files('sourceFiles',kml_files_sh,'fileName',kml_files{end},'foldernames','');
            delete(kml_files_sh{:});
        end
        
        if ii == length(coastline_changes)
            % All KML-files are created, let's combine them:
            if ii == 1
                KMLmerge_files('sourceFiles',kml_files,'fileName',[strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep datestr(now,'yyyymmdd') strrep(['_' strrep(matlab.lang.makeValidName(strrep(data(ii).name,' ','_')),'__','_') '_'],'__','_') 'combined' settings.file_suffix '.kml'],'foldernames',kml_folders);
            else
                KMLmerge_files('sourceFiles',kml_files,'fileName',[strrep([settings.output_folder filesep],[filesep filesep], filesep) 'Google_Earth' filesep datestr(now,'yyyymmdd') '_combined_aggregation_of_' num2str(length(coastline_changes)) '_models_and_datasets' settings.file_suffix '.kml'],'foldernames',kml_folders);
            end
            delete(kml_files{:});
        end
    end
    
    if isempty(settings.x_lims)
        x_lims = [min([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)])-0.05*diff([min([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)]) max([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)])]) max([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)])+0.05*diff([min([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)]) max([coastline_results.most_likely(:,1); coastline_results.min(:,1); coastline_results.max(:,1)])])];
    else
        x_lims = settings.x_lims;
    end
    if isempty(settings.y_lims)
        y_lims = [min([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)])-0.05*diff([min([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)]) max([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)])]) max([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)])+0.05*diff([min([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)]) max([coastline_results.most_likely(:,2); coastline_results.min(:,2); coastline_results.max(:,2)])])];
    else
        y_lims = settings.y_lims;
    end
    
    if settings.combined_fig
        figure(findobj(get(0,'children'),'Tag',['Alongshore plot 1']));
        axes(findobj(get(gcf,'children'),'Tag',['ax_' num2str(find(find(plot_fig_inds) == ii))])); hold on;
    else
        figure(findobj(get(0,'children'),'Tag',['Alongshore plot ' num2str(find(find(plot_fig_inds) == ii))]));
        axes(findobj(get(gcf,'children'),'Tag','ax_1')); hold on;
    end
    
    plot([part_coastline_used_dist(1) part_coastline_used_dist(end)]./1000,[0 0],'k-.','linewidth',1);
    
    non_nan_inds      = find(~isnan(coastline_changes(ii).most_likely(part_coastline_used_inds)))';
    non_nan_inds_inds = [non_nan_inds([1 find(diff(non_nan_inds)~=1)+1])' non_nan_inds([find(diff(non_nan_inds)~=1) end])'];
    for jj=1:size(non_nan_inds_inds,1)
        
        patch('Vertices',[part_coastline_used_dist([non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2) non_nan_inds_inds(jj,2):-1:non_nan_inds_inds(jj,1)])./1000 [coastline_changes(ii).most_likely(part_coastline_used_inds([non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)])); coastline_changes(ii).min(part_coastline_used_inds([non_nan_inds_inds(jj,2):-1:non_nan_inds_inds(jj,1)]))]; NaN NaN],'Faces',[[1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))-1; 2:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)); 2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))-1:-1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+1; 2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)):-1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+2]';repmat(2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+1,1,4)],'FaceVertexAlphaData',[shade_alpha(1).*ones(1,size(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2),2)) shade_alpha(2).*ones(1,size(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2),2)) 1]','FaceColor',data(ii).color,'FaceAlpha','interp','linestyle','none');
        patch('Vertices',[part_coastline_used_dist([non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2) non_nan_inds_inds(jj,2):-1:non_nan_inds_inds(jj,1)])./1000 [coastline_changes(ii).most_likely(part_coastline_used_inds([non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)])); coastline_changes(ii).max(part_coastline_used_inds([non_nan_inds_inds(jj,2):-1:non_nan_inds_inds(jj,1)]))]; NaN NaN],'Faces',[[1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))-1; 2:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)); 2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))-1:-1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+1; 2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2)):-1:length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+2]';repmat(2.*length(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2))+1,1,4)],'FaceVertexAlphaData',[shade_alpha(1).*ones(1,size(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2),2)) shade_alpha(2).*ones(1,size(non_nan_inds_inds(jj,1):non_nan_inds_inds(jj,2),2)) 1]','FaceColor',data(ii).color,'FaceAlpha','interp','linestyle','none');
        
    end
    
    p_1 = plot(part_coastline_used_dist./1000,coastline_changes(ii).most_likely(part_coastline_used_inds),'k','color',data(ii).color,'linewidth',2); hold on;
    p_2 = plot(part_coastline_used_dist./1000,coastline_changes(ii).min(part_coastline_used_inds),'k--','color',data(ii).color,'linewidth',1);
    p_3 = plot(part_coastline_used_dist./1000,coastline_changes(ii).max(part_coastline_used_inds),'k--','color',data(ii).color,'linewidth',1);
    
    xlim([part_coastline_used_dist(1) part_coastline_used_dist(end)]./1000);
    max_num_ticks = 12; poss_dy       = sort([10.^[-3:5] 2.*10.^[-3:5] 5.*10.^[-3:5]]); dy = poss_dy(max(1,min(length(poss_dy),min(find(poss_dy>diff([min(get(p_2,'YData')) max(get(p_3,'YData'))])./max_num_ticks)))));
    ylim([min(-dy,floor(min(get(p_2,'YData'))./dy).*dy) max(dy,ceil(max(get(p_3,'YData'))./dy).*dy)]);
    hold on; grid on; box on; set(gca,'layer','top','YTick',[min(-dy,floor(min(get(p_2,'YData'))./dy).*dy):dy:max(dy,ceil(max(get(p_3,'YData'))./dy).*dy)]);
    xlabel(['Distance [km] (for reference see the ' layout_location ' panel)']);
    text(min(get(gca,'xlim')),0,' No coastline change line','verticalalignment','bottom');
    
    if settings.cumulative_results && find(find(plot_fig_inds) == ii) > 1
        title(['Coastline differences incl. uncertainty ranges for model/data: ' data(ii).name ' (w.r.t. previous model)']);
    else
        title(['Coastline differences incl. uncertainty ranges for model/data: ' data(ii).name]);
    end
    
    if ~isempty(find(isnan(part_coastline_used_orie)))
        nan_sets = [find(diff(isnan(part_coastline_used_orie))==1)+1 find(diff(isnan(part_coastline_used_orie))==-1)];
        for jj=1:size(nan_sets,1)
            p_p=patch(part_coastline_used_dist(min(length(part_coastline_used_dist),max(1,nan_sets(jj,[1 1 2 2 1])+[-1 -1 1 1 -1])))./1000,[get(gca,'YLim') fliplr(get(gca,'YLim')) min(get(gca,'YLim'))],[-10 -10 -10 -10 -10],[0.95 0.95 0.95],'linestyle','none');
            text(part_coastline_used_dist(nan_sets(jj,1)-1)./1000,max(get(gca,'YLim')),'\rightarrow No data section','verticalalignment','top','horizontalalignment','left','fontsize',8);
            text(part_coastline_used_dist(nan_sets(jj,2)+1)./1000,min(get(gca,'YLim')),'No data section \leftarrow','verticalalignment','bottom','horizontalalignment','right','fontsize',8);
        end
    end
    
    legend([p_1 p_2],'Most likely coastline changes','Min./max. coastline changes','location','southwest')
    
    if settings.combined_fig
        figure(findobj(get(0,'children'),'Tag',['Spatial plot 1']));
    else
        figure(findobj(get(0,'children'),'Tag',['Spatial plot ' num2str(find(find(plot_fig_inds) == ii))]));
    end
    
    if ~settings.combined_fig
        
        if settings.cumulative_results && find(find(plot_fig_inds) == ii) > 1
            leg = legend(hand(ii,1),[data(ii).name ' (w.r.t. previous model)']);
        else
            leg = legend(hand(ii,1),[data(ii).name]);
        end
        
        set(leg,'color','w');
        
        xlim(x_lims); ylim(y_lims);
        
        if settings.save_figures_to_file
            if exist([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures']) ~= 7
                mkdir([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures'])
            end
            disp([' ']);
            disp(['Saving figure ' num2str(find(find(plot_fig_inds) == ii)) '-A out of ' num2str(sum(plot_fig_inds))]);
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') strrep(['_spatial_frame_' num2str(find(find(plot_fig_inds) == ii)) '_' strrep(matlab.lang.makeValidName(strrep(data(ii).name,' ','_')),'__','_') '_'],'__','_') data(ii).plot_type settings.file_suffix '.png'],'-m3','-png');
            if ii == max(find(plot_fig_inds))
                disp(['Succesfully saved a total of ' num2str(sum(plot_fig_inds)) ' figures']);
            end
        end
    else
        if settings.cumulative_results && find(find(plot_fig_inds) == ii) > 1
            leg_text = [leg_text; [data(ii).name ' (w.r.t. previous model)']];
        else
            leg_text = [leg_text; data(ii).name];
        end
        x_lims_comb = [min([x_lims_comb(1) x_lims(1)]) max([x_lims_comb(2) x_lims(2)])];
        y_lims_comb = [min([y_lims_comb(1) y_lims(1)]) max([y_lims_comb(2) y_lims(2)])];
    end
    
    if settings.combined_fig
        figure(findobj(get(0,'children'),'Tag',['Alongshore plot 1']));
        axes(findobj(get(gcf,'children'),'Tag',['ax_' num2str(find(find(plot_fig_inds) == ii))])); hold on;
    else
        figure(findobj(get(0,'children'),'Tag',['Alongshore plot ' num2str(find(find(plot_fig_inds) == ii))]));
        axes(findobj(get(gcf,'children'),'Tag','ax_1')); hold on;
    end
    
    if ~settings.combined_fig
        if settings.save_figures_to_file
            if exist([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures']) ~= 7
                mkdir([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures'])
            end
            disp([' ']);
            disp(['Saving figure ' num2str(find(find(plot_fig_inds) == ii)) '-B out of ' num2str(sum(plot_fig_inds))]);
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') strrep(['_alongshore_frame_' num2str(find(find(plot_fig_inds) == ii)) '-B_' strrep(matlab.lang.makeValidName(strrep(data(ii).name,' ','_')),'__','_') '_'],'__','_') data(ii).plot_type settings.file_suffix '.png'],'-m3','-png');
            if ii == max(find(plot_fig_inds))
                disp(['Succesfully saved a total of ' num2str(sum(plot_fig_inds)) ' figures']);
                % close figures:
                fig_hands = findall(0,'type','figure'); close(fig_hands(find(strcmp(get(fig_hands,'Tag'),'ACDC_splash_screen')==0)));
            end
        end
    end
end

if settings.combined_fig && ~isempty(find(plot_fig_inds))
    figure(findobj(get(0,'children'),'Tag',['Spatial plot 1']));
    legend(hand(find(plot_fig_inds),1),leg_text,'color','w');
    xlim(x_lims_comb); ylim(y_lims_comb);
    if settings.save_figures_to_file
        if exist([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures']) ~= 7
            mkdir([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures'])
        end
        disp([' ']);
        disp(['Saving 1/2 aggregated figures to file']);
        if length(coastline_changes) == 1
            % Only a sinlge figure 'combined'
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') strrep(['_spatial_frame_1_' strrep(matlab.lang.makeValidName(strrep(data(ii).name,' ','_')),'__','_') '_'],'__','_') data(ii).plot_type settings.file_suffix '.png'],'-m3','-png');
        else
            % A real combined figure:
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') '_combined_spatial_aggregation_of_' num2str(sum(plot_fig_inds)) '_models_and_datasets' settings.file_suffix '.png'],'-m3','-png');
        end
        disp(['Succesfully saved aggregated figure to file']);
        
        disp([' ']);
        disp(['Saving 2/2 aggregated figures to file']);
        figure(findobj(get(0,'children'),'Tag',['Alongshore plot 1']));
        if length(coastline_changes) == 1
            % Only a sinlge figure 'combined'
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') strrep(['_alongshore_frame_1_' strrep(matlab.lang.makeValidName(strrep(data(ii).name,' ','_')),'__','_') '_'],'__','_') data(ii).plot_type settings.file_suffix '.png'],'-m3','-png');
        else
            % A real combined figure:
            export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') '_combined_alongshore_aggregation_of_' num2str(sum(plot_fig_inds)) '_models_and_datasets' settings.file_suffix '.png'],'-m3','-png');
        end
        disp(['Succesfully saved aggregated figure to file']);
        % close figures:
        fig_hands = findall(0,'type','figure'); close(fig_hands(find(strcmp(get(fig_hands,'Tag'),'ACDC_splash_screen')==0)));
    end
end

if ~isempty(settings.diff_indices) || ~isempty(loaded_diff_data)
    % Check what we need to do, either handle new data, or handle loaded data:
    if ~isempty(loaded_diff_data)
        diff_mode = 'loaded_data';
        if ~isempty(settings.diff_indices)
            disp('ERROR: Both loaded difference data, as well as new difference data is requested. This is not possible, we only consider the loaded data!');
        end
        settings.diff_indices = [1:length(loaded_diff_data)]';
    elseif ~isempty(settings.diff_indices)
        diff_mode = 'new_data';
    end
    
    diff_data = [];
    for ii=1:size(settings.diff_indices,1)
        
        disp(' ');
        disp(['Creating difference plot ' num2str(ii) ' out of ' num2str(size(settings.diff_indices,1))]);
        
        mult_vals = double(~isnan(coastline.offshore_orientation)); mult_vals(mult_vals == 0) = NaN;
        
        if strcmp(diff_mode,'loaded_data');
            
            diff_data(ii).most_likely = loaded_diff_data{ii}.coastline_changes.most_likely;
            diff_data(ii).min         = loaded_diff_data{ii}.coastline_changes.min;
            diff_data(ii).max         = loaded_diff_data{ii}.coastline_changes.max;
            diff_data(ii).model_1     = loaded_diff_data{ii}.data(1).name;
            diff_data(ii).model_2     = loaded_diff_data{ii}.data(2).name;
            diff_data(ii).model_data  = loaded_diff_data{ii}.data;
            
        elseif strcmp(diff_mode,'new_data');
            
            diff_data(ii).most_likely = mult_vals .* (coastline_changes(settings.diff_indices(ii,2)).most_likely - coastline_changes(settings.diff_indices(ii,1)).most_likely);
            diff_data(ii).min         = mult_vals .* ((coastline_changes(settings.diff_indices(ii,2)).most_likely - coastline_changes(settings.diff_indices(ii,2)).min) - (coastline_changes(settings.diff_indices(ii,1)).most_likely - coastline_changes(settings.diff_indices(ii,1)).min));
            diff_data(ii).max         = mult_vals .* ((coastline_changes(settings.diff_indices(ii,2)).max - coastline_changes(settings.diff_indices(ii,2)).most_likely) - (coastline_changes(settings.diff_indices(ii,1)).max - coastline_changes(settings.diff_indices(ii,1)).most_likely));
            diff_data(ii).model_inds  = settings.diff_indices(ii,:);
            diff_data(ii).model_1     = data(settings.diff_indices(ii,1)).name;
            diff_data(ii).model_2     = data(settings.diff_indices(ii,2)).name;
            diff_data(ii).model_data  = data(settings.diff_indices(ii,:));
            
            if settings.save_mat_files

                disp(['   Storing difference data to file: ' num2str(ii) ' out of ' num2str(size(settings.diff_indices,1))]);

                clear saved_data
                saved_data.coastline                     = coastline;
                saved_data.coastline_changes.most_likely = diff_data(ii).most_likely;
                saved_data.coastline_changes.min         = diff_data(ii).min;
                saved_data.coastline_changes.max         = diff_data(ii).max;
                saved_data.data                          = data(settings.diff_indices(ii,:));
                saved_data.settings                      = settings;
                saved_data.type                          = 'difference_data_model_storage';
                saved_data.explanation                   = {['This file contains information on differences in coastline changes for:'];
                                                            ['(1) ' saved_data.data(1).name];
                                                            ['(2) ' saved_data.data(2).name];
                                                            ['It contains a most likely, min and max. result:'];
                                                            ['The most likely result is a difference between (1) and (2), where'];
                                                            ['Positive values indicate less erosion/more accretion'];
                                                            ['Negative values indicate more erosion/less accretion'];
                                                            ['The min and max results are a difference between (1) and (2), where'];
                                                            ['Positive values indicate larger difference between the most-likely and min/max results (more uncertainty w.r.t. the most-likely result)'];
                                                            ['Negative values indicate smaller difference between the most-likely and min/max results (less uncertainty w.r.t. the most-likely result)'];
                                                            ['The data is mapped w.r.t. the coastline in .coastline.ldb_file']};

                if exist([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']) ~= 7
                    mkdir([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files']);
                end
                save([strrep([settings.output_folder filesep],[filesep filesep],filesep) 'mat_files' filesep 'diff_data_file_for_2_models_inds_' num2str(settings.diff_indices(ii,1)) '_and_' num2str(settings.diff_indices(ii,2)) '_' datestr(now,'yyyymmdd_HHMMSS') settings.file_suffix],'saved_data','-v7.3');
            end
        end
        
        
        % Make some figures:
        
        part_coastline_used_inds = min(find(~isnan(coastline.offshore_orientation))):max(find(~isnan(coastline.offshore_orientation)));
        part_coastline_used_ldb  = [coastline.ldb(part_coastline_used_inds,1) coastline.ldb(part_coastline_used_inds,2)];
        part_coastline_used_orie = coastline.offshore_orientation(part_coastline_used_inds);
        part_coastline_used_dist = pathdistance(part_coastline_used_ldb(:,1),part_coastline_used_ldb(:,2));
        
        figure; set(gcf,'color','w','invertHardcopy','off','position',[9 48 1903 949],'NumberTitle','off','Tag',['Difference plot ' num2str(ii)]);
        
        % if x-diff / y-diff:
        if (diff([min(part_coastline_used_ldb(:,1)) max(part_coastline_used_ldb(:,1))]) ./ diff([min(part_coastline_used_ldb(:,2)) max(part_coastline_used_ldb(:,2))])) < 1.5
            % Horizontal scale is much smaller than vertical one
            ax_1 = subplot(1,4,1);
            ax_2 = subplot(1,4,[2:4]);
            layout_location = 'left';
        else
            % Horitontal scale is much larger than vertical one
            ax_1 = subplot(4,1,1);
            ax_2 = subplot(4,1,[2:4]);
            layout_location = 'top';
        end
        
        axes(ax_1); hold on; axis equal; grid on; box on; set(gca,'layer','top');
        
        if settings.filled_LDB
            filledLDB(coastline.ldb,'k',[34 139 34]/255);
            set(gca,'color',[198 226 255]/255);
        else
            disp('WARNING: It is advised to turn on filled_LDB when creating difference plots (only if your coastline is properly formatted, of course)');
        end
        plot(part_coastline_used_ldb(:,1),part_coastline_used_ldb(:,2),'k','linewidth',2);
        
        max_no_pts = 10;
        dist_opts    = sort([1.*10.^[0:10] 2.*10.^[0:10] 5.*10.^[0:10]]);
        sel_dist_opt = dist_opts(min(find((part_coastline_used_dist(end) ./ dist_opts) < 10)));
        dist_steps   = unique([0:sel_dist_opt:part_coastline_used_dist(end) part_coastline_used_dist(end)]);
        dist_cols    = jet(size(dist_steps,2));
        [~,dist_step_inds] = closest(dist_steps,part_coastline_used_dist);
        for jj=1:size(dist_steps,2)
            dist_handle(jj) = plot(part_coastline_used_ldb(dist_step_inds(jj),1),part_coastline_used_ldb(dist_step_inds(jj),2),'o','markersize',10,'Color','k','MarkerFaceColor',dist_cols(jj,:),'linewidth',2);
        end
        leg = legend(dist_handle,[num2str(dist_steps'./1000,'%9.3f') repmat(' km',length(dist_steps),1)]);
        set(get(leg,'Title'),'String','Coastline distance');
        if strcmp(layout_location,'left')
            set(leg,'location','NorthOutside','Orientation','vertical','color','w');
        elseif strcmp(layout_location,'top')
            set(leg,'location','EastOutside','Orientation','vertical','color','w');
        end
        
        if length(coastline.structure_inds) > 0
            struc_lims_x = [min(coastline.ldb(cell2mat(coastline.structure_inds),1)) max(coastline.ldb(cell2mat(coastline.structure_inds),1))];
            struc_lims_y = [min(coastline.ldb(cell2mat(coastline.structure_inds),2)) max(coastline.ldb(cell2mat(coastline.structure_inds),1))];
        else
            struc_lims_x = [Inf -Inf];
            struc_lims_y = [Inf -Inf];
        end
        
        xlim([min([part_coastline_used_ldb(:,1); struc_lims_x(1)])-(0.05.*diff([min([part_coastline_used_ldb(:,1); struc_lims_x(1)]) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])])) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])+(0.05.*diff([min([part_coastline_used_ldb(:,1); struc_lims_x(1)]) max([part_coastline_used_ldb(:,1); struc_lims_x(2)])]))]);
        ylim([min([part_coastline_used_ldb(:,2); struc_lims_y(1)])-(0.05.*diff([min([part_coastline_used_ldb(:,2); struc_lims_y(1)]) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])])) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])+(0.05.*diff([min([part_coastline_used_ldb(:,2); struc_lims_y(1)]) max([part_coastline_used_ldb(:,2); struc_lims_y(2)])]))]);
        
        set(gca,'XTickLabel',[],'YTickLabel',[]);
        
        arrow_ind = min(find(cumsum(~isnan(part_coastline_used_orie)) == round(sum(~isnan(part_coastline_used_orie))./2)));
        
        if ~settings.filled_LDB
            offshore_arrow_start = [part_coastline_used_ldb(arrow_ind,1) part_coastline_used_ldb(arrow_ind,2)];
            offshore_arrow_end   = offshore_arrow_start + ((0.1.*max(part_coastline_used_dist)) .* [cosd(part_coastline_used_orie(arrow_ind)) sind(part_coastline_used_orie(arrow_ind))]);
            land_arrow_start     = [part_coastline_used_ldb(arrow_ind,1) part_coastline_used_ldb(arrow_ind,2)];
            land_arrow_end       = land_arrow_start + ((0.1.*max(part_coastline_used_dist)) .* [cosd(part_coastline_used_orie(arrow_ind)+180) sind(part_coastline_used_orie(arrow_ind)+180)]);

            arrow_thick(offshore_arrow_start(1),offshore_arrow_start(2),offshore_arrow_end(1),offshore_arrow_end(2),'plot_color',[198 226 255]/255,'axis_equal',false,'max_arrowhead_angle',90);
            arrow_thick(land_arrow_start(1),land_arrow_start(2),land_arrow_end(1),land_arrow_end(2),'plot_color',[34 139 34]/255,'axis_equal',false,'max_arrowhead_angle',90);
            if part_coastline_used_orie(arrow_ind) < 180
                text(offshore_arrow_end(1),offshore_arrow_end(2),' Offshore direction');
                text(land_arrow_end(1),land_arrow_end(2),'Land direction ','horizontalalignment','right');
            else
                text(offshore_arrow_end(1),offshore_arrow_end(2),'Offshore direction ','horizontalalignment','right');
                text(land_arrow_end(1),land_arrow_end(2),' Land direction');
            end
        end
        
        axes(ax_2); hold on; grid on; box on; set(gca,'layer','top');
        
        ax_2 = plotyy(part_coastline_used_dist./1000,diff_data(ii).most_likely(part_coastline_used_inds),part_coastline_used_dist./1000,diff_data(ii).min(part_coastline_used_inds));
        
        set(ax_2,'xlim',[part_coastline_used_dist(1) part_coastline_used_dist(end)]./1000,'YTickMode','auto','nextplot','add');
        
        axes(ax_2(2));
        plot(part_coastline_used_dist./1000,diff_data(ii).max(part_coastline_used_inds),'r--','linewidth',2);
        
        set(ax_2(1),'ylim',[min(-1,-max(abs(diff_data(ii).most_likely(part_coastline_used_inds)))-(0.2.*(max(abs(diff_data(ii).most_likely(part_coastline_used_inds)))))) max(1,max(abs(diff_data(ii).most_likely(part_coastline_used_inds)))+(0.2.*(max(abs(diff_data(ii).most_likely(part_coastline_used_inds))))))]);
        set(ax_2(2),'ylim',[min(-1,-max(abs([diff_data(ii).min(part_coastline_used_inds); diff_data(ii).max(part_coastline_used_inds)]))-(0.2.*(max(abs([diff_data(ii).min(part_coastline_used_inds); diff_data(ii).max(part_coastline_used_inds)]))))) max(1,max(abs([diff_data(ii).min(part_coastline_used_inds); diff_data(ii).max(part_coastline_used_inds)]))+(0.2.*(max(abs([diff_data(ii).min(part_coastline_used_inds); diff_data(ii).max(part_coastline_used_inds)])))))]);
        
        set(get(ax_2(1),'ylabel'),'string',{['Difference in most-likely coastline change between model/data #1 and #2 [m]'];['Negative values indicate increased erosion in model/data #2 w.r.t. #1 (and vice versa)']});
        set(get(ax_2(2),'ylabel'),'string',{['Difference in min./max. ranges w.r.t. respective most-likely coastline change between model/data #1 and #2 [m]'];['Postive values indicate larger uncertainty ranges in model/data #2 w.r.t. #1 (and vice versa)'];['Dashed line indicates landward side of uncertainties, solid line indicates seaward of uncertainties']});
        
        set(get(ax_2(1),'xlabel'),'string',['Distance [km] (for reference see the ' layout_location ' panel)']);
        
        title({['Differences in coastline changes and uncertainty ranges between model/data #1 and #2'];['Model/data #1: "' diff_data(ii).model_1 '"'];['Model/data #2: "' diff_data(ii).model_2 '"']})
        
        set(ax_2(1),'YColor','k'); set(get(ax_2(1),'children'),'color','k','linewidth',2);
        set(ax_2(2),'YColor','r'); set(get(ax_2(2),'children'),'color','r','linewidth',2);
        
        legend([get(ax_2(1),'children'); get(ax_2(2),'children')],'Difference in most likely coastline changes between model/data #1 and #2 [m]','Difference in max. ranges w.r.t. respective most-likely coastline change between model/data #1 and #2 [m]','Difference in min. ranges w.r.t. respective most-likely coastline change between model/data #1 and #2 [m]','location','northwest')
        
        plot([part_coastline_used_dist(1) part_coastline_used_dist(end)]./1000,[0 0],'k-.','linewidth',1); text(min(get(gca,'xlim')),0,' No difference between model/data #1 and #2','verticalalignment','bottom');
        
        if ~isempty(find(isnan(part_coastline_used_orie)))
            nan_sets = [find(diff(isnan(part_coastline_used_orie))==1)+1 find(diff(isnan(part_coastline_used_orie))==-1)];
            for jj=1:size(nan_sets,1)
                p_p=patch(part_coastline_used_dist(min(length(part_coastline_used_dist),max(1,nan_sets(jj,[1 1 2 2 1])+[-1 -1 1 1 -1])))./1000,[get(gca,'YLim') fliplr(get(gca,'YLim')) min(get(gca,'YLim'))],[-10 -10 -10 -10 -10],[0.95 0.95 0.95],'linestyle','none'); set(p_p,'Parent',ax_2(2));
                text(part_coastline_used_dist(nan_sets(jj,1)-1)./1000,max(get(gca,'YLim')),'\rightarrow No data section','verticalalignment','top','horizontalalignment','left','fontsize',8);
                text(part_coastline_used_dist(nan_sets(jj,2)+1)./1000,min(get(gca,'YLim')),'No data section \leftarrow','verticalalignment','bottom','horizontalalignment','right','fontsize',8);
            end
        end
        
        if settings.save_figures_to_file
            if exist([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures']) ~= 7
                mkdir([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures'])
            end
            disp(['   Saving difference plot to file: ' num2str(ii) ' out of ' num2str(size(settings.diff_indices,1))]);
            if strcmp(diff_mode,'loaded_data');
                export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') '_diff_plot_earlier_saved_data_' num2str(ii) settings.file_suffix '.png'],'-m3','-png');
            elseif strcmp(diff_mode,'new_data');
                export_fig([strrep([settings.output_folder filesep],[filesep filesep], filesep) 'figures' filesep datestr(now,'yyyymmdd') '_diff_plot_model_inds_' num2str(diff_data(ii).model_inds(1)) '_and_' num2str(diff_data(ii).model_inds(2)) settings.file_suffix '.png'],'-m3','-png');
            end
            % close figures:
            fig_hands = findall(0,'type','figure'); close(fig_hands(find(strcmp(get(fig_hands,'Tag'),'ACDC_splash_screen')==0)));
        end
        
    end
    
end

close(findall(0,'tag','ACDC_splash_screen'));

% Function end
end