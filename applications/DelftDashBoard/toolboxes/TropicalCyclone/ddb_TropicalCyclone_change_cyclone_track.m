function ddb_TropicalCyclone_change_cyclone_track(varargin)
%ddb_TropicalCyclone_change_cyclone_track  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCyclone_change_cyclone_track(x, y, varargin)
%
%   Input:
%   x        =
%   y        =
%   varargin =
%
%
%
%
%   Example
%   ddb_TropicalCyclone_change_cyclone_track
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

% $Id: ddb_TropicalCyclone_change_cyclone_track.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_TropicalCyclone_change_cyclone_track.m $
% $Keywords: $

%%

handles=getHandles;

inp=handles.toolbox.tropicalcyclone;

h=varargin{1};
x=varargin{2};
y=varargin{3};
nr=[];

if nargin==4
    nr=varargin{4};
end

setInstructions({'','Left-click and drag track vertices to change track position','Right-click track vertices to change cyclone parameters'});

inp.nrTrackPoints=length(x);
inp.track.x=x;
inp.track.y=y;

if isempty(nr)

    % This is a new track
    
    % Delete existing track
    try
        delete(h);
    end
    inp.trackhandle=[];

    nt=length(x);
    
    inp.track=ddb_TropicalCyclone_set_dummy_track_values(nt);
    
    inp.track.time=inp.startTime:inp.timeStep/24:inp.startTime+(nt-1)*inp.timeStep/24;
    
    inp.track.x=x;
    inp.track.y=y;
    inp.track.vmax=zeros(nt,1)+inp.vmax;
    inp.track.pc=zeros(nt,1)+inp.pc;
    inp.track.rmax=zeros(nt,1)+inp.rmax;

    % Ensemble parameters
    inp.ensemble.t0=inp.track.time(1);
    inp.ensemble.t0_spw=inp.track.time(1);
    inp.ensemble.length=inp.track.time(end)-inp.track.time(1);
    
    inp.drawingtrack=0;

    handles.toolbox.tropicalcyclone=inp;
    
    setHandles(handles);
    
    ddb_TropicalCyclone_plot_cyclone_track;

    model=handles.activeModel.name;
    if inp.track.time(1)>handles.model.(model).domain(ad).startTime
        ddb_giveWarning('text','Start time cyclone is greater than simulation start time!');
    end
    
    if inp.track.time(end)<handles.model.(model).domain(ad).stopTime
        ddb_giveWarning('text','Stop time cyclone is smaller than simulation stop time!');
    end

else
    handles.toolbox.tropicalcyclone=inp;
    setHandles(handles);
end

gui_updateActiveTab;
