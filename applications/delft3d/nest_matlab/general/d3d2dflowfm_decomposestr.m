function index = d3d2dflowfm_decomposestr(string,varargin)

% d3d2flowfm_decomposestr : gives back start indices of various fields in a string

OPT.Delimiter = ' ';
OPT   = setproperty(OPT,varargin);

index = [];
tmp   = strfind(string,OPT.Delimiter');

if ~isempty(tmp)
   %
   % First entry
   %
   if tmp(1) ~= 1
      index(1) = 1;
      i_field  = 2;
   else
      i_field   = 1;
   end
   %
   % Other entries
   %
   if length(tmp) >= 2
       for i_index = 2: length(tmp)
           if tmp(i_index) - tmp(i_index - 1) > 1
               index(i_field) = tmp(i_index - 1) + 1;
               i_field = i_field + 1;
           end
       end
   end

   %
   % Last entry
   %
   if tmp(end) ~= length(string)
       index(i_field) = tmp(end) + 1;
       i_field = i_field + 1;
       index(i_field) = length(string) + 1;
   end
end

