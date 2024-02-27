function varargout = get_fnames(varargin)
%UNTITLED  get the filenames in a certain directory, a filter is applied.
%
%   The dir() function is used, a filter is applied.
%
%   Syntax:
%   varargout = get_fnames(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  = 
%         filter = the file name should contain this.
%
%   Output:
%   varargout = fnames
%
%   Example
%   fnames = get_fnames('fdir','D:\Projects\ShortQuestions\Chatham\Scripts','filter','set','fext','m')
%
%   dir(), setOptions()

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       Kees Pruis
%
%       kees.pruis@boskalis.com	
%
%       +31 78 696 8470
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
% Created: 09 Sep 2014
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = setOptions();
OPT.fdir= pwd;
OPT.filter = OPT.fext;
% return defaults (aka introspection)
if nargin==0;
   varargout = {OPT};
   return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

fnames = dir(OPT.fdir);
fnames = {fnames.name};
filter = strfind(fnames,OPT.filter);
fnames = fnames(cellfun(@(s) ~isempty(s),filter));
if length(fnames)>1
    button = questdlg('More raw files are found, do you want to use them all?','Read raw data','Yes');
    if ~strcmp(button,'Yes');
        msgbox('Operation canceled','Read raw data')
        return
    end
elseif isempty(fnames) 
    msgbox('No raw data is found','Read raw data')
else
end
varargout = {fnames};
end
