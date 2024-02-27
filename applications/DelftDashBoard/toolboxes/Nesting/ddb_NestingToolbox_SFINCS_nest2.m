function ddb_NestingToolbox_SFINCS_nest2(varargin)
%DDB_NESTINGTOOLBOX_NESTHD2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD2(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD2
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

% $Id: ddb_NestingToolbox_nestHD2.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_nestHD2.m $
% $Keywords: $

%%
if isempty(varargin)
    
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    
    % Check to see if there are any constituents in the model. If not, make
    % sure the transport box is not ticked.
    
    setInstructions({'Click Run Nesting in order to generate boundary conditions for the nested model', ...
        'The overall model simulation must be finished and a history file must be present','The nested model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest2'}
            nest2;
    end
end

%%
function nest2

handles=getHandles;

if isempty(handles.toolbox.nesting.trihFile)
    ddb_giveWarning('text','Please first load history file of overall model!');
    return
end

hisfile=handles.toolbox.nesting.trihFile;
nestadm=handles.toolbox.nesting.admFile;
z0=handles.toolbox.nesting.zCor;

mn=load(nestadm);
m=mn(:,1);
n=mn(:,2);

fid=qpfopen(hisfile);
times = qpread(fid,1,'water level','times');
stations = qpread(fid,1,'water level','stations');
tref=handles.model.sfincs.domain(ad).tref;
tstart=handles.model.sfincs.domain(ad).tstart;
tstop=handles.model.sfincs.domain(ad).tstop;
it0=find(times>=tstart,1,'first');
it1=find(times<=tstop,1,'last');
times=times(it0:it1);
t=86400*(times-tref);
wl=qpread(fid,1,'water level','data',it0:it1,0);

bnddata0=zeros(length(times),length(m));
bnddata=bnddata0;
for iobs=1:length(m)
    mstr=[repmat(' ',[1 5-length(num2str(m(iobs)))]) num2str(m(iobs))];
    nstr=[repmat(' ',[1 5-length(num2str(n(iobs)))]) num2str(n(iobs))];
    name=['(M,N)=('   mstr ','  nstr ')'];
    ii=strmatch(name,stations,'exact');
    v=squeeze(wl.Val(:,ii))+z0;
    bnddata(:,iobs)=v;
end
    
[filename, pathname, filterindex] = uiputfile('*.bzs','Select Water Level Timeseries File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    
    sfincs_write_boundary_conditions(filename,t,bnddata);
    
    handles.model.sfincs.domain(ad).input.bzsfile=filename;
    handles.model.sfincs.domain(ad).flowboundaryconditions.time=t;
    handles.model.sfincs.domain(ad).flowboundaryconditions.val=bnddata;

    % Also write wave conditions: this is a temporary fix !!!
    sfincs_write_boundary_conditions('sfincs.bhs',t,bnddata0+handles.model.sfincs.boundaryconditions.hs);
    sfincs_write_boundary_conditions('sfincs.btp',t,bnddata0+handles.model.sfincs.boundaryconditions.tp);
    sfincs_write_boundary_conditions('sfincs.bwd',t,bnddata0+handles.model.sfincs.boundaryconditions.wd);
    handles.model.sfincs.domain(ad).input.bwvfile=handles.model.sfincs.domain(ad).input.bndfile;

end
    
setHandles(handles);
