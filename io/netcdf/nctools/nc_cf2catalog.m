function nc_cf_opendap2catalog_loop(varargin)
%NC_CF2CATALOG_loop   loop for creating catalogs in a set of directories (BETA)
%
% wrapper for nc_cf_opendap2catalog.
%
%See also: STRUCT2NC, NC2STRUCT

% TO DO: gather all catalogs from subdirectories into overlying levels

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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

%% which directories to scan

   OPT.load_nc        = 'http://opendap.deltares.nl/thredds/opendap/rijkswaterstaat/';
   OPT.load_nc        = 'F:\opendap\thredds\rijkswaterstaat\';

   OPT.base_nc        = 'F:\opendap\thredds\';
   OPT.serviceBaseURL = 'http://opendap.deltares.nl/thredds/';
   OPT.serviceBase    = 'dodsC/opendap/'; % @ opendap.deltares.nl for THREDDS, not for HYRAX

   OPT.pause          = 0;
   OPT.directories    = [];
   
%% get files   
   
   if isempty(OPT.directories)
   [files,OPT.directories]=findallfiles(OPT.load_nc);
   end
   
%% Directory loop

for idir = 1:length(OPT.directories)

   directory_nc = [OPT.directories{idir} filesep];
   
   OPT.path = directory_nc(length(OPT.base_nc)+1:end);
   
  %disp([directory_nc,'=',OPT.base_nc,'+',OPT.path)

   disp(['Processing   ',num2str(idir,'%0.4d'),'/',num2str(length(OPT.directories),'%0.4d'),': ',directory_nc,filesep]);
   
   nc_cf_opendap2catalog(directory_nc,...
         'save',1,...
     'maxlevel',1,... % this script already handles the directory levels
   'urlPathFcn',@(s) path2os(strrep(s,OPT.base_nc,[OPT.serviceBaseURL,OPT.serviceBase]),'http'));
   
   if OPT.pause
      pausedisp
   end
   
end   

%% EOF
