function [runflag runtime msg] = XB_run(varargin)
%XB_RUN  runs xbeach calculation
%
% Routine calls "xbeach.exe" (by default; another exefile can be specified
% with keyword-value pairs) within the exepath, using inpfile as input for
% the run.
%
% See also CreateEmptyXBeachVar XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: XB_run_old.m 3772 2010-12-30 16:56:10Z hoonhout $
% $Date: 2010-12-31 00:56:10 +0800 (Fri, 31 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3772 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_run_old.m $
% $Keywords:

%%
OPT = struct(...
    'inpfile', fullfile(cd, 'params.txt'),...
    'exepath', cd,...
    'exefile', 'xbeach.exe',...
    'mpiexe', 'mpiexec.exe',...
    'np', 1,...
    'priority', '1:1',...
    'passphrase', '');

% provide backward compatibility
if isvector(varargin) && ~any(strcmp(fieldnames(OPT), varargin{1}))
    OPT.inpfile = varargin{1};
    if nargin >= 2 && ~any(strcmp(fieldnames(OPT), varargin{2}))
        OPT.exepath = varargin{2};
    end
end

OPT = setproperty(OPT, varargin{:});

%% input file
if ~exist(OPT.inpfile, 'file')
    error('XB_RUN:NoInpfileFound', ['No inputfile "' OPT.inpfile '" found.'])
end
if ~isempty(which(OPT.inpfile))
    OPT.inpfile = which(OPT.inpfile);
end
[inpath fname fext] = fileparts(OPT.inpfile);
OPT.inpfile = fullfile(inpath, [fname fext]);

%% path of executable
if ~exist(fullfile(OPT.exepath, OPT.exefile), 'file')
    error('XB_RUN:NoExecutableFound', ['"' OPT.exefile '" not found.'])
end

msg = '';

%% derive date of xbeach.exe and create message
exeinfo = dir(fullfile(OPT.exepath, OPT.exefile));
try %#ok<TRYNC>
    msg = sprintf('Version: %s\n', datestr(exeinfo.datenum, 'yyyy-mmm-dd'));
end

cdtemp = cd;
if ~strcmp(inpath, cd)
    % params.txt is in another path, run it from there
    cd(inpath);
end

%% read expected number of timesteps from params.txt
fid = fopen(OPT.inpfile, 'r');
strtext = fread(fid, '*char')';
searchstr = {'morstart' 'tint' 'tstop'};
for i = 1:length(searchstr)
    strbgn = findstr(strtext, searchstr{i});
    strend = min(findstr2afterstr1(strtext, searchstr{i}, char(10)))-1;
    evalstr = [strtext(strbgn:strend) ';'];
    eval(evalstr);
end
fclose(fid);

TintExists = exist('tint','var');
if TintExists
    Nrtimesteps = length(morstart:tint:tstop);
end

%% make sure that dims.dat is created as output
% dims.dat is always created. Even if not specified as output...

% DIMSisoutput = ~isempty(findstr(strtext, 'dims'));
% if ~DIMSisoutput
%     strbgn = findstr(strtext, 'nglobalvar');
%     strend = min(findstr2afterstr1(strtext, 'nglobalvar', char(10)))-1;
%     evalstr = [strtext(strbgn:strend) ';'];
%     eval(evalstr);
%     nglobalvar = nglobalvar + 1; %#ok<NODEF>
%     nglobalvarstr = sprintf('%s %g\n', evalstr(1:findstr(evalstr, '=') + 1), nglobalvar);
%     strtext = sprintf('%s', strtext(1:strbgn-1), nglobalvarstr, 'dims', strtext(strend+1:end));
%     fid = fopen(OPT.inpfile, 'w');
%     fprintf(fid, '%s', strtext);
%     fclose(fid);
% end

tic
if OPT.np == 1
    system(['"' fullfile(OPT.exepath, OPT.exefile) '" "' fname fext '"']);
else
    if isempty(OPT.passphrase) && any(strcmp(varargin, 'passphrase'))
        % work around, in case of empty passphrase
        passphrase = ' < NUL';
    elseif any(strcmp(varargin, 'passphrase'))
        passphrase = [' -phrase "' OPT.passphrase '"'];
    else
        passphrase = '';
    end
    system(['"' OPT.mpiexe '" -np ' num2str(OPT.np) ' -localonly -priority ' OPT.priority ' "' fullfile(OPT.exepath, OPT.exefile) '" "' fname fext '"' passphrase]);
end

runtime = toc;

%% read actual number of timesteps from dims.dat
dimsfile = 'dims.dat';
if exist(dimsfile, 'file')
    fid = fopen(dimsfile, 'r');
    temp = fread(fid, [3,1], 'double');
    nt = temp(1);
    fclose(fid);
else
    nt = NaN; % will result in runflag = false
    msg = sprintf('%s%s\n', msg, 'dims.dat not found.');
end

%% set runflag and create message
if TintExists && Nrtimesteps == nt
    runflag = true;
    msg = sprintf('%s', msg, 'Run successfully completed: ', datestr(now));
elseif ~TintExists
    runflag = true;
    msg = sprintf('%s', msg, 'Run successfully completed: ', datestr(now));
else    
    runflag = false;
    if ~isnan(nt)
        msg = sprintf('%sit %i of %i completed: %s', msg, nt, Nrtimesteps, datestr(now));
    end
end

cd(cdtemp);