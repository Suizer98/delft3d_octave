function [time obs_x obs_y velocity depth discharge] = xb_generateOvertoppingTimeseries(varargin)
% XB_GENERATEOVERTOPPINGTIMESERIES  extract from XBeach output info and translate to overtopping timeseries
%
% 
%
% See also: xbeach

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section 
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id: xb_generateOvertoppingTimeseries.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $

%% optional: draw points thinned out to allow for quick dataselection (reduce number of points)

%% settings
% defaults
OPT.basedir   = 'D:\checkouts\OpenEarthTools\trunk\matlab\applications\xbeach\output_translation\';    % description of input argument 1
OPT.stride_t  = 1;     % take a stride of OPT.stride_t through the time vector
OPT.obs_x     = [];
OPT.obs_y     = [];
OPT.obs_n     = [100 100];
OPT.obs_m     = [100 110];

% overrule default settings by property pairs, given in varargin
OPT     = setproperty(OPT, varargin{:});

%% read output data
output      = xb_output_read('basedir', OPT.basedir, 'var', {'zb'}, 'stride_t', OPT.stride_t);
output_temp = xb_output_read('basedir', OPT.basedir, 'var', {'zs'}, 'stride_t', OPT.stride_t); output.zs = output_temp.zs;
output_temp = xb_output_read('basedir', OPT.basedir, 'var', {'ue'}, 'stride_t', OPT.stride_t);  output.ue  = output_temp.ue;
clear output_temp

%% extract runup timeseries
[time, obs_x, obs_y, velocity, depth] = deal([]);
for i = 1:length(OPT.obs_n)
    time        = [time; output.time];
    obs_x       = [obs_x; output.x(OPT.obs_n(i),OPT.obs_m(i))];
    obs_y       = [obs_y; output.y(OPT.obs_n(i),OPT.obs_m(i))];
    velocity    = [velocity; squeeze(output.ue(OPT.obs_n(i),OPT.obs_m(i),:))'];
    depth       = [depth; squeeze(output.zs(OPT.obs_n(i),OPT.obs_m(i),:) - output.zb(OPT.obs_n(i),OPT.obs_m(i),:))'];
end
discharge     = velocity.*depth;
xx=  0;


