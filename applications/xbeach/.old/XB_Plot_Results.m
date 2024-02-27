function output = xb_plot_results(varargin)
%XB_PLOT_RESULTS  Simple routine for first basic inspection of XBeach results
%
%   Simple routine for first basic inspection of XBeach results.
%
%   Syntax:
%   output = xb_plot_results(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   output =
%
%   Example
%   XB_plot_results
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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
% Created: 27 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XB_Plot_Results.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_Plot_Results.m $
% $Keywords: $
clc
%% settings
% defaults
OPT.basedir   = [];    % description of input argument 1
OPT.var       = { ...
    'zb', ...          % bed level [m]
    'zs', ...          % waterlevel including long waves [m]
    'u',  ...          % crossshore velocity [m/s]
    'v'};              % alongshore [m/s]
OPT.stride_t  = 1;     % take a stride of OPT.stride_t through the time vector

% overrule default settings by property pairs, given in varargin
OPT     = setproperty(OPT, varargin{:});

%% Open the dims.dat to extract all relevant dimensions
if isempty(OPT.basedir)
    fid = fopen(fullfile(pwd,'dims.dat'),'r');
else
    fid = fopen(fullfile(OPT.basedir,'dims.dat'),'r');
end

nt      = fread(fid,1,'double');
nx      = fread(fid,1,'double');
ny      = fread(fid,1,'double');

fclose(fid);

%% Read x and y grids
fixy    = fopen('xy.dat','r');

output.x       = fread(fixy,[nx+1,ny+1],'double');
output.y       = fread(fixy,[nx+1,ny+1],'double');

fclose(fixy);

%% read variables indicated in OPT.var
% initialise the tdim
tdim = 1:OPT.stride_t:nt;
output.time = tdim;

for i   = 1:length(OPT.var)
    % initialise
    output.(OPT.var{i}) = zeros(nx+1, ny+1, length(tdim))*nan;
    
    fid = fopen([OPT.var{i} '.dat'],'r');
    for j = 1 : length(tdim);
        if ismember(j,tdim)
            output.(OPT.var{i})(:,:,j) = fread(fid,[nx+1,ny+1],'double');
        else
            fread(fid,[nx+1,ny+1],'double');
        end
        if j==1 && strcmpi(OPT.var{i}, 'z')
            output.z0 = z;
        end
    end
end

% figure(2);
% 
% for i=1:nt;
% end
% if 1
%     if mod(i,1)==0
%         %     subplot(221);pcolor(x,y,f);shading interp;colorbar;title('Hrms');caxis([0 2]);axis equal
%         %     subplot(222);pcolor(x,y,z);shading flat;caxis([-10 5]);colorbar;title('zb');axis equal
%         %     subplot(223);pcolor(x,y,s);shading interp;colorbar;title('setup');axis equal;caxis([-1 1])
%         %     subplot(224);pcolor(x,y,sqrt(u.^2+v.^2));shading interp;caxis([-.5 .5]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('velocity');hold off;axis equal
%         pcolor(x,y,z-z0);shading interp;caxis([-2 2]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('H,Velocity');hold off;axis equal
%         %       pcolor(x,y,z);shading interp;caxis([-10 2]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('H,Velocity');hold off;axis equal
%         
%         drawnow
%         %pause(0.5);
%         %F = getframe(gcf);
%         %mov = addframe(mov,F);
%     end
% end;
% fclose(fid)
% %mov = close(mov);
% 
% 
%     
% % fiz     = fopen('zb.dat','r');
% % fiu     = fopen('u.dat','r');
% % fiv     = fopen('v.dat','r');
% % fis     = fopen('zs.dat','r');
% % fidzl   = fopen('dzlayer.dat','r');
% % fis=fopen('v.dat','r');
% %mov = avifile('mov','fps',5,'keyframe',9999);
% for i=1:nt;
%     f=fread(fid,[nx+1,ny+1],'double');
%     z=fread(fiz,[nx+1,ny+1],'double');
%     s=fread(fis,[nx+1,ny+1],'double');
%     u=fread(fiu,[nx+1,ny+1],'double');
%     v=fread(fiv,[nx+1,ny+1],'double');
%     %    dzlayer=fread(fidzl,[nx+1,ny+1],'double');
%     if i==1
%         z0=z;
%     end
% end
% 
% if 1
%     if mod(i,1)==0
%         %     subplot(221);pcolor(x,y,f);shading interp;colorbar;title('Hrms');caxis([0 2]);axis equal
%         %     subplot(222);pcolor(x,y,z);shading flat;caxis([-10 5]);colorbar;title('zb');axis equal
%         %     subplot(223);pcolor(x,y,s);shading interp;colorbar;title('setup');axis equal;caxis([-1 1])
%         %     subplot(224);pcolor(x,y,sqrt(u.^2+v.^2));shading interp;caxis([-.5 .5]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('velocity');hold off;axis equal
%         pcolor(x,y,z-z0);shading interp;caxis([-2 2]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('H,Velocity');hold off;axis equal
%         %       pcolor(x,y,z);shading interp;caxis([-10 2]);colorbar;hold on;quiver(x,y,u,v,2,'k');title('H,Velocity');hold off;axis equal
%         
%         drawnow
%         %pause(0.5);
%         %F = getframe(gcf);
%         %mov = addframe(mov,F);
%     end
% end;
% fclose(fid)
% %mov = close(mov);
% 
