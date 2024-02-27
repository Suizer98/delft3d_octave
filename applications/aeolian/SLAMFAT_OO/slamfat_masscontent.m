function slamfat_masscontent(s, varargin)
%SLAMFAT_MASSCONTENT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = slamfat_masscontent(varargin)
%
%   Input: For <keyword,value> pairs call slamfat_masscontent() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   slamfat_masscontent
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 05 Dec 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% settings

OPT = struct();
OPT = setproperty(OPT, varargin);

%% development of volumes over time

figure;
subplot(3,1,1)
plot(s.output_time,sum(s.data.supply,2)+sum(s.data.transport,2),'Displayname','Total sediment in domain')
xlabel('Time [s]')
ylabel('mass [kg/m]')
legend('show','location','nw')

subplot(3,1,2)
plot(s.output_time,s.data.cummulative_transport(:,end),'Displayname','Cumulative transport at downwind boundary')
% plot(sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time)
xlabel('Time [s])')
ylabel('mass [kg/m]')
legend('show','location','nw')

% let's calciulate the total mass
tot_sup = sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time'; % total cumulative supply
tot_out = s.data.cummulative_transport(:,end); % total cumulative transport at downwind boundary
tot_bed = sum(s.data.supply(:,2:end),2); % sediment at the bed at any moment
tot_transport = sum(s.data.transport,2); % sediment in transport at any moment

tot_mass = tot_sup-tot_out-tot_bed-tot_transport;
subplot(3,1,3)

plot(s.output_time,tot_mass,'Displayname','Sum of total mass (this should be zero)')
xlabel('Time [s]')
ylabel('mass [kg/m]')
hline(0)
legend('show','location','nw')

% plot(sum(s.bedcomposition.source(2:end))/(s.wind.dt*s.dx)*s.output_time'-s.data.total_transport(:,end))


% how much total source material du we have at any time ?
% hold all
% index = logical(zeros(size(source)));
% 
% 
% for i=1:length(s.data.transport)
%     
%     if 1
%         % assume constant supply
%         volume_in(i) = sum(source(1,2:end))*i;
%     else
%         % This method is more generic but for some reason very slow
%         index = logical(zeros(size(source)));
%         index(1:i,2:end)=1;
%         volume_in(i) = sum(sum(source(index)));
%     end
%     
%     if i==1
%         volume_out(i)=0;
%     else
% %         volume_out(i) = s.data.transport(i-1,end)*s.data.wind(i-1)*s.wind.dt+volume_out(i-1);
%                 volume_out(i) = s.data.transport(i-1,end)*s.data.wind(i-1)*s.wind.dt+volume_out(i-1);
% 
%     end
% end
% plot(volume_in-volume_out)
% 
% subplot(3,1,2)
% plot((volume_in-volume_out)-(sum(s.data.supply')+sum(s.data.transport')))
% 
% subplot(3,1,3)
% plot(s.data.capacity(:,end))
