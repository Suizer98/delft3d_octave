function varargout = getICESparameters(code)
%getICESparameters get ICES parametr meta-data
%
%  [code, name, compounds, units] = getICESparameters(<code>)
%
% where code is the ICES ParamterCode to be used in getICESdata.
% Get complete list when omitting input.
%
% Example:
%    [~,name,~,units]=getICESparameters('PSAL')
%
%See also: getICESdata

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: getICESparameters.m 10029 2014-01-17 07:12:19Z boer_g $
% $Date: 2014-01-17 15:12:19 +0800 (Fri, 17 Jan 2014) $
% $Author: boer_g $
% $Revision: 10029 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ices/getICESparameters.m $
% $Keywords$

table = ...
 {'TEMP','Temperature'               ,''       ,'deg C'   ;
  'PSAL','Salinity'                  ,''       ,'psu'     ;
  'DOXY','Oxygen'                    ,''       ,'O2, ml/l';
  'PHOS','Phosphate Phosphorus'      ,'PO4-P'  ,'umol/l'  ;
  'TPHS','Total Phosphorus'          ,'P'      ,'umol/l'  ;
  'AMON','Ammonium'                  ,'NH4-N'  ,'umol/l'  ;
  'NTRI','Nitrite Nitrogen'          ,'NO2-N'  ,'umol/l'  ;
  'NTRA','Nitrate Nitrogen'          ,'NO3-N'  ,'umol/l'  ;
  'NTOT','Total Nitrogen'            ,'N'      ,'umol/l'  ;
  'SLCA','Silicate Silicon'          ,'SiO4-Si','umol/l'  ;
  'H2SX','Hydrogen Sulphide Sulphur' ,'H2S-S'  ,'umol/l'  ;
  'PHPH','Hydrogen Ion Concentration','H'      ,''        ;
  'ALKY','Alkalinity'                ,''       ,'meq/l'   ;
  'CPHL','Chlorophyll a'             ,''       ,'ug/l'    };

if nargin==0
   varargout = {{table{:,1}},{table{:,2}},{table{:,3}},{table{:,4}}};
   return
end

ind = strmatch(lower(code),lower({table{:,1}}));

if isempty(ind)
    error(['''',code,''' not a valid code.'])
else
   varargout = {table{ind,:}};
end