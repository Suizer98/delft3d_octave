function writeLTR(filename, shoreline, locations, active_height, pro_file, cfs_file, cfe_file, sco_file, varargin)
%write LTR : Writes a unibest lt-run specification file (automatically computing coast angle)
%
%   Syntax:
%     function writeLTR(filename, LTRdata)
%       or :
%     function writeLTR(filename, shoreline, locations, active_height, pro_file, cfs_file, cfe_file, sco_file, ray_file)
% 
%   Input:
%     filename             string with output filename
%     LTRdata              Structure with the following fields:
%                          .angle
%                          .h0
%                          .pro_file
%                          .cfs_file
%                          .cfe_file
%                          .sco_file
%                          .ray_file
% 
%     or alternatively:
%     filename             string with output filename
%     shoreline            Shoreline, string with filename of polygon or matrix [Nx2]
%                          (if shoreline is [Nx1] and locations is empty -> shoreline values will be used as coast angle)
%     locations            SCO locations, string with filename of polygon or matrix [Nx2]
%     active_height        Active height (closure depth + active beach crest) ([Nx1] matrix or single value)
%     pro_file             string with name of the pro-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     cfs_file             string with name of the cfs-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     cfe_file             string with name of the cfe-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     sco_file             string with name of the sco-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     ray_file             (optional; assumed to be similar to sco-file otherwise) string with name of the ray-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%  
%   Output:
%     .LTR file
%
%   Example:
%     writeLTR('test.ltr', 20, [], 8, 'diep', 'bijker', 'waves', 'baseline', 'baseline')
%     writeLTR('test.ltr', 'shore.pol', 'loc.ldb', 5, 'diep', 'bijker', 'waves', 'baseline', 'baseline')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeLTR.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeLTR.m $
% $Keywords: $

if isstruct(shoreline)

    LTRdata = shoreline;
    
    fid = fopen(filename,'wt');
    fprintf(fid,'%s\n','Number of Climates');
    fprintf(fid,'%s\n', num2str(LTRdata.no));
    fprintf(fid,'%s\n','         ORKST     PROFH     .PRO       .CFS       .CFE       .SCO       .RAY');
    for ii=1:LTRdata.no
        fprintf(fid,'     %8.2f    %8.2f   ''%s''   ''%s''  ''%s''  ''%s''  ''%s'' \n',LTRdata.angle(ii), LTRdata.h0(ii), LTRdata.pro_file{ii}, LTRdata.cfs_file{ii}, LTRdata.cfe_file{ii}, LTRdata.sco_file{ii}, LTRdata.ray_file{ii} );
    end
    fclose(fid);
    
elseif nargin>=8

    %-----------Catch input data----------------
    %-------------------------------------------
    max_distance_between_gridpoints = 10;
    option           = 0;
    if isstr(shoreline)
        shoreline    = readldb(shoreline);
        option       = 1;
    elseif size(shoreline,2)==2
        shoreline    = struct('x',shoreline(:,1),'y',shoreline(:,2));
        option       = 1;
    elseif size(shoreline,2)==1
        locs2        = struct;
        locs2.angles = shoreline;
    end

    if option == 1
        if isstr(locations)
            locs = readldb(locations);
        else
            locs = struct('x',locations(:,1),'y',locations(:,2));
        end
    end

    if option==1
        id = find(shoreline.x~=999.999);
        shoreline.x = shoreline.x(id);
        shoreline.y = shoreline.y(id);

        %----------determine coast angle------------
        %-------------------------------------------
        shoreline2 = add_equidist_points(max_distance_between_gridpoints,[shoreline.x,shoreline.y]);
        dx = shoreline2(2:end,1) - shoreline2(1:end-1,1);
        dy = shoreline2(2:end,2) - shoreline2(1:end-1,2);
        cangle = mod(-360*atan2(dy, dx)/(2*pi),360);
        cangle = (cangle(1:end-1)+cangle(2:end))/2;
        locs2=struct;

        % find nearest locations on the shoreline relative to offshore boundary point
        for ii = 1: length(locs.x)
            dx   = shoreline2(:,1) - locs.x(ii);
            dy   = shoreline2(:,2) - locs.y(ii);
            dist = sqrt(dx.^2+dy.^2);
            id   = find(dist==min(min(dist)));
            locs2.x(ii)  = shoreline2(id,1);
            locs2.y(ii)  = shoreline2(id,2);
            locs2.angles(ii) = cangle(id);
            locs2.id(ii) = id;
        end
        number_of_rays    = length(locs.x);
    else
        number_of_rays    = length(locs2.angles);
    end

    %-----------Catch input data----------------
    %-------------------------------------------
    err=0;
    if length(locs2.angles)~=number_of_rays
        locs2.angles = repmat(locs2.angles(1),[number_of_rays 1]);
    end
    if length(active_height)~=number_of_rays
        active_height = repmat(active_height(1),[number_of_rays 1]);
    end
    if length(pro_file)~=number_of_rays
        pro_file = [repmat(pro_file,[number_of_rays 1])];
        pro_file = [pro_file, num2str([1:number_of_rays]','%02.0f')];
        pro_file = num2cell(pro_file,2);
    end
    if length(cfs_file)~=number_of_rays
        cfs_file = [repmat(cfs_file,[number_of_rays 1])];
        %cfs_file = [cfs_file, num2str([1:number_of_rays]','%02.0f')];
        cfs_file = num2cell(cfs_file,2);
    end
    if length(cfe_file)~=number_of_rays
        cfe_file = [repmat(cfe_file,[number_of_rays 1])];
        %cfe_file = [cfe_file, num2str([1:number_of_rays]','%02.0f')];
        cfe_file = num2cell(cfe_file,2);
    end

    if length(sco_file)~=number_of_rays
        sco_file = [repmat(sco_file,[number_of_rays 1])];
        sco_file = [sco_file, num2str([1:number_of_rays]','%02.0f')];
        sco_file = num2cell(sco_file,2);
    end

    if nargin==9
        ray_file = varargin{1};
        if length(ray_file)~=number_of_rays
            ray_file = [repmat(ray_file,[number_of_rays 1])];
            ray_file = [ray_file, num2str([1:number_of_rays]','%02.0f')];
            ray_file = num2cell(ray_file,2);
        end
    else
        ray_file = sco_file;
    end

    %-----------Write data to file--------------
    %-------------------------------------------
    if err==0
        fid = fopen(filename,'wt');
        fprintf(fid,'%s\n','Number of Climates');
        fprintf(fid,'%s\n', num2str(number_of_rays));
        fprintf(fid,'%s\n','         ORKST     PROFH     .PRO      .CFS      .CFE      .SCO      .RAY');
        for ii=1:number_of_rays
            fprintf(fid,'     %8.2f    %8.2f   ''%s''%s  ''%s''  ''%s''  ''%s''  ''%s'' \n',locs2.angles(ii), active_height(ii), pro_file{ii},repmat(' ',[1 max(0,25-length(pro_file{ii}))]), cfs_file{ii}, cfe_file{ii}, sco_file{ii}, ray_file{ii});
        end
        fclose(fid);
    else
        fprintf(' warning: input incorrectly specified!')
    end

else
    fprintf('Error in writing LTR file : Number of input variables is incorrect! \n');
end

