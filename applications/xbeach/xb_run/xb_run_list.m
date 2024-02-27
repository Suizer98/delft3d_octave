function xb_run_list(varargin)
%XB_RUN_LIST  Lists registered runs
%
%   Lists runs registered by the xb_run_register function.
%
%   Syntax:
%   xb_run_list(varargin)
%
%   Input:
%   varargin  = n:      Number of log lines to show
%
%   Output:
%   none
%
%   Example
%   xb_run_list
%   xb_run_list('n', 10)
%
%   See also xb_run, xb_run_remote, xb_run_register

% TODO: neat interface with links to plot and show functions, extract
% relevant data from log instead of displaying entire log, graphical
% progress bar??

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
% Created: 15 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_run_list.m 7531 2012-10-19 11:14:02Z hoonhout $
% $Date: 2012-10-19 19:14:02 +0800 (Fri, 19 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7531 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_list.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'n', 10 ...
);

OPT = setproperty(OPT, varargin{:});

%% list runs

runs = xb_getpref('runs');

formatstr = '%8s %-10s: %-30s %-20s: %-30s\n';

if ~isempty(runs) && iscell(runs)
    
    % remove doubles, non-existing and outdated
    fpaths = {};
    for i = 1:length(runs)
        fpath = xs_get(runs{i}, 'path');
        if ~isdir(fpath); fpath = fileparts(fpath); end;
        if ~exist(fpath, 'dir') || now-datenum(runs{i}.date) > 3
            fpath = ' ';
        elseif ismember(fpath, fpaths)
            idx = strcmpi(fpath, fpaths);
            if any(idx); fpaths{idx} = ' '; end;
        end
        fpaths = [fpaths{:} {fpath}];
    end
    runs(strcmpi(' ', fpaths)) = [];
    
    for i = min([OPT.n length(runs)]):-1:1
        xb = xs_peel(runs{end-i+1});
        
        if isdir(xb.path)
            fpath = xb.path;
        else
            fpath = fileparts(xb.path);
        end
            
        % read log file
        log = xb_run_parselog(fpath);

        fprintf(formatstr, num2str(xb.id), 'Name',   xb.name,                     'Date',               runs{i}.date);
        fprintf(formatstr, ' ',            'Path',   shortdisp(fpath,30),         'Time remaining',     datestr(xs_get(log, 'remtime'), 'HH:MM:SS'));
        fprintf(formatstr, ' ',            'Binary', shortdisp(xb.binary,30),     'Total run duration', datestr(xs_get(log, 'duration'), 'HH:MM:SS'));
        fprintf(formatstr, ' ',            'Nodes',  num2str(xb.nodes),           'Average timestep',   datestr(xs_get(log, 'timestep'), 'SS.FFF'));
        fprintf(formatstr, ' ',            'Remote', num2str(isfield(xb, 'ssh')), 'Finished',           num2str(xs_get(log, 'finished')));
        fprintf(formatstr, ' ',            'Netcdf', num2str(xb.netcdf),          'Error',              xs_get(log', 'error'));

        disp(' ');

        p = xs_get(log, 'progress');
        fprintf(['         [' repmat('>',1,round(p)) repmat(' ',1,round(100-p)) '] %2.1f%%\n'], p);

        disp(' ');

        fprintf('         ');
        fprintf('<a href="matlab:xb_run_unregister(''%s''); xb_run_list;">delete</a> | ', num2str(xb.id))
        fprintf('<a href="matlab:xb_view(''%s'');">view</a> | ', fpath)
        fprintf('<a href="matlab:cd(''%s'');">cd</a> | ', fpath)
        fprintf('<a href="matlab:runs = xb_getpref(''runs''); runs{%d}">get</a> | ', length(runs)-i+1)
        fprintf('<a href="matlab:runs = xb_getpref(''runs''); xb_check_run(runs{%d},''repeat'',true); show_info_box(runs{%d});">warn</a>', length(runs)-i+1)
        fprintf('\n');
        
        disp(' ');
    end
else
    disp('No runs');
end

xb_setpref('runs', runs);

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = shortdisp(str, n)

if length(str) > n
    str = [str(1:floor((n-5)/2)) ' ... ' str(end-ceil((n-5)/2-1):end)];
end

function show_info_box(run)
    msg = sprintf([ 'Warning is enabled for XBeach run "%s" [%d]. \n' ...
                    'A message will be displayed once the run has finished. \n\n' ...
                    'Location: %s' ], ...
                    xs_get(run, 'name'), xs_get(run, 'id'), xs_get(run, 'path'));
    
    msgbox(msg,'Warning enabled','warn','modal');
