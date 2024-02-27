function varargout = xb_delft3d_flow(trihfile, bndfile, nstfile, varargin)
%XB_DELFT3D_FLOW  Nest Delft3D-FLOW or XBeach model in another Delft3D-FLOW
%
%   Nests a Delft3D-FLOW model based on the trih-*, BND and NST files.
%
%   Syntax:
%   varargout = xb_delft3d_flow(trihfile, bndfile, nstfile, varargin)
%
%   Input:
%   trihfile  = Path to the trih-* file to use
%   bndfile   = Path to the BND file to use
%   nstfile   = Path to the NST file to use
%   varargin  = type:       Type of output (delft3d/xbeach)
%               file:       Path to output file
%               zcorr:      Water level correction
%               tstart:     Datenum indicating simulation start time
%               tlength:    Datenum indicating simulation length
%
%   Output:
%   varargout = Path to output file and dimensions of file, if applicable
%
%   Example
%   file = xb_delft3d_flow(trihfile, bndfile, nstfile)
%   [file tidelen tideloc] = xb_delft3d_flow('trih-csm.dat', 'kuststrook.bnd', 'kuststrook.nst', 'type', 'xbeach')
%
%   See also xb_nest_xbeach, xb_nest_delft3d, xb_delft3d_wave, xb_delft3d_bathy, xb_bct2xb

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
% Created: 10 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_delft3d_flow.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_delft3d_flow.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'delft3d', ...
    'file', [], ...
    'zcorr', 0, ...
    'tstart', 0, ...
    'tlength', Inf ...
);

OPT = setproperty(OPT, varargin{:});

err = '';
info = struct();

%% determine paths

nesthd2_path = fullfile(fileparts(which(mfilename)), 'nesthd2.exe');
smoothbct_path = fullfile(fileparts(which(mfilename)), 'smoothbct.exe');
current_dir = pwd;

% determine runid
[fdir fname fext] = fileparts(trihfile);
trihfile = fullfile(fdir, [fname '.*']);
m = regexp(fname, '^trih-(?<runid>.+)$', 'names');
runid = m.runid;

%% nest model

copyfile(trihfile, tempdir, 'f');
copyfile(bndfile, fullfile(tempdir, 'model.bnd'), 'f');
copyfile(nstfile, fullfile(tempdir, 'model.nst'), 'f');

cd(tempdir);

fid = fopen('nesthd2.inp', 'wt');
fprintf(fid, '%s\n', 'model.bnd');
fprintf(fid, '%s\n', 'model.nst');
fprintf(fid, '%s\n', runid);
fprintf(fid, '%s\n', 'temp.bct');
fprintf(fid, '%s\n', 'dummy.bcc');
fprintf(fid, '%s\n', 'nest.dia');
fprintf(fid, '%d\n', OPT.zcorr);
fclose(fid);

[s r] = system([nesthd2_path ' < nesthd2.inp']);

%% smooth boundary conditions

fid = fopen('smoothbct.inp','wt');
fprintf(fid, '%s\n', 'temp.bct');
fprintf(fid, '%s\n', 'model.bct');
fprintf(fid, '%s\n', '3');
fclose(fid);

[s r] = system([smoothbct_path ' < smoothbct.inp']);

%% finalize result

varargout = {};
switch OPT.type
    case 'delft3d'
        if isempty(OPT.file); OPT.file = [runid '.bct']; end;
        
        movefile('model.bct', bctfile, 'f');
        
        varargout{1} = bctfile;
    case 'xbeach'
        if isempty(OPT.file); OPT.file = 'tide.txt'; end;
        
        [tidefile tidelen tideloc] = xb_bct2xb('model.bct', ...
            'tstart', OPT.tstart, 'tlength', OPT.tlength, 'tidefile', OPT.file);
        
        varargout{1} = fullfile(fileparts(bctfile), tidefile);
        varargout{2} = tidelen;
        varargout{3} = tideloc;
        
        movefile(tidefile, varargout{1}, 'f');
    otherwise
        err = ['Unknown target model type [' OPT.type ']'];
end

%% clean up

delete('nesthd2.inp');
delete('smoothbct.inp');

delete('model.bnd');
delete('model.nst');
delete('temp.bct');
delete('dummy.bcc');
delete('nest.dia');

delete(trihfile);

cd(current_dir);

% show errors
if err
    error(err);
end