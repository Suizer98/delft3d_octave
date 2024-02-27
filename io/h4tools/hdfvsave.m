function varargout = hdfvsave(file_name,datastruct,varargin)
%HDFVSAVE                 save multi-layered Matlab struct as HDF4 file.
%
%    hdfvsave(file_name,datastruct)
%
%    hdfvsave(file_name,datastruct,                 <keyword, value>)
%    hdfvsave(file_name,datastruct,meta_info_struct,<keyword, value>)
%
% where the following case-insensitive <keyword, value> pairs  have been implemented:
%
% * overwrite_append  'o<verwrite>' = overwrite
%                     'c<ancel>'    = cancel
%                     'p<rompt>'    = prompt (default, after which o/a/c can be chosen)
%                     'a<ppened>'   = append (no recommended as HDF is VERY inefficient 
%                                     due to disk space fragmentation when appending data.)
%
% * vgroup_name        FUTURE
% * level              0 puts 1 dimensonal datastruct at     highest level in HDF file
%                      1 puts 1 dimensonal datastruct at 2nd highest level in HDF file 
%                      in a nameless VGROUP (default for multidimensional datastruct)
%
% HDFVSAVE without arguments returns struct with default <keyword, value> settings.
%
% status = hdfvsave(...) returns a status number 
%  0 if succesfull, -2 when cancelled, -1 when HDF libary failed
%
% Writes a matlab multi-layered struct with substructs 
% to a HDF Vgroup/Vdata HDF4 file. Allowed fields are:
% - numeric fields (saved as SDS or Vdata)
% - char fields with ascii values 0 up to 255 (saved as Vdata)
%
% Limitations / capabilities :
%
% - Cell fields are not allowed.
%
% - Logical fields are written to file as int8 (in SDS mode only, not in VDATA mode)
%   with attribute 'original_data_type'='logical'.
%
% - For numeric arrays saved as Vdata only 2D arrays are saved AND loaded 
%   correctly, more dimensions are always squeezed and saved as a 2D array,
%   and thus need to be reshaped to obtain the original dimensions and sizes.
%   The original sizes and shapes thus need to be known when loading. 
%   Saving these Vdata have succesfully been tested for 24 dimensions.
%   
% - Numeric arrays saved as SDS have succesfully been tested for 24 
%   dimensions, they load and save with correct sizes and dimensions.
%
% - Character arrays (1D and 2D) are saved as Vdatas.
%   Characters 256 and higher are not supported. Characters are written
%   in the range of the ascii characters 0 t0 256 in the 
%   unsigned character data type. Has been tested succesfully for 2D arrays.
%
% When an unsupported field is encountered, an warning (no error)
% is displayed, and only the supported fields are written to file.
%
% NOTE: While in matlab fieldnames in a struct should be unique,
% Vgroup names and SDS names in a HDF file are not unique, only the 
% identification numbers are unique. So appending an SDS/Vgroup/VData with 
% the same name as an exisiting object of the same class, does not lead
% to overwriting, but to coexistance. When loading based on vgroup_name, this
% leads to confusion. This is the full responsiblilty of user of this functions.
% When loading such such an ambigous HDF file, all vgroups encountered 
% are returned as a multidimensional field.
% - When hdfvsave is used in append mode, such confusion can arise. 
% - Equal field names are not allowed in matlab struct, but multidimensional
%   fields are written to HDF as Vgroups with the same name.
%   When saving and loading multidimensional structs, the loaded indices do 
%   not match the saved ones.
%
% All functions and subfunctions are built using the instructions at:
% <http://hdf.ncsa.uiuc.edu/training/HDFtraining/UsersGuide/>
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT


% When loading such such an ambigous HDF file, only the vgroup that was 
% encountered latest is returned as a field, any previous ones are overwritten. So 
% only when hdfvsave is used in append mode, such confusion can arise. An ambiguous
% HDF file can never be written with hdfvsave at once, as equal field names are 
% not allowed in matlab structs.

% 2006 Jan 18: added check for overwriting, append possibility
% 2006 Nov 13: added option to add separate user defined struct as meta info to hdf file.
% 2008 Jan 15: added option that saves logical arrays as int8 (when...).
% 2008 Mar 07: Renamed created_as New_Overwrite_Append to be a valid matlab field name
% 2008 Mar 07: Do not create file attributes (e.g. filename) when a data field with the same exists
% 2008 Apr 08: Added keywords
% 2008 Apr 23: Save mutidimension structs per dimension as one nameless Vgroup each
% 2008 Apr 23: Do not create file attributes (e.g. filename) when a data field with the same exists (now correct)
% 2008 Jun 20: removed option to have as 3rd argument as o<verwrite>, a<ppend>
% 2008 Aug 13: repaired keyword value cycling, and fixed overwrite_append to allow for longer, case-insentisive value strings.

% TO DO: save below a sub V group
% TO DO: save also SD annotation into main struct ?
% TO DO  save 1D char array not as vdata but as annotation, so you can read in hdftool
% TO DO: save annotation at file level (date, author)
% TO DO: call mkpath before saving, to allow saving in a non-existent directory (as option)

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
   OPT.add_annotation            = true;  % setting sds attributes does not remove older attributes >> disk space fragmentation
   OPT.save_logicals2integers    = true;
   OPT.overwrite_append          = 'p'; % prompt
   OPT.level                     = 0;
   OPT.debug                     = 0;

%% Deal optional arguments

   if nargin==1
      error('syntax: HDFVSAVE(file_name,datastruct,<...>) ')
   else
      if odd(nargin)
          meta_info = varargin{1};
          iarg      = 2;
      else      
          meta_info = [];
          iarg      = 1;
      end
      
      %% remaining number of arguments is always even now
      while iarg<=nargin-2,
          switch lower ( varargin{iarg})
          % all keywords lower case
          case 'save_numeric_array_as_sds' ;iarg=iarg+1;OPT.save_numeric_array_as_sds = varargin{iarg};
          case 'save_1Dchar_array_as_sds'  ;iarg=iarg+1;OPT.save_1Dchar_array_as_sds  = varargin{iarg};
          case 'add_annotation'            ;iarg=iarg+1;OPT.add_annotation            = varargin{iarg};
          case 'save_logicals2integers'    ;iarg=iarg+1;OPT.save_logicals2integers    = varargin{iarg};
          case 'overwrite_append'          ;iarg=iarg+1;OPT.overwrite_append          = varargin{iarg};
          case 'level'                     ;iarg=iarg+1;OPT.level                     = varargin{iarg};
          case 'debug'                     ;iarg=iarg+1;OPT.debug                     = varargin{iarg};
          otherwise
            error(sprintf('Invalid string argument (caps?): "%s".',varargin{iarg}));
          end
          iarg=iarg+1;
      end
   end
   
%% Return default aguments (with 0 as arg, because 0 args => input GUI)

   if nargin==0
      varargout = {OPT};
      return
   end   

%%  1a. Check the HDF file(name).

   status    = 0;

   if isempty(strfind('oacp',lower(OPT.overwrite_append(1))))
      error('overwrite_append should be o/a/c/p')
   end

   % file_id = hdfh('open',file_name,access,n_dds)
   if exist(file_name,'file')==2
      
      FILEexists = 1;
      
      if strcmpi(OPT.overwrite_append(1),'p')
         disp(['File ',file_name,' alreay exists. '])
         OPT.overwrite_append = input(['Overwrite/append/cancel ? (o/a/c): '],'s');
         % for some reason input in Matlab R14 SP3 removes slashes
         % OPT.overwrite_append = input(['File ',file_name,' alreay exists. Overwrite/append/cancel ? (o/a/c)'],'s');
         while isempty(strfind('oac',lower(OPT.overwrite_append(1))))
             OPT.overwrite_append = input(['Overwrite/append/cancel ? (o/a/c): '],'s');
         end
      end
      
      if strcmpi(lower(OPT.overwrite_append(1)),'o')
         disp (['File ',file_name,' overwritten as it alreay exists.'])
      end      
      
      if strcmpi(lower(OPT.overwrite_append(1)),'a')
         disp (['Data appended to file ',file_name,' as it alreay exists.'])
      end  
      
      if strcmpi(lower(OPT.overwrite_append(1)),'c')
         if nargout==0
            error(['File ',file_name,' not saved as it alreay exists.'])
         else
            status = -2;
            disp(['File ',file_name,' not saved as it alreay exists.'])
         end
      end        
      
   else
      FILEexists           = 0;
      OPT.overwrite_append = 'o'; % create
   end
   
   %% http://hdf.ncsa.uiuc.edu/training/HDFtraining/UsersGuide/Fundmtls.fm2.html#29514
   %  TABLE 2B - File Access Code Flags
   %  DFACC_READ     1 Read access
   %  DFACC_WRITE    2 Read and write access
   %  DFACC_CREATE   4 Create with read and write access
   
   if     strcmpi(OPT.overwrite_append(1),'a')
      access_mode = 'DFACC_WRITE';
   elseif strcmpi(OPT.overwrite_append(1),'o')
      access_mode = 'DFACC_CREATE';
   end

%%  1b. Open

if status >= 0

   %% Follows recipe at:
   %  http://hdf.ncsa.uiuc.edu/training/HDFtraining/UsersGuide/Fundmtls.fm2.html#19271
   
   file_id = hdfh('open',file_name,access_mode,0); % n_dds = 0 for default data descriptors
   if file_id == -1
     error(['HDF hopen failed for file: ',file_name]);
   else
     % disp(['HDF hopen succeeded for file: ',file_name]);
   end
   
%%  Cycle datastruct

   %  Check whether fields is already present
   %  in hdf vfile as SDS, Vgroup, VData before overwriting
   %  SO obtain tree-info from existing file.
   
   if strcmpi(OPT.overwrite_append(1),'a')
      file_info                = hdfinfo(file_name);
      overwrite_append_fldname = 'A'; % 'p'
      %  note that the HDF file doubles in size every time you append
      %  the same struct to it, it does not increas elinearly in size
      %  when adding info. Even when you add just annotation, the file
      %  grows with a size more than the datastruct. SO by default we
      %  just append everything, as that does not results in larger file size !?!
   else
      file_info  = [];
      overwrite_append_fldname = 'A'; % 'p'
   end

   if length(datastruct) >1

      %% Multi-dimensional structure

      for idim=1:length(datastruct)
      
         if OPT.debug
            disp(['dimension main struct: ',num2str(idim)])
            disp(' ')
         end
      
         VGROUP_ID_PARENT = []; % parent vgroup
         status = hdfvsave_struct2vgroup(file_id,file_name,datastruct(idim),'',VGROUP_ID_PARENT);        
         
      end
      
      fldnames = [];

   else % length(datastruct) >1
   
      idim             = 1;
      VGROUP_ID_PARENT = []; % parent vgroup
      fldnames         = fieldnames(datastruct(idim));
      nfield           = length(fldnames);
      
      for ifield = 1:nfield
      
      fldname = char(fldnames{ifield});
   
      %% Write data
   
         %% Structures
   
         if isstruct(datastruct(idim).(fldname))
         
            if OPT.debug
               disp(['isstruct(datastruct(idim).(fldname)): ',fldname])
               disp(' ')
            end
            
            %% Check whether data with that name already exists
   
            if strcmpi(OPT.overwrite_append(1),'a')
            
               for iVgroup = 1:length(file_info.Vgroup)
               
                  if strcmp(fldname,file_info.Vgroup(iVgroup).Name)
                  
                     if strcmp(overwrite_append_fldname,'p')
                     
                        disp(['Field ',fldname,' is already present in ',file_name,', but overwriting fields is not possible.'])
                        while isempty(strfind('aAsSc',overwrite_append_fldname))
                           overwrite_append_fldname = input(['append field/append all/skip field/skip all/cancel futher hdfvsave ? (a/A/s/S/c): '],'s');
                        end
                     end
                  end
               end
            end
            
            %% Write (multi-dimensional) data
   
            % all vdata residing lower in datastruct are 
            % appended by hdfvsave_struct2vgroup(...) which calls 
            % append_matrix2vdata(...)
   
            if lower(overwrite_append_fldname)=='a'

               %% Write more-dimensional structs as Vgroups with identical names

               for idim2 = 1:length(datastruct(idim).(fldname))

                  status = hdfvsave_struct2vgroup(file_id,file_name,datastruct(idim).(fldname)(idim2),fldname,VGROUP_ID_PARENT);
               end

               if overwrite_append_fldname =='a'
                  overwrite_append_fldname = 'p';
               end

            elseif overwrite_append_fldname=='s'
                   overwrite_append_fldname = 'p';
            elseif lower(overwrite_append_fldname)=='c'
               if nargout==0
                  error(['File ',file_name,' not saved further as field ',fldname,'  alreay exists.'])
               else
                  status = -2;
                  disp(['File ',file_name,' not saved further as field ',fldname,'  alreay exists.'])
                  break
               end
            end
         
         %% Numerical data
   
         elseif isnumeric(datastruct(idim).(fldname))
         
            if OPT.debug
               disp(['isnumeric(datastruct(idim).(fldname)): ',fldname])
               disp(' ')
            end
         
            if OPT.save_numeric_array_as_sds
              status = hdfvsave_matrix2sds  (file_id,file_name,VGROUP_ID_PARENT,fldname,datastruct(idim).(fldname));
            else
              status = hdfvsave_matrix2vdata(file_id,datastruct(idim).(fldname),fldname,VGROUP_ID_PARENT);
            end         
            
         %% Characters
   
         elseif ischar   (datastruct(idim).(fldname)) | ...
                iscellstr(datastruct(idim).(fldname))
             
             if     ischar   (datastruct(idim).(fldname))
                str =      datastruct(idim).(fldname);
             elseif iscellstr(datastruct(idim).(fldname))
                str = char(datastruct(idim).(fldname));
             end
         
            if OPT.debug
               disp(['ischar(datastruct(idim).(fldname)): ',fldname])
               disp(' ')
            end
         
            if (OPT.save_1Dchar_array_as_sds) & ...
               (min(size(str))==1)
               status = hdfvsave_char2sdsatr  (file_id,file_name,VGROUP_ID_PARENT,fldnamestr);
               disp(['Saved char field ''',fldname,''' as SDS atr, cannot be attached to a Vgroup'])
            else
               status = hdfvsave_matrix2vdata (file_id,str,fldname,VGROUP_ID_PARENT);
              %disp(['Saved char field ''',fldname,''' as VData'])
            end
    
            if status == -1
    	         error('HDF sdsetattr failed')
            end
    
         %% Logicals
         
         elseif islogical(datastruct(idim).(fldname))
         
            if OPT.debug
               disp(['islogical(datastruct(idim).(fldname)): ',fldname])
               disp(' ')
            end
   	    
            if OPT.save_logicals2integers
            
               if OPT.save_numeric_array_as_sds
               status = hdfvsave_matrix2sds  (file_id,file_name,VGROUP_ID_PARENT,fldname,int8(datastruct(idim).(fldname)),...
                                                {{'original_data_type','logical'}});
               disp(['Warning: Cell field ''',fldname,''' is logical, for which there is no HDF class. It has been converted to int8.'])
               else
               disp(['Warning: Cell field ''',fldname,''' not saved, as it is logical'])
               end    
   	    
            else
               disp(['Warning: Cell field ''',fldname,''' not saved, as it is logical'])
            end
   
         %% Cells
   
         elseif    iscell(datastruct(idim).(fldname)) & ...
               ~iscellstr(datastruct(idim).(fldname))
         
            disp(['Warning: Cell field ''',fldname,''' not saved, as there is no data class for that in HDF library'])
    
         end
         
      end % for ifield = 1:nfield
      
   end % length(datastruct) >1
   
%%  Add hdfvsave meta information
%   vgroup_id is not used yet and is [] ...
%   Make sure not to add a field with the same name as a data field
%   (names are not unqiue in HDF, only ID numbersd are) to prevent hdfvload errors 

   if OPT.add_annotation
      
      if ~any(strcmp(fldnames,'filename'))
      status    = hdfvsave_char2sdsatr(file_id,file_name,[],'filename'  ,file_name);
      end
      
      if ~any(strcmp(fldnames,'created_at'))
      status    = hdfvsave_char2sdsatr(file_id,file_name,[],'created_at',datestr(now));
      end
      
      if ~any(strcmp(fldnames,'created_by'))
      status    = hdfvsave_char2sdsatr(file_id,file_name,[],'created_by','hdfvsave.m "provided as is" by G.J. de Boer (g.j.deboer@tudelft.nl)');
      end
      
      if ~any(strcmp(fldnames,'created_as New_Overwrite_Append'))
        if FILEexists
         status = hdfvsave_char2sdsatr(file_id,file_name,[],'created_as New_Overwrite_Append',OPT.overwrite_append);
         % note that even appending just atributes is very inefficient with respect to file size.
        else
         status = hdfvsave_char2sdsatr(file_id,file_name,[],'created_as New_Overwrite_Append','n');
        end
      end
   end
   
%%  Add user meta information
%   vgroup_id is not used yet and is [] ...

   if ~isempty(meta_info)
   fldnames  = fieldnames(meta_info);
   nfield    = length    (fldnames );

   for ifield = 1:nfield
   
      fldname = char(fldnames{ifield});
      %  After using hdfvload there is a field for every SD, 
      %  even if the SD has no attributes.
      %  For symmetry we want the following to be possible though:
      %  > [DATA,META]=hdfvload(fname)
      %  >             hdfvsave(fname,DATA,META)
      %  So we have to skip empty attribute values here.

      if ~isempty(meta_info.(fldname))
         status  = hdfvsave_char2sdsatr(file_id,file_name,[],fldname,meta_info.(fldname));
      end
      
   end
   end
   
%%  9 Close the HDF file.

   status = hdfh('close',file_id);

   if status == -1
     if nargout==0
     error(['HDF hend failed for file: ',file_name]);
     end
   end
   
end % if status  > 0

%%  Return status

   if nargout==1
      varargout = {status};
   end

%% EOF   
