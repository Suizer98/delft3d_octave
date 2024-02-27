function varargout = nc2struct(ncfile,varargin)
%NC2STRUCT   load netCDF file with to struct (beta)
%
%   dat      = nc2struct(ncfile,<keyword,value>)
%  [dat,atr] = nc2struct(ncfile,<keyword,value>)
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric/character data
%   atr    - optional structure of file and variable attributes
%
% For NC2STUCT <keyword,value> options /defaults call without arguments: nc2struct() . 
% * exclude:   cell array with subset of variables NOT to load, e.g.: {'a','b'}
% * include:   cell array with subset of variables ONLY to load, e.g.: {'lon','lat'}
% * rename :   cell array describing how to rename variables in netCDF
%              file to variables in struct, e.g.: {{'x','y'},{'x1','x2'}}
% * structfun: apply function handle to each field, e.g. @(x) transpose(x)
%              to turn rows into column vectors and vv, or @(x) maked1d(x)
%
% - dimensions are swapped to accomodate C convention, so struct2nc does not behave as nccreate.
% - nc2struct writes char & cellstr  as char, nc2struct reads them as nx1 cellstr, so 
%   nc2struct and struct2nc are not fully inverses of one another.
% - fieldnames starting with 'time' are automatically converted to matlab
%   datenum in another field starting with 'datenum', based on nc conventions.
%
% Example:
%
%  [dat,atr] = nc2struct('file_created_with struct2nc.nc');
%  [dat,atr] = nc2struct('catalog.nc');
%  [dat,atr] = nc2struct('catalog.nc','exclude',{'x','y'});
%  [dat,atr] = nc2struct('catalog.nc','include',{'lon','lat'});
%
% NOTE: do not use for VERY BIG! files, as your memory will be swamped.
%
%See also: STRUCT2NC, NCINFO, XLS2STRUCT, CSV2STRUCT, SDSAVE_CHAR, LOAD & SAVE('-struct',...)

% TO DO: pass global attributes as <keyword,value> or as part of M.

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc2struct.m 16283 2020-03-04 10:48:18Z l.w.m.roest.x $
% $Date: 2020-03-04 18:48:18 +0800 (Wed, 04 Mar 2020) $
% $Author: l.w.m.roest.x $
% $Revision: 16283 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc2struct.m $
% $Keywords: $

% Behaviour should be as of nc_getall, but without the data being part of M, but in a separate struct D.
% And what about global atts, part of D (NOOOOOOOOO!), or part of M(perhaps), or part of M.nc_global.?

OPT.global2att   = 2; % 0=not at all, 1=as fields, 2=as subfields of nc_global
OPT.time2datenum = 1; % time > datenum in extra variable datenum
OPT.exclude      = {};
OPT.rename       = {{},{}};
OPT.include      = {};
OPT.structfun    = []; % apply transformation, e.g. make1D(), (:) or transpose()
OPT.disp         = 1; % 1=enabled, 0=disabled

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

%% handle legacy

   ver.str  = version('-release');
   ver.year = str2double(ver.str(1:4));
   
   if ver.year < 2011 % 2011a introduced good HDF for netCDF4
       warning('Please upgrade to R2011a or higher, or use deprecated nc_struct.')
       return
   end

%% Load file info

   % get info from ncfile
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = ncinfo(ncfile);
   end
   
%% get all variable names

if isempty(OPT.include)
   OPT.include = {fileinfo.Variables.Name};
end
   
%% Load all fields

  D = [];

   ndat = length(fileinfo.Variables);
   for idat=1:ndat
      fldname     = fileinfo.Variables(idat).Name;
      if ~any(strmatch(fldname,OPT.exclude, 'exact')) && ...
          any(strmatch(fldname,OPT.include, 'exact'))
         fldname_nc = fldname;
         if any(strmatch(fldname,OPT.rename{1}, 'exact'))
            j = strmatch(fldname,OPT.rename{1}, 'exact');
            fldname = OPT.rename{2}{j};
         end
         ndim = length(fileinfo.Variables(idat).Dimensions);
         pm = ndim:-1:1;         
         %for idim=1:length(fileinfo.Variables(idat).Dimensions)
         %    disp([fldname,':',num2str(idim),' ',num2str(fileinfo.Variables(idat).Dimensions(idim).Length)])
         %end
         D.(fldname) = ncread(fileinfo.Filename,fldname_nc);
         if OPT.time2datenum
            if strncmpi(fldname_nc,'time',4)
                if length(fldname_nc)<=4;
                    fldname='datenum';
                else
                    fldname=['datenum',fldname_nc(5:end)];
                end
                try
                    D.(fldname) = ncread_cf_time(fileinfo.Filename,fldname_nc);
                    if OPT.disp
                        units = ncreadatt(fileinfo.Filename,'time','units');
                        disp([mfilename,': added extra variable with Matlab datenum=f(',fldname,')'])
                    end
               end
            else
                if ~isempty(fileinfo.Variables(idat).Attributes);
                j = strmatch('standard_name',{fileinfo.Variables(idat).Attributes.Name}, 'exact');
                    if ~isempty(j)
                    %Try to covert non-standard time field, but it must at least be numeric!
                        if strcmpi(fileinfo.Variables(idat).Attributes(j).Value,'time') && ~strcmpi(fileinfo.Variables(idat).Datatype,'char');
                            if length(fldname_nc)<=4;
                                fldname='datenum';
                            else
                                fldname=['datenum',fldname_nc(5:end)];
                            end
                            D.(fldname) = ncread_cf_time(fileinfo.Filename,fldname_nc);
                            if OPT.disp
                               disp([mfilename,': added extra variable with Matlab datenum=f(',fldname,')'])
                            end
                        end
                    end
                end
            end
         end
         if length(pm)>1
            D.(fldname) = permute(D.(fldname),pm);
         end         
         if ischar(D.(fldname))
%             if length(size(D.destination)) <= 2
            D.(fldname) = cellstr(D.(fldname)); % always n x 1, can be wrong order if mat file was 1 x n
%             end
         end
      end % exclude/include

   end % ivar
   
if nargout==1

   varargout = {D};
   
else

   ndat = length(fileinfo.Variables);
   if OPT.global2att>0
   
%% attributes
   
   for iatt=1:length(fileinfo.Attributes);
      attname  = fileinfo.Attributes(iatt).Name;
      attname  = mkvar(attname); % ??? Invalid field name: 'CF:featureType'.
      if     OPT.global2att==1;
         M.(attname) = fileinfo.Attributes(iatt).Value;
      elseif OPT.global2att==2
         M.nc_global.(attname) = fileinfo.Attributes(iatt).Value; % netcdf.getConstant('NC_GLOBAL')
      end
   end
   end
   
%% data
   
   for idat=1:ndat
      fldname     = fileinfo.Variables(idat).Name;
      if ~any(strmatch(fldname,OPT.exclude, 'exact')) & ...
          any(strmatch(fldname,OPT.include, 'exact'))
         if any(strmatch(fldname,OPT.rename{1}, 'exact'))
            j = strmatch(fldname,OPT.rename{1}, 'exact');
            fldname = OPT.rename{2}{j};
         end
         for iatt=1:length(fileinfo.Variables(idat).Attributes);
                      attname  = fileinfo.Variables(idat).Attributes(iatt).Name;
                      attname  = mkvar(attname); % ??? Invalid field name: '_FillValue'.
         M.(fldname).(attname) = fileinfo.Variables(idat).Attributes(iatt).Value;
         end
      end % exclude/include
   end
   
%% Apply function

   if ~isempty(OPT.structfun)
      fldnames = fieldnames(D);
      for i=1:length(fldnames)
          D.(fldnames{i}) = OPT.structfun(D.(fldnames{i}));
      end
   end
 
%%
   
   if nargout<2
   varargout = {D};
   else
   varargout = {D,M};
   end

end

%% EOF