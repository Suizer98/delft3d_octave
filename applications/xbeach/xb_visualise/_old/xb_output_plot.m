function output = xb_output_plot(output, varargin)
%XB_OUTPUT_PLOT  Simple routine for first basic inspection of XBeach results
%
%   Simple routine for first basic inspection of XBeach results.
%
%   Syntax:
%   output = xb_output_plot(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   output =
%
%   Example
%   xb_output_plot
%
%   See also xb_output_read

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

% $Id: xb_output_plot.m 3497 2010-12-02 17:16:30Z hoonhout $
% $Date: 2010-12-03 01:16:30 +0800 (Fri, 03 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3497 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/_old/xb_output_plot.m $
% $Keywords: $

clc

%% settings
% defaults
OPT.basedir   = [];    % description of input argument 1
OPT.stride_t  = 100;     % take a stride of OPT.stride_t through the time vector
% OPT.plottype  = {'uv'};                                % type of plot to make
OPT.plottype  = {'uv', 'zb-z0'};                                % type of plot to make
% OPT.plottype  = {'H', 'zs', 'zb', 'u', 'v', 'uv', 'zb-z0'};    % type of plot to make

% overrule default settings by property pairs, given in varargin
OPT     = setproperty(OPT, varargin{:});

if nargin == 0
    output = xb_output_read('stride_t', OPT.stride_t);
end

%%
fields       = fieldnames(output);
if isempty(OPT.plottype)
    OPT.plottype = [fields(~ismember(fields, {'x', 'y', 'time', 'z0'})); 'zb-z0'];
end

figure(1); clf
%% Open the dims.dat to extract all relevant dimensions
for i = 1:length(output.time)
    for j = 1:length(OPT.plottype)
        if i == 1
            sph(j)    = subplot(ceil(length(OPT.plottype)/2), min([length(OPT.plottype) 2]), j);
        end
        
        switch OPT.plottype{j}
            case {'H', 'zb', 'zs', 'u', 'v'}
                data  = sqrt(output.u(:,:,i).^2+output.v(:,:,i).^2);
                if i == 1
                    ph(j) = pcolor(sph(j), output.x, output.y, data); axis equal
                    shading interp; colorbar; box on
                    caxis(sph(j), [ ...
                        min(min(min(output.(OPT.plottype{j}),[],3))) ...
                        max(max(max(output.(OPT.plottype{j}),[],3)))]);
                else
                    set(ph(j), 'CData', data);
                end
                
            case 'zb-z0'
                data  = output.(fields{ismember(fields, 'zb')})(:,:,i) - output.z0;
                if i == 1
                    ph(j) = pcolor(sph(j), output.x, output.y, data); axis equal
                    shading interp; colorbar; box on
                    caxis([-2 2]);
                else
                    set(ph(j), 'CData', data);
                end
                
            case 'uv'
                data1 = sqrt(output.u(:,:,i).^2 + output.v(:,:,i).^2);
                if i == 1
                    ph1   = pcolor(sph(j), output.x, output.y, data1); hold on; axis equal
                    ph2   = quiver(sph(j), output.x, output.y, output.u(:,:,i), output.v(:,:,i), 2, 'k');
                    shading interp; colorbar; box on
                    caxis([-2 2]);
                else
                    set(ph1, 'CData', data1);
                    set(ph2, 'UData',  output.u(:,:,i) ,'VData', output.v(:,:,i) );
                end
                
        end
        
        xlabel(sph(j),'x - distance [m]');
        ylabel(sph(j),'y - distance [m]')
        title(sph(j),{['Variable : ' OPT.plottype{j}]; ['Time = ' num2str(output.time(1,i)) ' s']});
    end
    pause(0.1);
    drawnow
end
