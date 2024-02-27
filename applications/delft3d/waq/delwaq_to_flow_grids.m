function output = delwaq_to_flow_grids(lga_file,grd_files,varargin)
% When combining multiple Delft3D-FLOW grids to a single *.hyd file (to use
% with DELWAQ, e.g. when using a domain decomposition Delft3D-FLOW model)
% the separate gridded FLOW information gets both combined, vectorized and
% aggregated (last one if applied by the modeller).
%
% If DELWAQ results are to be plotted or referenced to the original Delft3D
% grids, excesssive processing is required. This script is aimed at just
% that. Therefore, it uses the combined DELWAQ grid input (*.LGA file)
% combined with all original Delft3D FLOW-grids (list of original files)
% that were used to construct this *.LGA file.
%
% SYNTAX (<> indicates optional in- or output):
%
% <output> = delwaq_to_flow_grids(lga_file,grid_files,<delwaq_output>,<delwaq_variables>,<time>,<plotting>,<animate>)
%
% INPUT VARIABLES (REQUIRED):
%
% lga_file          Location of the *.lga file, specified in a single line
%                   character string. Can in- or exclude the complete path.
%                   Make sure that the associated *.cco file (equally
%                   named) is also available within the same path.
%
%                   Examples:
%
%                   (1) 'file.lga'
%                   (2) 'D:/tmp_model/some_lga_file.lga'
%
% grid_files        Cellstring of grid files associated with the lga_file
%                   (the grids that were used to construct the *.lga DELWAQ
%                   file). The cellstr can be of any shape. If you wish to
%                   only consider a single (or a few) grids: this is also
%                   possible/allowed.
%
%                   Examples:
%
%                   (1) {'grid1.grd','grid2.grd','D:/tmp_model/grid3.grd'}
%                   (2) grid_files (Cellstring, e.g. constructed from:
%                       [a,b] = uigetfile('*.grd','','multiselect','on')
%                       grid_files = cellstr([repmat(b,length(a),1) char(a')]);
%
% INPUT VARIABLES (OPTIONAL):
%
% delwaq_output     Location of the DELWAQ output (*.map file), specified
%                   in a single line character string. Can in- or exclude
%                   the complete path. When providing this optional input
%                   variable, the script will verify the relation between
%                   the *.LGA and *.map file (and indicate a mis-match if
%                   needed). Along with the delwaq_output *.map file, you
%                   can now also provide delwaq variables you wish to
%                   interpolate on the Delft3D flow grids.
%
%                   Examples:
%
%                   (1) 'file.map'
%                   (2) 'D:/tmp_model/some_DELWAQ_output_file.map'
%
% delwaq_variable   Delwaq variable(s) to interpolate on the flow grids,
%                   this optional input variable can be specified as a 
%                   variable indice or -name. It also allows multiple 
%                   variable calls(either multiple indices or a cellstring 
%                   of names). The provided information is always checked 
%                   with the available information within the *.map file 
%                   (specified with the delwaq_output (3rd) input variable)
%
%                   Examples:
%
%                   (1) 'Salinity'
%                   (2) {'SO4','NH4','Salinity','OXY'}
%                   (3) 6
%                   (4) [2 6 10 37]
%
% time              When variables are loaded, you can indicate the point
%                   in time you wish to load. This can either be a time
%                   indice (or multiple specified in a vector) or the value
%                   'all' (which will load all the available time points).
%                   Do note that the latter option may quickly require a
%                   lot of data to be loaded into memory (especially for
%                   multiple grids). When not specified (or left empty:
%                   []), the last time indice is automatically selected.
%
% plotting          When set to true, for all the requested fields (so
%                   looping through Delwaq variables, timepoints and
%                   layers), plots will be generated. If you do not wish to
%                   specify a timepoint (which is required for plotting),
%                   simply leave the time variable empty (which is []).
%
% animate           When plotting is true, and only 1 variable and layer is
%                   considered, why not animate your results over time?
%                   When setting animate to true, the output figures are
%                   not generated separately, but updated, resulting in an
%                   animation. Please note that this option will also work
%                   when considering more variables and/or more layers, but
%                   the resulting behavior may not be best.
%
% OUTPUT VARIABLES (OPTIONAL):
%
% output            The output of the script can be stored in an output
%                   variable, in this case called output. The output
%                   variable will contain the indices of the aggregated and
%                   vectorized DELWAQ output on each of the provided FLOW
%                   grids, stored in a {N,1} cell (with N the number of
%                   provided (input) Delft3D FLOW grids), when no DELWAQ
%                   variables were specified (2 or 3 input variables in
%                   total). The scripts will provide interpolated (gridded)
%                   data for each of the specified DELWAQ variables, on
%                   each of the different flow grids when DELWAQ output 
%                   variables were specified (so 4 function input variables
%                   in total). This will be stored in M {N,1} cells, named 
%                   after the variables they were based on (with M the
%                   number of DELWAQ variables, and N the number of Delft3D
%                   FLOW grids). Grid information will also be available,
%                   for the purpose of convenient plotting.
%________________________________________________________________________
%
%Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%              
%See also: delwaq, delft3d_io_grd

%   --------------------------------------------------------------------
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Developed as part of the TO27 project at the Water Institute of the
%       Gulf, Baton Rouge, Louisiana. Please do not make any functional
%       changes to this script, as it is relied upon within this modelling
%       framework.
%
%       Please contact me if errors occur.
%
%       Deltares
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

% Check the lga_data:
if isstr(lga_file)
    if size(lga_file,1) == 1
        if exist(lga_file,'file')~=2
            error(['The *.lga file does not exist: ' lga_file]);
        end
    else
        error('Please specify the *.lga file as a single line character string');
    end
else
    error('Please specify the *.lga file as a character string');
end

% Check the grd_files:
if isstr(grd_files)
    if size(grd_files,1) == 1
        if exist(grd_files,'file')~=2
            error(['The specified *.grd file does not exist: ' grd_files]);
        else
            grd_files = {grd_files};
        end
    else
        error('Please specify multiple grid files in a cell-string');
    end
elseif iscellstr(grd_files)
    grd_files = grd_files(:);
    for ii=1:size(grd_files,1)
        if exist(grd_files{ii,1},'file')~=2
            error(['The specified *.grd file does not exist: ' grd_files{ii,1}]);
        end
    end
else
    error('Please specify the grid files in either a single line character string, or a cell-string');
end


lga_data       = delwaq('open',lga_file);
lga_data.MNK   = lga_data.MNK([2 1 3]);
lga_data.Index = lga_data.Index';
lga_data.X     = lga_data.X';
lga_data.Y     = lga_data.Y';

no_of_layers = 1;
if length(varargin) > 0
    if isstr(varargin{1})
        try
            dwq_info = delwaq('open',varargin{1});
            time_ax  = delwaq_time(dwq_info,'datenum',1,'quiet',true)';
            if size(unique(lga_data.Index(find(lga_data.Index>0))),1) ~= dwq_info.NumSegm
                if (dwq_info.NumSegm / size(unique(lga_data.Index(find(lga_data.Index>0))),1)) == round((dwq_info.NumSegm / size(unique(lga_data.Index(find(lga_data.Index>0))),1)))
                    no_of_layers = (dwq_info.NumSegm / size(unique(lga_data.Index(find(lga_data.Index>0))),1));
%                     disp(['Looks like the *.lga file matches with the output *.map file with ' num2str(no_of_layers) ' layers'])
                else
                    disp(['This *.map file does not match with the provided *.lga file'])
                end
            else
                % disp('Your *.map file matches well with the *.lga file');
            end
        catch
            error(['Unable to open *.map file: ' varargin{1}])
        end
    else
        disp('Unknown optional input provided, ignored..')
    end
    disp(' ')
end

if length(varargin) > 1
    if isnumeric(varargin{2})
        if min(size(varargin{2})) == 0
            error('Please specify any values for the variable integers')
        end
        varargin{2} = varargin{2}(:);
        if (min(varargin{2})<1) || (max(varargin{2}) > size(dwq_info.SubsName,1)) || ~isempty(find(diff([varargin{2} round(varargin{2})],1,2)~=0))
            error(['Please, only specify (a) positive variable integer(s) in the range of 1 up to (for this case) ' num2str(size(dwq_info.SubsName,1))]);
        end
    elseif isstr(varargin{2})
        if size(varargin{2},1) ~= 1
            if size(varargin{2},1) > 1
                error(['If you wish to specify multiple DELWAQ variables, use a cellstring instead'])
            else
                error(['Please specify some text for the DELWAQ variable you wish to consider'])
            end
        else
            ind = find(strcmpi(dwq_info.SubsName,varargin{2}) == 1);
            if isempty(ind)
                disp(dwq_info.SubsName)
                error(['The variable ''' varargin{2} ''' is not found within the provided DELWAQ *.map file, choose from the list above'])
            else
                varargin{2} = ind;
            end
        end
    elseif iscellstr(varargin{2})
        varargin{2} = varargin{2}(:);
        for ii = 1:size(varargin{2},1)
            ind(ii,:) = max([find(strcmpi(dwq_info.SubsName,varargin{2}{ii,1}) == 1) 0]);
            if ind(ii,1) == 0
                disp(dwq_info.SubsName)
                error(['The variable ''' varargin{2}{ii,1} ''' is not found within the provided DELWAQ *.map file, choose from the list above'])
            end
        end
        varargin{2} = ind;
    else
        error('Unknown input for DELWAQ variables, please refer to the help')
    end
end

if length(varargin) > 2
    if isnumeric(varargin{3})
        if isempty(varargin{3})
            varargin{3} = dwq_info.NTimes;
        end
        varargin{3} = varargin{3}(:);
        if (min(varargin{3})<1) || (max(varargin{3}) > dwq_info.NTimes) || ~isempty(find(diff([varargin{3} round(varargin{3})],1,2)~=0))
            error(['Please, only specify (a) positive time integer(s) in the range of 1 up to (for this case) ' num2str(dwq_info.NTimes)]);
        end
    elseif isstr(varargin{3})
        if size(varargin{3},1) == 1
            if strcmp(varargin{3},'all')
                varargin{3} = [1:dwq_info.NTimes]';
            else
                error('When specifying time, the only text option is ''all''')
            end
        else
            error('When specifying time, the only text option is ''all''')
        end
    else
        error('Unknown time input provided')
    end
elseif length(varargin) == 2
    varargin{3} = dwq_info.NTimes;
end

if length(varargin) > 3
    if islogical(varargin{4}) || isnumeric(varargin{4})
        if varargin{4} == 1
            varargin{4} = true;
        else
            varargin{4} = false;
        end
    else
        error('Unknown plotting option input')
    end
end

if length(varargin) > 4
    if islogical(varargin{5}) || isnumeric(varargin{5})
        if varargin{5} == 1
            varargin{5} = true;
        else
            varargin{5} = false;
        end
    else
        error('Unknown plotting option input')
    end
elseif length(varargin) == 4
    varargin{5} = false;
end

% Remove gridpoints outside of the grid (not really required..)
lga_data.X(find(round(lga_data.X)==-1000)) = NaN;
lga_data.Y(find(round(lga_data.Y)==-1000)) = NaN;

grd_inds = NaN(size(lga_data.X));
for grd_id = 1:size(grd_files,1)
    disp(['Checking grid ' num2str(grd_id) ' out of ' num2str(size(grd_files,1))])
    grd_tmp = delft3d_io_grd('read',grd_files{grd_id,1});
    grd_data{grd_id,1}.X = grd_tmp.cor.x;
    grd_data{grd_id,1}.Y = grd_tmp.cor.y;
    grd_data{grd_id,1}.X_cen = grd_tmp.cen.x;
    grd_data{grd_id,1}.Y_cen = grd_tmp.cen.y;
    grd_data{grd_id,1}.FileName = grd_tmp.files.grd.name;
    grd_data{grd_id,1}.MissingValue = grd_tmp.nodatavalue;
    grd_data{grd_id,1}.CoordinateSystem = grd_tmp.CoordinateSystem;
    if ~isnan(grd_data{grd_id,1}.MissingValue)
        grd_data{grd_id,1}.X(find(round(grd_data{grd_id,1}.X) == round(grd_data{grd_id,1}.MissingValue))) = NaN;
        grd_data{grd_id,1}.Y(find(round(grd_data{grd_id,1}.Y) == round(grd_data{grd_id,1}.MissingValue))) = NaN;
    end
    if strcmp(grd_data{grd_id,1}.CoordinateSystem,'Cartesian')
        err_dist = 1; %Cart.
    else
        err_dist = 0.00001; %Deg.
    end
    for ii=1:size(grd_data{grd_id,1}.X,1)
        for jj=1:size(grd_data{grd_id,1}.X,2)
            if ~isnan(grd_data{grd_id,1}.X(ii,jj)) && ~isnan(grd_data{grd_id,1}.Y(ii,jj))
                [cur_inds_ii,cur_inds_jj] = find(sqrt(((lga_data.X - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y - grd_data{grd_id,1}.Y(ii,jj)).^2)) == min(min(sqrt(((lga_data.X - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y - grd_data{grd_id,1}.Y(ii,jj)).^2)))));
                cur_dist = sqrt(((lga_data.X(cur_inds_ii(1,1),cur_inds_jj(1,1)) - grd_data{grd_id,1}.X(ii,jj)).^2) + ((lga_data.Y(cur_inds_ii(1,1),cur_inds_jj(1,1)) - grd_data{grd_id,1}.Y(ii,jj)).^2));
                if cur_dist <= err_dist
                    % Point lies close enough, else just a NaN is given...:
                    if size(cur_inds_ii,1) == 1
                        % We have found 1 unique point that lies within both the combined and single (grd_ind) grid.
                        % We can use this point in combination with the current ii and jj indices as reference, to construct the grd_inds for grid grd_id.
                        grd_base_ii = cur_inds_ii - ii + 1;
                        grd_base_jj = cur_inds_jj - jj + 1;
                        grd_end_ii  = grd_base_ii+size(grd_data{grd_id,1}.X,1)-1;
                        grd_end_jj  = grd_base_jj+size(grd_data{grd_id,1}.X,2)-1;
                        % Ok, now set the grd_id values:
                        for ii2 = grd_base_ii:grd_end_ii
                            for jj2 = grd_base_jj:grd_end_jj
                                if ~isnan(grd_data{grd_id,1}.X(ii2-cur_inds_ii+ii,jj2-cur_inds_jj+jj)) && ~isnan(grd_data{grd_id,1}.Y(ii2-cur_inds_ii+ii,jj2-cur_inds_jj+jj))
                                    if ~isnan(grd_inds(ii2,jj2))
                                        Error('Unexpected error, please contact the script developer with code 34563489')
                                    end
                                    grd_inds(ii2,jj2) = grd_id;
                                end
                            end
                        end
                    end
                end
            end
            if ~isempty(find(grd_inds==grd_id))
                break
            end
        end
        if ~isempty(find(grd_inds==grd_id))
            break
        end
    end
    % Now for each flow grid, we have the indices of the lga file, lets now couple it to the delwaq output file with help of the index(es):
    output.grid_info{grd_id,1}.FileName = grd_data{grd_id,1}.FileName;
    output.grid_info{grd_id,1}.X = grd_data{grd_id,1}.X;
    output.grid_info{grd_id,1}.Y = grd_data{grd_id,1}.Y;
    output.grid_info{grd_id,1}.X_cen = grd_data{grd_id,1}.X_cen;
    output.grid_info{grd_id,1}.Y_cen = grd_data{grd_id,1}.Y_cen;
    output.grid_info{grd_id,1}.DELWAQ_Index = lga_data.Index(grd_base_ii:grd_end_ii,grd_base_jj:grd_end_jj);
    output.grid_info{grd_id,1}.DELWAQ_Index(find(lga_data.Index(grd_base_ii:grd_end_ii,grd_base_jj:grd_end_jj) < 1)) = NaN;
    output.grid_info{grd_id,1}.DELWAQ_Index_cen = output.grid_info{grd_id,1}.DELWAQ_Index(2:end,2:end);
    
    % pcolor(grd_data{grd_id,1}.X,grd_data{grd_id,1}.Y,output{grd_id,1})
end

if size(varargin,2) > 1
    % Now, for each of the provided variables, provide the data on the grid:
    
    disp(' ')
    if no_of_layers > 1
        disp(['Obtaining data - Grids: ' num2str(size(grd_files,1)) ' - Variables: ' num2str(length(varargin{2})) ' - Timesteps: ' num2str(length(varargin{3})) ' - Layers: ' num2str(no_of_layers)])
    else
        disp(['Obtaining data - Grids: ' num2str(size(grd_files,1)) ' - Variables: ' num2str(length(varargin{2})) ' - Timesteps: ' num2str(length(varargin{3}))])
    end
    
    for var_ind = varargin{2}'
        [var_time,var_data] = delwaq('read',dwq_info,var_ind,0,varargin{3});
        var_data            = reshape(var_data,[lga_data.NoSeg,no_of_layers,length(varargin{3})]);
        % Remove some dummy's:
        var_data(var_data==-999) = NaN;
        
        var_name = {['variable_' num2str(var_ind)],dwq_info.SubsName{var_ind,1}};
        output.(var_name{1,isvarname(var_name{1,2})+1}).Substance_name = var_name{1,2};
        
        for grd_ind = 1:size(grd_files,1)
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.dimension = '[M,N,K,T]';
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.plot_call = ['pcolor(output.grid_info{' num2str(grd_ind) ',1}.X,output.grid_info{' num2str(grd_ind) ',1}.Y,squeeze(output.' var_name{1,isvarname(var_name{1,2})+1} '.gridded_data{' num2str(grd_ind) ',1}.cor(:,:,1,1)));'];
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor = NaN([size(grd_data{grd_ind,1}.X) no_of_layers size(varargin{3},1)]);
            for lay = 1:size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,3)
                for t = 1:size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,4)
                    cur_lay_dat = var_data(:,lay,t);
                    to_add = output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor(:,:,lay,t);
                    to_add(output.grid_info{grd_ind,1}.DELWAQ_Index>0) = cur_lay_dat(output.grid_info{grd_ind,1}.DELWAQ_Index(output.grid_info{grd_ind,1}.DELWAQ_Index>0));
                    output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor(:,:,lay,t) = to_add;
                end
            end
            % We have gridcell data, so correct for that:
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cen = output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor(2:end,2:end,:,:);
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor = NaN(size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor));
            output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor(1:end-1,1:end-1,:,:) = output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cen;
        end
        
        if length(varargin) > 3
            if varargin{4}
                for lay = 1:size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,3)
                    for t = 1:size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,4)
                        if lay == 1 && t == 1
                            fig = figure; hold on;
                        elseif ~varargin{5}
                            fig = figure; hold on;
                        else
                            try; delete(findobj(fig,'type','surface')); end;
                        end
                        figure(fig);
                        for grd_ind = 1:size(grd_files,1)
                            pcolor(output.grid_info{grd_ind,1}.X,output.grid_info{grd_ind,1}.Y,squeeze(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor(:,:,lay,t)));
                        end
                        axis tight; axis equal; shading flat; box on; set(gca,'layer','top'); grid on; xlabel('X-direction'); ylabel('Y-direction');
                        cb = colorbar; set(get(cb,'ylabel'),'string',output.(var_name{1,isvarname(var_name{1,2})+1}).Substance_name);
                        if no_of_layers > 1
                            title([output.(var_name{1,isvarname(var_name{1,2})+1}).Substance_name ' field for layer ' num2str(lay) ' on ' datestr(time_ax(varargin{3}(t)),'dd-mm-''yy HH:MM:SS')])
                        else
                            title([output.(var_name{1,isvarname(var_name{1,2})+1}).Substance_name ' field on ' datestr(time_ax(varargin{3}(t)),'dd-mm-''yy HH:MM:SS')])
                        end
                        if varargin{5}
                            drawnow;
                        end
                    end
                end
            end
        end
    end
    if length(varargin) > 3
        if varargin{4}
            disp(' ')
            if varargin{5}
                disp(['Successfully created ' num2str(size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,3) * size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,4) * length(varargin{2})) ' frames']);
            else
                disp(['Successfully created ' num2str(size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,3) * size(output.(var_name{1,isvarname(var_name{1,2})+1}).gridded_data{grd_ind,1}.cor,4) * length(varargin{2})) ' figures']);
            end
        end
    end
else
    output = output.grid_info;
end
disp(' ');
disp('Script completed succesfully');




