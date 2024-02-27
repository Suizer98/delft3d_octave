function UCIT_next(direction,objTag)
%UCIT_NEXTYEAR   this routine steps to the next value in the popup
%
% this routine steps to the next value in the popup
%              
% input:       
%    direction = integer identifying step direction
%       -1 : previous
%        1 : next
%    objtag    = tag identifying popup to alter
%
% output:       
%    function has no output
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)  
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

% $Id: UCIT_next.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

[popupValue,info]=UCIT_getInfoFromPopup(objTag);

% find the soundingID of focus
id=find(strcmp(info.string,popupValue));

% switch direction in case walking through the years (because years are sorted recent-old) 
if strcmp(objTag,'TransectsSoundingID'), direction = -direction; end

switch direction
    case 1
        if id==max(size(info.string))
            nextid=2;
        else
            nextid=id+1;
        end
    case -1
        if id==2
            nextid=max(size(info.string));
        else
            nextid=id-1;
        end
end

set(findobj('tag',objTag), 'value', nextid); 

if ~isempty(findobj('tag','plotWindow'))
    UCIT_plotTransect
end

if ~isempty(findobj('tag','plotWindow_US'))
    UCIT_plotLidarTransect
end

if ~isempty(findobj('tag','plotWindow_multiple'))
    UCIT_plotMultipleTransects
end

if ~isempty(findobj('tag','plotWindowMKL'))
    UCIT_calculateMKL
end

if ~isempty(findobj('tag','plotWindowTKL'))
    UCIT_calculateTKL
end

if ~isempty(findobj('tag','plotWindowTimestack'))
    plotTimestackOfTransect
end

if ~isempty(findobj('tag','mapWindow'))
    UCIT_showTransectOnOverview
end

if ~isempty(findobj('tag','analyseTransectWindow'))
    UCIT_analyseTransectVolume
end

