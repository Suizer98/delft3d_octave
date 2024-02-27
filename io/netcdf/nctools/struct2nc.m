function varargout = struct2nc(outputfile,D,varargin)
%STRUCT2NC   save struct with 1D arrays to netCDF file (beta)
%
%   struct2nc(ncfile,dat    ,<keyword,value>)
%   struct2nc(dat   ,ncfile ,<keyword,value>)
%   struct2nc(ncfile,dat,atr,<keyword,value>)
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric/character data
%   atr    - optional structure of file and variable attributes
%                 atr.att_name.var_name
%            NOT: atr.var_name.att_name
%
% Note that this function has limited applicability only
% because it does the naming of dimensions based on size only
% and not on the actual meaning of the dimension.
%
% - dimensions are swapped to accomodate C convention, so struct2nc does not behave as ncrreate.
% - nc2struct writes char & cellstr  as char, nc2struct reads them as nx1 cellstr, so 
%   nc2struct and nc2struct are not fully inverses of one another.
% - Default file type is netCDF3 classic, for other types see ncwriteschema.
%
% Example 1:
%
%  D.datenum               = datenum(1970,1,1:.1:3);
%  D.eta                   = sin(2*pi*D.datenum./.5);
%  M.terms_for_use         = 'These data can be used freely for research purposes provided that the following source is acknowledged: OET.';
%  M.disclaimer            = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
%  M.units.datenum         = 'time';
%  M.units.eta             = 'meter';
%  M.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
%  M.standard_name.eta     = 'sea_surface_height';
%  struct2nc('file.nc',D,M);
%
% Example 2:
%
%  [D,M.units] = xls2struct('file_created_with_struct2xls.xls');
%  struct2nc('file.nc',D,M);
%
%See also: NC2STRUCT, NCINFO, XLS2STRUCT, CSV2STRUCT, SDLOAD_CHAR, LOAD & SAVE('-struct',...)

% TO DO: allow for meta/attribute info struct: atr.var_name.att_name
% TO DO: pass global attributes as <keyword,value> or as part of M.
% TO DO: fix issue that space is considered as end-of-line

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
% $Id: struct2nc.m 11255 2014-10-21 09:37:10Z gerben.deboer.x $
% $Date: 2014-10-21 17:37:10 +0800 (Tue, 21 Oct 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11255 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/struct2nc.m $
% $Keywords: $

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;
   OPT.debug             = 0;
   OPT.header            = 0;
   OPT.write0dimension   = 1;
   OPT.mode              = 'clobber'; %'classic';% 'classic','64bit_offset','netcdf4-classic','netcdf4' 
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% Units

   if odd(nargin)
       M           = varargin{1};
       varargin(1) = [];
       attnames    = fieldnames(M);
       natt        = length(attnames);
   else
       natt        = 0;
   end
   
   OPT = setproperty(OPT,varargin{:});
   
%% handle legacy

   ver.str  = version('-release');;
   ver.year = str2num(ver.str(1:4));
   
   if ver.year < 2011 % 2011a introduced good HDF for netCDF4
       warning('Please upgrade to R2011a or higher, or use deprecated struct_nc.')
       return
   end   

%% Parse struct to netCDF

   if isstruct(outputfile)
       tmp = D;
       D = outputfile;
       outputfile = tmp;
   end

   fldnames = fieldnames(D);
   nfld     = length(fldnames);

%% 0 Create file

   nc.Name   = '/';
   nc.Format = 'classic';   

%% 1 Add global meta-info to file
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

   for iatt=1:natt
       attname = attnames{iatt};
       if ~isstruct(M.(attname)); % others are variable attributes
           nc.Attributes(iatt) = struct('Name',attname,'Value',  M.(attname));           
       end
   end

%% 2 Create dimensions
%    Do realize automatic - and hence useless - dimension names 
%    violates the self-describing philosphy of netCDF ...

   dimension_lengths = [];
   
   for ifld=1:nfld
       
       fldname = fldnames{ifld};
       
       if iscellstr(D.(fldname))
           D.(fldname) = char(D.(fldname));
       end
       
       if iscell(D.(fldname)) && all(cellfun(@isnumeric, D.(fldname)))
           D.(fldname) = cell2mat(D.(fldname));
       end
       
       dimension_lengths = [dimension_lengths size(D.(fldname))];
       
   end
   
   dimension_lengths = sort(unique(dimension_lengths));
   dimension_lengths = setdiff(dimension_lengths,0); % exclude 0
   for ilen=1:length(dimension_lengths)
       nc.Dimensions(ilen) = struct('Name', ['dimension_length_',num2str(dimension_lengths(ilen))],'Length',dimension_lengths(ilen)); % CF wants x last, which means 1st in Matlab       
   end

%% 3 Create variables
   
   for ifld=1:nfld
       
       fldname = fldnames{ifld};
       
       %disp(['fldname:',fldname,' (',nums2str(size(D.(fldname)),','),')'])
       
       nc.Variables(ifld).Name               = fldname;
       nc.Variables(ifld).Datatype           = class(D.(fldname));
       
       dimensions = [];
       %for idim=1:length(size(D.(fldname))) % NO: Matlab has reverse dimension order !
       for idim=length(size(D.(fldname))):-1:1
           dimension_length = ['dimension_length_',num2str(size(D.(fldname),idim))];
           dimmatch = strmatch(dimension_length, {nc.Dimensions.Name},'exact');
           if ~isempty(dimmatch)
              dimensions(end+1)=dimmatch;
           end
       end
       nc.Variables(ifld).Dimensions = nc.Dimensions(dimensions);
       
       par_att = 0;
       for iatt=1:natt
           attname = attnames{iatt};
           if isstruct(M.(attname)) % others are file attributes
               if isfield(M.(attname),fldname)
                   par_att = par_att + 1;
                   nc.Variables(ifld).Attributes(par_att) = struct('Name',attname,'Value', M.(attname).(fldname));
               end
           end
       end
       
   end
   
   ncwriteschema (outputfile,nc);  
   
%% 5 Fill variables

   for ifld=1:nfld
       
       fldname = fldnames{ifld};
       
       if ~length(D.(fldname))==0
           
           if OPT.debug
              disp(fldname)
              var2evalstr(nc(ifld))
           end
           pm = fliplr(1:length(size(D.(fldname))));
           ncwrite(outputfile, fldname , permute(D.(fldname),pm)); % cannot handle logicals
           
       end
       
   end

%% Pause

   if OPT.pause
    pausedisp
   end

%% EOF