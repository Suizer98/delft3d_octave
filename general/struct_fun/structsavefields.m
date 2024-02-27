function structsavefields(varargin)
%STRUCTSAVEFIELDS   Saves struct fields as separate variables as SAVE('-struct'').
%
%    savestructfields() 
%
% saves variables as 'save', but for a struct it saves not the struct, 
% but their fields as variables. Note that subfield can be multidimensional
% structs, whoich is not possibel with matlab save.
%
% Note: This function CANNOT save non-struct variables 
% as it is not yet implemented.
%
% Note: This function was initally made for Matlab R6 which does alllow 
%
%    save(...,'-struct',...)
%
% pass options   : as strings
% pass variables : as real variables
%                  and not only their names
%                  as trings as 'save' does.
%
% Use save (,'-append',...) for adding those.
% or Use savestructfields(,'-append',...) for adding
% the struct to an existing mat file
%
% Example:
%
%   A.x(1).a= [1 2 3];
%   A.x(1).b= ['456'];
%   A.x(2).a= [7 8 9];
%   A.x(2).b= ['012'];
%  %save('A','A','-struct'); % does not work
%   structsavefields('A',A); % does work
%   A2 = load('A');
%
% See also: SAVE

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

var_options    = {};
var_fieldnames = {};
for i=2:nargin
   if isstruct(varargin{i})
      % get fieldnames
      var_fieldnames = fieldnames(varargin{i})';
      % assing fieldnames to local variables
      assigninstruc(varargin{i});
   else
      if strcmp(varargin{i}(1),'-')
         %   SAVE ...  -MAT     saves in MAT format regardless of extension.
         %   SAVE ...  -V4      saves a MAT-file that MATLAB 4 can LOAD.
         %   SAVE ...  -APPEND  adds the variables to an existing file (MAT-file only).
         var_options = {var_options{:},varargin{i}};
      else
      end
   end
end

var_options_string = [];
for i=1:length(var_options)
   var_options_string = [var_options_string,',''',var_options{i},''''];
end   

var_fieldnames_sting = [];
for i=1:length(var_fieldnames)
   var_fieldnames_sting = [var_fieldnames_sting,',''',var_fieldnames{i},''''];
end   

    % display for debugging purposes
disp(['save(''',varargin{1},'''',var_options_string,var_fieldnames_sting,')'])
    
eval(['save(''',varargin{1},'''',var_options_string,var_fieldnames_sting,')'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function assigninstruc(varargin)
%
%  this  function assigns the values of
%  (default:all) fields of a struct to variables 
%  in the calling workspace with a similar name.
%
%   An optional list of fields can be passed with:
%   assigninstruc(STRUCT,'fldlist',fldlist)
%
%  Existing variables with the same name are overwritten.
%
%   struc = {}
%   struc.a='aap'
%   struc.b=2
%   assigninstruc(struc,'fldlist',{'a'});
%   isstring(a)
%   assigninstruc(struc);
%   b/2
% 
%  Hans Bonekamp Okt  2001


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREFIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix  ='';
postfix ='';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARGUMENTS  & OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

struc  = varargin{1};
opt     = varargin(2:end);
for k = 1:2:length(opt)
   assigninfunc(opt{k},opt{k+1});
end;
if exist('options','var')
    assigninstruc(options)
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(struc)
    if ~exist('fldlist','var'); fldlist = fieldnames(struc)  ;end;

    for fld=fldlist(:)'
        c   = char(fld);
        cpp = strcat(prefix,c,postfix);
        assignin('caller',cpp ,getfield(struc,c))
    end;
end;
