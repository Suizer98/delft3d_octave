function XB = XBeach_selectgrid(X, Y, Z, varargin)
%XBEACH_SELECTGRID  One line description goes here.
%
%   Please note:
%   deepval and dryval are both considered as positive. In addition, it is
%   assumed that the reference level is in between the deepval and dryval
%   level
%
%   Syntax:
%   varargout = XBeach_selectgrid(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_selectgrid
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Dano Roelvink / Ap van Dongeren / C.(Kees) den Heijer / Mark van Koningsveld
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 03 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: XBeach_selectgrid.m 4591 2011-05-24 12:38:51Z roelvin $
% $Date: 2011-05-24 20:38:51 +0800 (Tue, 24 May 2011) $
% $Author: roelvin $
% $Revision: 4591 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xb_grid/XBeach_selectgrid.m $

%% default Input section
OPT = struct(...
    'manual', true,...
    'struct',false,...
    'plot', true,...
    'WL_t', 0,...       % (unknown parameter)
    'xori', 0,...       % xloc of XBeach grid origin
    'yori', 0,...       % yloc of XBeach grid origin
    'alfa', 0,...       % alpha orientation of XBeach grid
    'dx', 2,...         % dx of support grid (raw data interpolated to this grid)
    'dy', 2,...         % dy of support grid (raw data interpolated to this grid)
    'dryval', 10,...    % landward extrapolation max value
    'maxslp', .2,...    % landward directed slope
    'seaslp', .02,...   % seaward directed slope
    'deepval', 10,...   % seaward extrapolation depth
    'dxmax', 20,...     % max value of crossshore gridsize (automatically generated)
    'dxmin', 2,...      % min value of crossshore gridsize (automatically generated)
    'dymax', 50,...     % max value of alongshore gridsize (automatically generated)
    'dymin', 10,...     % min value of alongshore gridsize (automatically generated)
    'finepart', 0.3,... % part of the grid that has the finest longshore resolution (centralised)
    'posdwn', 1,...
    'polygon', [],...
    'bathy', {{[] [] []}},...
    'calcdir', cd);

% check whether XB-structure is given as input
XBid = find(cellfun(@isstruct, varargin));
if ~isempty(XBid)
    XB = varargin{XBid};
    varargin(XBid) = [];
end
try
    % the functions keyword_value and CreateEmptyXBeachVar are available in OpenEarthTools
    OPT = setproperty(OPT, varargin{:});
    if ~exist('XB', 'var')
        XB = CreateEmptyXBeachVar;
    end
catch
    if ~isempty(varargin)
        warning(['Properties ' sprintf('"%s" ', varargin{1:2:end}) 'have not been set']) %#ok<WNTAG>
    end
end

if isempty(OPT.polygon)
    OPT.manual = true;
else
    [xi yi] = deal(OPT.polygon(1,:), OPT.polygon(2,:));
end

% modify deepval and dryval to make them correspond with posdwm (and so, with Z)
OPT.deepval =  OPT.posdwn * abs(OPT.deepval);
OPT.dryval  = -OPT.posdwn * abs(OPT.dryval);

if OPT.manual
    figure;
    ids     = convhull(OPT.bathy{1}, OPT.bathy{2});
    lh      = line(OPT.bathy{1}(ids),OPT.bathy{2}(ids),OPT.bathy{3}(ids));
    set(lh,'color','m')
    hold on
    if length(OPT.bathy{1})<=10000
        scatter(OPT.bathy{1}, OPT.bathy{2}, 5, OPT.bathy{3}, 'filled');
    else
        try
            rd_ids = randi(length(OPT.bathy{1}),10000,1);
            scatter(OPT.bathy{1}(rd_ids),OPT.bathy{2}(rd_ids), 5, OPT.bathy{3}(rd_ids), 'filled');
        catch
            scatter(OPT.bathy{1}, OPT.bathy{2}, 5, OPT.bathy{3}, 'filled');
        end
    end
    
    colorbar;
    hold on
    xn = max(X(:));
    yn = max(Y(:));
    plot([0 xn xn 0 0],[0 0 yn yn 0],'r-')
    axis ([0 xn 0 yn]);axis equal
    
    % Select polygon to include in bathy
    % Loop, picking up the points.
    fprintf(1, '%s\n',...
        'Select polygon to include in bathy',...
        'Left mouse button picks points.',...
        'Right mouse button picks last point.')
    fprintf(1, '\n')
    [xi yi]=select_polygon
end

% Interpolate to grid
in = inpolygon(X, Y, xi, yi);
Z(~in) = NaN;

if OPT.plot
    figure;
    surf(X, Y, Z);
    shading interp;
    colorbar
end

% Extrapolate to sides
[nX nY] = size(X);
for i = 1:nX
    for j = floor(nY/2):nY
        %         if j == nY
        %             dbstopcurrent
        %         end
        %         dbclear all
        if isnan(Z(i,j))
            Z(i,j) = Z(i,j-1);
        end
    end
    for j = floor(nY/2)-1:-1:1
        if isnan(Z(i,j))
            Z(i,j) = Z(i,j+1);
        end
    end
end
for j = 1:nY
    % Extrapolate to land
    for i = floor(nX/2):nX
        if isnan(Z(i,j));
            if OPT.posdwn==-1
                Z(i,j) = min(Z(i-1,j)+OPT.maxslp*OPT.dx, OPT.dryval);
            else
                Z(i,j) = max(Z(i-1,j)-OPT.maxslp*OPT.dx, -OPT.dryval);
            end
        end
    end
    % Extrapolate to sea
    for i = floor(nX/2):-1:1
        if isnan(Z(i,j));
            if OPT.posdwn==-1
               Z(i,j) = max(Z(i+1,j)-OPT.seaslp*OPT.dx, -OPT.deepval);
            else
               Z(i,j) = min(Z(i+1,j)+OPT.seaslp*OPT.dx, OPT.deepval);
            end
        end
    end
end

if OPT.plot
    figure;
    surf(X,Y,Z);
    shading interp;
    colorbar
end
    if OPT.posdwn==-1
        Z=max(Z,OPT.posdwn*abs(OPT.deepval));
        Z=min(Z,-OPT.posdwn*abs(OPT.dryval));
    else
        Z=min(Z,OPT.posdwn*abs(OPT.deepval));
        Z=max(Z,-OPT.posdwn*abs(OPT.dryval));
    end
%
% Include structures
if OPT.struct
    figure;
    scatter(OPT.bathy{1}, OPT.bathy{2}, 5, OPT.bathy{3}, 'filled');
    colorbar;
    hold on
    xn = max(X(:));
    yn = max(Y(:));
    plot([0 xn xn 0 0],[0 0 yn yn 0],'r-')
    axis ([0 xn 0 yn]);axis equal
    % Select polygon to define structure
    % Loop, picking up the points.
    disp('Select polygon to include in structure')
    disp('Left mouse button picks points.')
    disp('Right mouse button picks last point.')
    [xi yi]=select_polygon
end

%% x-grid
xnew = X(:,1);
d0 = min(OPT.WL_t) + mean(OPT.posdwn*Z(1,:)); % mean depth at seaward boundary
i = 1; % start at seaward boundary

while xnew(i)<X(end,1);
    % interpolate for each y the corresponding z with the newly
    % chosen x value
    znew = interp2(X', Y', Z', repmat(xnew(i), 1, nY), Y(1,:));
    d = min(OPT.WL_t) + mean(OPT.posdwn*znew);
    dxnew = max(OPT.dxmax * sqrt(max(d,.1)/d0), OPT.dxmin);
    i = i+1;
    xnew(i) = xnew(i-1)+dxnew;
end
xnew(i+1:end) = [];
%{
figure
plot(xnew, ones(size(xnew)), 'o',...
[X(end) X(end)], [0 2], '--')
xlabel('x [m]')
%}
nxnew = length(xnew); % number of grid points in x direction

%% y-grid
ynew = Y(1,:);
yrefine = [0 0.5-OPT.finepart/2 0.5+OPT.finepart/2 1]*Y(1,end);
dyrefine = [OPT.dymax OPT.dymin OPT.dymin  OPT.dymax];
i = 1;
while ynew(i) < Y(1,end);
    dynew = interp1(yrefine, dyrefine, ynew(i));
    i = i+1;
    ynew(i) = ynew(i-1) + dynew;
end
ynew(i+1:end) = [];
%{
figure
plot(yrefine, dyrefine, '-',...
 ynew, [diff(ynew) dyrefine(end)], 'o',...
 [Y(end) Y(end)], dyrefine(end-1:end), '--')
ylabel('dy [m]')
xlabel('y [m]')
%}
nynew = length(ynew); % number of grid points in y direction

%% plot grid
Xnew = repmat(xnew, 1, nynew);
Ynew = repmat(ynew, nxnew, 1);
Znew = interp2(X', Y', Z', Xnew, Ynew);

% prevent NaNs at the boundaries
Znew(end,:) = Znew(end-1,:);
Znew(:,end) = Znew(:, end-1);

if OPT.struct
    in = inpolygon(Xnew, Ynew, xi, yi);
    Z_hard=Znew-20;
    Znew(in) = 5;
    Z_hard(in)=5;
end

% figure
% pcolor(Xnew,Ynew,Znew);axis equal

XB.Input.xInitial = Xnew;
XB.Input.yInitial = Ynew;
XB.Input.zInitial = Znew;

XB.settings.Grid = struct(...
    'nx', nxnew-1,...
    'ny', nynew-1,...
    'vardx', 1,...
    'depfile', '',...
    'xfile', '',...
    'yfile', '',...
    'dx', OPT.dx,...
    'dy', OPT.dy,...
    'xori', OPT.xori,...
    'yori', OPT.yori,...
    'alfa', OPT.alfa*180/pi,...
    'posdwn', -1);



fi=fopen(fullfile(OPT.calcdir, 'bathy.dep'),'wt');
for j=1:nynew
    fprintf(fi,'%7.3f ',Znew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);

if OPT.struct
    fi=fopen(fullfile(OPT.calcdir, 'hardlayer.dep'),'wt');
    for j=1:nynew
        fprintf(fi,'%7.3f ',Z_hard(:,j));
        fprintf(fi,'\n');
    end
    fclose(fi);
end

fi=fopen(fullfile(OPT.calcdir, 'x.dep'),'wt');
for j=1:nynew
    fprintf(fi,'%7.3f ',Xnew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);

fi=fopen(fullfile(OPT.calcdir, 'y.dep'),'wt');
for j=1:nynew
    fprintf(fi,'%7.3f ',Ynew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);
%
fi=fopen(fullfile(OPT.calcdir, 'griddata.txt'),'wt');
fprintf(fi,'nx      = %3i \n',nxnew-1);
fprintf(fi,'ny      = %3i \n',nynew-1);
fprintf(fi,'dx      = %6.1f \n',OPT.dx);
fprintf(fi,'dy      = %6.1f \n',OPT.dy);
fprintf(fi,'xori    = %10.2f \n',OPT.xori);
fprintf(fi,'yori    = %10.2f \n',OPT.yori);
fprintf(fi,'alfa    = %10.2f \n',OPT.alfa*180/pi);
fprintf(fi,'depfile = bathy.dep \n');
fprintf(fi,'vardx   = 1 \n');
fprintf(fi,'xfile = x.dep \n');
fprintf(fi,'yfile = y.dep \n');
fprintf(fi,'posdwn  = -1 \n');
if OPT.struct
    fprintf(fi,'struct = 1 \n');
    fprintf(fi,'ne_layer  = hardlayer.dep \n');
end

fclose(fi);
