function oetnewclass(varargin)
%OETNEWCLASS  Cleates a new class definition file (classdef)
%
% Routine to create a new class including help block template and
% copyright block. The description can be specified using property value 
% pairs. Company, address, email and author are obtained from the
% application data with getlocalsettings.
%
% Syntax:
% oetnewclass;
% oetnewclass('filename')
% oetnewclass('filename', 'PropertyName', PropertyValue,...)
%
% Input:
% varargin  = 'filename'
% PropertyNames: 
%   'description' = One line description
%
% Example:
% oetnewclass('filename',...
%     'description', 'This is an example of a new classdef.')
%
% See also: newfun, oetnewfun, oetnewtest, getlocalsettings, load_template

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Pieter
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 06 Nov 2010
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: oetnewclass.m 3439 2010-11-26 15:48:19Z geer $
% $Date: 2010-11-26 23:48:19 +0800 (Fri, 26 Nov 2010) $
% $Author: geer $
% $Revision: 3439 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/oetnewclass.m $
% $Keywords: $

%% defaults
OPT = getlocalsettings;

OPT.classh1 = 'One line description goes here.';
OPT.constructorh1 = 'One line description goes here.';
OPT.code        = '';
OPT.seeAlso     = '';

className = 'Untitled';
i0 = 2;
if nargin > 1 && any(strcmp(fieldnames(OPT), varargin{1}))
    i0 = 1;
elseif nargin > 0
    className = varargin{1};
end    

OPT = setproperty(OPT, varargin{i0:end});

if ischar(OPT.ADDRESS)
    OPT.ADDRESS = {OPT.ADDRESS};
end

%%
[fpath fname] = fileparts(fullfile(cd, className));

% read template file
fid = fopen(which('oetclasstemplate.m'));
str = fread(fid, '*char')';
fclose(fid);

str = strrep(str, '$seeAlso', OPT.seeAlso);
str = strrep(str, '$classname', fname);

% str = strrep(str, '%   $varargin  ='  , OPT.varargin);
str = strrep(str, '$CLASSNAME'         , upper(fname));
str = strrep(str, '$classh1'      , OPT.classh1);
str = strrep(str, '$constructorh1'      , OPT.constructorh1);
str = strrep(str, '$date(dd mmm yyyy)', datestr(now, 'dd mmm yyyy'));
str = strrep(str, '$date(yyyy)'       , datestr(now, 'yyyy'));
str = strrep(str, '$Company'          , OPT.COMPANY);
str = strrep(str, '$author'           , OPT.NAME);
str = strrep(str, '$email'            , OPT.EMAIL);
address = sprintf('%%       %s\n'     , OPT.ADDRESS{:});
address = address(1:end-1);
str = strrep(str, '%       $address', address);
str = strrep(str, '$version', version);

if ~isempty(OPT.code)
    % add predefined code
    str = sprintf('%s', str, OPT.code);
end

%% open new file in editor
createneweditordocument(str);
