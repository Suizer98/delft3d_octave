function obspoints=nest1_delft3dflow_in_dflowfm(varargin)
%nest1_delft3dflow_in_dflowfm  Step 1 of nesting Delft3D-FLOW in DFlow-FM model.
%
% Creates nesting administration file
% Optionally returns structure with new observation points for Delft3D-FLOW model
% Optionally creates temporary obs file for Delft3D-FLOW model
%
%   Example
%           newpoints=nest1_delft3dflow_in_dflowfm('admfile','nesting.adm','extfile','test.ext', ...
%                'grdfile','newyork.grd','encfile','newyork.enc');        
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_nesthd1_dflowfm_in_delft3dflow.m 9236 2013-09-19 09:30:05Z ormondt $
% $Date: 2013-09-19 11:30:05 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9236 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_nesthd1_dflowfm_in_delft3dflow.m $
% $Keywords: $

%%

% Set defaults
csoverall.name='WGS 84';
csoverall.type='geographic';
csdetail.name='WGS 84';
csdetail.type='geographic';
admfile='nesting.adm';
obsfile='';
extfile='';
grdfile='';
encfile='';

% Input
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'admfile'}
                admfile=varargin{ii+1};
            case{'grdfile'}
                grdfile=varargin{ii+1};
            case{'encfile'}
                encfile=varargin{ii+1};
            case{'bndfile'}
                bndfile=varargin{ii+1};
            case{'csoverall'}
                csoverall=varargin{ii+1};
            case{'csdetail'}
                csdetail=varargin{ii+1};
        end
    end
end

obspoints=[];

% Read grd file
[x,y,enc]=ddb_wlgrid('read',grdfile);
mn=ddb_enclosure('read',encfile);
[x,y]=ddb_enclosure('apply',mn,x,y);
kcs=determineKCS(x,y);

% Read bnd file    
bnd=delft3dflow_readBndFile(bndfile);
% Initialize individual boundary sections
t0=0;
t1=0;
nrsed=0;
nrtrac=0;
nrharmo=0;
z=zeros(size(x));
kmax=1;
for ib=1:length(bnd)
    bnd=delft3dflow_initializeOpenBoundary(bnd,ib,t0,t1,nrsed,nrtrac,nrharmo,x,y,z,kcs,kmax);
end

nrobs=0;

for ib=1:length(bnd)
    
    % Loop through boundaries
    
    % A
    
    x=bnd(ib).x(1);
    y=bnd(ib).y(1);
    
    if ~strcmpi(csdetail.name,'unspecified')
        if ~strcmpi(csoverall.name,csdetail.name) || ~strcmpi(csoverall.type,csdetail.type)
            [x,y]=convertCoordinates(x,y,'CS1.name',csdetail.name,'CS1.type',csdetail.type, ...
                'CS2.name',csoverall.name,'CS2.type',csoverall.type);
        end
    end
    
    nrobs=nrobs+1;
    
    obspoints(nrobs).name=[bnd(ib).name '_A'];
    obspoints(nrobs).x=x;
    obspoints(nrobs).y=y;
    
    % B
    
    x=bnd(ib).x(end);
    y=bnd(ib).y(end);
    
    if ~strcmpi(csdetail.name,'unspecified')
        if ~strcmpi(csoverall.name,csdetail.name) || ~strcmpi(csoverall.type,csdetail.type)
            [x,y]=convertCoordinates(x,y,'CS1.name',csdetail.name,'CS1.type',csdetail.type, ...
                'CS2.name',csoverall.name,'CS2.type',csoverall.type);
        end
    end
    
    nrobs=nrobs+1;
    
    obspoints(nrobs).name=[bnd(ib).name '_B'];
    obspoints(nrobs).x=x;
    obspoints(nrobs).y=y;
    
end

% No need for nesting administration file
