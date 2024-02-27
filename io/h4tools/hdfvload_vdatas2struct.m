function varargout = hdfvload_vdatas2struct(finfo,file_name,hdftree,varargin)
%HDFVLOAD_VDATAS2STRUCT   load an HDF vdata set to a sub-structure
%
%    [DATA                  ] = hdfvload_vdatas2struct(finfo,file_name,hdftree)
%    [DATA,ATTRIBUTES       ] = hdfvload_vdatas2struct(finfo,file_name,hdftree)
%    [DATA,ATTRIBUTES,status] = hdfvload_vdatas2struct(finfo,file_name,hdftree)
%
% Note: do not use HDFVLOAD_VDATAS2STRUCT directly, use through HDFVLOAD.
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT

% 2008 Mar 10 : capture error for empty data field
% 2008 May 07 : updated fix above for lentgh >0 instead of length>1 to read 1-letter chars correctly.
% 2008 Jun 06 : added hdftree for logging depth in HDf file
%               and debug switch
% 2008 Jul 03 : added <keyword,value> pairs for optional debug logging
% 2008 Aug 10 : added keyword for selective loading and updated comments.

%   --------------------------------------------------------------------
%   Copyright (C) 2005+ Delft University of Technology
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

   %% Set defaults for keywords

   OPT.debug                   = 1;
   OPT.vdataselection          = [];
   
   %% Cycle keywords in input argument list to overwrite default values.

   iargin = 1;
   
   while iargin<=nargin-3,
     if isstruct(varargin{iargin})
        OPT = mergestructs('overwrite',OPT,varargin{iargin});
     elseif ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'debug'         ;iargin=iargin+1;OPT.debug          = varargin{iargin};
       case 'vdataselection';iargin=iargin+1;OPT.vdataselection = varargin{iargin};
       otherwise
          error(['Invalid string argument: ''',varargin{iargin},'''']);
       end
     end;
     iargin=iargin+1;
   end; 
   
   %% Initialize
   
   DATA        = [];
   ATTRIBUTES  = [];

   %% Load numeric fields

   if isfield(finfo,'Vdata')

      nVdata  = length(finfo.Vdata);
      
      if nVdata > 0
         for idata = 1:nVdata
         
            fldname        = finfo.Vdata(idata).Name;
            
            if isempty(OPT.vdataselection) | any(strcmpi(OPT.vdataselection,fldname))

               %% capture error when the data field is empty
               if finfo.Vdata(idata).NumRecords >0
               datafield      = hdfread(finfo.Vdata(idata));
               DATA.(fldname) = datafield{1};
               else
               DATA.(fldname) = [];
               end
               
               if OPT.debug
                  disp(['loaded  Vdata  : ',hdftree,filesep,fldname])
               end
               
            else
         
               if OPT.debug
                  disp(['skipped Vdata  : ',hdftree,filesep,fldname])
               end         

            end               

         end
      end
      
      %% Load attributes as character fields
      
      if nargout>1
      
         if isfield(finfo,'Ref')
         
            %% Open file, interface and vgroup

            file_id        = hdfh('open'  ,finfo.Filename,'DFACC_READ',0); % 0 = default data descriptors, remember to close it later
            status         = hdfv('start' ,file_id); % remember to end it later
            
            %% Refs are in finfo struct

            %[refs,count]   = hdfv('lone'  ,file_id,1); % works only ...
            %[refs,nref ]   = hdfv('lone'  ,file_id,count);
            
            vgroup_id      = hdfv('attach',file_id,finfo.Ref, 'r'); % remember to detahc it later
         
            nattrs         = hdfv('nattrs',vgroup_id);
            
            %% Chars are also taken care of as arrays
            
            for iattr   = 1:nattrs
            
               [name,data_type,count,nbytes,status] = hdfv('attrinfo',vgroup_id,iattr);
               [value,status] = hdfv('getattr',vgroup_id,iattr);
               
               if ~isempty(name)
                  ATTRIBUTES.(char(name)) = value;
               end
            
            end
               
            %% Close file, interface and vgroup

            status         = hdfv('detach',vgroup_id);
            status         = hdfv('end'   ,file_id);
            status         = hdfh('close' ,file_id); % 0 = default data descriptors
         
         end % if isfield(finfo,'Ref')
         
      end % if nargout>1

   end % if isfield(finfo,'Vdata')
   
   status = 1;   
   
   if     nargout ==1
      varargout = {DATA};
   elseif nargout ==2
      varargout = {DATA,ATTRIBUTES};
   elseif nargout ==3
      varargout = {DATA,ATTRIBUTES,status};
   end
   
% disp('finished hdfvload_vdatas2struct')

%% EOF   
