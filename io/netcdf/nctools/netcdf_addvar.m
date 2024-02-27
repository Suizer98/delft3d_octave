function varid = netcdf_addvar ( ncid, varstruct )
%netcdf_addvar  adds a variable to a NetCDF file using the matlab netcdf library
%
%    NOTE: almost same as private snctools function NC_ADDVAR_TMW
% 
% USAGE:  netcdf_addvar ( ncid, varstruct );
%
% This function exist because NC_ADDVAR_TMW closes the netcdf file
% after each variable, resulting in sub-optimal files. netcdf_addvar
% does not create file until all variables to be added are knwom
% resuling in optimimization of netCDF file.
%
% PARAMETERS:
% Input
%    ncid      = handle returned by netcdf.open
%    varstruct = This is a structure with four fields:
%
%        Name
%        Nctype
%        Dimension
%        Attribute
%
%      "Name" is just that, the name of the variable to be defined.
%
%      "Nctype" should be 
%          'double', 'float', 'int', 'short', or 'byte', or 'char'
%          'NC_DOUBLE', 'NC_FLOAT', 'NC_INT', 'NC_SHORT', 'NC_BYTE', 'NC_CHAR'
%
%      "Dimension" is a cell array of dimension names.
%
%      "Attribute" is also a structure array.  Each element has two
%      fields, "Name", and "Value", e.g.
%
%      varstruct.Attribute(    1) = struct('Name', 'long_name' ,'Value', 'time');
%      varstruct.Attribute(end+1) = struct('Name', 'units'     ,'Value', 'days since 1970-01-01');
%
% Output: 
%     None.  In case of an error, an exception is thrown.
%
%See also: nc_addvar, nctools, snctools, NCwrite, NCWRITESCHEMA

warning([mfilename ' is not up-to-date any more with nc_addvar, it does not handle empty dimensions correctly.'])

% Checks on the input
if  ischar(ncid) 
	disp( 'NETCDF_ADDVAR:badInput', 'ncid argument id number' );
end

if ( ~isstruct(varstruct) )
	disp( 'NETCDF_ADDVAR:badInput', '2nd argument must be a structure' );
end

varstruct = validate_varstruct ( varstruct,ncid );

varid = netcdf.defVar(ncid,varstruct.Name,varstruct.Nctype,varstruct.dimid); 

% Create an attribute associated with the variable.
for j = 1:length(varstruct.Attribute)
	attribute_name = varstruct.Attribute(j).Name;
	attval         = varstruct.Attribute(j).Value;
   
    % code copied from SNCTOOLS nc_attput_tmw.m
    try
        netcdf.putAtt(ncid,varid,attribute_name,attval);
    catch me
        switch(me.identifier)
            case 'MATLAB:netcdf_common:emptySetArgument'
                % Bug #609383
                % Please consult the README.
                %
                % If char, change attval to ' '
        %        warning('SNCTOOLS:NCATTPUT:emptyAttributeBug', ...
        %            'Changing attribute from empty to single space, please consult the README.');
                netcdf.putAtt(ncid,varid,attribute_name,' ');
            otherwise
                rethrow(me);
        end
                
    end    
    
end

function varstruct = validate_varstruct ( varstruct,ncid )

%
% Check that required fields are there.
% Must at least have a name.
if ~isfield ( varstruct, 'Name' )
	disp ( 'NETCDF_ADDVAR:badInput', 'structure argument must have at least the ''Name'' field.' );
end

% Default Nctype is double.
if ~isfield ( varstruct, 'Nctype' )
	varstruct.Nctype = 'double';
end

%
% Are there any unrecognized fields?
fnames = fieldnames ( varstruct );
for j = 1:length(fnames)
	fname = fnames{j};
	switch ( fname )

	case { 'Nctype', 'Name', 'Dimension', 'dimid', 'Attribute' }
		%
		% These are used to create the variable.  They are ok.
		
	case { 'Unlimited', 'Size', 'Rank' }
		%
		% These come from the output of nc_getvarinfo.  We don't 
		% use them, but let's not give the user a warning about
		% them either.

	otherwise
		fprintf ( 2, '%s:  unrecognized field name ''%s''.  Ignoring it...\n', mfilename, fname );
	end
end

% If the datatype is not a string.
% Change suggested by Brian Powell
if ( isa(varstruct.Nctype, 'double') && varstruct.Nctype < 7 )
	types={ 'byte' 'char' 'short' 'int' 'float' 'double'};
	varstruct.Nctype = char(types(varstruct.Nctype));
end


% Check that the datatype is known.
switch ( varstruct.Nctype )
case { 'NC_DOUBLE', 'double', ...
	   'NC_FLOAT', 'float', ...
	   'NC_INT', 'int', ...
	   'NC_SHORT', 'short', ...
	   'NC_BYTE', 'byte', ...
	   'NC_CHAR', 'char'  }
	%
	% Do nothing
otherwise
	disp ( 'NETCDF_ADDVAR:unknownDatatype', 'unknown type ''%s''\n', mfilename, varstruct.Nctype );
end


%
% Check that required fields are there.
% Default Dimension is none.  Singleton scalar.

if ~isfield ( varstruct, 'Dimension' )

    varstruct.Dimension = [];
    
else

   if ~isfield ( varstruct, 'dimid' )
       for ii = 1:length(varstruct.Dimension)
           varstruct.dimid{ii} = netcdf.inqDimID(ncid,varstruct.Dimension{ii});
       end
   end
       
   if ~isfield ( varstruct, 'dimid' )
       varstruct.dimid = 1;
   else
       if iscell(varstruct.dimid)
           varstruct.dimid = [varstruct.dimid{:,:}] ;
       end
   end
   
   % Check that required fields are there.
   % Default Attributes are none
   if ~isfield ( varstruct, 'Attribute' )
   	varstruct.Attribute = [];
   end

end