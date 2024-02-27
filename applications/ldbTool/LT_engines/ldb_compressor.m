function varargout = ldb_compressor(varargin)
%LDB_COMPRESSOR
%
%This function takes all landboundary segments, checks for identical
%start and/or end points, and connects them accordingly. It does so in an
%iterative fashion, and will thus automatically stop upon completion.
%
%This is particularly handy when the ldb was converted from an AutoCAD
%format and consists of many separate components. Also, it can be used to
%reduce the number of steps required to make the landboundary-file
%complient for the filledLDB function (e.g. through the function ldbTool).
%
%Syntax:
%
%<output_var> = ldb_compressor(<input_file>,<output_file>);
%
%  Input:
%    <input_file>  (optional)   - Either a filename of the ldb to compress
%                                 or the landboundary as a [Nx2] matrix
%    <output_file> (optional)   - A string containing the filename of the
%                                 output ldb (the ldb will only be written
%                                 if this is supplied)
%
%   Output
%     <output_var>  (optional)   - Output variable where the [Nx2] output
%                                  landboundary is stored to in memory
%                                  (else it is stored in ans automatically)
%Examples:
%
%   ldb_compressor();                        (will promt for a *.ldb-file)
%   ldb_new = ldb_compressor('ldb_old');
%   ldb_compressor(ldb_data,'ouput_file.ldb');
%
%   % Manual example:
%   ldb = [10 10; 11 11; 12 12; NaN NaN; 15 15; 14 13; 13 15; 12 12];
%   ldb_new = ldb_compressor(ldb);
%   % ldb_new will be: [10 10; 11 11; 12 12; 13 15; 14 13; 15 15];
%
%Note that ldb_data should be loaded using the function landboundary
%
%See also: landboundary, ldbTool, filledLDB, tekal, ldb_compressor_2

%   --------------------------------------------------------------------
%       Freek Scheel 2017
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
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

write_to_file = false;
if nargin == 0
    try
        ldb_ori = landboundary('read');
    catch
        error('Cannot load this ldb file, does it have the correct file-format?');
    end
    if isempty(ldb_ori)
        disp('No landboundary loaded');
        return
    end
else
    if iscell(varargin{1})
        varargin(1) = varargin{1};
    end
    
    if ischar(varargin{1})
        if exist(varargin{1},'file')==2
            try
                ldb_ori = landboundary('read',varargin{1});
            catch
                error('Cannot load this ldb file, does it have the correct file-format?');
            end
        else
            error('Supplied filename is not a file');
        end
    elseif isnumeric(varargin{1})
        if length(size(varargin{1})) == 2 && ~isempty(find(size(varargin{1}) == 2))
            if size(varargin{1},2) ~= 2
                ldb_ori = varargin{1}';
            else
                ldb_ori = varargin{1};
            end
        else
            error('Incorrect format supplied');
        end
    else
        error('Incorrect input');
    end
    
    if nargin > 1
        
        if iscell(varargin{2})
            varargin(2) = varargin{2};
        end
        
        if ischar(varargin{2})
            ldb_out = varargin{2};
        else
            error('Output filename should be supplied as a string');
        end
        
        write_to_file = true;
        
        if length(ldb_out)>4
            if ~strcmp(ldb_out(1,end-3:end),'.ldb')
                ldb_out = [ldb_out '.ldb'];
            end
        else
            ldb_out = [ldb_out '.ldb'];
        end
        
        if nargin > 2
            disp(['A total of ' num2str(nargin) ' input variables supplied, script is only using the first 2!']);
        end
        
    end
end

start_end_inds_ori = [[1; find(isnan(ldb_ori(:,1)))+1] [find(isnan(ldb_ori(:,1)))-1; size(ldb_ori,1)]];

num_parts_prev = Inf;
num_parts_new  = size(start_end_inds_ori,1);

ldb = ldb_ori;

iter = 0;

while num_parts_prev ~= num_parts_new
    
    iter = iter + 1;
    
    start_end_inds = [[1; find(isnan(ldb(:,1)))+1] [find(isnan(ldb(:,1)))-1; size(ldb,1)]];

    ind_check    = 1;
    inds_checked = zeros(size(start_end_inds,1),1);
    ldb_parts    = {};
    new_part     = 1;
    tel          = 0;
    prog_disp    = 0;
    
    fprintf(['Iteration ' num2str(iter) ': ' num2str(floor(prog_disp),'%03.0f') '/100']);
    
    while ~isempty(find(inds_checked == 0))
        tel=tel+1;
        
        prog = 100.*(tel./size(start_end_inds,1));
        if floor(prog) > prog_disp
            fprintf([repmat('\b',1,20) 'Iteration ' num2str(iter) ': ' num2str(floor(prog_disp),'%03.0f') '/100']);
            prog_disp = floor(prog);
        end
        
        cur_start_pt = ldb(start_end_inds(ind_check,1),[1 2]);
        cur_end_pt   = ldb(start_end_inds(ind_check,2),[1 2]);

        % Find a start point linked to the current end point
        inds = find(ldb(start_end_inds(:,1),1) == cur_end_pt(1,1) & ldb(start_end_inds(:,1),2) == cur_end_pt(1,2) & inds_checked==0);
        ind  = min(inds(find(inds~=ind_check)));
        if ~isempty(ind)
            if new_part
                ldb_parts{end+1} = ldb([start_end_inds(ind_check,1):start_end_inds(ind_check,2) start_end_inds(ind,1)+1:start_end_inds(ind,2)],:);
            else
                ldb_parts{end}   = [ldb_parts{end}; ldb([start_end_inds(ind,1)+1:start_end_inds(ind,2)],:)];
            end
            new_part  = 0;
            inds_checked(ind_check,1) = 1;
            ind_check = ind;
            continue
        end

        % Find an end point linked to the current end point
        inds = find(ldb(start_end_inds(:,2),1) == cur_end_pt(1,1) & ldb(start_end_inds(:,2),2) == cur_end_pt(1,2) & inds_checked==0);
        ind  = min(inds(find(inds~=ind_check)));
        if ~isempty(ind)
            % In this case, we're flipping the new part to turn it into a start point:
            ldb(start_end_inds(ind,1):start_end_inds(ind,2),:) = flipud(ldb(start_end_inds(ind,1):start_end_inds(ind,2),:));
            % Now we've basically found a start point, linked to the current end point
            if new_part
                ldb_parts{end+1} = ldb([start_end_inds(ind_check,1):start_end_inds(ind_check,2) start_end_inds(ind,1)+1:start_end_inds(ind,2)],:);
            else
                ldb_parts{end}   = [ldb_parts{end}; ldb([start_end_inds(ind,1)+1:start_end_inds(ind,2)],:)];
            end
            new_part  = 0;
            inds_checked(ind_check,1) = 1;
            ind_check = ind;
            continue
        end

        if new_part

            % Find a start point linked to the current start point
            inds = find(ldb(start_end_inds(:,1),1) == cur_start_pt(1,1) & ldb(start_end_inds(:,1),2) == cur_start_pt(1,2) & inds_checked==0);
            ind  = min(inds(find(inds~=ind_check)));
            if ~isempty(ind)
                % In this case, we're flipping the original part to turn it into an end point:
                ldb(start_end_inds(ind_check,1):start_end_inds(ind_check,2),:) = flipud(ldb(start_end_inds(ind_check,1):start_end_inds(ind_check,2),:));
                % Now we've basically found a start point, linked to the current end point
                ldb_parts{end+1} = ldb([start_end_inds(ind_check,1):start_end_inds(ind_check,2) start_end_inds(ind,1)+1:start_end_inds(ind,2)],:);
                new_part  = 0;
                inds_checked(ind_check,1) = 1;
                ind_check = ind;
                continue
            end

            % Find an end point linked to the current start point
            inds = find(ldb(start_end_inds(:,2),1) == cur_start_pt(1,1) & ldb(start_end_inds(:,2),2) == cur_start_pt(1,2) & inds_checked==0);
            ind  = min(inds(find(inds~=ind_check)));
            if ~isempty(ind)
                % In this case, we flip both parts and link them:
                ldb(start_end_inds(ind,1):start_end_inds(ind,2),:)             = flipud(ldb(start_end_inds(ind,1):start_end_inds(ind,2),:));
                ldb(start_end_inds(ind_check,1):start_end_inds(ind_check,2),:) = flipud(ldb(start_end_inds(ind_check,1):start_end_inds(ind_check,2),:));
                % Now we've basically found a start point, linked to the current end point
                ldb_parts{end+1} = ldb([start_end_inds(ind_check,1):start_end_inds(ind_check,2) start_end_inds(ind,1)+1:start_end_inds(ind,2)],:);
                new_part  = 0;
                inds_checked(ind_check,1) = 1;
                ind_check = ind;
                continue
            end

            % Nothing found, stored as a single line:
            ldb_parts{end+1} = ldb(start_end_inds(ind_check,1):start_end_inds(ind_check,2),:);

        end

        inds_checked(ind_check,1) = 1;
        ind_check = min(find(inds_checked==0));
        ldb_parts{end} = [ldb_parts{end}; NaN NaN];
        new_part  = 1;

    end
    
    fprintf([repmat('\b',1,20) 'Iteration ' num2str(iter) ': ' num2str(floor(prog_disp),'%03.0f') '/100\n']);
    
    ldb = cell2mat(ldb_parts');
    ldb = ldb(1:end-1,:);

    num_parts_prev = size(start_end_inds,1);
    num_parts_new  = size(ldb_parts,2);
    
end
disp(' ');
if iter > 1
    disp(['Converted landboundary from ' num2str(size(start_end_inds_ori,1)) ' to ' num2str(num_parts_new) ' segments in ' num2str(iter) ' iterations (From ' num2str(sum(~isnan(ldb_ori(:,1)))) ' to ' num2str(sum(~isnan(ldb(:,1)))) ' X,Y-points)']);
    if write_to_file
        disp(' ');
        disp(['Writing to file ''' ldb_out '''...']);
    end
else
    disp('No changes made to the supplied ldb file');
    if write_to_file
        write_to_file = false;
        disp('File will not be written to the supplied filename (it was not changed)');
    end
end

if write_to_file
    landboundary('write',ldb_out,ldb);
    disp('Done!');
end

varargout{1} = ldb;
if nargout > 1
    disp(' ');
    disp(['A total of ' num2str(nargout) ' output variables requested, script will only use the first!']);
    for ii = 2:nargout
        varargout{ii} = NaN;
    end
end
    

end