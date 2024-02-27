function [DATA,ATTRIBUTES,iostat] = hdfvload(varargin)
%HDFVLOAD                 load HDF4 file into multi-layered Matlab struct.
%
%    [data_struct]                         = hdfvload(file_name)
%    [data_struct]                         = hdfvload(file_name,<keyword,value>)
%
%    [data_struct]                         = hdfvload(..)
%    [data_struct,attribute_struct]        = hdfvload(..)
%    [data_struct,attribute_struct,iostat] = hdfvload(..)
%
% where iostat=1 when succesfull, iostat=0 when failed 
% (when iostat=0, data_struct=[], attribute_struct=[])
%
%    [..] = hdfvload                            launches file load GUI
%    [..] = hdfvload(filename)                  loads hdf file filename
%    [..] = hdfvload(filename,<keyword, value>) passes <keyword,value> pairs
%
% Where the following <keyword, value> have been implemented:
%
% * vgroup_name       char loads only vgroup with name char from hdf file filename.
%                     []   Set vgroup_name = [] to load only data on highest level in HDF file.
% * load_main_data    0    loads only vgroup with name vgroup_name from hdf file filename.
%                     1    loads only vgroup with name vgroup_name from hdf file filename 
%                          as well as data on highest level in HDF file.
% * debug             0    display log of components read
%
% HDFVLOAD(0) returns struct with default <keyword, value> settings.
%
% Loads a a HDF Vgroup/Vdata HDF4 file into a multi-layered matlab 
% struct with substructs. Supported fields in the hdf are char
% and numeric fields. Optionally all attributes are also read.
%
% Limitations / capabilities :
%
% - Cell fields are not allowed.
%
% - Int8 fields with with attribute 'original_data_type'='logical'
%   are read from file as logical (in SDS mode only, not in VDATA mode).
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

% 2006 Feb  3 : added file load gui, check for file existance, iostat and selctively load vgroup
% 2006 Nov 13 : added file file attributes to meta info struct ATTRIBUTES
% 2006 Nov 17 : and do not do that when one it is emtpy 
% 2007 Mar 21 : convert Vgroup names with spac es to valid matlab field names without spaces.
% 2007 Mar 22 : do not add file Attributes when hdfinfo does not return them (such as in SeaDaS mapped SeaWIFS L2 imagery).
% 2008 Jan 15 : added option that reads int8 arrays as logical arrays (when...).
% 2008 Feb 22 : add non-empty attributes to data struct (as SDLOAD_CHAR) (internally optional) 
% 2008 Jun 06 : added hdftree for logging depth in HDf file
% 2008 Aug 10 : repaired OPT keyword cycle and added option sdsselection

% TO DO: allow loading only a deeper sub V group using a vgroup_name-tree argument
%        that is separated with slashed between vrgoup (like hdf 5 syntax).
% TO DO: allow selectively loading mutiple vgroups (using cell char )
% TO DO: load also SD annotation into main struct ?
% TO DO: load annotation at file level (date, author)

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

%% Deal optional arguments

   if odd(nargin)
      
      file_name = varargin{1};
      
   else

     [filename, pathname, filterindex] = uigetfile( ...
        {'*.hdf', 'Delft3d-FLOW hdf fourier file (*.hdf)'; ...
         '*.*'  , 'All Files (*.*)'}, ...
         'Delft3d-FLOW hdf fourier file');
      
      if ~ischar(filename) % uigetfile cancelled
         file_name = [];
         iostat    = 0;
      else
         file_name = [pathname, filename];
         iostat    = 1;
      end

   end
   
%% Set defaults for keywords

   OPT.vgroup_name    = [];
   OPT.load_main_data = 1;
   OPT.attr2data      = 0; % goes wrong when file attribute filename as added by hdfvsave
                           % overwrites a vdata field filename
   OPT.debug          = 0; % also for function at lower level.
   OPT.sdsselection   = [];
   OPT.vdataselection = [];

%% Cycle keywords in input argument list to overwrite default values.

   OPT = setproperty(OPT,varargin{2:end});
   
%% Return default aguments (with 0 as arg, because 0 args => input GUI)

   if nargin==1 & varargin{1}==0
      DATA = OPT;
      return
   end
   
%% Initialize
   
   DATA       = [];
   ATTRIBUTES = [];
   hdftree    = file_name; % for logging depth in HDf tree while debuggging
   
   if ~isempty(file_name)
   
      if exist(file_name,'file')==2
      
%         try
      
            finfo    = hdfinfo(file_name);
            
            if OPT.load_main_data
            
            %% Load SDS and Vdata in current Vgroup
               
               [DATA ,ATTRIBUTES ,status] = hdfvload_vdatas2struct (finfo,file_name,hdftree,'debug',OPT.debug,...
                                                                                   'vdataselection',OPT.vdataselection);
               
               [DATA1,ATTRIBUTES1,status] = hdfvload_sds2struct    (finfo,file_name,hdftree,'debug',OPT.debug,...
                                                                                     'sdsselection',OPT.sdsselection);
                
               if isempty(DATA)
                  DATA       = DATA1      ; % is empty when DATA1 is empty
                  ATTRIBUTES = ATTRIBUTES1; % is empty when ATTRIBUTES1 is empty
               elseif isempty(DATA1)
                  % DATA = DATA;
               else
                  DATA       = mergestructs(DATA      ,DATA1      );
                  if isempty(ATTRIBUTES)
                  ATTRIBUTES = ATTRIBUTES1;
                  elseif isempty(ATTRIBUTES1)
                  ATTRIBUTES = ATTRIBUTES;
                  else
                  ATTRIBUTES = mergestructs(ATTRIBUTES,ATTRIBUTES1);
                  end
                  clear DATA1 ATTRIBUTES1
               end
               
            end % if OPT.load_main_data

         %% Add file meta information

            if isfield(finfo,'Attributes')
               for iatr = 1:length(finfo.Attributes)
                  fldname = mkvar(finfo.Attributes(iatr).Name);
                  val     = finfo.Attributes(iatr).Value;
                  ATTRIBUTES.(fldname) = val;
                  if OPT.attr2data
                     if ~isempty(val)
                        DATA.(fldname) = val;
                     end
                  end
               end
            end
               
         %% Load lower Vgroups
               
            if isfield(finfo,'Vgroup')
            
            nVgroup           = length(finfo.Vgroup);
            
            at_least_one_empty_Vgroup = 0;
            
            for iVgroup=1:nVgroup
            
               if isempty(finfo.Vgroup(iVgroup).Name)
               
                  at_least_one_empty_Vgroup = 1;
               
                  % disp('FOUND NAMELESS VGROUP')
                  
                  fldname = [];
                  
                  [NEWDATA,...
                   NEWATTRIBUTES,...
                   status] = hdfvload_vgroup2struct(finfo.Vgroup(iVgroup),file_name,[hdftree,filesep,'(',num2str(iVgroup),')'],'debug',OPT.debug);
                   
                   if iVgroup==1
                   DATA          = NEWDATA;
                   else
                   DATA(iVgroup) = NEWDATA;
                   end

               else
               
                  if at_least_one_empty_Vgroup
                    error('Vgroup should all be empty or none should be empty.')
                  end

                  fldname = mkvar(finfo.Vgroup(iVgroup).Name);
                  
               %% Check if only this vgroup must be loaded as substruct 
                  
                  load_this_vgroup = 0;
                  
                  if isempty (OPT.vgroup_name)                  
                     load_this_vgroup = 1;
                  else
                     if strmatch(mkvar(OPT.vgroup_name),fldname,'exact')
                     load_this_vgroup = 1;
                     end
                  end

                  if load_this_vgroup
                  
                     [NEWDATA,...
                      ATTRIBUTES.(fldname),...
                      status] = hdfvload_vgroup2struct(finfo.Vgroup(iVgroup),file_name,[hdftree,filesep,fldname],'debug',OPT.debug);
                   
                     if isfield(DATA,fldname)
                        L = length(DATA.(fldname)(:))
                        DATA.(fldname)(L+1) = NEWDATA;
                     else
                        DATA.(fldname)      = NEWDATA;
                     end

                  end % load_this_vgroup

               end % isempty(finfo.Vgroup(i).Name)
            
            end % for i=1:nVgroup
            end % if isfield(finfo,'Vgroup')
         
            iostat = 1;

%         catch 
%
%            disp(['File exist but is probably not a hdf file: ',file_name]);
%            iostat     = 0;
%
%         end % try
     
      else
   
         disp(['File does not exist: ',file_name]);
         iostat     = 0;
   
      end % if exist(file_name,'file')==2
     
   end % if ~isempty(file_name)

%% EOF   
