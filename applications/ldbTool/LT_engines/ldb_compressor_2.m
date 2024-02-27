function varargout = ldb_compressor_2(varargin)
%LDB_COMPRESSOR_2
%
%This function cuts a landboundary into segments of 2 points each,
%subsequently removes all identical sections and reconstructs a
%landboundary based on these points.
%
%This is particularly handy when the ldb was converted from e.g. an AutoCAD
%format and consists of many separate components, some of which may be
%overlapping. It can also be used to reduce the number of steps required to
%make the landboundary-file complient for the filledLDB function (e.g.
%through the function ldbTool).
%
%Syntax:
%
%<output_var> = ldb_compressor_2(<input_file>,<output_file>);
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
%   ldb = [10 10; 11 11; 12 12; 11 11; 12 12; 14 13; 13 15; 15 15];
%   ldb_new = ldb_compressor(ldb);
%   % ldb_new will be: [10 10; 11 11; 12 12; 14 13; 13 15; 15 15];
%
%Note that ldb_data should be loaded using the function landboundary
%
%See also: landboundary, ldbTool, filledLDB, tekal, ldb_compressor

%   --------------------------------------------------------------------
%       Freek Scheel 2018
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

ldb     = ldb_ori;

% Add start-end NaN's:
if ~isnan(ldb(1,1))
    ldb = [NaN NaN; ldb];
end
if ~isnan(ldb(end,1))
    ldb = [ldb; NaN NaN];
end

nan_inds        = find(isnan(ldb(:,1)));
single_pts_inds = sort(nan_inds(find(diff(nan_inds)==2))+1);

single_pts = {};
for ii = flipud(single_pts_inds)'
    single_pts{end+1,1} = ldb(ii,:);
    ldb([ii ii+1],:) = [];
end

ldb = ldb(2:end-1,:);

prog_disp  = 0;
sections   = cell(size(ldb,1),1);
prev_ii    = 2;
tel        = 0;
fprintf(['Part 1: Iteration ' num2str(1) ': ' num2str(floor(prog_disp),'%03.0f') '/100']);
for ii=1:size(ldb,1)-1
    
    prog = 100.*(ii./(size(ldb,1)-1));
    if floor(prog) > prog_disp
        fprintf([repmat('\b',1,27+ceil(log10(prev_ii))) 'Part 1: Iteration ' num2str(ii) ': ' num2str(floor(prog_disp),'%03.0f') '/100']);
        prog_disp = floor(prog); prev_ii = ii;
    end
    
    if sum(isnan(ldb([ii ii+1],1))) == 0
        new_section = ldb([ii ii+1],:);
        
        if tel > 0
            sections_num = cell2mat(sections);
            old_inds     = sort([ceil(find(sections_num(:,1) == new_section(1,1) & sections_num(:,2) == new_section(1,2))./2); ceil(find(sections_num(:,1) == new_section(2,1) & sections_num(:,2) == new_section(2,2))./2)]);

            if max(count(old_inds)) == 2
                % Section already exists (or in opposite direction)
                inds = unique(old_inds); inds(find(count(old_inds) == 2));
            else
                tel = tel + 1;
                sections{tel,1} = new_section;
            end
        else
            tel = tel + 1;
            sections{tel,1} = new_section;
        end
        
    end
end

sections = sections(1:tel);

all_pts      = zeros(size(sections));
sections_num = cell2mat(sections);
ldb_new      = [];

% Now let's assemble the ldb again:
fprintf([repmat('\b',1,27+ceil(log10(prev_ii))) 'Part 2: Re-assembling ldb, may take some time...']);
while sum(all_pts) ~= length(sections)
    
    ldb_new = [ldb_new; NaN NaN; sections{min(find(all_pts == 0))}];
    all_pts(min(find(all_pts == 0))) = 1;
    section_start_ind = size(ldb_new,1)-1;
    
    for L_R = 0:1
        if L_R == 1
            ldb_new(section_start_ind:end,:) = flipud(ldb_new(section_start_ind:end,:));
        end
        
        if ~isempty(find(all_pts == 0))
            % Let's start by finding a point that connects to the second point, and so on, and so forth:
            while ~isempty(min(ceil(find(sections_num(:,1) == ldb_new(end,1) & sections_num(:,2) == ldb_new(end,2) & reshape([all_pts'; all_pts'],[2.*size(all_pts,1),1]) == 0)./2)))
                sect_to_add = sections{min(ceil(find(sections_num(:,1) == ldb_new(end,1) & sections_num(:,2) == ldb_new(end,2) & reshape([all_pts'; all_pts'],[2.*size(all_pts,1),1]) == 0)./2))};
                all_pts(min(ceil(find(sections_num(:,1) == ldb_new(end,1) & sections_num(:,2) == ldb_new(end,2) & reshape([all_pts'; all_pts'],[2.*size(all_pts,1),1]) == 0)./2)),1) = 1;
                ldb_new = [ldb_new; sect_to_add(find([2 1] == find(sect_to_add(:,1) == ldb_new(end,1) & sect_to_add(:,2) == ldb_new(end,2))),:)];
            end
        end
    end  
end
ldb_new = [ldb_new; NaN NaN];

for ii=1:length(single_pts)
    ldb_new = [ldb_new; single_pts{ii,1}; NaN NaN];
end

ldb_new = ldb_new(2:end-1,:);

if write_to_file
    landboundary('write',ldb_out,ldb_new);
    disp('Done!');
end

varargout{1} = ldb_new;
if nargout > 1
    disp(' ');
    disp(['A total of ' num2str(nargout) ' output variables requested, script will only use the first!']);
    for ii = 2:nargout
        varargout{ii} = NaN;
    end
end








