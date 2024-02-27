function UCIT_showRay
%UCIT_SHOWRAY   this routine shows the selected transects on the overview windo
%              
% input:       
%    routine has no input
%
% output:       
%    routine has no output
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $  (Version 1.0, January 2004) 
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

% $Id: UCIT_showRay.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make a JARKUS Overview!','No map found');
    return
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);

%Find all rays
rayH=findobj(gca,'type','line','LineStyle','-');
dpTs=strvcat(get(rayH,'tag'));
for ii=1:size(dpTs,1);
    if strfind(dpTs(ii,:),'.')
        res(ii)=1;
    end
end
rayH=rayH(find(res==1));

if isempty(rayH)
    errordlg('No rays found!','');
    return
end

[DataType,info1]=UCIT_DC_getInfoFromPopup('TransectsDatatype');
[Area,info2]=UCIT_DC_getInfoFromPopup('TransectsArea');
[TransectID,info3]=UCIT_DC_getInfoFromPopup('TransectsTransectID');
[SoundingID,info4]=UCIT_DC_getInfoFromPopup('TransectsSoundingID');

curRay=findobj(rayH,'tag',[Area ':' TransectID]);

set(rayH,'color',[1 0 0],'linewidth',0.15);
set(curRay,'color',[0 1 0],'linewidth',1.5);
refresh;

