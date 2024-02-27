%MUPPET_COMPILE  Compile script for Muppet.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: muppet_compile.m 13219 2017-03-24 11:47:39Z ormondt $
% $Date: 2017-03-24 19:47:39 +0800 (Fri, 24 Mar 2017) $
% $Author: ormondt $
% $Revision: 13219 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/muppet_v4/src/general/muppet_compile.m $
% $Keywords: $

delete('bin\*');

% Remove paths to statistics toolbox
% statspath='c:\Program Files\MATLAB2013b_64\toolbox\stats\';
% statspath='c:\Program Files\Mathlab\MATLAB2012a_64\toolbox\stats\';
statspath='c:\Program Files\MATLAB\MATLAB2013b_64\toolbox\stats\';

rmpath([statspath 'classreg']);
rmpath([statspath 'stats']);
rmpath([statspath 'statsdemos']);

statspath='c:\Program Files\MATLAB\MATLAB2013b_64\toolbox\images\';
rmpath([statspath 'colorspaces']);
rmpath([statspath 'images']);

muppetpath=fileparts(which('muppet4'));
exedir=[fileparts(muppetpath) filesep 'bin'];

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

% GUI scripts
flist=dir([muppetpath filesep 'gui' filesep '*.m']);
for ii=1:length(flist)
    fprintf(fid,'%s\n',flist(ii).name);    
end

% Import scripts
flist=dir([muppetpath filesep 'import' filesep '*.m']);
for ii=1:length(flist)
    fprintf(fid,'%s\n',flist(ii).name);    
end

fclose(fid);

% mcc('-m','-d',exedir,'muppet4.m','-B','complist','-a','xml');
mcc('-m','-d',exedir,'muppet4.m','-B','complist');

delete('complist');

