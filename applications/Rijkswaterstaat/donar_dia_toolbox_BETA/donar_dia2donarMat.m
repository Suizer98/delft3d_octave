function [T] = donar_dia2donarMat(sourcename,cellstr_fields,timezone)
%donar_dia2donarMat convert dia file to mat file
%
% [T] = donar_dia2donarMat(sourcename,cellstr_fields,timezone)
%
% See also: 

%   sourcename = 'p:\1204561-noordzee\data\svnchkout\donar_dia\dia_ctd\Copy of ctd_2003_-_2009.dia'
%   cellstr_fields = {'longitude','latitude','z','datestring','timestring','variable'}
    
    warning('BETA Version')
    
    numcol = size(cellstr_fields,1);
    fid    = fopen(sourcename);
    theformat = '%s';    
    
    for i=numcol:-1:1,      
        theformat = ['%f',theformat];
    end
              
    % The dia file that I am dealing with is divided into several batches
    % (stukjes) of data, separated by headers (Hdr). Lets read the file
    % identifying the separate batches.
    res   = struct([]);
    iStuk = 1;
    iHdr  = 1;
    
    while true
        
        clear batch_data temp
        % Read a data line
        temp = textscan(fid,theformat,'delimiter',';:');

        if isempty(temp{numcol})
            
            % It did not read anything? It is not of type '%f'
            % It doesn't comply to "theformat", it might be a hdr
            result = donar_readHDR(fid);
            
            if ~isstruct(result)
                
                % Nope, It is actually the end of the file
                numhdr = iHdr-1;
                numstuk = iStuk-1;
                clear iHdr iStuck;
                break;
            
            else
                iHdr = iHdr + 1;
            end
            
        else
            
            %% Produce an array of information
            
            batch_data = cell2mat(temp(:,1:end-1));
            
            %% Get the coordinates degrees
            
            batch_data(:,1) = dms2degrees([mod(fix(batch_data(:,1)/1000000),100), ...
                                           mod(fix(batch_data(:,1)/10000),100), ...
                                           mod(    batch_data(:,1),10000)/100]);
            
            batch_data(:,2) = dms2degrees([mod(fix(batch_data(:,2)/1000000),100), ...
                                           mod(fix(batch_data(:,2)/10000),100), ...
                                           mod(    batch_data(:,2),10000)/100]);
            
            %% Flag the data
            
            variableCol = find(ismember(lower(cellstr_fields(:,1)),lower('variable')));
            batch_data(batch_data(:,variableCol)>1E9, :) = [];
            batch_data(:,numcol+1) = iStuk;
            batch_data = donar_flagValues(result.PAR{2},batch_data);
            
            %% Organize information by time and flag the data

            dateCol = find(ismember(lower(cellstr_fields(:,1)),lower('datestring')));
            timeCol = find(ismember(lower(cellstr_fields(:,1)),lower('timestring')));
            
            batch_data(:,dateCol) = time2datenum(batch_data(:,dateCol),batch_data(:,timeCol));
            the_years = year(batch_data(:,dateCol));
            batch_data(:,dateCol) = batch_data(:,dateCol) - datenum(1970,1,1);
            
            batch_data(:,timeCol) = [];
            if variableCol > timeCol, variableCol = variableCol -1; end
            batch_data = sortrows(batch_data,dateCol);
            
            [~,field_name] = donarname2standardnames(strrep(wns2name(result.WNS{1}),' ','_'));
            field_name = strrep(field_name,' ','_');
            [unique_years,~,years_index] = unique(the_years);

            for iyear = unique_years'
                
                data = batch_data(the_years == iyear,:);
                
                %% Organize the headers, just write one and store the ones
                %  that change from piece to piece.

                if iStuk == 1

                    % Structure is empty lets initialize it
                    make_field(iyear,field_name)
                
                % CHECK IF THE YEAR IS ALREADY IN THE STRUCTURE
                elseif isfield(thecompend,(['year',num2str(iyear)]))
                    

                    % CHECK IF THE FIELD IS ALREADY IN THE YEAR STRUCTURE
                    if isfield(thecompend.(['year',num2str(iyear)]),field_name)


                        thefields = fields(result);
                        thefieldname = field_name;


                        % Check that the headers are all the same
                        for k=1:length(thefields)
                            if (~strcmpi(thefields{k},'tyd') && ...
                                ~strcmpi(thefields{k},'bgs') ) && ...
                                ~strcmp(cell2mat(thecompend.(['year',num2str(iyear)]).(field_name).hdr.(thefields{k})(1,:)),[result.(thefields{k}){:}])

                                % The headers are not the same!!!! Lets
                                % make a new field and store the data there.
                                thefieldname = [thefieldname,'_',thefields{k},'_',result.(thefields{k}){1}];
                            end
                        end


                        % The name of the new field will contain the hdr
                        % differences: thefieldname.
                        if ~isfield(thecompend.(['year',num2str(iyear)]),thefieldname)
                            % Let's make the new field...
                            make_field(iyear,thefieldname)
                        else

                            thecompend.(['year',num2str(iyear)]).(thefieldname).data = [thecompend.(['year',num2str(iyear)]).(field_name).data; data];
                        end

                    else

                        % This field is not yet in the structure, we need to
                        % make it.
                        make_field(iyear,field_name)
                    end
                
                else
                    make_field(iyear,field_name)
                end
                
            iStuk = iStuk + 1;
            if ~mod(iStuk,100),   disp([num2str(iStuk),' batches processed']);  end
            end
        end   
    end
    
    if numstuk ~=  numhdr, warning('The number of headers and data batches are disimilar.');  end
    fclose(fid);
    
        
    % This little function is here just to make the code a little bit more
    % organized. It needs to have the workspace accesible and the only
    % thing the really changes from call to call is the name of the new
    % field.
    function [] = make_field(whatyear,name_of_field)
        eval(['thecompend.',(['year',num2str(whatyear)]),'.',name_of_field,'.hdr = struct(result);'])
        eval(['thecompend.',(['year',num2str(whatyear)]),'.',name_of_field,'.data = data;'])
        
        thecompend.(['year',num2str(whatyear)]).(name_of_field).referenceDate = ...
            datenum(1970,1,1);
        
        thecompend.(['year',num2str(whatyear)]).(name_of_field).dimensions = ...
            cellstr_fields(~ismember(cellstr_fields(:,1),'variable') & ~ismember(cellstr_fields(:,1),'timestring'),:);
        
        thecompend.(['year',num2str(whatyear)]).(name_of_field).dimensions(ismember(thecompend.(['year',num2str(whatyear)]).(name_of_field).dimensions(:,1),'datestring'),:) = ...
            {'time',['days since ',datestr(datenum(1970,1,1),'yyyy-mm-dd HH:MM:SS'),' ',timezone]};
        
        thecompend.(['year',num2str(whatyear)]).(name_of_field).name = ...
            strrep(wns2name(thecompend.(['year',num2str(whatyear)]).(name_of_field).hdr.WNS),' ','_');
        
        [thecompend.(['year',num2str(whatyear)]).(name_of_field).standard_name,thecompend.(['year',num2str(whatyear)]).(name_of_field).deltares_name] = ...
            donarname2standardnames(thecompend.(['year',num2str(whatyear)]).(name_of_field).name);
        
        thecompend.(['year',num2str(whatyear)]).(name_of_field).variableCol = ...
            variableCol;
        
    end

end