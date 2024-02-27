function obspoints=nest1_sfincs_in_delft3dflow(varargin)
%ddb_nesthd1_dflowfm_in_delft3dflow  Step 1 of nesting Delft3D-FLOW model in Delft3D-FLOW model.
%
% Creates nesting administration file
% Optionally returns structure with new observation points for Delft3D-FLOW model
% Optionally creates temporary obs file for Delft3D-FLOW model
%
%   Example
%           newpoints=ddb_nesthd1_dflowfm_in_delft3dflow('admfile','nesting.adm','extfile','test.ext', ...
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

% $Id: ddb_nesthd1_dflowfm_in_delft3dflow.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_nesthd1_dflowfm_in_delft3dflow.m $
% $Keywords: $

%%

% Set defaults
overall.cs.name='WGS 84';
overall.cstype='geographic';
detail.cs.name='WGS 84';
detail.cs.type='geographic';

% Input
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'overall'}
                overall=varargin{ii+1};
            case{'detail'}
                detail=varargin{ii+1};
            case{'admfile'}
                admfile=varargin{ii+1};
        end
    end
end

obspoints=[];

%% SFINCS boundary points
xy=load(detail.bndfile);
xp=xy(:,1);
yp=xy(:,2);

%% Overall grid
grd=ddb_wlgrid('read',overall.grdfile);

% Convert detailed grid (if necessary)
if ~isfield(detail,'cs')
    if (~strfind(detail.cs.name, overall.cs.name) || ~strfind(detail.cs.type, overall.cs.type))
        detail.cs.name='unspecified';
    end
end

if ~strcmpi(detail.cs.name,'unspecified')
    % Convert SFINCS points to coordinate system of Delft3D model
    [xp,yp]=convertCoordinates(xp,yp,'CS1.name',detail.cs.name,'CS1.type',detail.cs.type,'CS2.name',overall.cs.name,'CS2.type',overall.cs.type);    
end

% Get 
[m,n]=findgridcell(xp,yp,grd.X,grd.Y);

for iobs=1:length(m)
    mstr=[repmat(' ',[1 5-length(num2str(m(iobs)))]) num2str(m(iobs))];
    nstr=[repmat(' ',[1 5-length(num2str(n(iobs)))]) num2str(n(iobs))];
    name=['(M,N)=('   mstr ','  nstr ')'];
    obspoints(iobs).name=name;
    obspoints(iobs).m=m(iobs);
    obspoints(iobs).n=n(iobs);    
end

fid=fopen(admfile,'wt');
for iobs=1:length(m)
    fprintf(fid,'%5i %5i\n',m(iobs),n(iobs));
end
fclose(fid);

