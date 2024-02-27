function varargout = rate_stress(varargin)
%UNTITLED  Calculates the erosion rate from the Gust Chamber experiment.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = rate_stress((varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%         oslimread =  raw data of the oslim reading.
%
%   Output:
%   varargout = 
%         error = std time unit is dt
%         means = mean time unit is dt
%         error2 = std time unit is sec 
%         means2 = mean time unit is sec
%         timeline = timeline in sec.
%
%   Example
%   [error, means, means_sec, error_sec, timeline] = rate_stress('oslimread',oslimread,'fdir',rawfiledir)
%
%   setOptions() 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       Kees Pruis
%
%       kees.pruis@boskalis.com	
%
%       +31 78 696 8470
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
% Created: 10 Sep 2014
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = setOptions();
OPT.oslimread='';
% return defaults (aka introspection)
if nargin==0;
   varargout = {OPT};
   return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

%% load txt file to read information.

%% Make this section variable

fid         = fopen([OPT.fdir,filesep,OPT.params],'r');
while ~feof(fid)
    line = fgetl(fid);
    if strcmp(line(1:8), 'interval')
        [v ind] = find(line == '#');
        interval = str2num(line(ind(1)+1:ind(2)-1));
    elseif strcmp(line(1:2), 'dt')
        [v ind] = find(line == '#');
        OPT.dt = str2num(line(ind(1)+1:ind(2)-1));
    elseif strcmp(line(1:3), 'dev')
        [v ind] = find(line == '#');
        dev = str2num(line(ind(1)+1:ind(2)-1));
    end
end
fclose(fid);
OPT.oslimread = OPT.oslimread - dev;
timesteps = interval/OPT.dt;

discharge = OPT.discharge / (1000*60);                                              % from mg/min to l/s
discharge = num2cell(discharge);                                                    %l/s

timesteps = num2cell(diff(timesteps));                                              % length of each 'section' in dt steps
timesteps = cellfun(@(c) ones(1,c),timesteps,'UniformOutput',false);                % vector with length timesteps
erosion_all = nan(size(OPT.oslimread));                                             % prepare erosion vector

t = 0;
%timesteps = vector with length in dt's per step in experiment.
for i = 1:length(timesteps)
    % Oslim0 [g/l) = Oslimread [V]/slope calibration equation
    oslim{1,i}      = OPT.oslimread(t+1:(length(timesteps{i})+t))/OPT.slope_calibration;    % g/L            %why did they do oslim=(oslimread)*1/slope_calibration_equation;
    discharge{1,i}  = [discharge{1,i} * timesteps{i}]';                                     % L/s * dt
    erosion{1,i}    = discharge{1,i}.*oslim{1,i};                                           % L/s * dt * g/L = g/s * dt
    erosion_all(t+1:(length(timesteps{i})+t)) = erosion{1,i};
    t               = t + length(timesteps{i});
end

area    = pi*((OPT.diameter*10^-3)/2)^2;
error   = cellfun(@std, erosion)/area;                                                        % g/(s m^2)
means   = cellfun(@mean, erosion)/area;                                                       % g/(s m^2)

erosion = cellfun(@(c) c/OPT.dt, erosion,'UniformOutput',false);                              % devide by OPT.dt to get erosion rate per seconds??
error2   = cellfun(@std, erosion)/area;                                                       % g/(s m^2)
means2   = cellfun(@mean, erosion)/area;                                                      % g/(s m^2)

timeline = [0:OPT.dt:(length(OPT.oslimread)*OPT.dt)-OPT.dt];
varargout = {error, means, error2, means2, timeline};
 
end







