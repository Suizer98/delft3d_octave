function oetnewtest(varargin)
%OETNEWTEST    Create a new test file given the file or function name
%
%   Routine to create a new test including Credits and svn keywords.
%   Company, address, email and author are obtained using from the
%   application data with getlocalsettings. If there is already a
%   testdefinition with the same name, the function asks whether to
%   open the existing file, copy the most important code pieces into
%   a new template, or start from scratch with the same name.
%
%   Syntax:
%       oetnewtest('filename');
%       oetnewtest('currentfile');
%       oetnewtest('functionname');
%       oetnewfun(..., 'PropertyName', PropertyValue,...)
%
%   Input:
%       'filename'    -   name of the test file (this should end with
%                         "_test.m" otherwise it is treated as a function
%                         name. If the filename is not specified, an Untitled
%                         test will be generated.
%       'currentfile' -   Looks up the last selected file in the matlab editor
%                         and creates a test for that function.
%       'functionname'-   Name of the function for which this file should
%                         provide a test.
%
%   PropertyNames:
%       'h1line'      -   One line description
%       'description' -   Detailed description of the test
%       'testname'    -   An alternate name for the test
%
%   Example:
%       oetnewtest('oetnewtest_test');
%       oetnewtest('currentfile');
%
%   See also: oetnewfun, oetnewclass, getlocalsettings, load_template
%
%   <a href="matlab:oetnewtest;">Click here and create a new test</a>
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 12 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oetnewtest.m 9117 2013-08-26 12:49:12Z geer $
% $Date: 2013-08-26 20:49:12 +0800 (Mon, 26 Aug 2013) $
% $Author: geer $
% $Revision: 9117 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/oetnewtest.m $
% $Keywords: $

%% defaults
OPT                     = getlocalsettings;

OPT.H1Line              = 'One line description goes here';
OPT.Description         = 'More detailed description of the test goes here.';
OPT.DescriptionCode     = [];
OPT.RunCode             = [];
OPT.PublishCode         = [];
OPT.SeeAlso             = '';
OPT.Category            = 'MTestCategory.WorkInProgress';

OPT.Code                = '';

FunctionName            = 'Untitled_test';

%% treat input
i0 = 2;
if nargin > 1 && any(strcmp(fieldnames(OPT), varargin{1}))
    i0 = 1;
elseif nargin > 0
    if strcmp(varargin{1},'currentfile')
        [dum, FunctionName] = fileparts(editorCurrentFile);
    else
        FunctionName = varargin{1};
    end
end

%% append test id after functionname
id = strfind(FunctionName,'_test');
if isempty(id)
    FunctionName = cat(2,FunctionName,'_test');
end

%% Set OPT properties
OPT = setproperty(OPT, varargin{i0:end});

%% Convert Address to cell
if ischar(OPT.ADDRESS)
    OPT.ADDRESS = {OPT.ADDRESS};
end

%% Check existance of the file
if ~isempty(which(cat(2,FunctionName,'.m')))
    answ = questdlg('The specified test definition file is already present. What would you like to do?','Test definition already in use','Open Existing file','Copy contents in new template','Create test from scratch','Open Existing file');
    switch answ
        case 'Copy contents in new template'
            try
                %% Create mtest object
                t = MTest(FunctionName);
                
                %% Copy test variables to OPT
                vars   = {'H1Line','Description','SeeAlso'};
                for ivar = 1:length(vars)
                    if ~isempty(t.(vars{ivar}))
                        OPT.(vars{ivar}) = t.(vars{ivar});
                    end
                end
                if ~isempty(OPT.Description)
                    if ischar(OPT.Description) && strncmp(OPT.Description,'%',1)
                       OPT.Description(1) = [];
                    elseif iscell(OPT.Description) && strncmp(OPT.Description{1},'%',1)
                        OPT.Description{1} = strtrim(OPT.Description{1}(2:end));
                    end
                end
                
                OPT.Category = mtestcategory2string(t.Category);
                
                %% Paset complete code to new file
                fid = fopen(cat(2,FunctionName,'.m'));
                OPT.Code = cat(2,char(10),char(10),'%% Original code of ', FunctionName, '.m', char(10), fread(fid,'*char')');
                fclose(fid);
            catch me %#ok<NASGU>
                fid = fopen(cat(2,FunctionName,'.m'));
                OPT.Code = cat(2,char(10),char(10),'%% Original code of ', FunctionName, '.m', char(10), fread(fid,'*char')');
                fclose(fid);
            end
        case 'Open Existing file'
            edit(FunctionName);
            return
        case 'Create test from scratch'
            % Do nothing. Test will be generated with correct name, but with no input.
        otherwise
            return;
    end
else
    baseFunction = strrep(FunctionName,'_test','');
    OPT.H1Line              = ['Defines tests for: ' baseFunction];
    OPT.Description         = 'More detailed description of the test goes here.';
    OPT.SeeAlso             = baseFunction;
    OPT.Category            = 'MTestCategory.WorkInProgress';
    
    OPT.Code                = '';
end

%% read contents of template file
fid = fopen(which('oettesttemplate.m'));
str = fread(fid, '*char')';
fclose(fid);

%% replace keywords in template string

% First the helpblock part
[fpath, fname] = fileparts(fullfile(cd, FunctionName));
str = strrep(str, '$filename', fname);
str = strrep(str, '$FILENAME', upper(fname));
str = strrep(str, '$h1line', OPT.H1Line);
if iscell(OPT.Description)
    OPT.Description         = sprintf('%s\n',OPT.Description{:});
    OPT.Description(end)    = [];
end
str = strrep(str, '$helpblockdescription', OPT.Description);
if iscell(OPT.SeeAlso)
    OPT.SeeAlso             = sprintf('%s ',OPT.SeeAlso{:});
end
str = strrep(str, '$seeAlso', OPT.SeeAlso);

% Now all keywords in the credentials/copyright part
str = strrep(str, '$date(yyyy)', datestr(now, 'yyyy'));
str = strrep(str, '$Company', OPT.COMPANY);
str = strrep(str, '$author', OPT.NAME);
str = strrep(str, '$email', OPT.EMAIL);
OPT.ADDRESS = sprintf('%%       %s\n', OPT.ADDRESS{:});
OPT.ADDRESS(end) = [];
str = strrep(str, '%       $address', OPT.ADDRESS);

% Now the svn version part
str = strrep(str, '$date(dd mmm yyyy)', datestr(now, 'dd mmm yyyy'));
str = strrep(str, '$version', version);

% replace category
str = strrep(str, '$testcategory', [OPT.Category , ';']);

%% Append old code
% If the file was not according to the correct format and mtest couldn't read it, the complete
% string is pasted behind the normal content.
if ~isempty(OPT.Code)
    if iscell(OPT.Code)
        str = cat(2,str,char(10),...
            sprintf('%s\n',OPT.Code{:}));
    else
        str = cat(2, str, char(10), OPT.Code);
    end
end

%% open new file in editor
createneweditordocument(str);

end

function str = mtestcategory2string(category)
methodNames = methods(MTestCategory);
str = 'MTestCagetory.WorkInProgress';
for i = 1:length(methodNames)
   if  (category == MTestCategory.(methodNames{i}))
       str = ['MTestCategory.' methodNames{i}];
   end
end
end