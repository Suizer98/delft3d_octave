function OPT = txt2OPT(fname)
%TXT2OPT  Reads a txt file made with OPT2txt to an OPT structure
%
%   Meant to be used in conjuntion with OPT2txt, see OPT2txt for details
%
%   Syntax:
%   OPT = txt2OPT(fname)
%
%   Input:
%   fname = file to be read
%
%   Output:
%   OPT   = structure with options
%
%   Example
%   txt2OPT
%
%   See also: OPT2txt

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jan 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: txt2OPT.m 3893 2011-01-18 09:32:05Z thijs@damsma.net $
% $Date: 2011-01-18 17:32:05 +0800 (Tue, 18 Jan 2011) $
% $Author: thijs@damsma.net $
% $Revision: 3893 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/txt2OPT.m $
% $Keywords: $

%%
fid       = fopen(fname);
data      = char([]);
s         = fgetl(fid);
fieldname = [];
inCell    = false;
ind       = [];
while ~feof(fid)
    if length(s)>=10
        if strcmpi(s(1:10),'#FIELDNAME')
            if ~isempty(fieldname)&&~isempty(datatype);
                % strip trailing linebreaks from data
                data = regexprep(data,'[\n\r]+$','');
                % assign data to the field of that class
                if inCell 
                    if ~isempty(ind)
                        OPT.(fieldname){ind(1),ind(2),ind(3),ind(4),ind(5)} = assigndata(datatype,data);
                    end
                else
                    OPT.(fieldname) = assigndata(datatype,data);
                end
            end
            % reset data
            data       = char([]);
            % read fieldname
            
            % exit cell if fieldname does not begine with '#cell'
            if inCell
                if isempty(regexp(s(11:end),'#CELL','once'))
                    inCell = false;
                end
            end
            if inCell
                ind         = regexp(regexprep(s(11:end),'[ \t]+$',''),'{.*}','match');
                ind         =  textscan(ind{1}(2:end-1),'','collectOutput',true,'delimiter',',');
                ind         = [ind{1} ones(1,5)];
            else
                fieldname  = regexp(regexprep(s(11:end),'[ \t]+$',''),'[^= ].*','match');
                fieldname  = fieldname{1};
                try
                    OPT.(fieldname) = [];
                catch
                    error('The fieldname ''%s'' is invalid, check the contents of %s',fieldname,fname);
                end
                ind = [];
            end
            
            % read the next line
            s = fgetl(fid);
            if length(s)>=9
                if strcmpi(s(1:9),'#DATATYPE')
                    datatype = regexp(regexprep(s(11:end),'[ \t]+$',''),'[^= ].*','match');
                    datatype = datatype{1};
                    if strcmpi(datatype,'cell')
                        inCell = true;
                    end
                else
                    error('Datatype declaration expected after Fieldname ''%s'' in %s',fieldname,fname);
                end
            else
                error('Datatype declaration expected after Fieldname ''%s'' in %s',fieldname,fname);
            end
            s = fgetl(fid);
        else % read data
            data = [data s char(10)];
            s = fgetl(fid);
        end
    else
        data = [data s char(10)];
        s = fgetl(fid);
    end
end
fclose(fid);

% process last field
data = [data s char(10)];
if ~isempty(fieldname)&&~isempty(datatype);
    % strip trailing linebreaks from data
    data = regexprep(data,'[\n\r]+$','');
    % assign data to the field of that class
    if inCell
        if ~isempty(ind)
            OPT.(fieldname){ind(1),ind(2),ind(3),ind(4),ind(5)} = assigndata(datatype,data);
        end
    else
        OPT.(fieldname) = assigndata(datatype,data);
    end
end

function  contents = assigndata(datatype,data)
switch lower(datatype)
    case 'char'
        contents = data;
    case {  'double','single','logical','int8' ,'uint8','int16',...
            'uint16','int32' ,'uint32' ,'int64','uint64'}
        if isempty(regexp(data,'.*[\d\.].*', 'once'))
            contents = ([]);
        else
            contents = cell2mat(textscan(data,'','CollectOutput',true)) ;
        end
        switch lower(datatype)
            case 'double' ; contents = double (contents);
            case 'single' ; contents = single (contents);
            case 'logical'; contents = logical(contents);
            case 'int8'   ; contents = int8   (contents);
            case 'uint8'  ; contents = uint8  (contents);
            case 'int16'  ; contents = int16  (contents);
            case 'uint16' ; contents = uint16 (contents);
            case 'int32'  ; contents = int32  (contents);
            case 'uint32' ; contents = uint32 (contents);
            case 'int64'  ; contents = int64  (contents);
            case 'uint64' ; contents = uint64 (contents);
        end
    otherwise
        disp([datatype ' = unsupported']);
        contents = [];
end