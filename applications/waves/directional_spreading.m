function cdir = directional_spreading(directions,pdir,ms,varargin)
%directional_spreading  directional spreading of waves
%
%   directional_spreading(directions,pdir,ms,<keyword,value>)
% 
% where scalar pdir is the peak direction, and scalar ms is the power in cos(directions-pdir)^ms
%
% By default degrees are used, otherwise use directional_spreading(...,'units','rad)
%
% example:
%   dirs  = linspace(0,360,36);
%   dirTp = 180;
%   power = 2;
%   cdir  = directional_spreading(dirs,dirTp,power)
%
%See also: jonswap

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord; TU Delft
%       Gerben J de Boer <gerben.deboer@vanoord.com>; <g.j.deboer@tudelft.nl>
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

    OPT.units = 'deg';
    OPT.plot  = 0;
    OPT.quiet = 0;
    
    if nargin==0
        varargout = {OPT};
        return
    end
    OPT = setproperty(OPT,varargin);    

%% core

    cdir = 0.*directions;
    
    if strcmpi(OPT.units,'rad')
        directions = rad2deg(directions);
        pdir = rad2deg(pdir);
    end

    A1 = (2.^ms) * (gamma(ms/2+1))^2 / (pi * gamma(ms+1)); % coefficent to make sure integral is 1

    for id=1:length(directions)
        acos = cosd(directions(id) - pdir);
        if acos > 0
          cdir(id) = A1 * max(acos^ms, 1e-10);
        end
    end
    
%% units

    if strcmpi(OPT.units,'deg')
        cdir = cdir*pi/180;
    elseif strcmpi(OPT.units,'rad')
        % pass
    end
    
%% check for ill-sampling

    int = trapz(directions,cdir);
    if ~(abs(int-1)< 1e-6) && ~(OPT.quiet)
        disp(['integral not 1 for ms=',num2str(ms),':',num2str(int)])
    end
    
%% debug
    
    if OPT.plot
        TMP = figure;
        plot(directions, cdir)
        hold on
        vline(pdir)
        int = trapz(directions, cdir);
        pausedisp
        close(TMP)
    end
