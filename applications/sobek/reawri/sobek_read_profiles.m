function prof = sobek_read_profiles(prof_fname)
%Reads the Sobek profile.def file
%
%   More detailed description goes here.
%
%   Syntax:
%   prof = sobek_read_profiles(prof_fname)
%
%   Input:
%   prof_fname  = filename including path of the profile.def file
%
%   Output:
%   prof = struc with cell arrays containing profile data
%
%   Example
%   prof = sobek_read_profiles(prof_fname)
%
%   See also sobek

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 18 Jun 2015
% Created with Matlab version: 8.5.0.197613 (R2015a)

% $Id: sobek_read_profiles.m 12011 2015-06-18 11:50:16Z bartgrasmeijer.x $
% $Date: 2015-06-18 19:50:16 +0800 (Thu, 18 Jun 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 12011 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/sobek/reawri/sobek_read_profiles.m $
% $Keywords: $

%%
% OPT.keyword=value;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);

%% code
istart = 0;
istop = 0;
lines = 0;
fid = fopen(prof_fname,'r');
while 1
    tline = fgetl(fid);
    lines = lines+1;
    if ~ischar(tline), break, end
    if strfind(tline,'TBLE')
        istart = istart+1;
        startlines(istart) = lines;
    end
    if strfind(tline,'tble')
        istop = istop+1;
        stoplines(istop) = lines;
    end
end
fclose(fid);

disp([num2str(istart),' profiles found...']);

fid = fopen(prof_fname,'r');
C = textscan(fid, '%s','delimiter', '\n');
fclose(fid);

prof.crds = {C{1}{startlines-1}};

i1 = startlines + 1;
i2 = stoplines - 1;

multiWaitbar( 'CloseAll' );
for il = 1:length(startlines)
    multiWaitbar( 'Reading profiles...', il/length(startlines));
    mytmp = {C{1}{i1(il):i2(il)}};
    mytmp = regexprep(mytmp, '<', '');
    prof.yz{il} = mytmp';
end
multiWaitbar( 'CloseAll' );
