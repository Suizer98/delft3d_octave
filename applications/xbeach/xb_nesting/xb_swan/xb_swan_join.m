function sp2 = xb_swan_join(sp2, varargin)
%XB_SWAN_JOIN  Join multiple files in SWAN struct to a single file
%
%   Join multiple files in SWAN struct to a single file
%
%   Syntax:
%   sp2 = xb_swan_join(sp2, varargin)
%
%   Input:
%   sp2       = SWAN struct with multiple files
%   varargin  = none
%
%   Output:
%   sp2       = SWAN struct with a single file
%
%   Example
%   sp2 = xb_swan_join(sp2)
%
%   See also xb_swan_split

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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_swan_join.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_swan/xb_swan_join.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% join sp2 files

% read through sp2 files
JSP2 = [];
for n = 1:length(sp2)
    
    SP2 = sp2(n);

    if isempty(JSP2)
        JSP2 = SP2;
    else
        dims = {'time','location','frequency','direction'};
        for j = 1:length(dims)
            dim = dims{j};

            jdata = cat(1,JSP2.(dim).data,SP2.(dim).data);
            [udata k] = unique(jdata,'rows');

            if size(udata,1)>size(JSP2.(dim).data,1)
                JSP2.(dim).nr = size(udata,1);
                JSP2.(dim).data = udata;

                jdata = cat(j,JSP2.spectrum.data,SP2.spectrum.data);

                idx = {':' ':' ':' ':'}; idx{j} = k;
                JSP2.spectrum.data = jdata(idx{:});

                if j<3
                    jdata = cat(j,JSP2.spectrum.factor,SP2.spectrum.factor);

                    idx = {':' ':'}; idx{j} = k;
                    JSP2.spectrum.factor = jdata(idx{:});
                end
            end
        end
    end
end

sp2 = JSP2;
