function values = nc_varget_tmw(ncfile,varname,varargin)

ncid=netcdf.open(ncfile,'NOWRITE');

% Assume that we retrieve the variable in the root group until we know
% otherwise.  Assume that the variable name is given.
gid = ncid;
local_varname = varname;

% If the library is > 4 and the format is unrestricted netcdf-4, then we
% may need to drill down thru the groups.
lv = netcdf.inqLibVers;
if lv(1) == '4'
    fmt = netcdf.inqFormat(ncid);
    if strcmp(fmt,'FORMAT_NETCDF4') && (numel(strfind(varname,'/')) > 1)
        varpath = regexp(varname,'/','split');
        for k = 2:numel(varpath)-1
            gid = netcdf.inqNcid(gid,varpath{k});
        end
        local_varname = varpath{end};
    end
end

try
    values = nc_varget_tmw_group(gid,local_varname,varargin{:});
catch me
    netcdf.close(ncid);
    switch(me.identifier)
        case {'MATLAB:imagesci:netcdf:unrecognizedVarDatatype'}
            values = h5read(ncfile,['/' varname],varargin{:});
        otherwise
            values = nc_varget_java(ncfile,varname,varargin{:});
    end
    return

end

netcdf.close(ncid);



%--------------------------------------------------------------------------
function values = nc_varget_tmw_group(ncid,varname,varargin)

% The assumption is that ncid is ID for the group (possibly the root group)
% containing the named variable, which had better not have a slash in the
% name.  Since ncid may not be for the file, we do not close it.


preserve_fvd = nc_getpref('PRESERVE_FVD');


varid=netcdf.inqVarID(ncid,varname);
[dud,xtype,dimids]=netcdf.inqVar(ncid,varid); %#ok<ASGLU>
nvdims = numel(dimids);

the_var_size = determine_varsize_tmw(ncid,dimids,nvdims,preserve_fvd);

switch(nargin)
    case 2
        start = zeros(1,nvdims);
        count = the_var_size;
        stride = ones(1,nvdims);
    case 4
        stride = ones(1,nvdims);
    otherwise
        error('SNCTOOLS:wrongNumberOfInputs','Wrong number of inputs.');
end



% R2008b expects to preserve the fastest varying dimension, so if the
% user didn't want that, we have to reverse the indices.
if ~preserve_fvd
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
    the_var_size = fliplr(the_var_size);
end

% Check that the start, count, stride parameters have appropriate
% lengths.  Otherwise we get confusing error messages later on.
snc_validate_idx(start,count,stride,nvdims);


% If the user had set non-positive numbers in "count", then we replace
% them with what we need to get the rest of the variable.
negs = find((count<0) | isinf(count));
if isempty(stride)
    count(negs) = the_var_size(negs) - start(negs);
else
    count(negs) = floor((the_var_size(negs) - start(negs))./stride(negs));
end


% If there is a fill value, missing value, scale_factor, or add_offset,
% we will retrieve the data as double precision.
use_missing_value  = false;
has_scaling        = false;
use_fill_value     = false;
retrieve_as_double = false;
try
    att_type = netcdf.inqAtt(ncid, varid, '_FillValue' );
    if (att_type == var_type) | isnan(netcdf.getAtt(ncid, varid, '_FillValue' ))
        use_fill_value = true;
        retrieve_as_double = true;
    else
        warning('SNCTOOLS:nc_varget:tmw:fillValueMismatch', ...
            'The _FillValue datatype for %s is wrong.  The _FillValue will not be honored.', ...
            varname);
    end
catch %#ok<CTCH>
end

try
    att_type = netcdf.inqAtt(ncid, varid, 'missing_value' );
    if ~use_fill_value
        if (att_type == var_type) | isnan(netcdf.getAtt(ncid, varid, 'missing_value' ))
            % fill value trumps missing values
            use_missing_value = true;
            retrieve_as_double = true;
        else
            warning('SNCTOOLS:nc_varget:tmw:missingValueMismatch', ...
                'The missing_value datatype for %s is wrong.  The missing_value will not be honored.', ...
                varname);
        end
    end
catch %#ok<CTCH>
    %
end

try
    netcdf.inqAtt(ncid, varid, 'scale_factor' );
    has_scaling = true;
    retrieve_as_double = true;
catch %#ok<CTCH>
    %
end

try
    netcdf.inqAtt(ncid, varid, 'add_offset' );
    has_scaling = true;
    retrieve_as_double = true;
catch %#ok<CTCH>
    %
end

% NC_CHAR can never be retrieved as numeric.
if ( xtype == nc_char)
    retrieve_as_double = false;
end

ncargs{1} = ncid;
ncargs{2} = varid;
if ~isempty(start)
    ncargs{3} = start;
end
if ~isempty(count)
    ncargs{4} = count;
end
if ~isempty(stride)
    ncargs{5} = stride;
end
if retrieve_as_double
    ncargs{end+1} = 'double';
end


% At long last, retrieve the data.
values = netcdf.getVar(ncargs{:});


% If it's a 1D vector, make it a column vector.  Otherwise permute the
% data to make up for the row-major-order-vs-column-major-order issue.
if length(the_var_size) == 1
    values = values(:);
else
    if ~preserve_fvd
        pv = fliplr ( 1:length(the_var_size) );
        values = permute(values,pv);
    end
end


if use_fill_value
    values = handle_fill_value_tmw(ncid,varid,xtype,values);
end
if use_missing_value
    values = handle_missing_value_tmw(ncid,varid,xtype,values);
end
if has_scaling
    values = handle_scaling_tmw(ncid,varid,values);
end

% remove any singleton dimensions.
values = squeeze ( values );

return








%--------------------------------------------------------------------------
function values = handle_fill_value_tmw ( ncid, varid, var_type, values )
% HANDLE_TMW_FILL_VALUE
%     If there is a fill value, then replace such values with NaN.


switch ( var_type )
    case nc_char
        % For now, do nothing.  Does a fill value even make sense with 
        % char data?  If it does, please tell me so.

    case { nc_double, nc_float, nc_int, nc_short, nc_byte }
        fill_value = netcdf.getAtt(ncid,varid,'_FillValue','double');
        values(values==fill_value) = NaN;

    otherwise
        error ( 'SNCTOOLS:nc_varget:unhandledFillValueType', ...
            'Unhandled fill value datatype %d', var_type );

end

return






%--------------------------------------------------------------------------
function values = handle_missing_value_tmw(ncid,varid,var_type,values)
% HANDLE_TMW_MISSING_VALUE
%     If there is a missing value, then replace such values with NaN.

switch ( var_type )
    case nc_char
        % For now, do nothing.  Does a missing value even make 
        % sense with char data?  If it does, please tell me so.

    case { nc_double, nc_float, nc_int, nc_short, nc_byte }
        fill_value = netcdf.getAtt(ncid,varid,'missing_value','double');
        values(values==fill_value) = NaN;

    otherwise
        error('SNCTOOLS:nc_varget:tmw:unhandledMissingValueDatatype', ...
              'Unhandled datatype %d.', var_type );
end



return








%--------------------------------------------------------------------------
function values = handle_scaling_tmw ( ncid, varid, values )
% HANDLE_TMW_SCALING
%
% If there is a scale factor and/or  add_offset attribute, convert the data
% to double precision and apply the scaling.


try
    netcdf.inqAtt(ncid, varid, 'scale_factor' );
    have_scale = true;
catch me %#ok<NASGU>
    have_scale = false;
end
try
    netcdf.inqAtt(ncid, varid, 'add_offset' ); 
    have_addoffset = true;
catch me %#ok<NASGU>
    have_addoffset = false;
end

%
% Return early if we don't have either one.
if ~(have_scale || have_addoffset)
    return;
end

scale_factor = 1.0;
add_offset = 0.0;

if have_scale
    scale_factor = netcdf.getAtt(ncid,varid,'scale_factor','double');
end
if have_addoffset
    add_offset = netcdf.getAtt(ncid,varid,'add_offset','double');
end


values = values * scale_factor + add_offset;

return




%-----------------------------------------------------------------------
function the_var_size = determine_varsize_tmw(ncid,dimids,nvdims,preserve_fvd)
% DETERMINE_VARSIZE_TMW: Need to figure out just how big the variable is.
%
% 


% If not a singleton, we need to figure out how big the variable is.
if nvdims == 0
    the_var_size = 1;
else
    the_var_size = zeros(1,nvdims);
    for j=1:nvdims,
        dimid = dimids(j);
        [dim_name,dim_size]=netcdf.inqDim(ncid, dimid); %#ok<ASGLU>
        the_var_size(j)=dim_size;
    end
end

% Reverse the dimensionsions?
if ~preserve_fvd
    the_var_size = fliplr(the_var_size);
end

return





