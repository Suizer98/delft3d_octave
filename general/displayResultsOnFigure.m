function displayResultsOnFigure(ah,varargin)
% DISPLAYRESULTSONFIGURE zoom without affecting displayed summary results
%
% This routine displays results on a figure in such a way that the results remain even when zoom is adjusted
%
% Syntax:
% displayResultsOnFigure(ah,varargin)
%
% Input:
% ah       = axis handle to display results on
% varargin = variable input argument (multi-row three column cell array): leading text, value, units
%
% Output:
%
% See also: getTKL, getMKL

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  Version 1.0, April 2008 (Version 1.0, April 2008)
%     M.van Koningsveld
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

% $Id: displayResultsOnFigure.m 5294 2011-10-03 14:38:05Z geer $
% $Date: 2011-10-03 22:38:05 +0800 (Mon, 03 Oct 2011) $
% $Author: geer $
% $Revision: 5294 $

%% pass handle of target plot axis 'ah'
plotAxes   = ah;

%% If legend already exist, delete and write displaynames of legend objects
try
    % Why a try catch Mark?? This should work...?
    legend(plotAxes,'off');
    loc = 'NorthWest';
catch
    loc = 'NorthWest';
end

%% plot invisible lines in plotax with DisplayNames according to input
varargin = varargin{:};
axprops = get(plotAxes);
th = repmat(NaN,size(varargin,1),1);
for i = 1:size(varargin,1)
    th(i) = plot([min(axprops.XLim) max(axprops.XLim)],[min(axprops.YLim) min(axprops.YLim)],...
        'LineStyle','none',...
        'DisplayName',[varargin{i,1} num2str(varargin{i,2},'%8.2f') varargin{i,3}]);
end

%% Create legend and set properties.
[leg object_h plot_h text_strings] = legend(plotAxes,'-DynamicLegend');

if any(plot_h~=-1) && any(~cellfun(@isempty, get(plot_h, 'Tag')))
    % retrieve DisplayNames which are alternativily saved in Tags, because
    % older matlab versions (than 8) don't have DisplayNames for patches
    % and lines
    ids = ~cellfun(@isempty, get(plot_h, 'Tag'));
    Tags = get(plot_h, 'Tag');
    text_strings(ids) = Tags(ids);
    set(leg,...
        'String', text_strings);
end

set(leg,...
    'FontSize',8,...
    'fontweight','bold',...
    'Location',loc,...
    'Box', 'off');

% if plotedit_state
%     plotedit(fh, 'on')
% end