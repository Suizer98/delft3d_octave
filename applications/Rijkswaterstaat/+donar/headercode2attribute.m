function  donarcode = headercode2attribute(donarcode)
%headercode2attribute translate DONAR datamodel property to global netCDF attribute
%
%  C = donar.headercode2attribute(donarcode)
%
% returns cell C = {data_type,variable_name,attribute_name,<?>,<?>,<?>}
%
% where C is multiple rows of {attcode,varname,attname} for
% ready use in nc_attput(ncfile, varname, attname, attval)
% with attcode the attribute sequence (row) number (1,2...)
% varname -1 for global attributes, and attname the
% attribute name, for ready use in nc_attput().
%
% Example: "Samengestelde_klassecode"
%
% {1,-1,'Compound_code'} = donar_rawcode2NCcode('sgk')
%
% see also: donar, read_header, ehd2units

    for icode = 1:1:length(donarcode)
        theinfo = get_the_code(donarcode{icode});
        if iscell(theinfo)
            donarcode(icode,2) = {theinfo};
        end
    end
end

function  outputcode = get_the_code(inputcode)
    switch lower(inputcode)
        case{'par'}
            % parameter
            outputcode = {1,-1,'Variable_code';  2,-1,'Variable_name'};
        case{'vat'}
            % veld_apparaat_name
            outputcode = {1,-1,'Device_code';    2,-1,'Device_name'};
        case{'grd'}
            % grid
            outputcode = {1,-1,'Grid'};
        case{'hdh'}
            % Hoedanigheid
            outputcode = {1,-1,'Quality_code';  2,-1,'Quality_name'};
        case{'ivs'}
            % Inventarisatie_Soort
            outputcode = {1,-1,'Inventory_code';2,-1,'Inventory_name'};
        case{'ogi'}
            % Opdrachtgevende_instantiecode
            outputcode = {1,-1,'Comission_code';2,-1,'Comission_name'};
        case{'org'}
            % Orgaan
            outputcode = {1,-1,'Organ_code';    2,-1,'Organ_name'};
        case{'plt'}
            % Plaats
            outputcode = {1,-1,'Place'};
        case{'sta'}
            % Reeks_status
            outputcode = {1,-1,'Series_status'};
        case{'typ'}
            % Reeks_type
            outputcode = {1,-1,'Series_code'};
        case{'sgk'}
            % Samengestelde_klassecode
            outputcode = {1,-1,'Compound_code'};
        case{'sys'}
            % System
            outputcode = {1,-1,'Unit_system'};
        case{'wns'}
            % Waarneming_soort_nummer
            outputcode = {1,-1,'Data_type_number'};
        case{'ana'}
            % Analyse_methode_code
            outputcode = {1,-1,'Analysis_method_code';2,-1,'Analysis_method_name'};
        case{'ani'}
            % Analyserende instantie_code
            outputcode = {1,-1,'Analyzer_code';       2,-1,'Analyzer_name'};
        case{'bhi'}
            % Beherende_instantie_code
            outputcode = {1,-1,'Manager_code';        2,-1,'Manager_name'};
        case{'bmi'}
            % Bemonsterende_instantie_code
            outputcode = {1,-1,'Sampler_code';        2,-1,'Sampler_name'};
        case{'bem'}
            % Bemonsterings_wijze_code
            outputcode = {1,-1,'Sampling_method_code';2,-1,'Sampling_method_name'};
        case{'bew'}
            % Bewerkings_methode
            outputcode = {1,-1,'Editing_method_code'; 2,-1,'Editing_method_name'};
        case{'btx'}
            % Biotaxon
            outputcode = {2,-1,'Biotaxon_code';       3,-1,'Biotaxon_name'};
        case{'cpm'}
            % Compartiment
            outputcode = {1,-1,'Compartiment_code';   2,-1,'Compartiment_name'};
        case{'gbd'}
            outputcode = {1,-1,'Area_id';             2,-1,'Area_name'};
            % gebieds_code
        case{'loc'}
            outputcode = {1,-1,'Location_code';       2,-1,'Location_name';4,-1,'Coordinate_system'};
            % locatie_code	

%% handled as variabel attributes, not as global attributes
%         case{'ehd'}
%            % eenheid
%            outputcode = {2,-1,'donar_units'};
%             
%         case{'variable'}                      % measurement
%             outputcode = {'data.value'};
%         case{'latitude'}                      % latitude
%             outputcode = {'data.lat'};
%         case{'longitude'}                     % longitude
%             outputcode = {'data.lon'};
%         case{'z'}                             % depth	
%             outputcode = {'data.z'};
        otherwise
            outputcode = -1;
    end
end