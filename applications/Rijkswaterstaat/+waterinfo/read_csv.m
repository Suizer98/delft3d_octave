function [OUT] = read_csv(fname)
%read_csv  Function to read .csv files MANUALLY downloaded from waterinfo
%
%   Syntax:
%   OUT = waterinfo.read_csv(fname)
%
%   Input:
%   fname           filename of .csv file
%
%   Output:
%   OUT             struct with fieldnames from the header of csv file
%
%   Example
%   [OUT] = waterinfo.read_csv('d:\waterinfo.csv\')
%
%   NOTES:
%   Script can deal with multiple variables in csv file, these are added as
%   GROOTHEID_OMSCHRJVING_1, GROOTHEID_OMSCHRJVING_2, GROOTHEID_OMSCHRJVING_n
%   the values as
%   NUMERIEKEWAARDE_1, NUMERIEKEWAARDE_2, NUMERIEKEWAARDE_n
%   and the corresponding date entries as
%   datenum_1, datenum_2, datenum_n
%
%   Function can deal with multiple stations, the names are added to
%   MEETPUNT_IDENTIFICATIE
%   the datenum and value fields are appended as
%   NUMERIEKEWAARDE_n{:,x}
%
%   Function can deal with multiple samplings heights, the heights are added to
%   BEMONSTERINGSHOOGTE
%   the datenum and value fields are appended as
%   NUMERIEKEWAARDE_n{x,:}
%
%   csv files downloaded from https://waterinfo.rws.nl/.
%
%   See also
%   waterinfo.read_csv

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       schrijve
%
%       reinier.schrijvershof@deltares.nl
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
% Created: 08 Apr 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: $
% $Date: 8 Apr 2019
% $Author: schrijve
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);

%% 1) Read header

% Header
delimiter   = ';';
frmt        = repmat('%s',1,50);
fid         = fopen(fname,'r');
header      = textscan(fid,frmt,1,...
    'Delimiter',delimiter);
fclose(fid);
header      = vertcat(header{:});
% ncols       = find(contains(header,'TAXON_NAME'));
% header(ncols+1:end) = [];
id = cellfun(@isempty,header);
header(id) = [];
header      = strrep(header,' ',''); % Remove whitespaces in header fields
% Change header charcters not valid from fieldnames
chars = {'(',')','/','\','.',';'};
for i = 1:length(chars)
    header = strrep(header,chars{i},'_');
end

%% 2) Read data
clear OUT;
% Empty struct
OUT        = cell2struct(num2cell(NaN(size(header))),header',1);

% Format specification
frmt        = cellstr(repmat('%s',length(header),1));

id1       = find(strcmp(header,'WAARNEMINGDATUM'));
id2       = find(contains(header,'WAARNEMINGTIJD'));
id3       = find(strcmp(header,'NUMERIEKEWAARDE'));
frmt{id1} = '%{dd-MM-yyyy}D';
frmt{id2} = '%{HH:mm:ss}D';
frmt{id3} = '%q';
frmt        = horzcat(frmt{:});

try
    delimiter = ';';
    startRow = 2;
    fid = fopen(fname,'r');
    data = textscan(fid,frmt,...
        'Delimiter',delimiter,...
        'HeaderLines',startRow-1,...
        'DateLocale','nl_NL',...
        'ReturnOnError',false);
    fclose(fid);
catch % time in other column
    id2       = find(strcmp(header,'REFERENTIE'));
    frmt        = cellstr(repmat('%s',length(header),1));
    frmt{id1} = '%{dd-MM-yyyy}D';
    frmt{id2} = '%{HH:mm:ss}D';
    frmt{id3} = '%q';
    frmt        = horzcat(frmt{:});
    
    delimiter = ';';
    startRow = 2;
    fid = fopen(fname,'r');
    data = textscan(fid,frmt,...
        'Delimiter',delimiter,...
        'HeaderLines',startRow-1,...
        'DateLocale','nl_NL',...
        'ReturnOnError',false);
    fclose(fid);
    
end

flds = fieldnames(OUT);
for i = 1:length(flds)
    f = flds{i};
    tmp = data{i};
    
    if length(unique(tmp)) == 1
        if cellfun('isempty',unique(tmp))
            OUT.(f) = [];
        elseif iscellstr(unique(tmp))
            OUT.(f) = unique(tmp);
        end
    elseif length(unique(tmp)) > 1
        
        

        if strcmp(f,'NUMERIEKEWAARDE') % Values
            % Replace decimal separator
            if any(contains(data{i},','))
                data{i} = strrep(data{i},',','.');
            end
            
            idv         = contains(flds,'GROOTHEID_OMSCHRIJVING');
            vars        = unique(data{idv});
            nvars       = length(vars);
            ids         = contains(flds,'MEETPUNT_IDENTIFICATIE');
            stats       = unique(data{ids});
            nstats      = length(stats);
            idh         = contains(flds,'BEMONSTERINGSHOOGTE');
            heights     = unique(data{idh});
            nheights    = length(heights);
            
            
            for j = 1:nvars % Loop through variables
                fvar = sprintf('%s_%d',f,j);
                fdat = sprintf('datenum_%d',j);
                v = vars{j};
                vlocs    = strcmp(data{idv},v);
                
                for k = 1:nstats % Loop through monitoring stations
                    s = stats{k};
                    slocs = strcmp(data{ids},s);
                    
                    
                    for m = 1:nheights
                        h = heights{m};
                        hlocs = strcmp(data{idh},h);                      
                        entries = vlocs & slocs & hlocs;

                        % Date entries
                        OUT.(fvar){m,k} = str2double(data{i}(entries));
                        OUT.(fdat){m,k} = datenum([year(data{id1}(entries)),...
                            month(data{id1}(entries)),...
                            day(data{id1}(entries)),...
                            hour(data{id2}(entries)),...
                            minute(data{id2}(entries)),...
                            second(data{id2}(entries))]);
                    end
                    
                end
            end
        else
            OUT.(f) = unique(data{i});
        end
        
    end
    
end





%% 3) Calculations


for j = 1:nvars
    v = sprintf('NUMERIEKEWAARDE_%d',j);
    d = sprintf('datenum_%d',j);
    for k = 1:size(OUT.(v),2)
        for m = 1:size(OUT.(v),1)
            
            % Replace dummy values with NaN
            % Note: dummy value changes with variable
            if any(OUT.(v){m,k} > 1e6) % Most likely dummy values
                dum = max(OUT.(v){m,k});
                OUT.(v){m,k}(OUT.(v){m,k} == dum) = NaN;
                fprintf('\tDummy values %d are set to NaN\n',dum);
            end
            
            % Check if time is sorted and sort otherwise
            if diff(OUT.(d){m,k}) < 0
                [OUT.(d){m,k},sid] = sort(OUT.(d){m,k});
            end
            
            % find double date entries on a single value
            if length(OUT.(d){m,k}) > length(unique(OUT.(d){m,k}))
                
                fprintf('\tDouble date entries found and removed\n');
                [OUT.OUT.(d){m,k},~,~] = unique(OUT.(d){m,k});
            end
        end
    end
end

% To add
% % Remove outliers
% for j = 1:nvars
%     v = sprintf('NUMERIEKEWAARDE_%d',j);
%     find(abs(OUT.(v)) > nanmean(OUT.(v)) +3*nanstd(OUT.(v)))
% end



%% 4) Write information
clc;
[fpath,name,ext] = fileparts(fname);

fprintf('\tDone reading %s%s\n',name,ext);
fprintf('\t%d monitoring station(s) was/were found and processed:\n',nstats);
fprintf('\t- %s\n',OUT.MEETPUNT_IDENTIFICATIE{:})
fprintf('\t%d variable(s) was/were found and processed:\n',nvars);
fprintf('\t- %s\n',OUT.GROOTHEID_OMSCHRIJVING{:})
fprintf('\t%d sampling height(s) was/were found and processed:\n',nheights);
fprintf('\t- %s\n',OUT.BEMONSTERINGSHOOGTE{:})

fprintf('\n');

return

