function getproperty(mfile)
%GETPROPERTIES  Find all options in a function. 
%
%   Only intended for debugging/creating functions, not for runtime use.
%
%   Example
%   getproperties('KMLline')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
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
% Created: 18 Jun 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: getproperty.m 2690 2010-06-20 21:58:36Z thijs@damsma.net $
% $Date: 2010-06-21 05:58:36 +0800 (Mon, 21 Jun 2010) $
% $Author: thijs@damsma.net $
% $Revision: 2690 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/getproperty.m $
% $Keywords: $

%%
if strcmpi(mfile(end-1:end),'.m')
    m =  fileread(mfile);
else
    m =  fileread([mfile '.m']);
end

pat = 'OPT\.\w*';
sp = strfind(m,'setproperty');
if sp
    disp(['unique properties before setproperty is called in ' mfile ':'])
    fprintf('\n')
    disp(char(unique(regexp(m(1:sp(end)),pat,'match'))'))
    fprintf('\n')
    disp(['unique properties after setproperty is called in ' mfile ':'])
    fprintf('\n')
    disp(char(unique(regexp(m(1:sp(end)),pat,'match'))'))
else
    disp(['unique properties in ' mfile ':'])
    fprintf('\n')
    disp(char(unique(regexp(m,pat,'match'))'))
end





