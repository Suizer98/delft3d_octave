function varargout = ddb_dnami(varargin)
%DDB_DNAMI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ddb_dnami(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ddb_dnami
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_dnami.m 10889 2014-06-25 08:09:38Z boer_we $
% $Date: 2014-06-25 16:09:38 +0800 (Wed, 25 Jun 2014) $
% $Author: boer_we $
% $Revision: 10889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/dnami/ddb_dnami.m $
% $Keywords: $

%%
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc     foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch flinepatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%global Areaeq

global progdir   datadir    workdir     tooldir ldbfile
global xgrdarea  ygrdarea   grdsize

xgrdarea = [];   ygrdarea = [];
d3dfilgrd= [];   d3dfildep= [];
%
%initialise all necessary constants and data
%
raddeg= 180./pi;   degrad= pi/180.;
rearth= 6378137.;  mu    = 30.0e9;
iarea = 0;         Mw    = 0;        nseg = 1;
%
% Reinitialise all values
%
ddb_dnami_initValues()

%Start always in the path with ddb_dnami.m
cd(strrep(which('dnami.m'),'ddb_dnami.m',''));

%Reset paths
path(pathdef);
%Add current path and code-path
addpath(pwd);
% check Delft3D environment variable
tooldir=getINIValue('DTT_config.txt','Tooldir');
progdir=getINIValue('DTT_config.txt','Progdir');
datadir=getINIValue('DTT_config.txt','Datadir');
workdir=getINIValue('DTT_config.txt','Workdir');

addpath(tooldir);
addpath(datadir);

dum=str2num(getINIValue('DTT_config.txt','GridAreaLft')); xgrdarea= dum;
dum=str2num(getINIValue('DTT_config.txt','GridAreaRgt')); xgrdarea=[xgrdarea;dum];
dum=str2num(getINIValue('DTT_config.txt','GridAreaBot')); ygrdarea= dum;
dum=str2num(getINIValue('DTT_config.txt','GridAreaTop')); ygrdarea=[ygrdarea;dum];
grdsize   =str2num(getINIValue('DTT_config.txt','GridSize'));
tolFlength=str2num(getINIValue('DTT_config.txt','TolerancefLength'));



%wlsettings
fig1 = openfig(mfilename,'reuse');
% Generate a structure of handles to pass to callbacks, and store it.
handles = guihandles(fig1);
guidata(fig1, handles);

% Use system color scheme for figure:
set(fig1,'Color',get(0,'defaultUicontrolBackgroundColor'));
set(fig1,'name','Tsunami Toolkit')
set(fig1,'Units','normalized')
set(fig1,'Position', ddb_dnami_getPlotPosition('LR'))

if nargout > 0
    varargout{1} = fig1;
end

%
% Set all values for initial start
%
ddb_dnami_setValues();

