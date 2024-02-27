function ddb_saveDelft3D_keyWordFile(fname, s)
%DDB_SAVEDELFT3D_KEYWORDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDelft3D_keyWordFile(fname, s)
%
%   Input:
%   fname =
%   s     =
%
%
%
%
%   Example
%   ddb_saveDelft3D_keyWordFile
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

% $Id: ddb_saveDelft3D_keyWordFile.m 15715 2019-09-11 13:21:53Z leijnse $
% $Date: 2019-09-11 21:21:53 +0800 (Wed, 11 Sep 2019) $
% $Author: leijnse $
% $Revision: 15715 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_saveDelft3D_keyWordFile.m $
% $Keywords: $

%% Write structure to Delft3D keyword file

fid=fopen(fname,'wt');

% Add header text
if isfield(s,'headerText')
    for i=1:length(s.headerText)
        fprintf(fid,'%s\n',s.headerText{i});
    end
    fprintf(fid,'%s\n','');
end

fldnames=fieldnames(s);

for i=1:length(fldnames)
    if ~strcmpi(fldnames{i},'headertext')
        if isfield(s.(fldnames{i}),'fieldLongName')
            fldlongname=s.(fldnames{i}).fieldLongName;
        else
            fldlongname=fldnames{i};
        end
        fldname=fldnames{i};
        nf=length(s.(fldname));
        for j=1:nf
            fprintf(fid,'%s\n',['[' fldlongname ']']);
            keywords=fieldnames(s.(fldname)(j));
            for k=1:length(keywords)
                valstr=[];
                keyw=keywords{k};
                
                if ~isempty(s.(fldname)(j).(keyw))
                    
                    if ~strcmpi(keyw,'fieldlongname')

                        if isfield(s.(fldname)(j).(keyw),'keyword')
                            keywstr=s.(fldname)(j).(keyw).keyword;
                            keywstr=[keywstr repmat(' ',1,17-length(keywstr))];
                        else
                            keywstr=[keyw repmat(' ',1,17-length(keyw))];
                        end
                        
                        % Value
                        if isfield(s.(fldname)(j).(keyw),'value')
                            % First determine type
                            if isfield(s.(fldname)(j).(keyw),'type')
                                tp=s.(fldname)(j).(keyw).type;
                            else
                                tp='string';
                            end
                            if ~isempty(s.(fldname)(j).(keyw).value)
                                switch lower(tp)
                                    case{'real'}
                                        valstr=num2str(s.(fldname)(j).(keyw).value,'%14.7e');
                                    case{'integer'}
                                        valstr=num2str(s.(fldname)(j).(keyw).value);
                                    case{'string'}
                                        valstr=s.(fldname)(j).(keyw).value;
                                        % Only put # around string in case of keyword
                                        % has unit OR comment
                                        %                            if ~isempty(findstr(valstr,' ')) && (isfield(s.(fldname)(j).(keyw),'unit') || isfield(s.(fldname)(j).(keyw),'comment'))
                                        if (isfield(s.(fldname)(j).(keyw),'unit') || isfield(s.(fldname)(j).(keyw),'comment'))
                                            valstr=['#' valstr '#'];
                                        end
                                    case{'boolean'}
                                        if s.(fldname)(j).(keyw).value
                                            valstr='true';
                                        else
                                            valstr='false';
                                        end
                                end
                                valstr=[valstr repmat(' ',1,17-length(valstr))];
                            end
                        else
                            % 'Simple' structure type without value and
                            % type fields
                            if ~isempty(s.(fldname)(j).(keyw))
                                if islogical(s.(fldname)(j).(keyw))
                                    if s.(fldname)(j).(keyw)
                                        valstr='true';
                                    else
                                        valstr='false';
                                    end
                                elseif isnumeric(s.(fldname)(j).(keyw))
                                    if round(s.(fldname)(j).(keyw))==s.(fldname)(j).(keyw)
                                        valstr=num2str(s.(fldname)(j).(keyw));
                                    else
                                        valstr=num2str(s.(fldname)(j).(keyw),'%14.7e');
                                    end
                                else
                                    valstr=s.(fldname)(j).(keyw);
                                end
                            end
                            valstr=[valstr repmat(' ',1,17-length(valstr))];
                        end
                        
                        % Unit                        
                        if isfield(s.(fldname)(j).(keyw),'unit')
                            unit=['[' s.(fldname)(j).(keyw).unit ']'];
                        else
                            unit='';
                        end
                        unit=[unit repmat(' ',1,12-length(unit))];
                        
                        % Comment
                        if isfield(s.(fldname)(j).(keyw),'comment')
                            if iscell(s.(fldname)(j).(keyw).comment)
                                comment=s.(fldname)(j).(keyw).comment{1};
                            else
                                comment=s.(fldname)(j).(keyw).comment;
                            end
                        else
                            comment='';
                        end
                        comment=[comment repmat(' ',1,12-length(comment))];
                        
                        valstr=[valstr repmat(' ',1,17-length(valstr))];
                        str=['   ' keywstr ' = ' valstr ' ' unit ' ' comment];
                        if iscell(str) == 1
                            fprintf(fid,'%s\n',str{:});
                        else
                            fprintf(fid,'%s\n',str);                            
                        end
                        
                        % Additional comments
                        if isfield(s.(fldname)(j).(keyw),'comment')
                            if iscell(s.(fldname)(j).(keyw).comment)
                                n=length(s.(fldname)(j).(keyw).comment);
                                if n>1
                                    for ic=2:n
                                        str=[repmat(' ',1,54) s.(fldname)(j).(keyw).comment{ic}];
                                        fprintf(fid,'%s\n',str);
                                    end
                                end
                            end
                        end
                        
                    end
                end
            end
        end
    end
    fprintf(fid,'%s\n','');
end
fclose(fid);

