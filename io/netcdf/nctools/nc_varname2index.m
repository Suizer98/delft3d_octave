function index = varname2index(ncfile,name,varargin)
%NC_VARNAME2INDEX   get index of variable name from ncfile
%
%   index = varname2index(ncfile,name)
%
% returns empty if no matching variable is found, where
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
%
% Example:
%
%   index = varname2index(F,'latitude')
%
%   F.Dataset(index)
%
%See also: NC_INFO, NC_ATRNAME2INDEX, NC_VARFIND

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_varname2index.m 2773 2010-07-01 21:58:47Z boer_g $
% $Date: 2010-07-02 05:58:47 +0800 (Fri, 02 Jul 2010) $
% $Author: boer_g $
% $Revision: 2773 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_varname2index.m $
% $Keywords: $

%%
   OPT.debug = 0;
   OPT       = setproperty(OPT,varargin{:});
   
%% Load file info

   %% get info from ncfile
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = nc_info(ncfile);
   end
   
   %% deal with name change in scntools: DataSet > Dataset
   if     isfield(fileinfo,'Dataset'); % new
     fileinfo.DataSet = fileinfo.Dataset;
   elseif isfield(fileinfo,'DataSet'); % old
     fileinfo.Dataset = fileinfo.DataSet;
     disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
   else
      error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
   end

%% Do varname2index

   index     = [];

   %% find index of coordinates attribute
   nvar = length(fileinfo.Dataset);
   for ivar=1:nvar
   if OPT.debug
      disp([num2str(ivar,'%0.3d'),': ',fileinfo.Dataset(ivar).Name])
   end
   if strcmpi(fileinfo.Dataset(ivar).Name,name)
      index = ivar;
      if ~OPT.debug
         break
      end
   end
   end  
         
%% EOF         