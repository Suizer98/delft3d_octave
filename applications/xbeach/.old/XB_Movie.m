function XB_Movie(XB, vars, varargin)
%XB_MOVIE  Creates an AVI movie based on XB_Plot_Results plots
%
%   Creates an AVI movie by storing several plots made using the function
%   XB_Plot_Results
%
%   Syntax:
%   XB_Movie(XB, vars, varargin)
%
%   Input:
%   XB          = XBeach result structure
%   vars        = cell with variables to be plotted
%   varargin    = key/value pairs of optional parameters
%                 multiple      = flag to determine whether multiple
%                                 variables should be plotted using
%                                 subplots (false) or in different movies
%                                 (true) (default: false)
%                 filePrefix    = prefix of avi filename (default: movie_)
%                 fps           = frames per second (default: 5)
%
%                 SEE THE DESCRIPTION OF XB_PLOT_RESULTS FOR THE PURPOSE OF
%                 OTHER OPTIONAL PARAMETERS
%
%   Output: no output
%
%   Example
%   XB_Movie(XB, vars)
%
%   See also XB_Read_Results, XB_Animate_Results, XB_Read_Coastline

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 2 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: XB_Movie.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_Movie.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'multiple', false, ...
	'filePrefix', 'movie_', ...
    'fps', 5, ...
    'title', 'XBeach output animation', ...
    'size', [800 600], ...
    'grid', true, ...
    'view', [37.5 30], ...
    'xlim', [], ...
    'ylim', [], ...
    'zlim', [] ...
);

OPT = setproperty(OPT, varargin{:});

% make sure variable is a cell structure
if ~iscell(vars); vars = {vars}; end;

%% initialization

if OPT.multiple
    numMovies = length(vars);
else
    numMovies = 1;
end

%% rendering frames

% loop through variables to animate
for i = 1:numMovies
    var = vars{i};
    
    % create display name
    if OPT.multiple
        varPost = var;
        varName = var;
    else
        varPost = vars;
        varName = vars{1};
        for j = 2:length(vars); varName = [varName '+' vars{j}]; end;
    end
    
    % read output variable
    zVar = XB.Output.(var);
    zSize = size(zVar);

    % determine space and time dimensions
    switch length(zSize)
        case 2
            animate2D = false;
            timeSteps = zSize(2);
        case 3
            animate2D = true;
            timeSteps = zSize(3);
        otherwise
            error('Provided variable has not the right amount of dimensions');
    end

    disp(['Rendering frames for variable(s) ' varName ' ...']);
        
    % create figure
    fig = figure();

    for i = 1:timeSteps
        
        % plot frame
        XB_Plot_Results(XB, varPost, 'fh', fig, 't', i, ...
            'title', OPT.title, 'size', OPT.size, 'grid', OPT.grid, 'view', OPT.view, ...
            'xlim', OPT.xlim, 'ylim', OPT.ylim, 'zlim', OPT.zlim);

        % save frame
        M(i) = getframe(gcf);

        % clear frames
        ha = findobj(gcf, 'Type', 'axes');
        for j = 1:length(ha)
            cla(ha(j));
        end
    end

    % close figure
    close(gcf);

    disp(['Writing movie file for variable(s) ' varName ' ...']);

    % write avi file
    movie2avi(M, [OPT.filePrefix varName '.avi'], 'fps', OPT.fps);

end

disp('Done.');