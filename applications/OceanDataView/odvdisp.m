function odvdisp(D)
%ODVDISP    display contents of ODV struct
%
%   odvdisp(D)
%
% displays content of  ASCII file in Ocean Data Viewer (ODV) format
% that was read by ODVREAD into structure D.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
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

% $Id: odvdisp.m 8909 2013-07-10 16:24:17Z boer_g $
% $Date: 2013-07-11 00:24:17 +0800 (Thu, 11 Jul 2013) $
% $Author: boer_g $
% $Revision: 8909 $
% $HeadURL
% $Keywords:

  %disp('error: ODVREAD is still a test project!')

  %disp('META-INFO:')
   
   disp(['META-INFO: ',pad('filename',12,' '),':',D.file.name])
   disp(['           ',pad('filesize',12,' '),':',num2str(D.file.bytes)])
   
   disp('VARIABLES: ')
   
   for ivar=1:length(D.local_name)
   
   disp([num2str(ivar,'%0.2d'),' ',D.local_name{ivar}])
  %disp(['   standard_name:    ',' ',D.standard_name{ivar}])
   disp(['   sdn_standard_name:',' ',D.sdn_standard_name{ivar}])
   disp(['   sdn_units:        ',' ',D.sdn_units{ivar}])
   disp(['   sdn_long_name:    ',' ',D.sdn_long_name{ivar}])
   
   end

%% EOF