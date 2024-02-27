function standard_name = sdn2cf(varargin)
%SDN2CF   convert between SDN vocab code and CF standard_name and units
%
%   [standard_name, units] = sdn2cf(sdn)
%
% Examples:
%
%   [standard_name, units] = sdn2cf('<object>SDN:P011::PRESPS01</object><units>SDN:P061::UPDB</units>')
%
% Note: calling SDN2CF numerous times is rather slow.
%
%See web: IDsW, CF standard_name table, www.waterbase.nl/metis
%See also: OceanDataView, SDN_VERIFY, NERC_VERIFY

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

%% TO DO: use *.csv instead of *.xls

%% mapping table

   OPT.xlsfile       = [filepathstr(mfilename('fullpath')),filesep,'sdn2cf.xls'];
   DAT.standard_name = xls2struct(OPT.xlsfile,'standard_name');
   DAT.units         = xls2struct(OPT.xlsfile,'units');

%% input

   sdn         = varargin{1};
   if ischar(sdn)
      sdn = cellstr(sdn);
   end
   
%% map

for ii=1:length(sdn)   
   
   s1 = strfind(sdn{ii},'<subject>');
   s2 = strfind(sdn{ii},'</subject>');
   
   o1 = strfind(sdn{ii},'<object');
   o2 = strfind(sdn{ii},'</object>');
   
   u1 = strfind(sdn{ii},'<units>');
   u2 = strfind(sdn{ii},'</units>');
   
   subject = (sdn{ii}(s1+9:s2-1));
   object  = (sdn{ii}(o1+8:o2-1));
   units   = (sdn{ii}(u1+7:u2-1));
   
   for jj=1:length(DAT.standard_name)
      code                 = DAT.standard_name{jj};
      index                = strmatch(upper(code),upper(object));
      standard_name{i}     = DAT.standard_name{ii};
   end
   
   for jj=1:length(DAT.units)
      code                 = DAT.units{jj};
      index                = strmatch(upper(code),upper(units));
      units{i}             = DAT.units{ii};
   end
   
end   

%% EOF   