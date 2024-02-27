function UCIT_setValues2Popup(type,ValuePopup1,ValuePopup2,ValuePopup3,ValuePopup4)
% UCIT_SETVALUES2POPUP  This routine sets the popups of the UCIT gui to the predetermined values.
%
% This routine sets the popups of the UCIT gui to the predetermined values.
%
% Syntax:
% 	UCIT_setValues2Popup(type,ValuePopup1,ValuePopup2,ValuePopup3,ValuePopup4)
%
% Input:
% 	type        = 1. transect, 2. grid, 3. lines, 4. points
% 	ValuePopup1 = value first popup (datatypeinfo)
% 	ValuePopup2 = value second popup (area, map, etc.)
% 	ValuePopup3 = value third popup (soundingID etc.)
% 	ValuePopup4 = value fourth popup (date, etc.)
%
% Output:
%	function has no output
%
% See also: ucit

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.1, April 2008)
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

% $Id: UCIT_setValues2Popup.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $
 
switch type
    case 1
        [popupValue1,info1]=UCIT_getInfoFromPopup('TransectsDatatype');
        
        [popupValue2,info2]=UCIT_getInfoFromPopup('TransectsArea');
        id=find(strcmp(ValuePopup2,info2.string));
        UCIT_DC_setValuesOnPopup('TransectsArea', info2.string, id, 'on', [1 1 1]);
        UCIT_loadRelevantInfo2Popup(1,3);

        [popupValue3,info3]=UCIT_getInfoFromPopup('TransectsTransectID');
        
        if strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Jarkus Data')||strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Jarkus Data (test/next release)');
            ValuePopup3 = num2str(str2double(ValuePopup3) - round(str2double(ValuePopup3)/1000000)*1000000);
        end
        
        id= find(str2double(info3.string) == str2double(ValuePopup3)); % previously: find(strcmp(ValuePopup3,info3.string));
        UCIT_DC_setValuesOnPopup('TransectsTransectID', info3.string, id, 'on', [1 1 1]);
        UCIT_loadRelevantInfo2Popup(1,4);

        [popupValue4,info4]=UCIT_getInfoFromPopup('TransectsSoundingID');
        id=find(strcmp(ValuePopup4,info4.string));
        UCIT_DC_setValuesOnPopup('TransectsSoundingID', info4.string, id, 'on', [1 1 1]);

    case 2
    case 3
    case 4
end
