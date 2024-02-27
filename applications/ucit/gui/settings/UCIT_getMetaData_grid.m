function d = UCIT_getMetaData_grid
%UCIT_GETMETADATA_GRID .
%
%See also: UCIT_getMetaData

    %% get metadata
    
    getDataFromDatabase = false;
    
    % try to get metadata variable d from userdata UCIT console
    d = [];
    try % to find metadata
        d = get(findobj('tag','UCIT_mainWin'),'Userdata');
    end
    
    % if no data was on UCIT console yet (or if it is the wrong data) reload from database
    if ~isempty(d) % Check to see if some data is available in d ...
        
        % ... if the datatype info matches with the values in the gui the data will not have to be collected again
        if ~strcmp(d.datatypeinfo, UCIT_getInfoFromPopup('GridsDatatype'))
            
            % ... if there is not a match the data will have to be collected again
            disp('Data needs to be collected from database again ... please wait!')
            getDataFromDatabase = true;
        end
    else % ... if there is no data in d the data will have to be collected again
        getDataFromDatabase = true;
    end
    
    %% if getDataFromDatabase == true get the metadata and store it in the userdata of the UCIT console
    
    if getDataFromDatabase
    
        d               = [];
        datatypes       = UCIT_getDatatypes;
        
        if ~exist('datatype')
            d.datatypeinfo  = UCIT_getInfoFromPopup('GridsDatatype');
            if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN100')% temporary workaround until catalogfile AHN fixed
                temp_url = d.urls{1};d.urls = [];d.urls{1} = temp_url;
            elseif strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN250')
                temp_url = d.urls{2};d.urls = [];d.urls{1} = temp_url;
            end
        else
            d.datatypeinfo  = datatype;
        end
        ind             = find(strcmpi(d.datatypeinfo,datatypes.grid.names));
        if isempty(ind)
            datatypes.grid.names
            error(['Please use correct name of datatype'])
        end
        url             = datatypes.grid.urls{ind};
        d.catalog       = datatypes.grid.catalog{ind}; % need for grid_2D_orthogonal toolbox
        d.ldb           = datatypes.grid.ldbs{ind};
        d.axes          = datatypes.grid.axes{ind};
        d.cellsize      = datatypes.grid.cellsize{ind};
        OPT2            = grid_orth_getMapInfoFromDataset(d.catalog);
        d.contour       = [cell2mat([OPT2.x_ranges(:)])  cell2mat([OPT2.y_ranges(:)])];
        d.urls          = OPT2.urls; % makew sure orde rof urls is consistent with x\y_ranges !!!
        d.names         = d.urls;
        d.x_ranges      = OPT2.x_ranges;
        d.y_ranges      = OPT2.y_ranges;

        set(findobj('tag','UCIT_mainWin'),'UserData',d);
    else
        disp('Data gathered from gui-data UCIT console')
    end
