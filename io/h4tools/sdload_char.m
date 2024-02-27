%SDLOAD_CHAR read  HDF4 SD's and NetCDF files as a structure of arrays
%
% NAME
%
%   sdload -- read HDF4 SD's and NetCDF files as Matlab arrays
%
% SYNOPSIS
%
%   [dat, atr, dim] = sdload(hfile)
%   [dat, atr, dim] = sdload(hfile,struct)
%   [dat, atr, dim] = sdload(hfile,fieldnames)
%
% INPUT
%
%   hfile       - HDF SD or NetCDF file name
%   struct      - struct
%   fieldnames  - cell array of fieldnames of struct
%
% OUTPUT
%
%   dat    - structure whose fields are arrays, one for each SDS
%   atr    - optional structure of file and variable attributes
%   dim    - optional structure of variable dimension attributes
%
% ATTRIBUTES
% 
%   The attribute structure atr may contain both file and variable
%   attributes.  File attributes are fields of atr with names that do
%   not match any variable name.  The attribute values are character
%   arrays.
% 
%   If dat.df is a field of the dat structure, i.e. a variable to be
%   saved, then atr.df is an optional corresponding variable attribute.
%   Variables can have more than one attribute, so variable attributes
%   are cell arrays of the form { {name, value}, {name, value}, ... }
%   with "name" the attribute name, and "value" the value.  Both name
%   and value should be character arrays.
% 
% CHARACTER FIELDS (Addition 1, G.J. de Boer: Aug. 12 2005)
%
%   In addition each file attribute is ALSO read into a character 
%   field of the dat struct, besides into the atr struct (to stay compatible
%   with the original sdload).
%
% LOGICAL FIELDS (Addition 1, G.J. de Boer: June 6th 2006)
%
%   HDF does not support the logical data type. Logicals are therefore
%   saved by sdsave_char as int8 values 0 and 1 with an attribute 
%   'original_data_type'='logical'. These fields are casted to logicals by sdload_char.
%
% FIELD NAME ORDER (Addition 2, G.J. de Boer: Aug. 12 2005)
%
%   When loading the dat in an structure array as in
%     DATA(1) = sdload_char('file1.hdf')
%     DATA(2) = sdload_char('file2.hdf')
%   the fieldnames of the two structs should match, as
%   well as the order of the fieldsnames. A second argument can be 
%   passed to sdload_char. The order of the fieldnames in the hdffile
%   is then ordered to be equal to the example struct.(fieldnames) 
%   or a cell array. If this is not the case, a swarning is issued 
%   after reading all the data.
%
% DIMENSIONS
% 
%   The optional HDF4 dimensions are similar to variable attributes, but
%   don't have explicit names.
% 
%   If dat.df is a field of the dat structure, i.e. a variable to be
%   saved, then dim.df is an optional corresponding dimension attribute.
%   These are cell arrays of the form {name, name, ...}, with one name
%   for each dimension of dat.df.  The names should be character arrays.
% 
% BUGS
% 
%   Not all HDF SDS names can be represented as Matlab variables; 
%   to work around this, any character in an SDS name that's not a
%   letter or digit is replaced with an underscore.  If that is a 
%   problem, the lower lever h4sdread can be used instead of sdload.
%
%   Compatiblilty of the HDF SD's and NetCDF formats is limited by 
%   the libraries used.  sdload.m should read both HDF and NetCDF 
%   without any problems, but the output of sdsave.m is HDF, and may 
%   not be readable by NetCDF tools unless they were compiled with 
%   the HDF libraries.
% 
%   The function has succesfully been tested for array up to 24 dimensions.
%
% H. Motteler, 31 Oct 02
%

function [dat, atr, dim] = sdload(hfile,varargin)

% >>>>> 
% >>>>> added G.J. de Boer:  Aug 12 2005  
% >>>>> 

% Flag to choose whether to save character fields of array as file attributes
load_attr2char  = 1;

% Flag to choose whether to save empty numeric arrays as attributes
load_attr2empty = 1;

% Flag to choose whether to transform logicals to integers or to skip them
save_logicals2integers = 1;

% Extract fieldnames of example struct
% and clear struct if necesarry to save memory.
if nargin==2
  if isstruct(varargin{1})
    fieldnames_to_match = fieldnames(varargin{1});
  elseif iscell(varargin{1})
    fieldnames_to_match = varargin{1};
  end
  clear varargin{1}
end

% <<<<< 
% <<<<< added G.J. de Boer:  Aug 12 2005  
% <<<<< 

access_mode = 'read';
sd_id = hdfsd('start', hfile, access_mode);
if sd_id == -1
  error('HDF sdstart failed')
end

% general info about file contents
[ndatasets, nglobal_attr, status] = hdfsd('fileinfo',sd_id);
if status == -1
  error('HDF sdfileinfo failed')
end

% read any file attributes
fattr = {};
for attr_index = 0 : nglobal_attr - 1

  [name,data_type,count,status] = hdfsd('attrinfo',sd_id,attr_index);
  if status == -1
    error('HDF sdattrinfo failed')
  end

  [data,status] = hdfsd('readattr', sd_id, attr_index);
  if status == -1
    error('HDF sdreadattr failed')
  end

  % copy file attrs to atr structure
  vname = mkvar(name);
  %old% eval(sprintf('atr.%s = data;', vname));
  atr.(vname) = data;

  % >>>>> 
  % >>>>> added G.J. de Boer:  Aug 12 2005  
  % >>>>> 

  % copy file attrs to dat structure
  % this is reverse of what sdsave_char2attr does
  % file attributes cannot have the same name as an SDS dataset
  % as sdsave_char2attr refuses to save those.
  if load_attr2char
    vname = mkvar(name);
    if data==0 % null character is the value for an empty array 
               % in the sdsave_char2attr, sdload_char2attr
               % (which is by default numeric in matlab)
      if load_attr2empty
        %old% eval(sprintf('dat.%s = [];', vname));
        dat.(vname) = [];
      end
    else
      %old% eval(sprintf('dat.%s = data;', vname));
      
      
      
      %% NEW
      % reshape newline delimited 1D string to a 2D array
      data = line2str(data);
      %% NEW
      
      
      
      dat.(vname) = data;
    end
  end

  % <<<<< 
  % <<<<< added G.J. de Boer:  Aug 12 2005  
  % <<<<< 

end % for attr_index = 0 : nglobal_attr - 1

% loop on SDS indices and read SDS's
alist = {};
for sds_index = 0 : ndatasets-1

  % get sds ID from index
  sds_id = hdfsd('select',sd_id, sds_index);

  [name, A, attrs, dims] = sdsid2mat(sd_id, sds_id);

  % close the current SDS
  status = hdfsd('endaccess',sds_id);
  if status == -1
    error('HDF sdendaccess failed')
  end

  % copy data, attrs, and dims to structs
  vname = mkvar(name);
  %old% eval(sprintf('dat.%s = A;', vname));
  %old% eval(sprintf('atr.%s = attrs;', vname));
  %old% eval(sprintf('dim.%s = dims;', vname));
  dat.(vname) = A;
  atr.(vname) = attrs;
  dim.(vname) = dims;
  
  if save_logicals2integers
    for i = 1:length(    atr.(vname))
      if    strcmp(lower(atr.(vname){i}(1)),'original_data_type')
        if  strcmp(lower(atr.(vname){i}(2)),'logical')
          dat.(vname) = (dat.(vname)==1);
        end
      end
    end
  end
  
end

% close the file
status = hdfsd('end',sd_id);
if sd_id == -1
  error('HDF sdend failed')
end

% >>>>> 
% >>>>> added G.J. de Boer:  Aug 17 2005  
% >>>>> 

if nargin==2
   try
      dat = orderfields(dat,fieldnames_to_match);
   catch
      disp('??? Warning using ==> sdload_char')
      disp(['Fieldnames ',hfile, ' and struct(fieldnames) do not match']);
   end
end

% <<<<< 
% <<<<< added G.J. de Boer:  Aug 17 2005  
% <<<<< 

%% -------------------------------------------------------------
%
% function s2 = mkvar(s1);
%
% replace everything in s1 that's not a letter or digit with '_'
%
function s2 = mkvar(s1);

vok = isletter(s1) | ('0' <= s1 & s1 <= '9');
s2  = s1;
s2(~vok) = '_';
if s2(1) == '_'
  s2(1) = 'x';
end

