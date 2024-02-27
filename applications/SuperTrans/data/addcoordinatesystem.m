function addcoordinatesystem


cs.coord_ref_sys_name='Bangladesh Transverse Mercator (BTM)';
cs.coord_ref_sys_kind='projected';
cs.source_geogcrs_name='Gulshan 303';
cs.area_name='Bangladesh';
cs.information_source='Bangladesh Flood Action Plan';
cs.data_source='FAP 19';
cs.revision_date='23-08-13';

cs.coord_op_name='Bangladesh Transverse Mercator (BTM)';
cs.coord_op_type='conversion';
cs.coord_op_method_name='Transverse Mercator';

cs.parameters(1).name='Scale factor at natural origin';
cs.parameters(1).value=0.9996;
cs.parameters(1).uom_name='unity';

cs.parameters(2).name='False easting';
cs.parameters(2).value=500000;
cs.parameters(2).uom_name='metre';

cs.parameters(3).name='False northing';
cs.parameters(3).value=-2000000;
cs.parameters(3).uom_name='metre';

cs.parameters(4).name='Latitude of natural origin';
cs.parameters(4).value=0;
cs.parameters(4).uom_name='degree';

cs.parameters(5).name='Longitude of natural origin';
cs.parameters(5).value=90;
cs.parameters(5).uom_name='degree';

s0=load('EPSG.mat');
s1=s0.user_defined_data;
s1=addCoordinateSystem(cs,s0,s1);
s0.user_defined_data=s1;

save('d:\checkouts\OpenEarthTools\trunk\matlab\applications\SuperTrans\data\EPSG_new.mat','-struct','s0','-v6');

function s1=addCoordinateSystem(cs,s0,s1)

cs.revision_date=datestr(floor(now),'dd-mm-yy');

% Some general stuff

% Area
ii=strcmp(s0.area.area_name,cs.area_name);
area_of_use_code=s0.area.area_code(ii);

% First add new coordinate operation
n=length(s1.coordinate_operation.coord_op_code);
coord_op_code=s1.coordinate_operation.coord_op_code(n)+1;
n=n+1;

s1.coordinate_operation.coord_op_code(n)=coord_op_code;
s1.coordinate_operation.coord_op_name{n}=cs.coord_op_name;
s1.coordinate_operation.coord_op_type{n}=cs.coord_op_type;
s1.coordinate_operation.source_crs_code(n)=NaN;
s1.coordinate_operation.target_crs_code(n)=NaN;
s1.coordinate_operation.coord_tfm_version{n}='';
s1.coordinate_operation.coord_op_variant{n}='';
s1.coordinate_operation.area_of_use_code(n)=area_of_use_code;
s1.coordinate_operation.coord_op_scope{n}='Geodetic survey; topographic mapping; engineering survey.';
s1.coordinate_operation.coord_op_accuracy{n}='0';

ii=strcmp(s0.coordinate_operation_method.coord_op_method_name,cs.coord_op_method_name);
coord_op_method_code=s0.coordinate_operation_method.coord_op_method_code(ii);

s1.coordinate_operation.coord_op_method_code(n)=coord_op_method_code;
s1.coordinate_operation.uom_code_source_coord_diff{n}='';
s1.coordinate_operation.uom_code_target_coord_diff{n}='';
s1.coordinate_operation.remarks{n}='';
s1.coordinate_operation.information_source{n}=cs.information_source;
s1.coordinate_operation.data_source{n}=cs.data_source;
s1.coordinate_operation.revision_date{n}=cs.revision_date;
s1.coordinate_operation.change_id{n}='';
s1.coordinate_operation.show_operation{n}='TRUE';
s1.coordinate_operation.deprecated{n}='FALSE';

% Add parameter values
n=length(s1.coordinate_operation_parameter_value.coord_op_code);
for j=1:length(cs.parameters)
    n=n+1;
    s1.coordinate_operation_parameter_value.coord_op_code(n)=coord_op_code;    
    s1.coordinate_operation_parameter_value.coord_op_method_code(n)=coord_op_method_code;
    ii=strcmp(s0.coordinate_operation_parameter.parameter_name,cs.parameters(j).name);
    s1.coordinate_operation_parameter_value.parameter_code(n)=s0.coordinate_operation_parameter.parameter_code(ii);
    s1.coordinate_operation_parameter_value.parameter_value(n)=cs.parameters(j).value;
    s1.coordinate_operation_parameter_value.param_value_file_ref{n}='';
    ii=strcmp(s0.unit_of_measure.unit_of_meas_name,cs.parameters(j).uom_name);
    uom_code=s0.unit_of_measure.uom_code(ii);
    s1.coordinate_operation_parameter_value.uom_code(n)=uom_code;
end

% Adjust coordinate_reference_system

n=length(s1.coordinate_reference_system.coord_ref_sys_code);
newcode=s1.coordinate_reference_system.coord_ref_sys_code(n)+1;
n=n+1;

s1.coordinate_reference_system.coord_ref_sys_code(n)=newcode;
s1.coordinate_reference_system.coord_ref_sys_name{n}=cs.coord_ref_sys_name;
s1.coordinate_reference_system.area_of_use_code(n)=area_of_use_code;

switch cs.coord_ref_sys_kind
    case{'projected'}
        coord_sys_code=4400;
    case{'geographic'}
end

s1.coordinate_reference_system.coord_ref_sys_kind{n}=cs.coord_ref_sys_kind;
s1.coordinate_reference_system.coord_sys_code(n)=coord_sys_code;
s1.coordinate_reference_system.datum_code(n)=NaN;

ii=strcmp(s0.coordinate_reference_system.coord_ref_sys_name,cs.source_geogcrs_name);
source_geogcrs_code=s0.coordinate_reference_system.coord_ref_sys_code(ii);

s1.coordinate_reference_system.source_geogcrs_code(n)=source_geogcrs_code;

s1.coordinate_reference_system.projection_conv_code(n)=coord_op_code;
s1.coordinate_reference_system.cmpd_horizcrs_code(n)=NaN;
s1.coordinate_reference_system.cmpd_vertcrs_code(n)=NaN;
s1.coordinate_reference_system.crs_scope{n}='Geodetic survey; topographic mapping; engineering survey.';
s1.coordinate_reference_system.remarks{n}='';
s1.coordinate_reference_system.information_source{n}=cs.information_source;
s1.coordinate_reference_system.data_source{n}=cs.data_source;
s1.coordinate_reference_system.revision_date{n}=cs.revision_date;
s1.coordinate_reference_system.change_id{n}='';
s1.coordinate_reference_system.show_crs{n}='TRUE';
s1.coordinate_reference_system.deprecated{n}='FALSE';

% 