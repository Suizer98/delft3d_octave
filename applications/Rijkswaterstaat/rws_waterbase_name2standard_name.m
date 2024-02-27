function standard_name = rws_waterbase_name2standard_name(varargin)
%RWS_WATERBASE_NAME2STANDARD_NAME   convert DONAR substance name to CF standard_name
%
%   standard_names = rws_waterbase_name2standard_name(DONARcodes)
%
% Note : vectorized for codes, e.g.: rws_waterbase_name2standard_name({'22','23'})
% Note : codes can be numeric, e.g.: rws_waterbase_name2standard_name([ 22   23])
%
% Wrapper for donar.resolve_wns
%
% Examples:
%
%   odvname2standard_name('22') % gives 'sea_surface_wave_significant_height'
%
%See web: donar.resolve_wns
%See also: OceanDataView, ODVNAME2STANDARD_NAME

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

   codes       = varargin{1};
   if ischar(codes) | iscell(codes)
      codes = str2num(char(codes));
   end
   
   for icode=1:length(codes)
      code                 = codes(icode);
      standard_name{icode} = donar.resolve_wns(code);
   end
   
   %% Return character instead of cell if input is a single character or number
   if length(codes)==1 & (ischar(varargin{1}) | isnumeric(varargin{1}))
      standard_name = char(standard_name);
   end
   
%% EOF   