function xb = xb_generate_waves(varargin)
%XB_GENERATE_WAVES  Generates XBeach structure with waves data
%
%   Generates a XBeach input structure with waves settings. A minimal set
%   of default settings is used, unless otherwise provided. Settings can be
%   provided by a varargin list of name/value pairs. The settings depend on
%   the type of waves genarated (jonswap or vardens), which is indicated by
%   the type parameter. The result is a XBeach structure, an instat number
%   and, if necessary another XBeach structure containing the swtable.
%
%   Syntax:
%   [xb instat swtable] = xb_generate_waves(varargin)
%
%   Input:
%   varargin  = type:       type of waves to be generated ('jons_table'
%                           (default), 'vardens' or 'jonswap').
%               duration:   array with durations in seconds
%               timestep:   array with timesteps in seconds
%
%               options for jonswap or jons_table:
%               Hm0:        significant wave height (default: 7.6)
%               Tp:         peak wave period (default: 12)
%               mainang     main wave direction (default: 270)
%               gammajsp:   peak-enhancement factor (default: 3.3)
%               s:          power in cosinus wave spreading (default: 20)
%               fnyq:       Nyquist frequency (default: 1)
%
%               options for vardens:
%               freqs:      array of frequencies
%               dirs:       array of directions
%               vardens:    matrix of the size [length(dirs) length(freqs)]
%                           containing variance densities
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_waves()
%   xb = xb_generate_waves('Hm0', 9, 'Tp', 18)
%   xb = xb_generate_waves('Hm0', [7 9 7], 'Tp', [12 18 12], 'duration', [1800 3600 1800])
%   xb = xb_generate_waves('type', 'vardens', 'freqs', [ ... ], 'dirs', [ ... ])
%
%   See also xb_generate_model

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% read options

xb_verbose(0,'---');
xb_verbose(0,'Generating wave timeseries');

idx = strcmpi('type', varargin(1:2:end));
if any(idx)
    type = varargin{find(idx)+1};
else
    %If type is not set in varargin, use default.
    type = 'jons_table';
end

switch type
    case 'jonswap'
        OPT = struct( ...
            'type', type, ...
            'Hm0', 7.6, ...
            'Tp', 12, ...
            'mainang', 270, ...
            'gammajsp', 3.3, ...
            's', 20, ...
            'fnyq', 1 ...
        );
    
        instat = 'jons';
        
        xb_verbose(1,'Type','JONSWAP');
    case 'vardens'
        OPT = struct( ...
            'type', type, ...
            'freqs', [], ...
            'dirs', [], ...
            'vardens', [] ...
        );
    
        instat = 'vardens';
        
        xb_verbose(1,'Type','Variance density');
        
    case 'jons_table'
        OPT = struct( ...
            'type', type, ...
            'Hm0', 7.6, ...
            'Tp', 12, ...
            'mainang', 270, ...
            'gammajsp', 3.3, ...
            's', 20, ...
            'fnyq', 1 ...
        );
    
        instat = 'jons_table';
        
        xb_verbose(1,'Type','JONSWAP');
        
    otherwise
        error('type must be ''jonswap'', ''vardens'' or ''jons_table'', not ''%s''.',type)
end

OPT.type = type;
OPT.duration = 2000; %Set duration equal to default in xb_generate_settings.
OPT.timestep = 1;
OPT.swtable = false;

OPT = setproperty(OPT, varargin{:});

% determine timesteps
l = 1;
f = fieldnames(OPT);
for i = 1:length(f)
    if strcmpi(f{i}, 'type'); continue; end;
    
    if strcmpi(type, 'vardens') && ismatrix(OPT.(f{i}))
        l = max(l, size(OPT.(f{i}),3));
    elseif strcmpi(type, 'jonswap') && isvector(OPT.(f{i}))
        l = max(l, length(OPT.(f{i})));
    end
end

xb_verbose(1,'Timesteps',l);

%% generate waves

xb_verbose(1,'Settings');

xb = xs_empty();

% create waves file
waves = xs_empty();
f = fieldnames(OPT);
for i = 1:length(f)
    waves = xs_set(waves, f{i}, OPT.(f{i}));
end
waves = xs_meta(waves, mfilename, 'waves');

xb = xs_set(xb, 'instat', instat, 'bcfile', waves);

xb_verbose(2,f,struct2cell(OPT));

% put timestep info in params.txt if no filelist is generated
if l == 1
    xb = xs_set(xb, 'rt', OPT.duration, 'dtbc', OPT.timestep);
    
    xb_verbose(0,'Store duration as settings');
    xb_verbose(1,'Duration',OPT.duration);
    xb_verbose(1,'Timestep',OPT.timestep);
end

% include swtable, if necessary
% if strcmpi(instat, 'jons') && OPT.swtable
%     swtable = xs_empty();
%     fpath = fullfile(fileparts(which(mfilename)), 'RF_table.txt');
%     if exist(fpath, 'file')
%         swtable = xs_set(swtable, 'data', load(fpath));
%         swtable = xs_meta(swtable, mfilename, 'swtable', fpath);
%     end
%     
%     xb = xs_set(xb, 'swtable', swtable);
% end

xb = xs_meta(xb, mfilename, 'input');
