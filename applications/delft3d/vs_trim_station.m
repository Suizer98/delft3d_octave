function H = vs_trim_station(varargin)
%VS_TRIM_STATION  Read timeseries from one location from map file
%
%     H = vs_trim_station(nefisfile,m,n)
%
%  loads timeseries of 3D variable at grid cell (m,n) into struct H.
%
% Example:
%
%   H = vs_trim_station('trim-3e-5mps.dat',m,n)
%   G = meshgrid_time_z(H.datenum,H.sigma_dz,H.dep,H.eta)
%
%   subplot(1,2,1)
%   pcolorcorcen(G.cen.x,G.cen.z,sqrt(H.u.^2 + H.v.^2))
%   hold on
%   plot(H.datenum,H.eta)
%   datetick('x');axis tight
%
%   subplot(1,2,2)
%   pcolorcorcen(G.int.x,G.int.z,log10(H.Ez))
%   hold on
%   plot(H.datenum,H.eta)
%   datetick('x');axis tight
%
%See also: DELFT3D

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

% $Id: vs_trim_station.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim_station.m $

if       ischar(varargin{1})
    S =    vs_use(varargin{1});
elseif isstruct(varargin{1})
    S =           varargin{1};
end

m = varargin{2};
n = varargin{3};

OPT.turb = 1;
OPT.w = 1;
OPT.visc = 1;

if nargin > 3
    OPT = setproperty(OPT,varargin{4:end});
end

G     = vs_meshgrid2dcorcen(S);

%% coordinates

H.m        = m;
H.n        = n;
H.x        = G.cen.x  (n-1,m-1);
H.y        = G.cen.y  (n-1,m-1);
H.dep      = G.cen.dep(n-1,m-1);
H.sigma_dz = G.sigma_dz;
H.datenum  = vs_time(S,0,1);

%% 'scalars'

H.eta = permute(     vs_let(S,'map-series',{0},'S1'  ,{n,m  }),[1 4 2 3]);
if OPT.w
    H.w   = permute(     vs_let(S,'map-series',{0},'WPHY',{n,m,0}),[1 4 2 3]);
end

%% constituents

I = vs_get_constituent_index(S);
fldnames = fieldnames(I);

for ifld=1:length(fldnames)
    fldname = fldnames{ifld};
    if strcmp(fldname,'turbulent_energy') | strcmp(fldname,'energy_dissipation') & OPT.turb
        H.(fldname) = permute(   vs_let(S,I.(fldname).groupname,{0},...
            I.(fldname).elementname,...
            {n,m,0,I.(fldname).index})   ,[1 4 2 3]);
    else if ~strcmp(fldname,'turbulent_energy') & ~strcmp(fldname,'energy_dissipation')
            H.(fldname) = permute(   vs_let(S,I.(fldname).groupname,{0},...
                I.(fldname).elementname,...
                {n,m,0,I.(fldname).index})   ,[1 4 2 3]);
        end
    end
end

%% velocities

[H.u,H.v]=vs_let_vector_cen(S,'map-series',{0},{'U1','V1'},{n,m});
H.u   = permute(H.u,[1 4 2 3]);
H.v   = permute(H.v,[1 4 2 3]);

%% viscosity

if OPT.visc
    H.Ez = permute(     vs_let(S,'map-series',{0},'VICWW',{n,m,0}),[1 4 2 3]);
end
