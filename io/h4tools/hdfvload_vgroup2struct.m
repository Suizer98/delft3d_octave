function varargout = hdfvload_vgroup2struct(finfo,file_name,hdftree,varargin)
%HDFVLOAD_VGROUP2STRUCT   load vgroup into matlab struct
%
%    [DATA                  ] = hdfvload_vgroup2struct(finfo,file_name,hdftree)
%    [DATA,ATTRIBUTES       ] = hdfvload_vgroup2struct(finfo,file_name,hdftree)
%    [DATA,ATTRIBUTES,status] = hdfvload_vgroup2struct(finfo,file_name,hdftree)
%
% Note: do not use HDFVLOAD_VGROUP2STRUCT directly, use through HDFVLOAD.
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT


% 2008 May 10: added   mkvar(fldname)
% 2008 Jun 06: added option to interpret string with () as multidimensional struct (does not work yet)
%              therefore optionally removed mkvar(fldname), because it conflicts with saving 
%              multi-dimensional structs as G(1) and G(2) etc.
% 2008 Jun 06: added hdftree for logging depth in HDf file
%              and debug switch

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

   OPT.fldname                = [];%'mkvar'; or 'dim';
   OPT.debug                  = 1;
   OPT.multidimensionalstruct = 0;

   OPT = setproperty(OPT,varargin);

   if OPT.debug
      disp(['loading Vgroup : ',hdftree]);
   end

   [DATA ,ATTRIBUTES,status] = hdfvload_vdatas2struct (finfo,file_name,hdftree,'debug',OPT.debug);

   [DATA1,ATTRIBUTES,status] = hdfvload_sds2struct    (finfo,file_name,hdftree,'debug',OPT.debug);
   
   if isempty(DATA)
      DATA = DATA1; % is empty when DATA1 is empty
   elseif isempty(DATA1)
      % DATA = DATA;
   else
      DATA = mergestructs(DATA,DATA1);
      clear DATA1;
   end

   nVgroup           = length(finfo.Vgroup);

   for i=1:nVgroup
   
      if OPT.multidimensionalstruct
      
         fldindex = 1;
         fldname  = finfo.Vgroup(i).Name;
         
         % Note: do not use mkvar() to allow for brackets, 
         % and anyway if it was written by hdfvsave_struct2vgroup 
         % it came from a matlab struct, and the fldname is a valid struct name .
         
      %% Check whether vgroupname represents a 
      %  muldi-dimensional array element.
      
         bracket1 = strfind(fldname,'(');
         bracket2 = strfind(fldname,')');
         if ~isempty(bracket1)
            if ~isempty(bracket2)
               fldindex = fldname(bracket1+1:bracket2-1); % before fldname = ...
               fldname  = fldname(         1:bracket1-1);
            end
         end
         
      %% Load

         [      DATA.(fldname)(fldindex),...
          ATTRIBUTES.(fldname)(fldindex)] = hdfvload_vgroup2struct(finfo.Vgroup(i),file_name,[hdftree,filesep,fldname]);
         
      else
      
         fldname  = mkvar(finfo.Vgroup(i).Name);

      %% Load
         [      DATA.(fldname),...
          ATTRIBUTES.(fldname)] = hdfvload_vgroup2struct(finfo.Vgroup(i),file_name,[hdftree,filesep,fldname]);
         
         end
   
   end
   
   status = 1;

if     nargout==1
   varargout = {DATA};
elseif nargout==2
   varargout = {DATA,ATTRIBUTES};
elseif nargout==3
   varargout = {DATA,ATTRIBUTES,status};
end

% disp('finished hdfvload_vgroup2struct')

%% EOF   
