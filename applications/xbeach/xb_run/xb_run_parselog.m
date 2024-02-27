function xb = xb_run_parselog(fpath, varargin)
%XB_RUN_PARSELOG  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_run_parselog(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_run_parselog
%
%   See also 

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

% $Id: xb_run_parselog.m 7531 2012-10-19 11:14:02Z hoonhout $
% $Date: 2012-10-19 19:14:02 +0800 (Fri, 19 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7531 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_run/xb_run_parselog.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'n', 10 ...
);

OPT = setproperty(OPT, varargin{:});

logfile = '';
errfile = '';

% set file paths
if exist(fpath, 'dir')
    logfile = fullfile(fpath, 'XBlog.txt');
    errfile = fullfile(fpath, 'XBerror.txt');
elseif exist(fpath, 'file');
    logfile = fpath;
    fpath = fileparts(fpath);
    errfile = fullfile(fpath, 'XBerror.txt');
end

xb = xs_empty;

%% parse error log

err = '';
if exist(errfile, 'file')
    fid = fopen(errfile);
    err = fread(fid, '*char')';
    fclose(fid);
end

xb = xs_set(xb, 'error', err);

%% parse log

xb = xs_set(xb, 'progress', 0);
xb = xs_set(xb, 'starttime', -1);
xb = xs_set(xb, 'remtime', -1);
xb = xs_set(xb, 'duration', -1);
xb = xs_set(xb, 'timestep', 0);
xb = xs_set(xb, 'finished', false);
xb = xs_set(xb, 'lines', '');

if exist(logfile, 'file')
    lines = tail(logfile, 'n', OPT.n);
    
    xb = xs_set(xb, 'lines', lines);
	
    for i = size(lines,1):-1:1
        
        re = regexpi(lines(i,:), 'Simulation \s*([\d\.]+)\s* percent complete', 'tokens');
        if xs_get(xb, 'progress') == 0 && ~isempty(re)
            xb = xs_set(xb, 'progress', str2double(re{1}{1}));
        end
        
        % starttime
        re = regexpi(lines(i,:), 'Simulation started: YYYYMMDD\s+hh:mm:ss\s+time zone (UTC)');
        if xs_get(xb, 'starttime') == -1 && ~isempty(re)
            re = regexpi(lines(i+1,:), '(\d{8})\s+(\d{2}:\d{2}:\d{2})', 'tokens');
            xb = xs_set(xb, 'starttime', datenum([re{1}{1} ' ' re{1}{2}]));
        end
        
        % endtime
        re = regexpi(lines(i,:), 'Time remaining \s*(.+)\s*', 'tokens');
        if xs_get(xb, 'remtime') == -1 && ~isempty(re)
            xb = xs_set(xb, 'remtime', eta2datenum(re{1}{1}));
        end
        
        % timestep
        re = regexpi(lines(i,:), 'Average dt :?\s*(.+)\s*', 'tokens');
        if xs_get(xb, 'timestep') == 0 && ~isempty(re)
            xb = xs_set(xb, 'timestep', eta2datenum(re{1}{1}));
        end
        
        % duration
        re = regexpi(lines(i,:), 'Total calculation time:\s*(.+)\s*', 'tokens');
        if ~isempty(re)
            xb = xs_set(xb, 'duration', eta2datenum(re{1}{1}));
        end
        
        re = regexpi(lines(i,:), 'Duration\s*:\s*(.+)\s*', 'tokens');
        if ~isempty(re)
            xb = xs_set(xb, 'duration', eta2datenum(re{1}{1}));
        end
        
        % finished
        re = regexpi(lines(i,:), 'End of program xbeach');
        if ~isempty(re)
            xb = xs_set(xb, 'progress', 100);
            xb = xs_set(xb, 'remtime', 0);
            xb = xs_set(xb, 'finished', true);
        end
    end
end

xb = xs_meta(xb, mfilename, 'log', {logfile errfile});

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function date = eta2datenum(str)
    date = 0;
    
    units = {'days' 'hours' 'minutes' 'seconds'};
    factors = [1 1/24 1/24/60 1/24/3600];
    
    for i = 1:length(units)
        re = regexp(str, ['([\d\.Ee-]+)\s+' units{i}], 'tokens');
        if ~isempty(re)
            date = date + str2double(re{1}{1})*factors(i);
        end
    end
end