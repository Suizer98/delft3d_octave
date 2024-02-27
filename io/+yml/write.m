function result = write(data, filename, flowstyle)
% Writes a struct to a YAML file 
%   Functions are copied from Google Code and modified to a name space 
%   structure. The test are updated and complimented.
%
%   Source: https://code.google.com/archive/p/yamlmatlab/
%           YAMLMatlab_0.4.3
%
%   Function recursively walks through a Matlab hierarchy and converts it
%   to the hierarchy of java.util.ArrayListS and java.util.MapS. Then calls
%   Snakeyaml to write it to a file.
%
%   Input:  data      = data to be written, can be cell or struct etc.
%           filename  = empty or filename
%           flowstyle = output style (0,1)
%
%   Output: result    = if filename isempty: output text  
%                     = else empty (but file is written)
%
%   Example
%   	fname  = C:\checkouts\oetools\trunk\matlab\io\+yml\examples\ibm_example.yml;
%       result = yml.read(fname);
%   	fname2 = C:\checkouts\oetools\trunk\matlab\io\+yml\examples\ibm_example.yml;
%       yml.write(fname2, result)
%
%   Remarks
%       - RHO 20171027: Changed writing empty string to empty string instead of a empty (cell)
%       - Tests are stored in: C:\checkouts\oetools\trunk\matlab\io\+yml\tests
%         Running the selftest_yamlmatlab.m will produce all the results
%
%   See also yml.read  yml.readraw

% TODO: 
%       - make time parsing optional? Keep the time as a string?
%       - make test for time and time zone etc. when not parsed
% DONE:
%       - converted the code to namespace functions
%       - added milliseconds to time read and write (parsing)
%       - updated tests (including time issues)

%   --------------------------------------------------------------------
%   Copyrights (C) see below code
% --------------------------------------------------------------------
%   $Id: votemplate.m 5290 2015-12-08 11:33:47Z rho@vanoord.com $
%   $HeadURL: svn://10.12.184.200/votools/trunk/matlab/general/vo_template/votemplate.m $
%   $Keywords:
% --------------------------------------------------------------------

    if ~exist('flowstyle','var')
        flowstyle = 0;
    end;
    if ~ismember(flowstyle, [0,1])
        error('Flowstyle must be 0,1 or empty.');
    end;
    result = [];
    [pth,~,~] = fileparts(mfilename('fullpath'));
    try
        import('org.yaml.snakeyaml.*');
        javaObject('Yaml');
    catch
        dp = [pth filesep 'external' filesep 'snakeyaml-1.9.jar'];
        if not(ismember(dp, javaclasspath ('-dynamic')))
        	javaaddpath(dp); % javaaddpath clears global variables...!?
        end
        import('org.yaml.snakeyaml.*');
    end;
    javastruct = scan(data);
    dumperopts = DumperOptions();
    dumperopts.setLineBreak(...
        javaMethod('getPlatformLineBreak',...
        'org.yaml.snakeyaml.DumperOptions$LineBreak'));
    if flowstyle
        classes = dumperopts.getClass.getClasses;
        flds = classes(3).getDeclaredFields();
        fsfld = flds(1);
        if ~strcmp(char(fsfld.getName), 'FLOW')
            error(['Accessed another field instead of FLOW. Please correct',...
            'class/field indices (this error maybe caused by new snakeyaml version).']);
        end;
        dumperopts.setDefaultFlowStyle(fsfld.get([]));
    end;
    yamlobj = Yaml(dumperopts);
    
    output = yamlobj.dump(javastruct);
    if ~isempty(filename)
        fid = fopen(filename,'w');
        fprintf(fid,'%s',char(output) );
        fclose(fid);
    else
        result = output;
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan(r)
    if ischar(r)
        result = scan_char(r);
    elseif iscell(r)
        result = scan_cell(r);
    elseif yml.tools.isord(r)
        result = scan_ord(r);
    elseif isstruct(r)
        result = scan_struct(r);                
    elseif isnumeric(r)
        result = scan_numeric(r);
    elseif islogical(r)
        result = scan_logical(r);
    elseif isa(r,'yml.tools.DateTime')
        result = scan_datetime(r);
    else
        error(['Cannot handle type: ' class(r)]);
    end
end

%--------------------------------------------------------------------------
%
%
function result = scan_numeric(r)
    if isempty(r)
        result = java.util.ArrayList();
    else
        result = java.lang.Double(r);
    end
end

%--------------------------------------------------------------------------
%
%

function result = scan_logical(r)
    if isempty(r)
        result = java.util.ArrayList();
    else
        result = java.lang.Boolean(r);
    end
end

%--------------------------------------------------------------------------
%
%
function result = scan_char(r)
    result = java.lang.String(r);
%     if isempty(r)
%         result = java.util.ArrayList();
%     else
%         result = java.lang.String(r);
%     end
end

%--------------------------------------------------------------------------
%
%
function result = scan_datetime(r)
    % datestr 30..in ISO8601 format
    %java.text.SimpleDateFormat('yyyymmdd'T'HH:mm:ssz" );
    
    [Y, M, D, H, MN,S] = datevec(double(r));            
	result = java.util.GregorianCalendar(Y, M-1, D, H, MN,S);
	result.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));
    result.setTimeInMillis(result.getTimeInMillis + (S-floor(S))*1000);
    
    %tz = java.util.TimeZone.getTimeZone('UTC');
    %cal = java.util.GregorianCalendar(tz);
    %cal.set
    %result = java.util.Date(datestr(r));
end

%--------------------------------------------------------------------------
%
%
function result = scan_cell(r)
    if(yml.tools.isrowvector(r))  
        result = scan_cell_row(r);
    elseif(yml.tools.iscolumnvector(r))
        result = scan_cell_column(r);
    elseif(yml.tools.ismymatrix(r))
        result = scan_cell_matrix(r);
    elseif(yml.tools.issingle(r));
        result = scan_cell_single(r);
    elseif(isempty(r))
        result = java.util.ArrayList();
    else
        error('Unknown cell content.');
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_ord(r)
    if(yml.tools.isrowvector(r))
        result = scan_ord_row(r);
    elseif(yml.tools.iscolumnvector(r))
        result = scan_ord_column(r);
    elseif(yml.tools.ismymatrix(r))
        result = scan_ord_matrix(r);
    elseif(yml.tools.issingle(r))
        result = scan_ord_single(r);
    elseif(isempty(r))
        result = java.util.ArrayList();
    else
        error('Unknown ordinary array content.');
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_cell_row(r)
    result = java.util.ArrayList();
    for ii = 1:size(r,2)
        result.add(scan(r{ii}));
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_cell_column(r)
    result = java.util.ArrayList();
    for ii = 1:size(r,1)
        tmp = r{ii};
        if ~iscell(tmp)
            tmp = {tmp};
        end;
        result.add(scan(tmp));
    end;    
end

%--------------------------------------------------------------------------
%
%
function result = scan_cell_matrix(r)
    result = java.util.ArrayList();
    for ii = 1:size(r,1)
        i = r(ii,:);
        result.add(scan_cell_row(i));
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_cell_single(r)
    result = java.util.ArrayList();
    result.add(scan(r{1}));
end

%--------------------------------------------------------------------------
%
%
function result = scan_ord_row(r)
    result = java.util.ArrayList();
    for i = r
        result.add(scan(i));
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_ord_column(r)
    result = java.util.ArrayList();
    for i = 1:size(r,1)
        result.add(scan_ord_row(r(i)));
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_ord_matrix(r)
    result = java.util.ArrayList();
    for i = r'
        result.add(scan_ord_row(i'));
    end;
end

%--------------------------------------------------------------------------
%
%
function result = scan_ord_single(r)
    result = java.util.ArrayList();
    for i = r'
        result.add(r);
    end;
end


%--------------------------------------------------------------------------
%
%
function result = scan_struct(r)
    result = java.util.LinkedHashMap();
    for i = fields(r)'
        key = i{1};
        val = r.(key);
        result.put(key,scan(val));
    end;
end


%   --------------------------------------------------------------------
%   Copyright (C) 2017 Van Oord, RHO@vanoord.com
%
%   This library is copyrighted Van Oord software intended for internal
%   use only: you cannot redistribute it outside of Van Oord.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. In case of
%   errors or suggestions, refer to the central HeadURL address below.
%   --------------------------------------------------------------------
%
%   ---------------- Original code -------------------------------------
%   Copyright (c) 2011 CTU in Prague and  Energocentrum PLUS s.r.o.
% 
%   Permission is hereby granted, free of charge, to any person
%   obtaining a copy of this software and associated documentation
%   files (the "Software"), to deal in the Software without
%   restriction, including without limitation the rights to use,
%   copy, modify, merge, publish, distribute, sublicense, and/or sell
%   copies of the Software, and to permit persons to whom the
%   Software is furnished to do so, subject to the following
%   conditions:
% 
%   The above copyright notice and this permission notice shall be
%   included in all copies or substantial portions of the Software.
% 
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%   OTHER DEALINGS IN THE SOFTWARE.
%   --------------------------------------------------------------------









