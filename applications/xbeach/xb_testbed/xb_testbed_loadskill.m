function s = xb_testbed_loadskill(var, varargin)
%XB_TESTBED_LOADSKILL  Loads testbed skill history of specific variable
%
%   Loads testbed skill history of specific variable
%
%   Syntax:
%   s = xb_testbed_loadskill(var)
%
%   Input:
%   var       = Variable name
%
%   Output:
%   s         = Struct with skill history
%
%   Example
%   s = xb_testbed_loadskill('zb')
%
%   See also xb_testbed_storeskill

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_testbed_loadskill.m 4457 2011-04-14 09:01:41Z hoonhout $
% $Date: 2011-04-14 17:01:41 +0800 (Thu, 14 Apr 2011) $
% $Author: hoonhout $
% $Revision: 4457 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_testbed/xb_testbed_loadskill.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'average',  false, ...
    'binary',   '', ...
    'type',     '' ...
);

OPT = setproperty(OPT, varargin{:});

%% load testbed skill history

s = struct( ...
    'file',     '', ...
    'revision', [], ...
    'r2',       [], ...
    'sci',      [], ...
    'relbias',  [], ...
    'bss',      []      );
    
if xb_testbed_check
    
    p = xb_testbed_getpref;
    
    if ~isempty(OPT.binary);    p.info.binary = OPT.binary; end;
    if ~isempty(OPT.type);      p.info.type = OPT.type;     end;
    
    if ~OPT.average
        s.file = fullfile(p.dirs.network, 'SKILL', p.info.binary, p.info.type, var, [p.info.test '_' p.info.run '.mat']);

        if exist(s.file, 'file')
            s = load(s.file);
        end
    else
        fdir    = fullfile(p.dirs.network, 'SKILL', p.info.binary, p.info.type, var);
        fnames  = dir(fullfile(fdir, '*.mat'));
        
        si = s;
        for i = 1:length(fnames)
            si(i) = load(fullfile(fdir, fnames(i).name));
        end
        
        s.file      = {si.file};
        s.revision  = unique([si.revision]);
        
        for i = 1:length(si)
            s.r2        = s.r2          + interp1(si(i).revision, si(i).r2,         s.revision)/length(si);
            s.sci       = s.sci         + interp1(si(i).revision, si(i).sci,        s.revision)/length(si);
            s.relbias   = s.relbias     + interp1(si(i).revision, si(i).relbias,    s.revision)/length(si);
            s.bss       = s.bss         + interp1(si(i).revision, si(i).bss,        s.revision)/length(si);
        end
    end
end
