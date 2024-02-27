function [check] = UCIT_checkPopups(type, prescription)
%UCIT_CHECKPOPUPS   This routine checks if popup settings are conform prescription. Prescription may vary for each action.
%
% This routine checks if popup settings are conform prescription. 
% Prescription may vary for each action.
%
% syntax:
%    [check] = UCIT_checkPopups(type, prescription)
%
% input:
%    type         = 1. transects, 2. grids, 3. lines, 4. points
%    prescription = 1, 2, 3 or 4 (indicates the number of popups that need to be selected
%
% output:
%   check        = 0. NOT OK, 1. OK
% 
% see also UCIT_getObjTags, UCIT_DC_getInfoFromPopup 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, February 2004)
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

% $Id: UCIT_checkPopups.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

[objTag1, objTag2, objTag3, objTag4] = UCIT_getObjTags(type);

[popupValue1,info1]=UCIT_getInfoFromPopup(objTag1);
[popupValue2,info2]=UCIT_getInfoFromPopup(objTag2);
[popupValue3,info3]=UCIT_getInfoFromPopup(objTag3);
[popupValue4,info4]=UCIT_getInfoFromPopup(objTag4);

switch prescription 
    case 1 % first popup.value must be not be 1
        if info1.value~=1
            check=1;
        else
            check=0;
        end
    case 2 % first two popup.value must be not be 1
        if info1.value~=1 & info2.value~=1
            check=1;
        else
            check=0;
        end
    case 3 % first three popup.value must be not be 1
        if info1.value~=1 & info2.value~=1 & info3.value~=1
            check=1;
        elseif info1.value~=1 & info2.value~=1 & strcmp(info3.focus,'All')
            check=1;
        else
            check=0;
        end
    case 4 % first four popup.value must be not be 1
        if info1.value~=1 & info2.value~=1 & info3.value~=1 & info4.value~=1
            check=1;
        elseif info1.value~=1 & info2.value~=1 & strcmp(info3.focus,'All') & strcmp(info4.focus,'All')
            check=1;
        elseif info1.value~=1 & info2.value~=1 & strcmp(info3.focus,'All') & info4.value~=1
            check=1;
        elseif info1.value~=1 & info2.value~=1 & info3.value~=1 & strcmp(info4.focus,'All')
            check=1;
        else
            check=0;
        end
end

if check == 0
    errordlg('Please select an Area, Transect ID and Date first','Check pulldown boxes');
    return
end