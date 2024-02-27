function index = atrname2index(ncfile,name,varargin)
%NC_ATRNAME2INDEX   get index of attribute name from ncfile
%
%   index = atrname2index(ncfile,name)
%
% returns empty if no matching variable is found. Works for 
% global attribites and for variable attribites, where
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
%
% Example:
%
%   index = atrname2index(F,'history')
%   F.Attribute(history)
%
%   index = atrname2index(F.Dataset(1),'standard_name')
%   F.Dataset(1).Attribute(index)
%
%See also: NC_INFO, NC_VARNAME2INDEX, NC_VARFIND

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Deltares
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
      %error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
      %can be variable attributes
   end

%% Do atrname2index

   index     = [];

   %% find index of coordinates attribute
   natr = length(fileinfo.Attribute);
   for iatr=1:natr
   if OPT.debug
      disp([num2str(iatr,'%0.3d'),': ',fileinfo.Attribute(iatr).Name])
   end
   if strcmpi(fileinfo.Attribute(iatr).Name,name)
      index = iatr;
      if ~OPT.debug
         break
      end
   end
   end  
         
%% EOF         