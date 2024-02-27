function S1 = array_of_structs2struct_of_arrays(S2,varargin)
%ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS    merge D(:).fields(:) into D.fields(:,:)
%
%      s1 = array_of_structs2struct_of_arrays(s2)
%
% transforms an array of structures into a structure of arrays when
% all fields are character or numeric. The first dimension of s1
% corresponds to the size of s2. You can adjust this with PERMUTE.
%
% All fields with a common name need to be of the same type, and have the
% same size if numeric. cellstrings are turned into chars.
%
% Example: if s2(1:6) is an array of 6 structs, in which each with field looks like:
%   
%     a: 'lampje'
%     b: [1x3]
%     c: [1x2]
%
% then s1 is a structure
%   
%     a: {1x6 cell}
%     b: [6x1x3]
%     c: [6x1x2]
%
% If a field has an odd size (or is []) in one element s2(i), this is 
% considered an error. To continue with the other fieldnames that are OK 
% use array_of_structs2struct_of_arrays(s2,'IgnoreErrors',1);
%
% Input:
%   S2: non-scalar struct.
%   varargin:
%       IgnoreErrors: ignore fields that generate an error, boolean, default false
%       ExclField: exclude fields from transformation, cell array, default none
% 
% Output:
%   S1: scalar struct.
%   
%See also: CELL2STRUCT, STRUCT2CELL, PERMUTE, cell2mat, struct_of_arrays2array_of_structs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: array_of_structs2struct_of_arrays.m 16801 2020-11-11 22:13:55Z l.w.m.roest.x $
% $Date: 2020-11-12 06:13:55 +0800 (Thu, 12 Nov 2020) $
% $Author: l.w.m.roest.x $
% $Revision: 16801 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/array_of_structs2struct_of_arrays.m $
% $Keywords: $

OPT.IgnoreErrors = false;
OPT.ExclFld     = '';
OPT = setproperty(OPT,varargin{:});

fldnames = fieldnames(S2);
n        = length(S2);

% C = struct2cell(S2);

for ifld = 1 : length(fldnames)  % loop on fields
    fldname = fldnames{ifld};
    if any(strcmp(fldname,OPT.ExclFld))
        fprintf(1,'Field: ''%s'' is excluded\n.',fldnames{ifld});
    else
        str = ischar(S2(1).(fldname)) || iscellstr(S2(1).(fldname));
        ignore = 0;

        if str
            %% check for identical type
            for i = 1 : n
                if ~(ischar(S2(i).(fldname)) || iscellstr(S2(i).(fldname)))
                    if OPT.IgnoreErrors
                        warning(['Field ''',fldname,''' in struct(',num2str(i),') is not a char while in struct(1) it is.'])
                        ignore = 1;
                    else
                        error (['Field ''',fldname,''' in struct(',num2str(i),') is not a char while in struct(1) it is.'])
                    end
                end
            end
            %% merge data      
            if ~ignore
                for i = 1 : n
                     if ischar(S2(i).(fldname))
                        S1.(fldname){i} = S2(i).(fldname);
                     else
                        S1.(fldname){i} = char(S2(i).(fldname));
                     end
                end      
            end
        else
            sz = size(S2(1).(fldname));
            %% check for identical type
            for i = 1 : n
                if ~isnumeric(S2(i).(fldname))
                    error(['Field ''',fldname,''' in struct(',num2str(i),') is not numeric while in struct(1) it is.'])
                end
            end
            %% check for identical size
            for i = 1 : n
                if ~isequal(size(S2(i).(fldname)),sz)
                    if OPT.IgnoreErrors
                        warning(['Size of field ''',fldname,''' in struct(',num2str(i),') does not have same size as in struct(1).'])
                        ignore = 1;
                    else
                        error  (['Size of field ''',fldname,''' in struct(',num2str(i),') does not have same size as in struct(1).'])
                    end
                end
            end    
            %% merge data
            if ~ignore
              S1.(fldname) = nan([n sz(:)']);
              for i = 1 : n
                 S1.(fldname)(i,:) = S2(i).(fldname)(:);
              end
            end
        end
    end

end

%% EOF

