function UCIT_loadRelevantInfo2Popup(type,PopupNR)
%UCIT_DC_LOADRELEVANTINFO2POPUP   This routine loads info from the database to the next popup
%
%    UCIT_loadRelevantInfo2Popup(type,PopupNR)
%
% loads info from the database to the next popup.
%
% input:
%    type = variable identifying which kind of data is selected
%        1: transects
%        2: grids
%        3: lines
%        4: points
%    PopupNR = values range from 1:4
%
% output:
%    function has no output
%
% example:
% 	UCIT_loadRelevantInfo2Popup(1,1)
%
% See also: UCIT_getInfoFromPopup

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2013-08-05 16:44:21 +0800 (Mon, 05 Aug 2013) $ (Version 1.0, January 2006)
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

% $Id: UCIT_loadRelevantInfo2Popup.m 8975 2013-08-05 08:44:21Z heijer $
% $Date: 2013-08-05 16:44:21 +0800 (Mon, 05 Aug 2013) $
% $Author: heijer $
% $Revision: 8975 $

datatypes = UCIT_getDatatypes;

if type==1&&PopupNR==1
    %% TRANSECTS :
    
    % *** set TransectsDatatype: get info from local ini file
    
    names = datatypes.transect.names; % datatype; % allow same dataset to be on different locations: same type, other name
    
    % manufacture the string for in the popup menu
    string{length(names)}=[]; string{1}='Select datatype ...';
    for i = 1:length(names)
        string{i+1} = names{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_resetValuesOnPopup(1,0,1,1,1,1);
    
    set(findobj('tag','UCIT_mainWin'),'Userdata',[]); % test
    
elseif type==1&&PopupNR==2
    
    % *** set TransectsArea
    
    objTag='TransectsDatatype';
    [name, info]=UCIT_getInfoFromPopup(objTag);
    
    if info.value==1
        UCIT_loadRelevantInfo2Popup(1,1);
        return
    end
    
    name  = UCIT_getInfoFromPopup(objTag);
    index = strmatch(name,datatypes.transect.names,'exact');
    type  = datatypes.transect.datatype{index};
    
    % get info from database
    if strcmp(type,'Jarkus Data')
        % get from single netCDF file
        areanames = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names))}, 'areaname');
        areas     = unique(cellstr(areanames));
    else
        areas = datatypes.transect.areas{index};
    end
    
    % manufacture the string for in the popup menu
    string{max(size(areas))+1}=[]; string{1}='Select area ...';
    for i = 1:max(size(areas))
        string{i+1}=areas{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsArea'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_resetValuesOnPopup(1,0,0,1,1,0)
    
    % find available actions for this datatype
    index = strmatch(name,datatypes.transect.names,'exact');
    datatypes = UCIT_getActions;
    actions  = [datatypes.transect.commonactions{index} datatypes.transect.specificactions{index}];
    
    % manufacture the string for in the popup menu
    string=[]; string{1}='Select action ...';
    for i = 1:max(size(actions))
        string{i+1}=actions{i};
    end
    
    objTag='TrActions';
    set(findobj('tag',objTag), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    
    % make overview plot
    fh = findobj('tag','mapWindow');
    if isempty(fh)
        UCIT_plotTransectOverview
    end
    
elseif type==1&&PopupNR==3
    
    % *** set TransectsTransectID
    
    objTag = 'TransectsDatatype';
    name   = UCIT_getInfoFromPopup(objTag);
    index  = strmatch(name,datatypes.transect.names,'exact');
    type   = datatypes.transect.datatype{index};
    
    % get info from database
    
    if strcmp(type,'Jarkus Data')
        areanames   = nc_varget(datatypes.transect.urls{strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names)}, 'areaname');
        ids         = nc_varget(datatypes.transect.urls{strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names)}, 'id');
        id_match    = cellfun(@(x) (strcmp(x, UCIT_getInfoFromPopup('TransectsArea'))==1), {cellstr(areanames)}, 'UniformOutput',false);
        transectIDs = {ids(id_match{1})- unique(round(ids(id_match{1})/1000000))*1000000}; % convert back from uniqu id
    else
        areanames = datatypes.transect.areas{index};
        urls = datatypes.transect.urls{strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names)};
        try
            transectIDs = {nc_varget(urls{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))}, 'id')};
        catch
            errordlg('Please check links to NetCDF files in ucit_getDatatypes');
        end
    end
    
    % manufacture the string for in the popup menu
    string{max(size(transectIDs))+1}=[]; string{1}='Select transect ID ...';
    for i = 1:max(size(transectIDs))
        string{i+1}=transectIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsTransectID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_resetValuesOnPopup(1,0,0,0,1,0)
    
elseif type==1&&PopupNR==4
    
    % *** set TransectsSoundingID
    
    objTag = 'TransectsDatatype';
    name   = UCIT_getInfoFromPopup(objTag);
    index  = strmatch(name,datatypes.transect.names,'exact');
    type   = datatypes.transect.datatype{index};
    
    % get info from database
    
    if strcmp(type,'Jarkus Data')
        years     = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names))}, 'time');
    else
        urls      = datatypes.transect.urls{strcmp(UCIT_getInfoFromPopup(objTag),datatypes.transect.names)};
        years     = nc_varget(urls{strcmp(datatypes.transect.areas{index},UCIT_getInfoFromPopup('TransectsArea'))}, 'time');
    end
    years        = sort(years,'descend');
    soundingIDs  = {datestr(years+datenum(1970,1,1))};
    
    % manufacture the string for in the popup menu
    string{max(size(soundingIDs))+1}=[]; string{1}='Select date ...';
    for i = 1:max(size(soundingIDs))
        string{i+1}=soundingIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    
    
elseif type==2&&PopupNR==1
    %% GRIDS
    
    % *** set GridsDataType: get info from local ini file
    
    names = datatypes.grid.names; % datatype; % allow same dataset to be on different locations: same type, other name
    
    % manufacture the string for in the popup menu
    string{length(names)}=[]; string{1}='Select datatype ...';
    for i = 1:length(names)
        string{i+1} = names{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','GridsDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_resetValuesOnPopup(2,0,1,1,1,1)
    
    set(findobj('tag','UCIT_mainWin'),'Userdata',[]); % test
    
elseif type==2&&PopupNR==2
    % *** set GridsYear
    objTag='GridsDatatype';
    %     [popupValue, info]=UCIT_getInfoFromPopup(objTag);
    %     if info.value==1
    %         UCIT_loadRelevantInfo2Popup(2,1);
    %         return
    %     end
    
    % get info from database
    name   = UCIT_getInfoFromPopup(objTag);
    years  = datenum(1927,1,1):datenum(now);
    years  = sort(years,'descend');
    string = cellstr(datestr(years,29));
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','GridsName'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_loadRelevantInfo2Popup(2,3);
    else
        set(findobj('tag','GridsName'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_resetValuesOnPopup(2,0,0,1,1,0)
    end
    
        % find available actions for this datatype
    index = strmatch(name,datatypes.grid.names,'exact');
    datatypes = UCIT_getActions;
    actions  = [datatypes.grid.commonactions{index} datatypes.grid.specificactions{index}];
    
    % manufacture the string for in the popup menu
    string=[]; string{1}='Select action ...';
    for i = 1:max(size(actions))
        string{i+1}=actions{i};
    end
    
    objTag='GrActions';
    set(findobj('tag',objTag), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_loadRelevantInfo2Popup(2,3);
    
elseif type==2&&PopupNR==3
    % *** set GridsInterval
    % get info from database
    objTag='GridsName';
    
    intervals = [1:100*12];
    
    for i = 1:max(size(intervals))
        string{i}=intervals(i);
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','GridsInterval'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_loadRelevantInfo2Popup(2,4);
    else
        set(findobj('tag','GridsInterval'), 'string', string, 'value',12, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_resetValuesOnPopup(2,0,0,0,1,0)
    end
    
    UCIT_loadRelevantInfo2Popup(2,4);
    
elseif type==2&&PopupNR==4
    % *** set GridsSoundingID
    
    thinnings = [1:10];
    % manufacture the string for in the popup menu
    for i = 1:max(size(thinnings))
        string{i} = thinnings(i);
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','GridsSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');

   % make overview plot
   mapW = findobj('tag','gridOverview');
   if isempty(mapW)
       UCIT_plotGridOverview
   end
    
end