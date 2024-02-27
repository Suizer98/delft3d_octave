function [xx,yy]=nest1_delft3dwave_in_delft3dwave(overall,detail,mindepth,method,len)
%nest1_delft3dwave_in_delft3dwave  Step 1 of nesting Delft3D-WAVE model in Delft3D-WAVE model.
%
%   E.g.
%
%   overall.cs.name='WGS 84'
%   overall.cs.type='geographic'
%   detail.cs.name='WGS 84 / UTM zone 11N'
%   detail.cs.type='projected'
%   detail.grdfile='sea.grd'
%   detail.depfile='sea.dep'
%
%   [xx,yy]=nest1_delft3dwave_in_delft3dwave(overall,detail,-5,'distance',10000)
%
%   method can be 'distance' or 'number_of_cells'

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
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

xx=[];
yy=[];

% Read grid and depth of detailed model
[xg,yg,enc,cs,nodatavalue] = wlgrid('read',detail.grdfile);
depth = -wldep('read',detail.depfile,[size(xg,1)+1 size(xg,2)+1]);
depth=depth(1:end-1,1:end-1);
depth(depth==999)=NaN;

if isfield(detail,'cs')
    if ~strcmpi(detail.cs.name,'unspecified')
        [xg,yg]=convertCoordinates(xg,yg,'CS1.name',detail.cs.name,'CS1.type',detail.cs.type,'CS2.name',overall.cs.name,'CS2.type',overall.cs.type);
    end
end
cstype=lower(overall.cs.type);

% Find all boundary points
[bnd,circ,sections]=find_boundary_sections_on_regular_grid(xg,yg,depth,mindepth);

% And now split up into boundary sections
switch method

    case{'distance'}
        np=0;
        lastxp=1e9;
        lastyp=1e9;
        for isec=1:length(sections)
            if isec>1
                % Check to see if this boundary section begins where the
                % previous section ended.
                if sections(isec).x(1)~=sections(isec-1).x(end) && sections(isec).y(1)~=sections(isec-1).y(end)
                    lastxp=1e9;
                    lastyp=1e9;
                end
            end
            
            lastxp=sections(isec).x(1);
            lastyp=sections(isec).y(1);
            
            for ip=1:length(sections(isec).x)
                xp=sections(isec).x(ip);
                yp=sections(isec).y(ip);
                switch cstype
                    case{'geographic'}
                        dstx=111111*(xp-lastxp)*cos(yp*pi/2);
                        dsty=111111*(yp-lastyp);
                        dst=sqrt(dstx^2+dsty^2);
                    otherwise
                        dst=sqrt((xp-lastxp)^2 + (yp-lastyp)^2);
                end
                % Check if this point is more than max_dist away from last point that was found
                if dst>len || ip==length(sections(isec).x)
                    % New point found
                    np=np+1;
                    xx(np)=xp;
                    yy(np)=yp;
                    lastxp=xp;
                    lastyp=yp;
                end
            end
        end
        
    case{'number_of_cells'}
        np=0;
        for isec=1:length(sections)
            lastip=1;
            icont=0;
            if isec>1
                % Check to see if this boundary section begins where the
                % previous section ended.
                if sections(isec).x(1)~=sections(isec-1).x(end) && sections(isec).y(1)~=sections(isec-1).y(end)
                    % It does not begin where last section ended
                    icont=0;
                else
                    icont=1;
                end
            end
            for ip=1:length(sections(isec).x)
                xp=sections(isec).x(ip);
                yp=sections(isec).y(ip);
                % Check if this point is more than max_dist away from last point that was found
                if icont==0 || ip-lastip==len || ip==length(sections(isec).x)
                    % New point found
                    np=np+1;
                    xx(np)=xp;
                    yy(np)=yp;
                    lastip=ip;
                    icont=1;
                end
            end
        end

end

