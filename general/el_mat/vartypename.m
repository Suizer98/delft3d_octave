function typ = vartypename(v)
%VARTYPENAME  Returns character name of variable type
%
% See also: isfloat, isinteger, ischar, 
%           iscell,  isstruct,  islogical
%           isempty, isa

% © G.J. de Boer, TU delft, Nov 2006.

% $Id: vartypename.m 17097 2021-02-25 15:35:12Z l.w.m.roest.x $
% $Date: 2021-02-25 23:35:12 +0800 (Thu, 25 Feb 2021) $
% $Author: l.w.m.roest.x $
% $Revision: 17097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/vartypename.m $
% $Keywords$

if     isempty  (v);         typ = 'empty';
elseif isnumeric(v);        %typ = 'numeric';
   if  isinteger(v);        %typ = 'integer';
      if     isa(v,'int8'  );typ = 'int8' ;
      elseif isa(v,'uint8' );typ = 'uint8';
      elseif isa(v,'int16' );typ = 'int16';
      elseif isa(v,'uint16');typ = 'uint16';
      elseif isa(v,'int32' );typ = 'int32';
      elseif isa(v,'uint32');typ = 'uint32';
      elseif isa(v,'int64' );typ = 'int64';
      elseif isa(v,'uint64');typ = 'uint64';
      end
   elseif isfloat(v);      %;typ = 'double';
      if     isa(v,'single');typ = 'single';
      elseif isa(v,'double');typ = 'double';
      end
   end    
elseif ischar   (v);         typ = 'char';
elseif isstring (v);         typ = 'string';
elseif iscell   (v);         typ = 'cell';
elseif isstruct (v);         typ = 'struct';
elseif istable  (v);         typ = 'table';
elseif islogical(v);         typ = 'logical';
elseif isobject (v);         typ = 'object';
elseif isa      (v,'function_handle');
                             typ = 'function_handle';
end
 
%% EOF