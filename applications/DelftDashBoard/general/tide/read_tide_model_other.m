function [lon, lat, amp, phi] = read_tide_model_other(fname,xl,yl,cns,tp)
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

fname_needed=fname;

switch tp
    case{'z','h'}
        lonstr='lon';
        latstr='lat';
        ampstr='tidal_amplitude_h'; phistr='tidal_phase_h';correction_factor=1.000;depth_name='depth';
    case{'u'}
        lonstr='lon_u';
        latstr='lat_u';
        ampstr='tidal_amplitude_u'; phistr='tidal_phase_u';correction_factor=0.01;depth_name='depth';
    case{'v'}
        lonstr='lon_v';
        latstr='lat_v';
        ampstr='tidal_amplitude_v'; phistr='tidal_phase_v';correction_factor=0.01;depth_name='depth';
    case{'U'}
        lonstr='lon_u';
        latstr='lat_u';
        ampstr='tidal_amplitude_U'; phistr='tidal_phase_U';correction_factor=0.01;depth_name='depth';
    case{'V'}
        lonstr='lon_v';
        latstr='lat_v';
        ampstr='tidal_amplitude_V'; phistr='tidal_phase_V';correction_factor=0.01;depth_name='depth';
end

fname_depth=fname;

% Consituents
cl=nc_varget(fname,'tidal_constituents');
for i=1:size(cl,1)
    cons{i}=upper(deblank(cl(i,:)));
end
icnst=strmatch(lower(cns),lower(cons),'exact');

xmin=xl(1);
ymin=yl(1);
xmax=xl(2);
ymax=yl(2);

% Get dimensions

x=nc_varget(fname_needed,lonstr);
y=nc_varget(fname_needed,latstr);

if x(2)<x(1) % this happens when e.g. x(1)=-359.875 and x(2)=0.125
    x(1)=x(1)-360;
end
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
    
    a =  nc_varget(fname_needed,ampstr,[ix1left-1 iy1-1 icnst-1],[ix2left-ix1left+1 iy2-iy1+1 1]);
    p =  nc_varget(fname_needed,phistr,[ix1left-1 iy1-1 icnst-1],[ix2left-ix1left+1 iy2-iy1+1 1]);
    ampleft(:,:)   = a;
    phileft(:,:)   = p;
%     
%     if getd
%         dpleft   = nc_varget(fname_depth,depth_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
%     end
    
    % pasting - right
    a =  nc_varget(fname_needed,ampstr,[ix1right-1 iy1-1 icnst-1],[ix2right-ix1right+1 iy2-iy1+1 1]);
    p =  nc_varget(fname_needed,phistr,[ix1right-1 iy1-1 icnst-1],[ix2right-ix1right+1 iy2-iy1+1 1]);
    ampright(:,:)   = a;
    phiright(:,:)   = p;
%     if getd
%         dpright  = nc_varget(fname_depth,depth_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
%     end
    
    % Now paste
    amp   = permute([permute(ampleft,[2 1 3]) permute(ampright,[2 1 3])],[2 1 3]);
    phi   = permute([permute(phileft,[2 1 3]) permute(phiright,[2 1 3])],[2 1 3]);
%     if getd
%         depth = [dpleft' dpright'];
%     end
    
    lon = [lonleft;lonright];
    lat = y(iy1:iy2);
    
else
    
    %% No pasting needed
    % Get values
    a =  nc_varget(fname_needed,ampstr,[ix1-1 iy1-1 icnst-1],[ix2-ix1+1 iy2-iy1+1 1]);
    p =  nc_varget(fname_needed,phistr,[ix1-1 iy1-1 icnst-1],[ix2-ix1+1 iy2-iy1+1 1]);
    amp   = a;
    phi   = p;
%     
%     % Get depth
%     switch tp
%         case{'u','v'}
%             depth = nc_varget(fname_depth,depth_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
%     end
    
    % Fix grid
    lon=x(ix1:ix2)+loncor;
    lat=y(iy1:iy2);
    
end

% % For velocities, divide by depth
% switch tp
%     case{'u','v'}
%         amp=amp./max(depth,0.1);
% end

% Save in structure
amp = amp*correction_factor;
amp=permute(amp,[2 1]);
phi=permute(phi,[2 1]);





% for i=1:length(gt)
%     
%     %% If not OK: pasting needed
%     if ~iok
%         
%         % pasting - left
%         for icnst=1:nrcons
%             ampleft(:,:,icnst)   = nc_varget(fname,gt(i).ampstr,[ix1left-1 iy1-1 icnst-1],[ix2left-ix1left+1 iy2-iy1+1 1]);
%             phileft(:,:,icnst)   = nc_varget(fname,gt(i).phistr,[ix1left-1 iy1-1 icnst-1],[ix2left-ix1left+1 iy2-iy1+1 1]);
%         end
%         if getd
%             dpleft   = nc_varget(fname,'depth',[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
%         end
%         
%         % pasting - right
%         for icnst=1:nrcons
%             ampright(:,:,icnst)   = nc_varget(fname,gt(i).ampstr,[ix1right-1 iy1-1 icnst-1],[ix2right-ix1right+1 iy2-iy1+1 1]);
%             phiright(:,:,icnst)   = nc_varget(fname,gt(i).phistr,[ix1right-1 iy1-1 icnst-1],[ix2right-ix1right+1 iy2-iy1+1 1]);
%         end
%         if getd
%             dpright  = nc_varget(fname,'depth',[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
%         end
%         
%         % Now paste
%         gt(i).amp   = permute([permute(ampleft,[2 1 3]) permute(ampright,[2 1 3])],[2 1 3]);
%         gt(i).phi   = permute([permute(phileft,[2 1 3]) permute(phiright,[2 1 3])],[2 1 3]);
%         if getd
%             depth = [dpleft' dpright'];
%         end
%         
%         % TODO This is still wrong!!! Make distinction between xu, xv and xz!
%         lonz = [lonleft;lonright];
%         lonu = [lonleft;lonright];
%         lonv = [lonleft;lonright];       
%         latz = y(iy1:iy2);
%         latu = yu(iy1:iy2);
%         latv = yv(iy1:iy2);
%         
%     else
%         %% No pasting needed
%         % Get values
%         for icnst=1:nrcons
%             gt(i).amp(:,:,icnst)   = nc_varget(fname,gt(i).ampstr,[ix1-1 iy1-1 icnst-1],[ix2-ix1+1 iy2-iy1+1 1]);
%             gt(i).phi(:,:,icnst)   = nc_varget(fname,gt(i).phistr,[ix1-1 iy1-1 icnst-1],[ix2-ix1+1 iy2-iy1+1 1]);
%         end
%         
%         % Get depth
%         if getd
%             depth = nc_varget(fname,'depth',[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
%             depth = depth';
%         end
%         
%         % Fix grid
%         lonz=x(ix1:ix2)+loncor;
%         latz=y(iy1:iy2);
%         lonu=xu(ix1:ix2)+loncor;
%         latu=yu(iy1:iy2);
%         lonv=xv(ix1:ix2)+loncor;
%         latv=yv(iy1:iy2);
%     end
%     
%     % Save in structure
%     gt(i).amp=permute(gt(i).amp,[2 1 3]);
%     gt(i).phi=permute(gt(i).phi,[2 1 3]);
%     gt(i).phi(gt(i).amp==0)=NaN;
%     gt(i).amp(gt(i).amp==0)=NaN;
% end
% 
