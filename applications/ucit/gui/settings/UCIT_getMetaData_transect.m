function d = UCIT_getMetaData_transect
%UCIT_GETMETADATA_TRANSECT .
%
%See also: UCIT_getMetaData

        datatypes  = UCIT_getDatatypes;
        ind        = strmatch(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names);
        TransectsDatatype = datatypes.transect.datatype{ind};

        %% get metadata
        
        getDataFromDatabase = false;
        
        % try to get metadata variable d from userdata UCIT console
        d = [];
        try % to find metadata
            d = get(findobj('tag','UCIT_mainWin'),'Userdata');
        end
        
        % set areaname
        if     strcmp(UCIT_getInfoFromPopup('TransectsArea'),'Oregon')    ,areaid = 'Oregon';
        elseif strcmp(UCIT_getInfoFromPopup('TransectsArea'),'Washington');areaid = 'Washington';end
        
        % if no data was on UCIT console yet (or if it is the wrong data) reload from database
        if ~isempty(d) % Check to see if some data is available in d ...
            
            % ... if the datatype info as well as the soundingID data matches with the
            % values in the gui the data will not have to be collected again
            if strcmp(TransectsDatatype, 'Jarkus Data'  ) &&  ~strcmp(d.datatypeinfo(1), TransectsDatatype) || ...
               strcmp(TransectsDatatype, 'Lidar Data US') && (~strcmp(d.datatypeinfo(1), TransectsDatatype) || ...
                    ~strcmp(areaid        , UCIT_getInfoFromPopup('TransectsArea')))
                
                % ... if there is not a match the data will have to be collected again
                disp('Data needs to be collected from database again ... please wait!')
                getDataFromDatabase = true;
            end
        else % ... if there is no data in d the data will have to be collected again
            getDataFromDatabase = true;
        end
        
        %% if getDataFromDatabase == true get the metadata and store it in the userdata of the UCIT console
        
        if getDataFromDatabase
            
            d             = [];
            url           = datatypes.transect.urls{ind};
            ldb           = datatypes.transect.ldbs{ind};
            axis_settings = datatypes.transect.axes{ind};
            
            if strcmp(TransectsDatatype,'Lidar Data US')
                url   = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                ldb   = ldb{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                axis_settings = axis_settings{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                extra = datatypes.transect.extra{ind};
                extra = extra{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
            end
            
            crossshore = nc_varget(url, 'cross_shore');
            alongshore = nc_varget(url, 'alongshore');
            areacodes  = nc_varget(url, 'areacode');
            areanames  = nc_varget(url, 'areaname');
            years      = nc_varget(url, 'time');
            ids        = nc_varget(url, 'id');
            
            areanames  = cellstr(areanames);
            transectID = cellstr(num2str(ids));
            soundingID = cellstr(num2str(years));
            
            if strcmp(TransectsDatatype, 'Jarkus Data')
                
                contours(:,1) = nc_varget(url, 'x',[0 0                   ],[length(alongshore) 1]);
                contours(:,2) = nc_varget(url, 'x',[0 length(crossshore)-1],[length(alongshore) 1]);
                contours(:,3) = nc_varget(url, 'y',[0 0                   ],[length(alongshore) 1]);
                contours(:,4) = nc_varget(url, 'y',[0 length(crossshore)-1],[length(alongshore) 1]);
                d.area        = areanames;
                
            elseif strcmp(TransectsDatatype, 'Lidar Data US')
                
                contours = nc_varget(url, 'contour'); % if you want all lidar data use UCIT_getLidarMetaData
                d.area   = repmat({UCIT_getInfoFromPopup('TransectsArea')},length(areanames),1);
                d.extra  = extra;
                
            end
            
            d.datatypeinfo = repmat({UCIT_getInfoFromPopup('TransectsDatatype')},length(alongshore),1);
            d.contour      = [contours(:,1) contours(:,2) contours(:,3) contours(:,4)];
            d.areacode     = areacodes;
            d.soundingID   = soundingID;
            d.transectID   = transectID;
            d.year         = years;
            d.ldb          = ldb;
            d.axes         = axis_settings;
            
            set(findobj('tag','UCIT_mainWin'),'UserData',d);
        else
            disp('Data gathered from gui-data UCIT console')
        end
