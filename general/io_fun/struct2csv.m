function varargout = struct2csv(fname,S,varargin)
%STRUCT2CSV   Save 1D data + fieldnames from matlab struct into csv file
%
% STRUCT2CSV(filename,struct) converts a matlab struct
% with 1D numerical fields !! to an csv file. Non-numeric
% arrays are allowed.
% Character arrays can be 2D. By default the 2nd dimension of all
% 1D arrays should be  equal, and are taken as the column
% length in the csv file.
%
%  Example of resulting *.csv file:
%
%  +---------------+---------------+---------------+---------------+
% <|# textline 1   |               |               |               |> optional
% <|# textline 2   |               |               |               |> optional
% <|# textline 3   |               |               |               |> optional
%  | columnname_01 | columnname_02 | columnname_03 | columnname_04 |
% <| units         | units         | units         | units         |> optional
%  | number/string | number/string | number/string | number/string |
%  | number/string | number/string | number/string | number/string |
%  | number/string | number/string | number/string | number/string |
%  | ...           | ...           | ...           | ...           |
%  | number/string | number/string | number/string | number/string |
%  +---------------+---------------+---------------+---------------+
%
% * Is not (by default) reciprocal of csv2struct (due to units line 
%   below column headers) and cell aray for 2D char arrays
% * Use orderfields to change column order
% * replaces char(10) with \n
%
% STRUCT2CSV(filename,struct,<keyword,value>) implemented key words:
% * units        - 0 = not,
%                - 1 = empty line
%                - cell array is yes
%                - struct with a fieldnames matching the struct field names is yes
% * coldimnum    dimension of fieldname input arrays to be used as column in excel (1 or 2)
%                (default 2) after option oneD has optionally reshaped so the 1st dimension is 1.
% * coldimchar   dimension of fieldname input arrays to be used as column in excel (1 or 2)
%                (default 2) after option oneD has optionally reshaped so the 1st dimension is 1.
% * oneD         makes sure that both numeric matrix columns and matrix rows are written as Excel
%                columns (default 1), only works for arrays where either 1st or 2nd dimension has lenght 1..
% * header       cell array of comment lines above column names (see also keyword commentchar)
% * overwrite    which can be
%                'o' = overwrite (1)
%                'c' = cancel
%                'p' = prompt (default, after which o/a/c can be chosen) (0)
% * commentchar  character to append to start of comment (header) line (default '#')
% * sorfields    flag for sorting the fields before sending to the output (default = 0)
% * column_names struct with name of columns in csv file (may contain spaces and special characters)
%
% [success]   = STRUCT2CSV(...)
% [success,M] = STRUCT2CSV(...) where M is the cell array passed to WRITETABLE.
%
% See also: CSV2STRUCT, STRUCT2XLS, XLS2STRUCT, TABLE, TEXTREAD

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       ronald.vanderhout@vanoord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
%
%   Copyright (C) 2006-2011 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Oct 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: struct2csv.m 12744 2016-05-20 12:10:46Z rho.x $
% $Date: 2016-05-20 20:10:46 +0800 (Fri, 20 May 2016) $
% $Author: rho.x $
% $Revision: 12744 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/struct2csv.m $
% $Keywords: $

%% Jan 15 2008: added logicals

%% Keywords

OPT.coldimchar   = 1;
OPT.coldimnum    = 1; %2;
OPT.addunits     = 0;
OPT.units        = [];
OPT.header       = {}; %{['This file has been created with struct2csv.m and writetable.m @ ',datestr(now)]};
OPT.oned         = 1; % reshape 1D matlab rows and columns into excel columns (numeric, logical and cellstr)
OPT.commentchar  = '#';
OPT.overwrite    = 'p'; %prompt
OPT.warning      = 0;
OPT.sortfields   = 0;
OPT.replace      = {{char(10),'\n'}};
OPT.column_names = [];

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin{:});

if ischar(OPT.header)
    OPT.header = cellstr(OPT.header);
end

%% Check if file already exists

if exist(fname,'file')==2
    
    if strcmp(OPT.overwrite,'p') || OPT.overwrite==0 || ~OPT.overwrite
        disp(['File ',fname,' alreay exists. '])
        OPT.overwrite = input('Overwrite/cancel ? (o/c): ','s');
        % for some reason input in Matlab R14 SP3 removes slashes
        % OPT.overwrite = input(['File ',fname,' alreay exists. Overwrite/cancel ? (o/a/c)'],'s');
        while isempty(strfind('oac',OPT.overwrite))
            OPT.overwrite = input('Overwrite/cancel ? (o/c): ','s');
        end
    end
    
    if strcmpi(OPT.overwrite,'o') || OPT.overwrite==1 || OPT.overwrite
        try 
            delete(fname)
        catch ME
            returnmessage(1,'File: %s, is NOT UPDATED! Because of the following error:\n    %s\n', fname, ME.message)
            return
        end
        returnmessage(1,'File %s, is overwritten as it alreay exists.\n',fname)
    end
    
    if strcmpi(OPT.overwrite,'c')
        if nargout==0
            error(['File ',fname,' not saved as it alreay exists.'])
        else
            %             success = -2;
            returnmessage(1,'File %s, is not saved as it alreay exists.\n',fname)
        end
    end
    
else
    OPT.overwrite = 'o'; % create
end


%% Transform into cell array
%  that can contain all 1D arrays

fldnames  = fieldnames(S);
if OPT.sortfields
    fldnames  = sort(fldnames);
end

nfld      = length(fldnames);

%% Make 1D vectors (rowwise and columnwise) 1D in right dimension for excel columns

if OPT.oned
    for ifld=1:nfld
        fldname   = char(fldnames(ifld));
        
        if iscell(S.(fldname))
            if all(cellfun(@isnumeric,S.(fldname))) || all(cellfun(@islogical,S.(fldname)))
                %Convert to numeric
                S.(fldname) = cell2mat(S.(fldname));
            end
        end
        
        if isnumeric(S.(fldname)) || islogical(S.(fldname))     
            if length(size(S.(fldname)))==2  % Meaning 2 dimensional
                if (size(S.(fldname),1)==1)
                    S.(fldname) = S.(fldname)';
                    if OPT.warning
                        returnmessage(1,'Warning: in %s, field ''%s'' has been transposed to fit into a column.\n', mfilename,fldname)
                    end
                elseif (size(S.(fldname),2)==2)
                    %Convert to two colums
                    data = S.(fldname);
                    S.(fldname) = data(:,1);
                    colname2 = [fldname '2'];
                    S.(colname2)= data(:,2);
                end
            end
            % for some reason cellstr needs to be [n x 1] instead of [1 x n]
        elseif iscellstr(S.(fldname))
            if length(size(S.(fldname)))==2
                if (size(S.(fldname),1)==1)
                    S.(fldname) = S.(fldname)';
                    if OPT.warning
                        returnmessage(1,'Warning: in %s, field ''%s'' has been transposed to fit into a column.\n', mfilename,fldname)
                    end
                end
            end
        end
    end
end

% re-define fieldnames
fldnames  = fieldnames(S);
if OPT.sortfields
    fldnames  = sort(fldnames);
end
nfld      = length(fldnames);

%% Initialize cell array

maxlength = 0;
for ifld=1:nfld
    fldname   = char(fldnames(ifld));
    maxlength = max(maxlength,length(S.(fldname)));
end


nheader = length(OPT.header);
nextra  = nheader + 1 + (OPT.addunits || OPT.addunits==1 || iscell(OPT.addunits));
M       = cell (maxlength + nextra,nfld);

%% Add header and column names

for iheader=1:nheader
    M{iheader,1} = [OPT.commentchar,' ',OPT.header{iheader}];
end

%% Fill cell array

for ifld=1:nfld
    
    fldname             = char(fldnames(ifld));
    fldsize             = size(S.(fldname));
    
    if isempty(OPT.column_names)
        M{nheader + 1,ifld}    = fldname;
    else
        M{nheader + 1,ifld}    = OPT.column_names.(fldname);
    end    
    
    if ~isempty(OPT.units)
        if iscell(OPT.units)
            M{nheader + 2,ifld}    = char(OPT.units{ifld});
        elseif isstruct(OPT.units)
            if isfield(OPT.units,fldname)
                M{nheader + 2,ifld}    = OPT.units.(fldname);
            end
        end
    end
       
    if iscellstr(S.(fldname))
        S.(fldname) = char(S.(fldname));
    end
    
    if isnumeric(S.(fldname)) || islogical(S.(fldname))
               
        if OPT.coldimnum==1
            for irow=1:1:fldsize(OPT.coldimnum)
                M{irow + nextra,ifld} = S.(fldname)(irow,:);
            end
        elseif OPT.coldimnum==2
            for irow=1:1:fldsize(OPT.coldimnum)
                M{irow + nextra,ifld} = S.(fldname)(:,irow);
            end
        end
    elseif ischar(S.(fldname))
                
        if OPT.coldimchar==1
            for irow=1:1:fldsize(OPT.coldimchar)
                M{irow + nextra,ifld} = S.(fldname)(irow,:);
            end
        elseif OPT.coldimchar==2
            for irow=1:1:fldsize(OPT.coldimchar)
                M{irow + nextra,ifld} = S.(fldname)(:,irow);
            end
        end
    end
    
    %end
end

try
    % R2014 way
    %       T = cell2table(M);
    %       writetable(T,path2os(fname))
    
    % R2012 way (also faster)
    T = M;
    
    % Convert empty cells to empty strings
    idx    = cellfun(@isempty,M);
    T(idx) = {' '};
    
    % Convert numeric to strings
    idx    = cellfun(@isnumeric,M);
    T(idx) = cellfun(@num2str, M(idx),'UniformOutput',false);
    
    % Write
    fileID = fopen(fname,'w+');
    [nrows,ncols] = size(T);  
    for row = 1:nrows
        %Create a single text row
        tmp = strcat(T(row,:),repmat({', '},1,ncols));
        tmp = [tmp{:}];
        fprintf(fileID,'%s\n',tmp);
    end
    fclose(fileID);
    
    success = true;
    
catch ME
    disp(ME.message)
    success = false;
end

if nargout==1
    varargout = {success};
elseif nargout==2
    varargout = {success,M};
end

%% EOF