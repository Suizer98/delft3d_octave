function succes = OPT2txt(OPT, fname)
%OPT2TXT  Saves an OPT structure to a legible file
%
%   This function is intended to save an OPT structure to a legible file
%   that can be processed by txt2OPT. Function does not use any eval
%   statements. 
%   Following numeric classes are supported:
%     * char:             only one dimensional char arrays are supported
%     * double,single,logical,int8,uint8,int16,uint16,int32,uint32,
%       int64,uint64      1D and 2D arrays are supported. 
%     * Cell arrays containing any of these classes are supported, but
%       nested cell arrays are not (yet).
%     * function_handle:  not supported (because it would require an eval
%                         to process)  
%     * struct:           not supported (might be added)
%
%   Syntax:
%   succes = OPT2txt(OPT, fname)
%
%   Input:
%   OPT    = structure to save
%   fname  = filename
%
%   Output:
%   succes = true or false
%
%   Example
%   OPT2txt
%
%   See also: txt2OPT

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

% $Id: OPT2txt.m 3893 2011-01-18 09:32:05Z thijs@damsma.net $
% $Date: 2011-01-18 17:32:05 +0800 (Tue, 18 Jan 2011) $
% $Author: thijs@damsma.net $
% $Revision: 3893 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/OPT2txt.m $
% $Keywords: $

%%
fid = fopen(fname,'w+');
fields =  fieldnames(OPT);
for ii = 1:length(fields);
  fieldname = fields{ii};  
  datatype  = class(OPT.(fields{ii}));
  data      = OPT.(fields{ii});
  printfield(fid,fieldname,datatype,data);
end
fclose(fid);
% now read the created file to test it
OPT2 = txt2OPT(fname);
fields = fieldnames(OPT);
testresult = false(size(fields));
for ii = 1:length(fields);
    testresult(ii) = isequalwithequalnans(OPT.(fields{ii}),OPT2.(fields{ii}));
end
succes = all(testresult);
if ~succes
    failed_fields = sprintf('%s, ', fields{~testresult});
    warning('some fields could not be saved correctly: %s',failed_fields(1:end-2)) %#ok<WNTAG>
end

function printfield(fid,fieldname,datatype,data)

fprintf(fid,'\r\n#FIELDNAME = %s\r\n#DATATYPE  = %s\r\n',fieldname,datatype);
if isempty(data)
    fprintf(fid,'\r\n');
else
    switch datatype
        case {  'double','single','logical','int8' ,'uint8','int16',...
                'uint16','int32' ,'uint32' ,'int64','uint64'}
            s = num2str(data);
            for jj = 1:size(s,1)
                fprintf(fid,'%s\r\n',s(jj,:));
            end
        case {'char'}
            fprintf(fid,'%s\r\n',data);
        case {'cell'}
            for ii = 1:numel(data)
                [indices{1:ndims(data)}] = ind2sub(size(data),ii);
                index_string = sprintf('%d,',indices{:});
               c.fieldname = sprintf('#CELL{%s}',index_string(1:end-1));
               c.data      = data{ii};
               c.datatype  = class(data{ii});
               printfield(fid,c.fieldname,c.datatype,c.data)
            end
        otherwise
            warning('OPT.%s is of the unsupported class: ', fieldname, datatype); %#ok<WNTAG>
    end
end
