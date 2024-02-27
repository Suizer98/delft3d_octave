function Info = ddb_bct_io(cmd, varargin)
%DDB_BCT_IO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   Info = ddb_bct_io(cmd, varargin)
%
%   Input:
%   cmd      =
%   varargin =
%
%   Output:
%   Info     =
%
%   Example
%   ddb_bct_io
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_bct_io.m 18380 2022-09-23 07:46:21Z kaaij $
% $Date: 2022-09-23 15:46:21 +0800 (Fri, 23 Sep 2022) $
% $Author: kaaij $
% $Revision: 18380 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/fileio/ddb_bct_io.m $
% $Keywords: $

%% BCT_IO Read/write boundary condition tables
%
%  Info=ddb_bct_io('read',filename);
%
%  ddb_bct_io('write',filename,Info);
%

switch lower(cmd),
    case 'read',
        Info=Local_read_bct(varargin{:});
    case 'write',
        OK=Local_write_bct(varargin{1},varargin{2},varargin{3:end});
        if nargout>0,
            Info=OK;
        elseif OK<0,
            error('Error writing file');
        end;
end;


function Info=Local_read_bct(filename),

fid=fopen(filename,'r');
Info.Check='NotOK';
Info.FileName=filename;
Info.NTables=0;
i=1;

floc=ftell(fid);
Line=fgetl(fid);
while ischar(Line) & ~isempty(Line) & Line(1)=='#',
    floc=ftell(fid);
    Line=fgetl(fid);
end;
fseek(fid,floc,-1);

while ~isempty(fscanf(fid,'table-name %['']')),
    Info.Table(i).Name=deblank(strextract(fgetl(fid)));

    if isempty(fscanf(fid,'contents %['']')),
        fclose(fid);
        return;
    end;
    Info.Table(i).Contents=deblank(strextract(fgetl(fid)));
    %% TK reading doesnot go properly when location name starts with lo(cation)
%    if isempty(fscanf(fid,'location %['']')),
%        fclose(fid);
%        return;
%    end;
    Line = fgetl(fid);
    index = strfind(Line,'''');
    if isempty(index)
        fclose(fid);
        return;
    end
    Info.Table(i).Location=deblank(Line(index(1) + 1:index(2)-1));

    if isempty(fscanf(fid,'time-function %['']')),
        fclose(fid);
        return;
    end;
    Info.Table(i).TimeFunction=deblank(strextract(fgetl(fid)));

    if isempty(fscanf(fid,'reference-tim%[e]')),
        fclose(fid);
        return;
    end;
    Info.Table(i).ReferenceTime=fscanf(fid,'%i',1);
    fgetl(fid); % skip remainder of line

    if isempty(fscanf(fid,'time-unit %['']')),
        fclose(fid);
        return;
    end;
    Info.Table(i).TimeUnit=deblank(strextract(fgetl(fid)));

    if isempty(fscanf(fid,'interpolation %['']')),
        fclose(fid);
        return;
    end;
    Info.Table(i).Interpolation=deblank(strextract(fgetl(fid)));

    j=0;
    while ~isempty(fscanf(fid,'parameter %['']')),
        j=j+1;
        [Info.Table(i).Parameter(j).Name,Part2]=strextract(fgetl(fid));
        Info.Table(i).Parameter(j).Name=deblank(Info.Table(i).Parameter(j).Name);
        Unit=findstr(Part2,'''');
        if isempty(Unit) % no quotes
            Unit=findstr(lower(Part2),'unit');
            if isempty(Unit) % no string 'unit'
                % nothing to do, Part2 most likely already contains the unit string
            else % remove 'unit'
                Part2=Part2((Unit(1)+4):end);
            end
            Info.Table(i).Parameter(j).Unit=deblank(Part2);
        else
            Part2=Part2((Unit(1)+1):end);
            Info.Table(i).Parameter(j).Unit=deblank(strextract(Part2));
        end
    end;
    NPar=j;

    if isempty(fscanf(fid,'records-in-tabl%[e]')),
        fclose(fid);
        return;
    end;
    NRec=fscanf(fid,'%i',1);
    Info.Table(i).Data=transpose(fscanf(fid,'%f',[NPar NRec]));
    fgetl(fid); % skip remainder of line

    i=i+1;

    Info.NTables=Info.NTables+1;
end;
if Info.NTables==0
    error('No tables in bct file?')
end
Info.Check='OK';
fclose(fid);



function [Str1,remainder]=strextract(Str,Quote);
if nargin==1,
    Quote='''';
end;

Q=findstr(Str,Quote);
if isempty(Q),
    warning('No ending quote found in string.');
    Str1=Str;
    remainder='';
    return;
end;

i=1;
done=0;
while ~done,
    if i<length(Q),
        if Q(i+1)==Q(i), % two quotes representing just one quote
            i=i+2;
        else,
            done=1;
        end;
    elseif i==length(Q),
        done=1;
    else,
        warning('No ending quote found in string.');
        Str1=strrep(Str,[Quote Quote],Quote);
        remainder='';
        return;
    end;
end;

Str1=strrep(Str(1:(Q(i)-1)),[Quote Quote],Quote);
remainder=Str((Q(i)+1):end);


function OK=Local_write_bct(filename,Info,varargin)

OK=0;
OPT.append = false;
OPT = setproperty(OPT,varargin);
if ~OPT.append fid=fopen(filename,'w'); else fid=fopen(filename,'a'); end
% When the file is written using a fixed line/record length this is
% shown in the first line
%fprintf(fid,'# %i\n',linelength);

for i=1:length(Info.Table),

    fprintf(fid,'table-name          ''%s''\n',Info.Table(i).Name);
    fprintf(fid,'contents            ''%s''\n',Info.Table(i).Contents);
    fprintf(fid,'location            ''%s''\n',Info.Table(i).Location);
    fprintf(fid,'time-function       ''%s''\n',Info.Table(i).TimeFunction);
    fprintf(fid,'reference-time       %i\n',Info.Table(i).ReferenceTime);
    fprintf(fid,'time-unit           ''%s''\n',Info.Table(i).TimeUnit);
    fprintf(fid,'interpolation       ''%s''\n',Info.Table(i).Interpolation);

    for j=1:length(Info.Table(i).Parameter),
        fprintf(fid,'parameter           ''%s'' unit ''%s''\n', ...
            Info.Table(i).Parameter(j).Name, ...
            Info.Table(i).Parameter(j).Unit);
    end;

    fprintf(fid,'records-in-table     %i\n',size(Info.Table(i).Data,1));
    fprintf(fid,['%15.2f ' repmat('%13.5e ',1,length(Info.Table(i).Parameter)-1) '\n'], ...
        transpose(Info.Table(i).Data));
end;
fclose(fid);
OK=1;

