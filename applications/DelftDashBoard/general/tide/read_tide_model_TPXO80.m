function [lon, lat, amp, phi] = read_tide_model_TPXO80(tidefile,xl,yl,cns,tp)
%READTIDEMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = readTideModel(fname, variables)
%
%   Input:
%   fname     =
%   variables  =
%
%   Output:
%   varargout =
%
%   Example
%   readTideModel
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: readTideModel.m 12110 2015-07-16 07:55:24Z ormondt $
% $Date: 2015-07-16 09:55:24 +0200 (Thu, 16 Jul 2015) $
% $Author: ormondt $
% $Revision: 12110 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/tide/readTideModel.m $
% $Keywords: $

%% Start

idpath = strfind(tidefile, 'tpxo80.nc');
fname_reduced = tidefile(1:idpath-1); % Path where all files sit

switch tp
    case{'z','h'}
        lonstr='lon_z';
        latstr='lat_z';
        real_name = 'hRe'; complex_name = 'hIm';correction_factor=0.001;depth_name='hz';
        fname_needed = [fname_reduced 'hf.' lower(cns) '_tpxo8.nc'];
    case{'u'}
        lonstr='lon_u';
        latstr='lat_u';
        real_name = 'uRe'; complex_name = 'uIm';correction_factor=1e-4;depth_name='hu';
        fname_needed = [fname_reduced 'uv.' lower(cns) '_tpxo8.nc'];
    case{'v'}
        lonstr='lon_v';
        latstr='lat_v';
        real_name = 'vRe'; complex_name = 'vIm';correction_factor=1e-4;depth_name='hv';
        fname_needed = [fname_reduced 'uv.' lower(cns) '_tpxo8.nc'];
    case{'U'}
        lonstr='lon_u';
        latstr='lat_u';
        real_name = 'uRe'; complex_name = 'uIm';correction_factor=1e-4;depth_name='hu';
        fname_needed = [fname_reduced 'uv.' lower(cns) '_tpxo8.nc'];
    case{'V'}
        lonstr='lon_v';
        latstr='lat_v';
        real_name = 'vRe'; complex_name = 'vIm';correction_factor=1e-4;depth_name='hv';
        fname_needed = [fname_reduced 'uv.' lower(cns) '_tpxo8.nc'];
end

switch lower(cns)
    case{'ms4','mn4','mf','mm'}
        fname_depth = [fname_reduced 'grid_tpxo8_atlas6.nc'];
    otherwise
        fname_depth = [fname_reduced 'grid_tpxo8atlas_30.nc'];
end

xmin=xl(1);
ymin=yl(1);
xmax=xl(2);
ymax=yl(2);

% Get dimensions

x=nc_varget(fname_needed,lonstr);
y=nc_varget(fname_needed,latstr);

% Y indices

dy=abs(y(2)-y(1));
iy1=find(y<=ymin-dy,1,'last');
if isempty(iy1)
    iy1=1;
end
iy2=find(y>=ymax+dy,1,'first');
if isempty(iy2)
    iy2=length(y);
end

%     dx=(xmax-xmin)/10;
%     dx=max(dx,0.5);
dx=x(2)-x(1);
iok=0;
iglob=0;
if x(end)-x(1)>330
    % Global dataset
    iglob=1;
end
loncor=0;

if iglob
    
    % Assuming global dataset
    % First check situation
    if xmin>=x(1) && xmax<=x(end)
        % No problems
        iok=1;
        ix1=find(x<=xmin-dx,1,'last');
        ix2=find(x>=xmax+dx,1,'first');
    elseif xmin<x(1) && xmax<x(1)
        % Both to the left of the data
        % Check if moving the data 360 deg to the left helps
        xtmp=x-360;
    elseif xmin>x(1) && xmax>x(1)
        % Both to the right of the data
        % Check if moving the data 360 deg to the right helps
        xtmp=x+360;
    else
        % Possibly pasting necessary
        xtmp=x;
    end
    
    if ~iok
        % Check again
        if xmin>=xtmp(1) && xmax<=xtmp(end)
            % No problems now, keep new x value
            iok=1;
            x=xtmp;
            ix1=find(x<=xmin-dx,1,'last');
            ix2=find(x>=xmax+dx,1,'first');
        end
    end
    
    if ~iok
        
        % Needs pasting
        
        % Left hand side
        if xmin<x(1)
            xtmp=x-360;
        else
            xtmp=x;
        end
        ix1left=find(xtmp<=xmin,1,'last');
        ix2left=length(x);
        
        lonleft=xtmp(ix1left:ix2left);
        
        % Right hand side
        if xmax>x(end)
            xtmp=x+360;
        else
            xtmp=x;
        end
        ix1right=1;
        ix2right=find(xtmp>=xmax,1,'first');
        
        lonright=xtmp(ix1right:ix2right);
        
    end
    
else
    
    % Not a global dataset
    % First check situation
    
    iok=1;
    ix1=find(x<=xmin-dx,1,'last');
    ix2=find(x>=xmax+dx,1,'first');
    if ix1==length(x)
        ix1=[];
    end
    if ix2==1
        ix2=[];
    end
    if isempty(ix1) && isempty(ix2)
        % Possibly using WL iso EL
        if xmin<x(1) && xmax<x(end)
            ix1=find(x<=xmin-dx+360,1,'last');
            ix2=find(x>=xmax+dx+360,1,'first');
            loncor=-360;
        else
            ix1=find(x<=xmin-dx-360,1,'last');
            ix2=find(x>=xmax+dx-360,1,'first');
            loncor=360;
        end
    end
    % Using
    if isempty(ix1)
        ix1=1;
    end
    if isempty(ix2)
        ix2=length(x);
    end
end

%% If not OK: pasting needed
if ~iok
    
    % pasting - left
    
    real    =  nc_varget(fname_needed,real_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
    complex =  nc_varget(fname_needed,complex_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
    ampleft(:,:)   = abs(real+1i*complex);
    val   = mod(180*atan2(real,complex)/pi,360) - 90;
    id = val < 270; val(id) = val(id)+360;
    id = val > 360; val(id) = val(id)-360;
    phileft(:,:)   = val;
    
    if getd
        dpleft   = nc_varget(fname_depth,depth_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
    end
    
    % pasting - right
    real    =  nc_varget(fname_needed,real_name,[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
    complex =  nc_varget(fname_needed,complex_name,[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
    ampright(:,:)   = abs(real+1i*complex);
    val   = mod(180*atan2(real,complex)/pi,360) - 90;
    id = val < 270; val(id) = val(id)+360;
    id = val > 360; val(id) = val(id)-360;
    phiright(:,:)   = val;
    if getd
        dpright  = nc_varget(fname_depth,depth_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
    end
    
    % Now paste
    amp   = permute([permute(ampleft,[2 1 3]) permute(ampright,[2 1 3])],[2 1 3]);
    phi   = permute([permute(phileft,[2 1 3]) permute(phiright,[2 1 3])],[2 1 3]);
    if getd
        depth = [dpleft' dpright'];
    end
    
    lon = [lonleft;lonright];
    lat = y(iy1:iy2);
    
else
    
    %% No pasting needed
    % Get values
    real    =  nc_varget(fname_needed,real_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
    complex =  nc_varget(fname_needed,complex_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
    amp   = abs(real+1i*complex);
    val   = mod(180*atan2(real,complex)/pi,360) - 90;
    id = val < 270; val(id) = val(id)+360;
    id = val > 360; val(id) = val(id)-360;
    phi   = val;
    
    % Get depth
    switch tp
        case{'u','v'}
            depth = nc_varget(fname_depth,depth_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
    end
    
    % Fix grid
    lon=x(ix1:ix2)+loncor;
    lat=y(iy1:iy2);
    
end

% For velocities, divide by depth
switch tp
    case{'u','v'}
        amp=amp./max(depth,0.1);
end

% Save in structure
amp = amp*correction_factor;
amp=permute(amp,[2 1]);
phi=permute(phi,[2 1]);

