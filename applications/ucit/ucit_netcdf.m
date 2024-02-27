function varargout = ucit_netcdf(varargin)
%ucit_netcdf   gui for data extraction and manipulation from OPeNDAP servers
%
%   ucit_netcdf()
%
% launches a GUI for coastal analysis that retrieves data from
% netCDF files at, amongst others, the OPeNDAP server of Deltares:
% <a href="http://opendap.deltares.nl/">opendap.deltares.nl</a>
%
% For working faster with local copies (caches) of netCDF files,
% please configure new sets in \ucit\gui\settings\UCIT_getDatatypes.m
% and download the local cache with OPENDAP_GET_CACHE or via:
% http://publicwiki.deltares.nl/display/OET/OPeNDAP+caching+on+a+local+machine
%
%See also: snctools, ddb, opendap_get_cache

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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

   % $Id: ucit_netcdf.m 9099 2013-08-23 09:16:19Z boer_g $ 
   % $Date: 2013-08-23 17:16:19 +0800 (Fri, 23 Aug 2013) $
   % $Author: boer_g $
   % $Revision: 9099 $
   
% TO DO: add points of timeseries from opendap.deltares.nl
% TO DO: add lines  of timeseries from opendap.deltares.nl
% TO DO: compile into stand-alone release version

%% Add java paths for snc tools
if isdeployed
%     pth=[ctfroot filesep 'checkout' filesep 'OpenEarthTools' filesep 'trunk' filesep 'matlab' filesep 'io' filesep 'netcdf' filesep 'toolsUI-4.1.jar'];
%     disp(['SNC jar file is : ' pth]);
%     javaaddpath(pth);
    setpref ('SNCTOOLS','USE_JAVA'       ,1); % This requires SNCTOOLS 2.4.8 or better
    setpref ('SNCTOOLS','PRESERVE_FVD'   ,0); % 0: backwards compatibility and consistent with ncBrowse
   %setpref ('SNCTOOLS','USE_NETCDF_JAVA',1); % vaklod8igen 2012 oes not work with native R2012 netcdf opendap
end

%% Open the UCIT console

   fig = UCIT_makeUCITConsole; set(fig,'visible','off')
 
   %% Use system color scheme for figure:
   
   set(fig,'name','UCIT 2.0 - Universal Coastal Intelligence Toolkit (netCDF/OPeNDAP database explorer)')
   set(fig,'Units','normalized')
   set(fig,'Position', UCIT_getPlotPosition('LR'))
   
%% Generate a structure of handles to pass to callbacks, and store it.
   
   handles = guihandles(fig);
   guidata(fig, handles);
   
   if nargout > 0
       varargout{1} = fig;
   end
   
   
%% Initialise datafields 
%  reset all 4 popup values for both types (1: transects, 2: grids)
   
   UCIT_resetValuesOnPopup(1,1,1,1,1,1)
   UCIT_resetValuesOnPopup(2,1,1,1,1,1)
   UCIT_resetValuesOnPopup(3,1,1,1,1,1)
   UCIT_resetValuesOnPopup(4,1,1,1,1,1)
   
%% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   
   disp('finding available transect data ...')
   
       UCIT_loadRelevantInfo2Popup(1,1)
   
%% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   
   disp('finding available grid data ...')
   try
       UCIT_loadRelevantInfo2Popup(2,1)
   end
   
%% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   
   disp('finding available line data ...')
   try
       UCIT_loadRelevantInfo2Popup(3,1)
   end
   
%% set for proper type (1: transects, 2: grids, 3: lines, 4: points) first popup menu: DataType
   
   disp('finding available point data ...')
   try
       UCIT_loadRelevantInfo2Popup(4,1)
   end
   
   set(fig,'visible','on');
   
%% change icon  (dll will not work in future versions of matlab)
   
   try
      figure(fig);icon(101, get(fig,'name'), which('Deltares_logo_32x32.ico'));
   end
   