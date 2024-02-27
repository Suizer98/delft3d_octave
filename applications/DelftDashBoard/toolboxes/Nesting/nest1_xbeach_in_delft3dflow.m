function obspoints=nest1_xbeach_in_delft3dflow(varargin)
%ddb_nesthd1_dflowfm_in_delft3dflow  Step 1 of nesting Delft3D-FLOW  in xbeach.
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
admfile='nesting.adm';

% Input
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'admfile'}
                admfile=varargin{ii+1};
            case{'overall'}
                overall=varargin{ii+1};
            case{'detail'}
                detail=varargin{ii+1};
            case{'exedir'}
                exedir=varargin{ii+1};
        end
    end
end

obspoints=[];

% Assuming gridform=xbeach !
% to do is delft3d

%% Detail grid
% Convert detailed grid (if necessary)
if ~strcmpi(detail.cs.name,'unspecified')
    [grd.X,grd.Y]= convertCoordinates(detail.x,detail.y, 'CS1.name',detail.cs.name,'CS1.type',detail.cs.type,'CS2.name',overall.cs.name,'CS2.type',overall.cs.type);
    grd.CoordinateSystem='Cartesian';
    filename = [detail.path, 'TMP.grd'];
    ddb_wlgrid('write',filename,grd, 'x', grd.X, 'y', grd.Y);
    detail.grdfile=filename;
end
% And write enclosure file
enc=enclosure('extract',grd.X,grd.Y);
filename = [detail.path, 'TMP.enc']
enclosure('write',filename,enc);
detail.encfile=filename;

%% Create TMP.bnd file
filename = [detail.path, 'TMP.bnd'];
detail.bndfile=filename;
fi2=fopen(filename,'wt');
fprintf(fi2,'%s\n',['sea                  Z T     1     1     ' num2str(size(grd.X,1)-1) '   1   0.0000000e+000']);
fclose(fi2);

%% Run NestHD1
cd(overall.path)
[ny nx] = size(detail.x);

if ny == 1;
    
    G1 = delft3d_io_grd('read' ,overall.grdfile);
    distance_x = detail.x(1,1) - G1.cen.x; distance_y = detail.y(1,1) - G1.cen.y;
    distance_tot = (distance_x.^2 + distance_y.^2).^0.5;
    [idx idy] = find(distance_tot == min(min(distance_tot)));
    obspoints.name = 'XBeach';
    obspoints.m = idx;
    obspoints.n = idy;
    
else
    
    % Run nesth1
    fid=fopen('nesthd1.inp','wt');
    fprintf(fid,'%s\n',overall.grdfile);
    fprintf(fid,'%s\n',overall.encfile);
    fprintf(fid,'%s\n',detail.grdfile);
    fprintf(fid,'%s\n',detail.encfile);
    fprintf(fid,'%s\n',detail.bndfile);
    fprintf(fid,'%s\n',admfile);
    fprintf(fid,'%s\n','ddtemp.obs');
    fclose(fid);
    system(['"' exedir 'nesthd1" < nesthd1.inp']);
    
    % Read obs file
    [name,m,n] = textread('ddtemp.obs','%21c%f%f');
    for iobs=1:length(m)
        obspoints(iobs).name=name(iobs,:);
        obspoints(iobs).m=m(iobs,:);
        obspoints(iobs).n=n(iobs,:);
    end

end

%% Delete temporary files
delete('nesthd1.inp');
for ii = 1:2
    if ii == 1;
        cd(overall.path)
    end
    if ii == 2;
        cd(detail.path);
    end
    try
        delete('ddtemp.obs');
    end
    if exist('TMP.grd','file')
        delete('TMP.grd');
    end
    if exist('TMP.enc','file')
        delete('TMP.enc');
    end
    if exist('TMP.bnd','file')
        delete('TMP.bnd');
    end
end
cd ..


