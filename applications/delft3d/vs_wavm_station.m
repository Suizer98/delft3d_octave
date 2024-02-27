function H = vs_wavm_station(varargin)
%VS_WAVM_STATION  Read timeseries from one location from map file
%
%     H = vs_wavm_station(nefisfile,m,n)
%
%  loads timeseries of 2D variable at grid cell (m,n) into struct H.
%
% Example:
%
%   H = vs_wavm_station('wavm-3e-5mps.dat',m,n)
%
%See also: DELFT3D, vs_trim_station, vs_meshgrid2dcorcen, vs_let

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Technische Universiteit Delft,
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: vs_wavm_station.m 16487 2020-07-17 13:41:59Z grasmeij $
% $Date: 2020-07-17 21:41:59 +0800 (Fri, 17 Jul 2020) $
% $Author: grasmeij $
% $Revision: 16487 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_wavm_station.m $

if       ischar(varargin{1})
    S =    vs_use(varargin{1});
elseif isstruct(varargin{1})
    S =           varargin{1};
end

m = varargin{2};
n = varargin{3};

% OPT.turb = 0;
% OPT.w = 0;
% OPT.visc = 0;
% OPT.constituents = 0;
OPT.height = 1;
OPT.period = 1;
OPT.direction = 1;
OPT.wind = 0;
OPT.qb = 0;

if nargin > 3
    OPT = setproperty(OPT,varargin{4:end});
end

G     = vs_meshgrid2dcorcen(S);

%% coordinates

H.m        = m;
H.n        = n;
H.x        = G.cor.x  (n,m);
H.y        = G.cor.y  (n,m);
H.datenum  = vs_time(S,0,1);

if OPT.wind
    disp('reading wind data from wavm...')
    H.WIND = qpread(S,'wind velocity','data',0,H.m,H.n);
    H.WIND.Mag = hypot(H.WIND.XComp,H.WIND.YComp);
end

% figure;
% ldb = landboundary('read','d:\Documents\03. Projecten Nederland\03.01. Morfologisch instrumentarium Vlaamse kust\B. Measurements and calculations\06_Flanders_FM\01_setup_bathymetry\Calais_Zeeland.ldb');
% plot(ldb(:,1),ldb(:,2));
% hold on;
% grid_plot(G.cor.x,G.cor.y)
% hold on;
% plot(H.x,H.y,'o')
% % plot(wind.X,wind.Y,'rx')
%
% figure;
% plot(wind.Time,wind.Mag)
%
%% Parameters
if OPT.height
    disp('reading wave height data from wavm...')
    H.HSIGN = vs_let(S,'map-series','HSIGN',{[ m ],[ n ]});
    H.DEPTH = vs_let(S,'map-series','DEPTH',{[ m ],[ n ]});
end
if OPT.direction
    disp('reading wave direction data from wavm...')
    H.DIR = vs_let(S,'map-series','DIR',{[ m ],[ n ]});
    H.DSPR = vs_let(S,'map-series','DSPR',{[ m ],[ n ]});       % directional spread of the waves
    H.DIR = vs_let(S,'map-series','DIR',{[ m ],[ n ]});         % mean wave direction
    H.PDIR = vs_let(S,'map-series','PDIR',{[ m ],[ n ]});       % peak wave direction
end
if OPT.qb
    disp('reading fraction of breaking waves data from wavm...')    
    H.QB = vs_let(S,'map-series','QB',{[ m ],[ n ]});           % the fraction of breaking waves
end
if OPT.period
    disp('reading wave period data from wavm...')
    H.PERIOD = vs_let(S,'map-series','PERIOD',{[ m ],[ n ]});   % mean wave period
    H.RTP = vs_let(S,'map-series','RTP',{[ m ],[ n ]});         % relative peak wave period
    H.TP = vs_let(S,'map-series','TP',{[ m ],[ n ]});           % peak wave period
    H.TPS = vs_let(S,'map-series','TPS',{[ m ],[ n ]});         % smoothed peak wave period
    H.TM02 = vs_let(S,'map-series','TM02',{[ m ],[ n ]});       % mean absolute zero-crossing period
    H.TMM10 = vs_let(S,'map-series','TMM10',{[ m ],[ n ]});     % mean absolute wave period
end
disp('reading location data from wavm...')
H.XP = vs_let(S,'map-series','XP',{[ m ],[ n ]});           % x coordinate output grid
H.YP = vs_let(S,'map-series','YP',{[ m ],[ n ]});           % y coordinate output grid

