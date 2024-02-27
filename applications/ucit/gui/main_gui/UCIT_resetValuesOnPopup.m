function UCIT_DC_resetValuesOnPopup(type,popup1,popup2,popup3,popup4,popup5)
%UCIT_DC_RESETVALUESONPOPUP   This routine resets the UCIT popups 
%
% This routine resets the UCIT popups
%
% syntax:       output = function(input)
%
% input: 
%    type = variable identifying which kind of data is selected
%    popup1,popup2,popup3,popup4,popup5 = boolean values identifying which popup to reset (0: no, 1: yes)
%
% output:       
%    function has no output  
%
% example:
%    UCIT_DC_resetValuesOnPopup(1,0,0,1,1,1)
%    UCIT_DC_resetValuesOnPopup(1) % 1 = transects
%    UCIT_DC_resetValuesOnPopup(2) % 2 = grids
%    UCIT_DC_resetValuesOnPopup(3) % 3 = lines
%    UCIT_DC_resetValuesOnPopup(4) % 4 = points
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

% $Id: UCIT_resetValuesOnPopup.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

OPT.backgroundcolor = [0.7529    0.7529    0.7529];

if type==1
    if popup1==1
        string{1}='Datatype (load first)';
        set(findobj('tag','TransectsDatatype')  ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup2==1
        string{1}='Area (load first)';
        set(findobj('tag','TransectsArea')      ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup3==1
        string{1}='Transect ID (load first)';
        set(findobj('tag','TransectsTransectID'),'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup4==1
        string{1}='Date (load first)';
        set(findobj('tag','TransectsSoundingID'),'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup5==1
        string{1}='Actions (load first)';
        set(findobj('tag','TrActions')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
elseif type==2
    if popup1==1
        string{1}='Datatype (load first)';
        set(findobj('tag','GridsDatatype')      ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup2==1
        string{1}='Date (load first)';
        set(findobj('tag','GridsName')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup3==1
        string{1}='Search window (load first)';
        set(findobj('tag','GridsInterval')      ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup4==1
        string{1}='Thinning factor (load first)';
        set(findobj('tag','GridsSoundingID')    ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup5==1
        string{1}='Actions (load first)';
        set(findobj('tag','GrActions')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
elseif type==3
    if popup1==1
        string{1}='Datatype (load first)';
        set(findobj('tag','LinesDatatype')      ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup2==1
        string{1}='Name (load first)';
        set(findobj('tag','LinesArea')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup3==1
        string{1}='Interval (load first)';
        set(findobj('tag','LinesSoundingID')    ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup4==1
        string{1}='Date (load first)';
        set(findobj('tag','LinesLineID')        ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup5==1
        string{1}='Actions (load first)';
        set(findobj('tag','LnActions')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
elseif type==4
    if popup1==1
        string{1}='Datatype (load first)';
        set(findobj('tag','PointsDatatype')     ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup2==1
        string{1}='Station (load first)';
        set(findobj('tag','PointsStation')      ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup3==1
        string{1}='Date (load first)';
        set(findobj('tag','PointsSoundingID')   ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup4==1
        string{1}='Data ID (load first)';
        set(findobj('tag','PointsDataID')       ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end
    if popup5==1
        string{1}='Actions (load first)';
        set(findobj('tag','PtActions')          ,'string',string,'value',1,'enable','off','backgroundcolor',OPT.backgroundcolor);
    end

end
