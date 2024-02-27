function xb = xb_generate_wavedirgrid(xb,varargin)
%UNTITLED  Generates wave directional grid for wave action balance.
%
%   More detailed description goes here.
%
%   Syntax:
%   xb          = xb_directional_wavegrid(xb,varargin)
%
%   Input:
%   varthr      = threshold (percentage of maximum variance) that is taken into account to set-up wavedir grid
%   nbins       = number of directional bins
%   normal      = direction normal to the shore line (optional)
%   plot        = 0 = no plot, 1 = plot of directional wave grid
%
%   Output:
%   xb          = XBeach structure array (with adapted theta
%
%   Example
%   %
%   waves = xb_generate_waves
%   xb = xs_join(xb, waves);
%   exmaple 1
%   xb = xs_empty(); xb = xs_set(xb,'alpha',0,'dir',[270],'s',[5]); xb = xb_generate_wavedirgrid(xb);
%   example 2
%   xb = xs_empty(); xb = xs_set(xb,'alpha',-33,'dir',[273],'s',[5]); xb = xb_generate_wavedirgrid(xb);
%   example 3
%   xb = xs_empty(); xb = xs_set(xb,'alpha',-33,'dir',[231 241 258 273],'s',[2 10 2 5]); xb = xb_generate_wavedirgrid(xb);
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Jaap van Thiel de Vries
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 08 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: xb_generate_wavedirgrid.m 14069 2018-01-04 14:20:37Z arvid.dujardin.x.1 $
% $Date: 2018-01-04 22:20:37 +0800 (Thu, 04 Jan 2018) $
% $Author: arvid.dujardin.x.1 $
% $Revision: 14069 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_generate_wavedirgrid.m $
% $Keywords: $

%%

OPT = struct( ...
            'varthr', 0.05, ...
            'nbins', 1, ...
            'normal', [], ...
            'plot', false ...
            );

OPT = setproperty(OPT, varargin{:});

if ismember(xs_get(xb, 'bcfile.type'), {'jonswap' 'jonswap_mtx'})
    
    xb_verbose(0,'---');
    xb_verbose(0,'Determine wave directional grid');

    % find mean wave direction, minimum wave direction and maximum wave
    % direction in wave bc time series

    % bas: this should be alfa instead of alpha, right?
    %      this parameter is not available at this location
    %      is it necessary anyway? thetabins should be defined in world coordinates
    alpha = 0; %xs_get(xb,'alpha');             % get coastline / grid orientation alpha

    phi0t = xs_get(xb,'bcfile.mainang');    % get wave directions (nautical)
    phi0 = mean(phi0t);                     % compute mean wave direction
    theta_min = phi0;
    theta_max = phi0;
    st = xs_get(xb,'bcfile.s');             % use max s to setup wavedir grid

    % make directional distribution as proposed by Longuet_Higgins et al.
    % (1963)
    if OPT.plot
        figure(333);hold on;grid on;box on
    end
    for i = 1:length(st)
        m = 2*st(i);
        phi = phi0t(i)-180:1:phi0t(i)+180;
        p = cosd((phi-phi0t(i))/2).^m;

        % find range over which directional distribution is larger than OPT.varthr
        indmin = find(p>=max(OPT.varthr), 1, 'first');
        indmax = find(p>=max(OPT.varthr), 1, 'last' );

        theta_min = min(theta_min,phi(indmin));
        theta_max = max(theta_max,phi(indmax));

        % directional spreading as defined by Kuik et al, 1988
        sig(i) = sqrt(2/(st(i)+1))/2/pi*360;

        if OPT.plot
            plot(phi,p,'b'); hold on;
            plot(phi(indmin),p(indmin),'r*');
            plot(phi(indmax),p(indmax),'r*');
        end

    end

    if ~isempty(OPT.normal)
        % only include bins that propagate wave action with a component
        % towards the shore
        theta_min = max(theta_min,OPT.normal-alpha-90);
        theta_max = min(theta_max,OPT.normal-alpha+90);

        % make shoe there is wavebin normal to the shore
        safety = 15; % degrees
        thata_min = min(theta_min, OPT.normal-alpha-safety);
        thata_max = max(theta_max, OPT.normal-alpha+safety);
    end

    if OPT.plot
        plot([theta_min theta_min; theta_max theta_max]',[0 1; 0 1;]','r--o','LineWidth',1.5,'MarkerSize',8);
        plot([270-alpha 270-alpha],[0 1],'g--o','LineWidth',1.5,'MarkerSize',8); grid on;
    end

    % combine range p> OPT.varthr and directional range from wave bc time series
    dthetasum = theta_max-theta_min;

    % set dtheta, thetamin and thetamax and round off at 5 degrees
    phim = theta_min+0.5*(theta_max-theta_min);
    dtheta = ceil(0.5*dthetasum/(0.5*OPT.nbins)/5)*5;
    theta_min = phim-dtheta*0.5*OPT.nbins;
    theta_max = phim+dtheta*0.5*OPT.nbins;

	% choose bin width based on directional spreading
    thetagr = [theta_min:dtheta:theta_max];	
	
    % get what we need as output
    xb = xs_set(xb,'thetamin',theta_min,'thetamax',theta_max','dtheta',dtheta,'thetanaut',1);

    if OPT.plot
        plot(thetagr,zeros(1,length(thetagr)),'g-s'); grid on;
    end

    xb_verbose(1,'Settings');
    xb_verbose(2,{'thetamin','thetamax','dtheta','thetanaut'},{theta_min,theta_max',dtheta,1});
    %
end


