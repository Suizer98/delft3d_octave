function htype = hdftypes(mtype)
%HTYPE       find HDF type corresponding to Matlab types
%
%    htype = hdftypes(mtype)
%    htype = hdftypes(class(variable))
%
% finds HDF type corresponding to certain matlab types
%
%See also: NC_TYPE, CLASS, SNCTOOLS

mtype = lower(mtype);
switch mtype
  case 'double',  htype = 'float64';
  case 'single',  htype = 'float32';
  case 'uint8',   htype = mtype;
  case 'uint16',  htype = mtype;
  case 'uint32',  htype = mtype;
  case 'int8',    htype = mtype;
  case 'int16',   htype = mtype;
  case 'int32',   htype = mtype;
  case 'char',    htype = 'char8';
  otherwise
    error(sprintf('htype(): can''t match type %s\n', mtype));
end

