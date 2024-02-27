function [to h dtwo Ho To] = bc_stormsurge(varargin)
%BC_STORMSURGE  Generates storm surge hydrograph as described in Steetzel, 1993.
%
%   Generates storm surge hydrograph as described in Steetzel, 1993. The
%   hydrograph is composed out of a surge and a tide component. The wave
%   parameters are discretizised in a few bins.
%
%   Syntax:
%   [to h dtwo Ho To] = bc_stormsurge(varargin)
%
%   Input:
%   varargin  = name/value pairs:
%               Tsurge:     duration of surge
%               Ttide:      period of tide
%               Tsim:       duration of output timeseries
%               Tpeak:      moment of maximum surge
%               h_max:      maximum water level (scales amplitudes of
%                           individual components)
%               h0:         still water level
%               ha:         amplitude of tide
%               hs:         amplitude of surge
%               Hm0_max:    maximum significant wave height
%               Tp_max:     maximum peak wave period
%               nwaves:     number of bins in wave discretization
%               plot:       boolean indicating whether to plot the results
%
%   Output:
%   to        = time axes for water levels
%   h         = timeseries for water levels
%   dtwo      = time step durations for wave parameters
%   Ho        = time series for wave heights
%   To        = time series for wave periods
%
%   Example
%   [to h dtwo Ho To] = bc_stormsurge('h_max',5,'Hm0_max',7.6,'Tp_max',12)
%
%   See also bc_normstorm

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Jaap van Thiel de Vries
%
%       jaap.vanthieldevries@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 17 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: bc_stormsurge.m 18424 2022-10-10 14:37:22Z l.w.m.roest.x $
% $Date: 2022-10-10 22:37:22 +0800 (Mon, 10 Oct 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 18424 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/bc/bc_stormsurge.m $
% $Keywords: $

%%

OPT = struct( ...
    'Tsurge',45, ...
    'Ttide',12.42, ...
    'Tsim',32, ...
    'Tpeak',32/2, ...
    'h_max',[], ...
    'h0',0.45, ...
    'ha',1.0, ...
    'hs',3.55, ...
    'Hm0_max',9, ...
    'Tp_max',12, ...
    'nwaves',3, ...
    'plot',0 ...
);

OPT = setproperty(OPT, varargin{:});

if mod(OPT.nwaves,2)==0
    OPT.nwaves = OPT.nwaves+1;
end

if ~isempty(OPT.h_max)
    ampl = [OPT.h0 OPT.ha OPT.hs];
    ampl = num2cell(OPT.h_max./sum(ampl)*ampl);
    [OPT.h0, OPT.ha, OPT.hs] = deal(ampl{:});
end

dt = .5; t = 0:dt:OPT.Tsim; to = ceil(t*3600);                                                                  % // time  

h = OPT.h0+OPT.ha*cos(2.*pi.*(t-OPT.Tpeak)./OPT.Ttide)+OPT.hs*cos(pi.*(t-OPT.Tpeak)./OPT.Tsurge).^2;            % // surge level  

htide = OPT.h0+OPT.ha*cos(2.*pi.*(t-OPT.Tpeak)./OPT.Ttide);

H = OPT.Hm0_max.*cos(pi.*(t-OPT.Tpeak)./(3*OPT.Tsurge)).^2;                                                     % // wave height  

T = OPT.Tp_max*cos(pi*(t-OPT.Tpeak)./(3*OPT.Tsurge));                                                           % // wave period  

dtw = t(end)/OPT.nwaves;

for i = 1:OPT.nwaves
    
    tw = [0:0.01:dtw]+(i-1)*dtw; 
    
    Ho(i) = sqrt(mean((OPT.Hm0_max.*cos(pi.*(tw-OPT.Tpeak)./(3*OPT.Tsurge)).^2).^2));                                          % // wave height  

    To(i) = mean(OPT.Tp_max*cos(pi*(tw-OPT.Tpeak)./(3*OPT.Tsurge)));                                                           % // wave period  
    
    if OPT.plot == 1
        twp((i-1)*2+1:(i)*2) = [tw(1) tw(end)];
        Hop((i-1)*2+1:(i)*2) = [Ho(i) Ho(i)]; 
        Top((i-1)*2+1:(i)*2) = [To(i) To(i)]; 
    end
    
end

Ho(Ho == max(Ho)) = OPT.Hm0_max;
To(To == max(To)) = OPT.Tp_max;
dtwo = ceil(3600*repmat(dtw,1,OPT.nwaves));

if OPT.plot == 1
    Hop(Hop == max(Hop)) = OPT.Hm0_max;
    Top(Top == max(Top)) = OPT.Tp_max;

    figure;
    subplot(311); hold on; plot(t,h,'b'); plot(t,htide,'--k'); ylabel('\eta [m]'); axis([t(1) t(end) 1.1*min(htide) 1.1*max(h)]); legend('SSL', 'tide', 'orientation', 'horizontal'); box on;
    %subplot(311); hold on; plot(tide(:,1)/3600,tide(:,2),'b'); axis([t(1) t(end) 1.1*min(tide(:,2)) 1.1*max(tide(:,2))]); box on; ylabel('\eta [m]');
    subplot(312); plot(t,H,'b'); hold on; plot(twp,Hop,'r-'); ylabel('H_{m0} [m]'); axis([t(1) t(end) 0.9*min(H) 1.1*max(H)]);
    subplot(313); plot(t,T,'b'); hold on; plot(twp,Top,'r-'); xlabel('Time [h]'); ylabel('T_p [s]'); axis([t(1) t(end) 0.9*min(T) 1.1*max(T)]);
end
