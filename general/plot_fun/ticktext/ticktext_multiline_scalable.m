function labels = ticktext_multiline_scalable(ticks, fcn, formats)
%TICKTEXT_MULTILINE_SCALABLE  Creates multiline scalable ticktext labels
%
%   Creates multiline scalable ticktext labels using a user-specified
%   formatting function and a set of multiline formats. For eacht tick
%   value a ticktext label is constructud using the formatting function
%   (e.g. datestr or sprintf) and the first format specification from the
%   formats cell array. If the resulting ticktext labels are not distinct
%   the next format is used until the values are distinct or the last
%   format specification is reached.
%   Each format specification can be a cell array itself. In that case the
%   ticktext labels will be multiline labels.
%   This function is in principle a helper function for other ticktext
%   label formatting functions, but can be used for custom purposes as
%   well.
%
%   Syntax:
%   labels = ticktext_multiline_scalable(ticks, fcn, formats)
%
%   Input:
%   ticks     = Array with tick values
%   fcn       = Function handle of formatting function
%   formats   = Cell array with multiline formats for different scales
%
%   Output:
%   labels    = Cell array with ticktext labels
%
%   Example
%   labels = ticktext_multiline_scalable(ticks, @sprintf, ...
%                   {'%1.0' '%3.1f' '%4.2f' '%5.3f' '%6.4f' '%6e'});
%   labels = ticktext_multiline_scalable(ticks, @datestr, ...
%                   {'yyyy' 'mmm-yyyy' 'dd-mmm-yyyy' {'dd-mmm-yyyy' 'HH:MM'} {'dd-mmm-yyyy' 'HH:MM:SS'}});
%
%   See also ticktext, ticktext_isdistinct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 09 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ticktext_multiline_scalable.m 7423 2012-10-10 08:13:03Z hoonhout $
% $Date: 2012-10-10 16:13:03 +0800 (Wed, 10 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7423 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/ticktext/ticktext_multiline_scalable.m $
% $Keywords: $

%% determine ticklabels

labels = cell(size(ticks));

for i = 1:length(formats)
    if ~iscell(formats{i})
        formats{i} = formats(i);
    end
    
    labels = cell(size(ticks));
    
    for j = 1:length(formats{i})
        for k = 1:length(ticks)
            labels{k} = [labels{k} {feval(fcn, ticks(k), formats{i}{j})}];
        end
    end

    if ticktext_isdistinct(labels)
        break
    end
end
