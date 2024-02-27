function D = delft3d_io_dad(fname,varargin)
%DELFT3D_IO_DAD loads a delft3d online dredging and dumping keyword file
% *.dad (BETA release)
%
%  D   = delft3d_io_dad(fname)
%
% loads contents of *.dad file into struct D
%
% Example: plot the dump areas based on info from .dad and .ldb files
%   dad_fname = 'mydad.dad';
%   dadldb_fname = 'mydad.ldb'
%   dad = delf3d_io_dad(dad_fname);
%   dadldb = tekal('read',dadldb_fname,'loaddata');
%   figure; hold on;
%   for i = 1:length(dadldb.Field)
%       index = find(ismember(cellstr(dad.Dump.UniqueNames),dadldb.Field(i).Name));
%       if index
%           plot(dadldb.Field(i).Data(:,1),dadldb.Field(i).Data(:,2),'c-','linewidth',1);
%       end
%   end
%
%See also: delft3d, inivalue, tekal, landboundary

%   --------------------------------------------------------------------
%   Copyright (C) 2011 ARCADIS
%       Bart Grasmeijer
%
%       <bart.grasmeijer@arcadis.nl>
%
%       ARCADIS
%       Hanzelaan 286
%       8017 JJ,  Zwolle
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id: delft3d_io_dad.m 11073 2014-08-28 09:00:36Z bartgrasmeijer.x $
% $Date: 2014-08-28 17:00:36 +0800 (Thu, 28 Aug 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 11073 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_dad.m $
% $Keywords: dredge dump dad$

OPT.commentchar = '*';

if ~odd(nargin)
    OPT = setproperty(OPT,varargin{2:end});
else
    OPT = setproperty(OPT,varargin{:});
end

D = inivalue_dad(fname,struct('commentchar',OPT.commentchar));

DumpNames = [];
for i = 1:length(D.Dredge)
    DumpNames = [DumpNames; {D.Dredge(i).Dump}];
end
D.Dump.Names = char(DumpNames);
D.Dump.UniqueNames = unique(char(DumpNames),'rows');


function varargout=inivalue_dad(fileName,varargin)
%INIVALUE   load key, section or entire contents of *.ini keyword file
%
%    keyValue      = inivalue(fileName, sectionName, keyName)
%    sectionValues = inivalue(fileName, sectionName)
%    fileValues    = inivalue(fileName)
%
% reads values of one keyName, one sectionName or entire file from fileName.
%
% Example: a sample *.ini file (sample.ini) may have entries:
%
%    +------------
%    |  [XYZ]
%    |  abc = 123
%    |  [ZZZ]
%    |  abc = 890
%    +-------------
%
%    inivalue('sample.ini','XYZ','abc') -> '123'
%    inivalue('sample.ini','ZZZ','abc') -> '890'
%
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=123
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=890
%
%    inivalue('sample.ini')             ->  ans.XYZ.abc=123
%                                           ans.ZZZ.abc=890
%
% if sectionName or the keyName is not found, it returns []
% if the keyName is empty, the entire section is returned as struct.
% if the sectionName is empty, the entire file is returned as struct.
%
% Note that a *.url file is has the *.ini file format.
% Optionally a struct with field 'commentchar' can be passed to skip comment lines.
%
%See also: textread, setproperty, xml_read, xml_load

% Based on code fragments from: http://www.mathworks.com/matlabcentral/fileexchange/5182-ini-file-reading-utility
% Created By: Irtaza Barlas
% Created On: June 9, 2004
% Created For: IAS Inc.

OPT.commentchar = '';

fid = 0;

sectionName = [];
keyName     = [];
out = struct;

if nargin > 1;
    if isstruct(varargin{1})
        OPT = setproperty(OPT,varargin{1});
    else
        sectionName = varargin{1};
    end
end

if nargin > 2;
    if isstruct(varargin{2})
        OPT = setproperty(OPT,varargin{2});
    else
        keyName = varargin{2};
    end
end

if nargin > 3;
    if isstruct(varargin{3})
        OPT = setproperty(OPT,varargin{3});
    else
        error('');
    end
end

if exist(fileName) ~= 2
    error(['file finding file: ', fileName]);
end;

fid = fopen(fileName);
if fid<=0
    error(['file opening file: ', fileName]);
    floce(fid)
end;

sectionString = ['[' sectionName ']'];
sectionFound  = 0;
sectioni = 0;
rec           = fgetl_no_comment_line(fid,OPT.commentchar);
nrofoccurrences(1) = 1;

while sectionFound~=1
    nrofDumps = 0;
    if isempty(rec)
        rec = fgetl_no_comment_line(fid,OPT.commentchar);
        continue;
    elseif rec==-1
        break;
    end;
    
    if isempty(sectionName) | strcmp(strtrim(rec), sectionString) > 0 % allow leading spaces
        
        if isempty(sectionName)
            i0=find(rec=='[');
            i1=find(rec==']');
            sectioni = sectioni+1;
            section{sectioni} = cellstr(rec(i0+1:i1-1));

            nrofoccur = 1;
            nrofoccurrences(sectioni) = 1;
            for tmpi = 1:sectioni-1
                if strcmp(section{sectioni},section{tmpi})
                    nrofoccur = nrofoccur+1;
                    nrofoccurrences(sectioni) = nrofoccur;
                    nrofDumps = 0;
                end
            end

        else
            section = sectionName;
        end
        
        %% look for the key
        
        sectionFound = 1;
        keyFound     = 0;
        rec          = fgetl_no_comment_line(fid,OPT.commentchar);
        
        while keyFound==0
            
            if isempty(rec)==1
                rec = fgetl_no_comment_line(fid,OPT.commentchar);
                continue;
            end;
            if rec==-1 % EOF
                break;
            end;
            if isempty(strtrim(rec)) == 0
                rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing
                if rec(1)=='[' % next section
                    break;
                end;
                
                %% look for the value
                
                eq_idx=find(rec=='=');
                if ~isempty(eq_idx) %~=1 & eq_idx(1)>1
                    key=strtrim(rec(1:eq_idx(1)-1));
                    if strcmp(key,'Dump')
                        nrofDumps = nrofDumps+1;
                    end
%                     nrofsamekeys = nrofsamekeys+1;
                    if isempty(keyName) | strcmp(key, keyName)>0
                        [rs, cs]=size(rec);
                        if eq_idx(1)>=cs
                            keyValue = '';
                        else
                            keyValue=strtrim(rec(eq_idx(1)+1:end));
                        end;
                        if strcmp(key, keyName)>0
                            keyFound = 1;
                            out      = keyValue;
                            break;
                        else
                            if isempty(sectionName)
                                disp(char(section{sectioni}));
                                disp(['nrofoccurrences= ',num2str((nrofoccurrences(sectioni)))]);
                                disp(['key = ', (mkvar(key))]);
                                if strcmp(key,'Dump')
                                    out.(mkvar(char(section{sectioni})))(nrofoccurrences(sectioni)).(mkvar(key))(nrofDumps,1:length(keyValue)) = keyValue; % in case section name has spaces etc. use mkvar()
                                else if strcmp(key,'Percentage')
                                        out.(mkvar(char(section{sectioni})))(nrofoccurrences(sectioni)).(mkvar(key))(nrofDumps,1) = str2num(keyValue); % in case section name has spaces etc. use mkvar()
                                    else
                                        out.(mkvar(char(section{sectioni})))(nrofoccurrences(sectioni)).(mkvar(key)) = keyValue; % in case section name has spaces etc. use mkvar()
                                    end
                                end
                            else
                                out.(mkvar(key)) = keyValue;
                            end
                        end
                        
                    end;
                end;
            end;
            
            rec = fgetl_no_comment_line(fid,OPT.commentchar);
            if rec==-1
                break
            end
            
            rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing
            
            if ~isempty(rec)
                if rec(1)=='[' % next section
                    
                    if isempty(sectionName)
                        i0=find(rec=='[');
                        i1=find(rec==']');
                        sectioni = sectioni+1;
                        section{sectioni} = cellstr(rec(i0+1:i1-1));

                        nrofoccur = 1;
                        nrofoccurrences(sectioni) = 1;
                        for tmpi = 1:sectioni-1
                            if strcmp(char(section{sectioni}),char(section{tmpi}))
                                nrofoccur = nrofoccur+1;
                                nrofoccurrences(sectioni) = nrofoccur;
                                nrofDumps = 0;
                            end
                        end
                        
                    else
                        section = sectionName;
                    end
                    
                    rec = fgetl_no_comment_line(fid,OPT.commentchar);
                    
                end
            else
                break
            end
            
        end; % keyFound
        break;
    end; % sectionString
    rec = fgetl_no_comment_line(fid,OPT.commentchar);
end; % sectionFound
fclose(fid);
varargout = {out};
