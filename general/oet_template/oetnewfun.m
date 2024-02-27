function oetnewfun(varargin)
% OETNEWFUN  Create a new function given the filename
%
% Routine to create a new function including help block template and
% copyright block. The description can be specified using property value 
% pairs. Company, address, email and author are obtained using from the
% application data with getlocalsettings.
%
% Syntax:
% oetnewfun('filename')
% oetnewfun('filename', 'PropertyName', PropertyValue,...)
%
% Input:
% varargin  = 'filename'
% PropertyNames: 
%   'description' = One line description
%
% Example:
% oetnewfun('filename',...
%     'description', 'This is an example of a new function.')
%
% See also: newfun, oetnewtest, oetnewclass, getlocalsettings,
% load_template, userpath
%
% <a href="matlab:oetnewfun;">Click here to create a new function</a>

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: oetnewfun.m 9588 2013-11-06 10:21:02Z boer_g $
% $Date: 2013-11-06 18:21:02 +0800 (Wed, 06 Nov 2013) $
% $Author: boer_g $
% $Revision: 9588 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/oetnewfun.m $

%% defaults
OPT = getlocalsettings;

OPT.description = 'One line description goes here.';
OPT.input       = {'varargin'};
OPT.output      = {'varargout'};
OPT.feval       = [];
OPT.code        = {'OPT.keyword=value;',...
                   '% return defaults (aka introspection)',...
                   'if nargin==0;',...
                   '   varargout = {OPT};',...
                   '   return',...
                   'end',...
                   '% overwrite defaults with user arguments',...
                   'OPT = setproperty(OPT, varargin);',...
                   '%% code'};
OPT.seeAlso     = '';

FuntionName = 'Untitled';
i0 = 2;
if nargin > 1 && any(strcmp(fieldnames(OPT), varargin{1}))
    i0 = 1;
elseif nargin > 0
    FuntionName = varargin{1};
    if ~isempty(which(FuntionName))
        % function is available in search path
        % get input and output variables and remove leading and trailing
        % spaces
        OPT.input  = getInputVariables(FuntionName)';
        OPT.output = getOutputVariables(FuntionName)';
    end 
end    

OPT = setproperty(OPT, varargin{i0:end});

if ischar(OPT.ADDRESS)
    OPT.ADDRESS = {OPT.ADDRESS};
end

if ischar(OPT.input)
    OPT.input = {OPT.input};
end

if ischar(OPT.output)
    OPT.output = {OPT.output};
end

MaxNrChars = max(cellfun(@length, [OPT.input(:); OPT.output(:)]));

if ~isscalar(OPT.input)
    % create list of input arguments
    OPT.varargin = '';
    for i = 1:length(OPT.input)
        Nrblanks = MaxNrChars - length(OPT.input{i});
        OPT.varargin = sprintf('%s%%   %s%s =\n', OPT.varargin, OPT.input{i}, blanks(Nrblanks));
    end
    OPT.varargin = OPT.varargin(1:end-1);
    
    % prepare input syntax
    OPT.input(1:2:2*length(OPT.input)) = OPT.input;
    OPT.input(2:2:length(OPT.input)) = {', '};
else
    OPT.varargin = sprintf('%%   %s%s =', OPT.input{1}, blanks(MaxNrChars - length(OPT.input{1})));
end
% create input syntax
OPT.input = sprintf('%s', OPT.input{:});

if ~isscalar(OPT.output)
    % create list of output arguments
    OPT.varargout = '';
    for i = 1:length(OPT.output)
        Nrblanks = MaxNrChars - length(OPT.output{i});
        OPT.varargout = sprintf('%s%%   %s%s =\n', OPT.varargout, OPT.output{i}, blanks(Nrblanks));
    end
    OPT.varargout = OPT.varargout(1:end-1);

    % prepare output syntax
    OPT.output(1:2:2*length(OPT.output)) = OPT.output;
    OPT.output(2:2:length(OPT.output)) = {' '};
    if length(OPT.output) > 1
        OPT.output = [{'['} OPT.output {']'}];
    end
else
    OPT.varargout = sprintf('%%   %s%s =', OPT.output{1}, blanks(MaxNrChars - length(OPT.output{1})));
end
% create output syntax
OPT.output = sprintf('%s', OPT.output{:});

%%
[fpath fname] = fileparts(fullfile(cd, FuntionName));

% read template file
fid = fopen(which('oettemplate.m'));
str = fread(fid, '*char')';
fclose(fid);

% replace strings in template
if ~isempty(OPT.output)
    str = strrep(str, '$output', OPT.output);
    str = strrep(str, '%   $varargout =', OPT.varargout);
else
    str = strrep(str, '$output = ', OPT.output);
    str = strrep(str, '%   Output:', '%');
    str = strrep(str, '%   $varargout =', '%');
end
str = strrep(str, '$seeAlso', OPT.seeAlso);
str = strrep(str, '$filename', fname);
if ~isempty(OPT.input)
    str = strrep(str, '$input', OPT.input);
else
    str = strrep(str, '($input)', OPT.input);
end
str = strrep(str, '%   $varargin  ='  , OPT.varargin);
str = strrep(str, '$FILENAME'         , upper(fname));
str = strrep(str, '$description'      , OPT.description);
str = strrep(str, '$date(dd mmm yyyy)', datestr(now, 'dd mmm yyyy'));
str = strrep(str, '$date(yyyy)'       , datestr(now, 'yyyy'));
str = strrep(str, '$Company'          , OPT.COMPANY);
str = strrep(str, '$author'           , OPT.NAME);
str = strrep(str, '$email'            , OPT.EMAIL);
address = sprintf('%%       %s\n'     , OPT.ADDRESS{:});
address = address(1:end-1);
str = strrep(str, '%       $address', address);
str = strrep(str, '$version', version);

if ~isempty(OPT.feval)
    str = feval(OPT.feval, str);
end

if ~isempty(OPT.code)
    % add predefined code
    str = sprintf('%s', str, str2line(OPT.code));
end

%% open new file in editor
createneweditordocument(str);

