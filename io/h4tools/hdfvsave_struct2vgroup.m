function varargout = hdfvsave_struct2vgroup(file_id,file_name,datastruct,fldname,VGROUP_ID_PARENT)
%HDFVSAVE_STRUCT2VGROUP   save a struct as a HDF Vgroup.
%
%    status = hdfvsave_struct2vgroup(file_id,file_name,datastruct,fldname,VGROUP_ID_PARENT)
%
%   [status,...
%    vgroup_id] = hdfvsave_struct2vgroup(file_id,file_name,datastruct,fldname,VGROUP_ID_PARENT)
%
% Note: do not use HDFVSAVE_STRUCT2VGROUP directly, use through HDFVSAVE.
%
% Follows recipe at:
% <http://hdf.ncsa.uiuc.edu/training/HDFtraining/UsersGuide/Vgroups.fm4.html#27961>
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT


% 2008 Jan 15: added option that saves logical arrays as int8 (when...).
% 2008 Apr 23: added debug option and renamed VGROUP_ID to VGROUP_ID_PARENT
%              to avoid case-sensitive confusion with vgroup_id.
% 2008 May 10: write multi-dimensional structs with fieldname 'F' as 'F(num2str(dimension))'

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

   OPT.save_numeric_array_as_sds = true ; % 0 = as vdata, 1= as sds
   OPT.save_1Dchar_array_as_sds  = false; % 0 = as vdata, 1= as sds attribute (problem: they cannot be attached to Vgroup!!!)
   OPT.save_logicals2integers    = true;  % Reciprokal of save_logicals2integers in HDFVLOAD_SDS2STRUCT.
   OPT.debug                     = 0;

      %%  1 Open the HDF file.

         % to be done at highest level by hdfvsave.m

      %%  2 Initialize the Vgroup interface.
      
         status = hdfv('start',file_id);
      
      %%  3 Create the new vgroup.
      
         % vgroup_id = hdfv('attach',file_id,vgroup_ref,access)
         % vgroup_ref = -1 when a new vgroup is created
         
         vgroup_ref = -1;
      
         vgroup_id  = hdfv('attach',file_id, vgroup_ref , 'w');
         
      %% INSERT VGROUP INTO PARENT VGROUP

         if ~isempty(VGROUP_ID_PARENT)
         ref = hdfv('insert',VGROUP_ID_PARENT, vgroup_id);
         end
         
      
      %%  4 Optionally assign a vgroup name
      %     Note: names need not be unique.
      
         % status = hdfv('setname',vgroup_id,name)

         status = hdfv('setname',vgroup_id,fldname);
      
      %%  5 Optionally assign a vgroup class.
      %     Note: optional
      %     Note: classes are user defined, and not HDF defined.
      
         % status = hdfv('setclass',vgroup_id,class)

      
      %%  6 Inserts data objects.
            
         %% Meta data

         status = hdfv('setattr',vgroup_id,'foo'                ,'foo'); % for soem reason the first attribute fials
         status = hdfv('setattr',vgroup_id,'date_added'         ,datestr(datenum(now)));
         status = hdfv('setattr',vgroup_id,'added_with_library' ,['HDF libray in matlab ',version,]);
         status = hdfv('setattr',vgroup_id,'added_with_software',['hdfvsave.m, hdfvsave_struct2vgroup.m bij G.J. de Boer Dec 2005']);
         status = hdfv('setattr',vgroup_id,'author'             ,'G.J. de Boer');
         

         %% Matlab struct
         
       %  vgroup_ref = hdfv('Queryref',vgroup_id);
       %  status     = hdfv('detach'  ,vgroup_id);
       %  status     = hdfv('end'     ,file_id);
       %
       %  status     = hdfv('start'   ,file_id);
       %  vgroup_id  = hdfv('attach'  ,file_id, vgroup_ref , 'w')

         if ~isempty(datastruct)
         fldnames = fieldnames(datastruct);
         else
         fldnames = [];
         end

         nfield   = length(fldnames);
         
         for ifield = 1:nfield
         
         fldname = char(fldnames{ifield});
         
         %% Structures
            
            if isstruct(datastruct.(fldname))
            
               if length(datastruct.(fldname)) >1
               
               %% Multi-dimensional structure
                  
                  for idim=1:length(datastruct.(fldname))
                     
                     if OPT.debug
                        disp(['hdfvsave_struct2vgroup: isstruct(datastruct.(fldname)): ',fldname,' dimension: ',num2str(idim)])
                        disp(' ')
                     end                     
                  
                     VGROUP_ID_PARENT = []; % parent vgroup
                     
                     % insert more VGroups with the same name
                     % rather then nameless VGroups at top level
                     
                     status = hdfvsave_struct2vgroup(file_id,file_name,datastruct.(fldname)(idim),[fldname,'(',num2str(idim),')'],vgroup_id);   
                     
                  end
                  
               else              
               
                  if OPT.debug
                     disp(['hdfvsave_struct2vgroup: isstruct(datastruct.(fldname)): ',fldname])
                     disp(' ')
                  end
	       
                  % all vdata residing lower in datastruct are 
                  % appended by hdfvsave_struct2vgroup(...) which calls 
                  % append_matrix2vdata(...)
	       
                  status = hdfvsave_struct2vgroup(file_id,file_name,datastruct.(fldname)    ,fldname,vgroup_id);       
                  
               end % length(datastruct) >1                  
            
            %% Numerical data
            
            elseif isnumeric(datastruct.(fldname))
            
               if OPT.debug
                  disp(['hdfvsave_struct2vgroup: isnumeric(datastruct.(fldname)): ',fldname])
                  disp(' ')
               end

               if OPT.save_numeric_array_as_sds
                 status = hdfvsave_matrix2sds  (file_id,file_name,vgroup_id,fldname,datastruct.(fldname));
               else
                 status = hdfvsave_matrix2vdata(file_id,datastruct.(fldname),fldname,vgroup_id);
               end
             
            %% Characters
            
            elseif ischar(datastruct.(fldname))
            
               if OPT.debug
                  disp(['hdfvsave_struct2vgroup: ischar(datastruct.(fldname)): ',fldname])
                  disp(' ')
               end            
              
               if (OPT.save_1Dchar_array_as_sds) & ...
                  (min(size(datastruct.(fldname)))==1)
                  status = hdfvsave_char2sdsatr  (file_id,file_name,VGROUP_ID_PARENT,fldname,datastruct.(fldname));
                  disp(['Saved char field ''',fldname,''' as SDS atr, cannot be attached to a Vgroup'])
               else
                  status = hdfvsave_matrix2vdata (file_id,datastruct.(fldname),fldname,vgroup_id);
                 %disp(['Saved char field ''',fldname,''' as VData'])
               end
 
               if status == -1
 	       error('HDF sdsetattr failed')
               end              

            %% Logicals
            
            elseif islogical(datastruct.(fldname))

               if OPT.debug
                  disp(['hdfvsave_struct2vgroup: islogical(datastruct.(fldname)): ',fldname])
                  disp(' ')
               end

               if OPT.save_logicals2integers
               
                  if OPT.save_numeric_array_as_sds
                  status = hdfvsave_matrix2sds  (file_id,file_name,vgroup_id,fldname,int8(datastruct.(fldname)),...
                                                   {{'original_data_type','logical'}});
                  disp(['Warning: Cell field ''',fldname,''' is logical, for which there is no HDF class. It has been converted to int8.'])
                  else
                  disp(['Warning: Cell field ''',fldname,''' not saved, as it is logical'])
                  end
	       
               else
                  disp(['Warning: Cell field ''',fldname,''' not saved, as it is logical'])
               end            

            %% Cells
            
            elseif iscell(datastruct.(fldname))
            
               disp(['Warning: Cell field ''',fldname,''' not saved, as there is no data class for that in HDF library'])

            end
            
         end % for ifield = 1:nfield
         
      %%  7 Terminate access to the vgroup.
      
         status = hdfv('detach',vgroup_id);
      
      %%  8 Terminate access to the Vgroup interface.
      
         status = hdfv('end',file_id);
         
      %%  9 Close the HDF file.
         
         % to be done at highest level by hdfvsave.m

   if nargout==1
      varargout = {status};
   else
      varargout = {status,vgroup_id};
   end

% disp('finished hdfvsave_struct2vgroup')