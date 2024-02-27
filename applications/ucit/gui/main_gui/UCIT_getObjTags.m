function [objTag1, objTag2, objTag3, objTag4] = UCIT_getObjTags(type)
%UCIT_GETOBJTAGS   This routine returns the tags of the popups for datatype <type>.
%
% syntax:
%  [objTag1, objTag2, objTag3, objTag4] = UCIT_getObjTags(type)
%
% input:
%    type = variable identifying which kind of data is selected
%        1: transects
%        2: grids
%        3: lines
%        4: points
%
% output:
%    objTag1 = tag of first popup
%    objTag2 = tag of second popup
%    objTag3 = tag of third popup
%    objTag4 = tag of fourth popup
%

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

% $Id: UCIT_getObjTags.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

switch type
    case 1
        objTag1='TransectsDatatype';
        objTag2='TransectsArea';
        objTag3='TransectsTransectID';
        objTag4='TransectsSoundingID';
    case 2
        objTag1='GridsDatatype';
        objTag2='GridsName';
        objTag3='GridsInterval';
        objTag4='GridsSoundingID';
    case 3
        objTag1='LinesDatatype';
        objTag2='LinesArea';
        objTag3='LinesYear';
        objTag4='LinesLineID';
    case 4
        objTag1='PointsDatatype';
        objTag2='PointsStation';
        objTag3='PointsSoundingID';
        objTag4='PointsDataID';
end