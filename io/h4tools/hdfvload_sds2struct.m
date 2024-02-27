function varargout = hdfvload_sds2struct(finfo,file_name,hdftree,varargin)
%HDFVLOAD_SDS2STRUCT      load an HDF SDS set to a sub-structure
%
%    [DATA                  ] = hdfvload_sds2struct(finfo,...)
%    [DATA,ATTRIBUTES       ] = hdfvload_sds2struct(finfo,...)
%    [DATA,ATTRIBUTES,status] = hdfvload_sds2struct(finfo,...)
%
% Note: do not use HDFVLOAD_SDS2STRUCT directly, use through HDFVLOAD.
%
%    [..] = hdfvload_sds2struct(finfo,file_name,hdftree)
%    [..] = hdfvload_sds2struct(finfo,file_name,hdftree,<keyword,value>)
%
% Where the following <keyword, value> have been implemented:
%
% * debug                  0/1 determines whether to log loading to command line (default 1).
% * save_logicals2integers 0/1 determines whether to transform int8 to logical (~int2),
%                          for which HDF has no datatype. Reciprokal of option
%                          save_logicals2integers in HDFVSAVE_STRUCT2VGROUP. (default 1)
% * sdsselection           cell array of SDS names to load (default all SDS are loaded)
%
% Do not use directly, use through HDFVLOAD.
%
% Calls sdsid2mat(...) to read the SDS as the reciprocal function 
% mat2sdsid(...) was used to write the SDS. (To avoid flipping of dimensions).
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT


% 2006 Nov 13 : Added warning when field name starts with a number
%               and add letter 'x' to make it a valid field name.
% 2008 Jan 15 : added option that reads int8 arrays as logical arrays (when...).
% 2008 Jun 06 : added hdftree for logging depth in HDf file
%               and debug switch
% 2008 Jul 03 : added <keyword,value> pairs for optional debug logging
% 2008 Aug 10 : added keyword for selective loading and updated comments.

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/,
%   http://www.fsf.org/
%   --------------------------------------------------------------------

%% Set defaults for keywords

   OPT.save_logicals2integers  = true;
   OPT.debug                   = 1;
   OPT.sdsselection            = [];
   
%% Cycle keywords in input argument list to overwrite default values.

   OPT = setproperty(OPT,varargin);   
%% Initialize

   DATA       = [];
   ATTRIBUTES = [];

   %% DO not load numeric fields like this:
   %  It results in flipped dimensions

   % nSDS  = length(finfo.SDS);
   % 
   % if nSDS > 0
   %    for idata = 1:nSDS
   %    
   %       fldname        = finfo.SDS(idata).Name;
   %       
   %       DATA.(fldname) = hdfread(finfo.SDS(idata));
   %      
   %    end
   % end

   if isfield(finfo,'SDS')

   %% Open the file

      access_mode = 'read';
      sd_id = hdfsd('start', file_name, access_mode);
      if sd_id == -1
        error('HDF sdstart failed')
      end
      
   %% Cycle all SDS

      nSDS  = length(finfo.SDS);
      
      if nSDS > 0
      
         for idata = 1:nSDS
      
         fldname        = finfo.SDS(idata).Name;
         
         if isempty(OPT.sdsselection) | any(strcmpi(OPT.sdsselection,fldname))
         
            if ~strcmpi(fldname,mkvar(fldname))
               disp(['Warning: hdfvload_sds2struct: changed field name from ',fldname,' to ',mkvar(fldname)])
               fldname = mkvar(fldname);
            end
            
            %% get sds ID from index (which also opens it 
            %  so it needs to be closed as well, which si done with 'endaccess')
            
            sds_index = finfo.SDS(idata).Index;
            sds_id    = hdfsd('select',sd_id, sds_index);
            
            %% sds SDS data with sdsid2mat(...) which is the
            %  reciprocal of mat2sdsid(...) with which the data set was created.
      	    
            [name,...
             DATA.(fldname),...
             ATTRIBUTES.(fldname),...
             dims] = sdsid2mat(sd_id, sds_id);
             
            status = hdfsd('endaccess',sds_id);
            
            %% Conditionally transform int8 to logical
            
            if OPT.save_logicals2integers
               attr = finfo.SDS(idata).Attributes;
               nattr = length(attr);
               for iattr = 1:nattr
                  if strcmp(finfo.SDS(idata).Attributes(iattr).Name,'original_data_type')
                  if strcmp(finfo.SDS(idata).Attributes(iattr).Value,'logical')
                     DATA.(fldname) = logical(DATA.(fldname));
                  end
                  end
               end
            end % OPT.save_logicals2integers
      	    
            if OPT.debug
               disp(['loaded  SDS    : ',hdftree,filesep,fldname])
            end
	    
         else
         
            if OPT.debug
               disp(['skipped SDS    : ',hdftree,filesep,fldname])
            end         

         end
               
         end % for idata = 1:nSDS 

      end % if nSDS > 0
      
   %% close the file

      status = hdfsd('end',sd_id);
      if sd_id == -1
        error('HDF sdend failed')
      end
      
      status = 1;   
      
   else
   
      status = 0;   

   end % if isfield(finfo,'SDS')

   
   if     nargout ==1
      varargout = {DATA};
   elseif nargout ==2
      varargout = {DATA,ATTRIBUTES};
   elseif nargout ==3
      varargout = {DATA,ATTRIBUTES,status};
   end
   
% disp('finished hdfvload_sds2struct')

%% EOF   
