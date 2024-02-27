function varargout = writeRAY(RAYdata)
%write RAY : Writes a RAY file
%
%   Syntax:
%     function writeRAY(RAYdata)
% 
%   Input:
%     RAYdata       struct with contents of ray file
%                     .name    :  cell with filenames
%                     .path    :  cell with path of files
%                     .info    :  cell with header info of RAY file (e.g. pro-file used)
%                     .equi    :  equilibrium angle degrees relative to 'hoek'
%                     .c1      :  coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)
%                     .c2      :  coefficient c2 [-] (used for shape of S-phi curve)
%                     .h0      :  active height of profile [m]
%                     .hoek    :  coast angle specified in LT computation
%                     .fshape  :  shape factor of the cross-shore distribution of sediment transport [-]
%                     .Xb      :  coastline point [m]
%                     .perc2   :  distance from coastline point beyond which 2% of transport is located [m]
%                     .perc20  :  distance from coastline point beyond which 20% of transport is located [m]
%                     .perc50  :  distance from coastline point beyond which 50% of transport is located [m]
%                     .perc80  :  distance from coastline point beyond which 80% of transport is located [m]
%                     .perc100 :  distance from coastline point beyond which 100% of transport is located [m] 
%                     .hass    :  (OPTIONAL) High Angle Stability Switch: When set to non-zero (e.g. 1), the 
%                                 minimum and maximum transports (S) are also set for even larger angles (phi)
%                                 This has a stabilizing effect on coastline development when coastline orientation
%                                 and direction of average wave conditions differ largely (e.g. > 45 degrees)
%
%   Calling writeRAY without an input variable will return a default RAYdata structure 
%
%   Multiple Ray-files can be generated using a RAYdata multi-structure ([1xN] or [Nx1])
%   An empty example of a RAYdata multi-structure can generated using
%   writeRAY(number_of_ray_files). Alse see example 2 below.
% 
%   Output:
%     .ray files
%
%   Example 1:
%     RAYdata = readRAY('test.ray')
%     writeRAY(RAYdata);
%
%   Example 2:
%     disp('A default RAYdata structure for 10 Ray files looks like:');
%     disp(' '); RAYdata = writeRAY(10); disp(RAYdata);
%
%   See also readRAY

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%       bas.huisman@deltares.nl	
%
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeRAY.m 14476 2018-07-05 07:24:09Z huism_b $
% $Date: 2018-07-05 15:24:09 +0800 (Thu, 05 Jul 2018) $
% $Author: huism_b $
% $Revision: 14476 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeRAY.m $
% $Keywords: $

if nargin == 0
    
    varargout{1} = readRAY;
    
elseif nargin == 1
    
    if isnumeric(RAYdata)
        varargout{1} = readRAY(RAYdata);
        return
    end
    
    for ii=1:length(RAYdata)
        if ~isfield(RAYdata(ii),'time')
            RAYdata(ii).time=[];
        end
        if ~isfield(RAYdata(ii),'QSoffset')
            RAYdata(ii).QSoffset=[];
        end
        if ~isfield(RAYdata(ii),'hass')
            RAYdata(ii).hass=[];
        end
        if ~isempty(RAYdata(ii).path);
            fid4 = fopen([RAYdata(ii).path filesep char(RAYdata(ii).name)],'wt');
        else
            fid4 = fopen([char(RAYdata(ii).name)],'wt');
        end
        for iii=1:6
            fprintf(fid4,'%s\n',RAYdata(ii).info{1,iii});
        end
        
        if isempty(RAYdata(ii).time)
            fprintf(fid4,'    equi              c1              c2             h0           angle         fshape\n');
            if isempty(RAYdata(ii).QSoffset)
                fprintf(fid4,'%8.6e %8.6e %8.6e %8.6e %8.6e %8.6e\n',[RAYdata(ii).equi RAYdata(ii).c1 RAYdata(ii).c2 RAYdata(ii).h0 RAYdata(ii).hoek RAYdata(ii).fshape]);
            else
                fprintf(fid4,'%8.6e %8.6e %8.6e %8.6e %8.6e %8.6e %8.6e\n',[RAYdata(ii).equi RAYdata(ii).c1 RAYdata(ii).c2 RAYdata(ii).h0 RAYdata(ii).hoek RAYdata(ii).fshape RAYdata(ii).QSoffset]);
            end
            % hass fieldname found:
            if ~isempty(RAYdata(ii).hass)
                % hass is not empty:
                % whatever non-zero value is set (e.g. 1, 1000, 'on', etc.), hass is printed as 1 (except for 0):
                fprintf(fid4,'       Xb           2 %%          20%%           50%%          80%%          100%%     high_angle_stability_switch\n');
                fprintf(fid4,'%8.6e %8.6e %8.6e %8.6e %8.6e %8.6e %8.6e\n',[RAYdata(ii).Xb RAYdata(ii).perc2 RAYdata(ii).perc20 RAYdata(ii).perc50 RAYdata(ii).perc80 RAYdata(ii).perc100 ~isempty(nonzeros(RAYdata(ii).hass))]);
            else
                % hass is empty, ignore it (not printed as zero, as in the original file):
                fprintf(fid4,'       Xb           2 %%          20%%           50%%          80%%          100%%\n');
                fprintf(fid4,'%8.6e %8.6e %8.6e %8.6e %8.6e %8.6e\n',[RAYdata(ii).Xb RAYdata(ii).perc2 RAYdata(ii).perc20 RAYdata(ii).perc50 RAYdata(ii).perc80 RAYdata(ii).perc100]);
            end
        else
            if isempty(RAYdata(ii).hass)
                if isempty(RAYdata(ii).QSoffset)
                    fprintf(fid4,'     timepoint          equi              c1              c2             h0           angle         fshape            Xb              2%%              20%%             50%%             80%%            100%%  \n');
                    fprintf(fid4,'   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e\n',...
                            [RAYdata(ii).time(:), RAYdata(ii).equi(:), RAYdata(ii).c1(:), RAYdata(ii).c2(:), RAYdata(ii).h0(:), RAYdata(ii).hoek(:), RAYdata(ii).fshape(:), ...
                            RAYdata(ii).Xb(:), RAYdata(ii).perc2(:), RAYdata(ii).perc20(:), RAYdata(ii).perc50(:), RAYdata(ii).perc80(:), RAYdata(ii).perc100(:)]');
                else
                    fprintf(fid4,'     timepoint          equi              c1              c2             h0           angle         fshape         QSoffset            Xb              2%%              20%%             50%%             80%%            100%%  \n');
                    fprintf(fid4,'   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e\n',...
                            [RAYdata(ii).time(:), RAYdata(ii).equi(:), RAYdata(ii).c1(:), RAYdata(ii).c2(:), RAYdata(ii).h0(:), RAYdata(ii).hoek(:), RAYdata(ii).fshape(:), RAYdata(ii).QSoffset(:), ...
                            RAYdata(ii).Xb(:), RAYdata(ii).perc2(:), RAYdata(ii).perc20(:), RAYdata(ii).perc50(:), RAYdata(ii).perc80(:), RAYdata(ii).perc100(:)]');
                end
            else
                if isempty(RAYdata(ii).QSoffset)
                    fprintf(fid4,'     timepoint          equi              c1              c2             h0           angle         fshape            Xb              2%%              20%%             50%%             80%%            100%%     high-angle switch  \n');
                    fprintf(fid4,'   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %1.0f\n',...
                            [RAYdata(ii).time(:), RAYdata(ii).equi(:), RAYdata(ii).c1(:), RAYdata(ii).c2(:), RAYdata(ii).h0(:), RAYdata(ii).hoek(:), RAYdata(ii).fshape(:), ...
                            RAYdata(ii).Xb(:), RAYdata(ii).perc2(:), RAYdata(ii).perc20(:), RAYdata(ii).perc50(:), RAYdata(ii).perc80(:), RAYdata(ii).perc100(:), repmat(RAYdata(ii).hass(1),[length(RAYdata(ii).perc100),1])]');
                else
                    fprintf(fid4,'     timepoint          equi              c1              c2             h0           angle         fshape         QSoffset            Xb              2%%              20%%             50%%             80%%            100%%     high-angle switch\n');
                    fprintf(fid4,'   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %8.6e   %1.0f\n',...
                            [RAYdata(ii).time(:), RAYdata(ii).equi(:), RAYdata(ii).c1(:), RAYdata(ii).c2(:), RAYdata(ii).h0(:), RAYdata(ii).hoek(:), RAYdata(ii).fshape(:), RAYdata(ii).QSoffset(:), ...
                            RAYdata(ii).Xb(:), RAYdata(ii).perc2(:), RAYdata(ii).perc20(:), RAYdata(ii).perc50(:), RAYdata(ii).perc80(:), RAYdata(ii).perc100(:), repmat(RAYdata(ii).hass(1),[length(RAYdata(ii).perc100),1])]');
                end
            end
        end
        
        fclose(fid4);
    end
else
    % Should not be possible to get here:
    error(['Specified ' num2str(nargin) ' input variables, maximum is 1'])
end
