function xb_write_skilltable(xb, measured, varargin)
%XB_WRITE_SKILLTABLE  Writes Latex table with skills to file
%
%   Writes Latex table with skills to file
%
%   Syntax:
%   varargout = xb_write_skilltable(xb, measured, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   measured  = Cell array containing measurement data with in the first
%               column the x-axis values and the second column z-axis
%               values
%   initial   = Cell array containing initial data with in the first
%               column the x-axis values and the second column z-axis
%               values
%   varargin  = file:   Filename
%               title:  Table title
%               vars:   Cell array with variable names to plot
%
%   Output:
%   none
%
%   Example
%   xb_write_skilltable(xb, measured, initial)
%
%   See also xb_skill

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

% $Id: xb_write_skilltable.m 13986 2017-11-23 10:25:17Z gawehn $
% $Date: 2017-11-23 18:25:17 +0800 (Thu, 23 Nov 2017) $
% $Author: gawehn $
% $Revision: 13986 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_write_skilltable.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'file',             'skills.tex', ...
    'title',            '', ...
    'vars',             {{}} ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.vars); OPT.vars = {OPT.vars}; end;
if isempty(OPT.vars); OPT.vars = {xb.data(2:end).name}; end;

%% create table

skills = [];
labels = {};

j = ceil(xs_get(xb, 'DIMS.globaly')/2);

n = 1;
for i = 1:length(measured)
    if length(OPT.vars) > i-1
        x = xs_get(xb, 'DIMS.globalx_DATA');
        t = xs_get(xb, 'DIMS.globaltime_DATA');
        y = xs_get(xb, OPT.vars{i});
        
        if isempty(y); continue; end;
        
        if isvector(y)
            y0 = [];
            y1 = squeeze(y);
            
            if size(y1,2) > 1
                y1 = y1';
            end
        elseif ndims(y) == 2
            y0 = squeeze(y(1,:))';
            y1 = squeeze(y(end,:))';
        elseif ndims(y) == 3
            y0 = squeeze(y(1,j,:));
            y1 = squeeze(y(end,j,:));
        end
        
        initial  = [];
        computed = [];
        
        if size(x,2) > size(x,1)
            x = x';
        end
        
        if length(y1) == length(x)
            if size(x,1) == size(y1,1)
                computed = [squeeze(x(:,j))    y1];
            else
                computed = [squeeze(x(j,:))'    y1];
            end
        elseif length(y1) == length(t)
            computed = [squeeze(t)          y1];
        end
        
        if ~isempty(y0)
            initial  = [computed(:,1)       y0];
        end
        
        [r2 sci relbias bss]    = xb_skill(measured{i}, computed, initial, 'var', OPT.vars{i});
        labels{n}               = OPT.vars{i};

        skills(n,:) = [r2 sci relbias bss];

        n = n + 1;
    end
end

% save tex file
dim = num2cell(2*ones(1,length(labels)));
dlm = num2cell(repmat('$',1,length(labels)));

matrix2latex(skills, 'filename', OPT.file, ...
    'caption',  OPT.title, ...
    'rowlabel', cellfun(@cat, dim, dlm, labels, dlm, 'UniformOutput', false), ...
    'collabel', {'$R^2$','Sci','Rel. bias','BSS'}, ...
    'format',	{'%s', '%4.2f', '%4.2f', '%4.2f', '%4.2f'});

% save mat file
[fdir fname fext] = fileparts(OPT.file);

BSS = cell2struct(num2cell(skills,2), labels);
save([fname '.mat'], '-struct', 'BSS');
