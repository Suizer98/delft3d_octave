function status = hdfvsave_matrix2vdata(file_id,datafield,fldname,VGROUP_ID)
%HDFVSAVE_MATRIX2VDATA    save a matrix as a HDF Vdata.
%
%    status = hdfvsave_matrix2vdata(file_id,datafield,fldname,VGROUP_ID)
%
% The matrix datafield is appended to the Vgroup with VGROUP_ID as 
% a Vdata field with name fldname. 
% The matrix can be of double or character type.
%
% Note: do not use HDFVSAVE_MATRIX2VDATA directly, use through HDFVSAVE.
%
% - Only 2D arrays are saved and loaded correctly, more dimensions
%   are saved as a 2D array, and need to be reshaped to obtain the
%   original dimensions and sizes. Tested succesfully for 24 dimensions.
%
% Follows recipe at:
% <http://hdf.ncsa.uiuc.edu/training/HDFtraining/UsersGuide/Vdatas.fm4.html#5891>
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT

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

            %% 6.01 Open a file.
      
               % to be done at highest level of hdfvsave.m
      
            %% 6.02 Initialize the Vdata interface.
      
               % Also required when NOT writing to a vgroup but to the highest
               % file level !!!!
               
               status = hdfv('start',file_id);

            %% 6.03 Create the new vdata.
      
               % vdata_id = hdfvs('attach',file_id,vdata_ref,access)
               % Establishes access to a specified vdata; access can be
               % 'r' or 'w'
	       
               vdata_id = hdfvs('attach',file_id, -1 , 'w');
               if vdata_id == -1
                 error(['HDF vsattach failed '])
               end
           
            %% 6.04 Assign a vdata name. (NOT optional otherwise HDFTOOL crashes)
      
               % status = hdfvs('setname',vdata_id,name)
               % Assigns a name to a vdata
	       
               status = hdfvs('setname',vdata_id,fldname);
            
            %% 6.05 Assign a vdata class. (optional)
                
                % status = hdfvs('setclass',vdata_id,class)
                % status = hdfvs('setclass',vdata_id,class)
                % Assigns a class to a vdata
            
            %% 6.06 Define the fields.
            
               % status = hdfvs('fdefine',vdata_id,fieldname,data_type,order)
               %  Defines a new vdata field. data_type is a string
               %  specifying the HDF number type. It can be of these
               %  strings: 'uchar8', 'uchar', 'char8', 'char', 'double',
               %  'uint8', 'uint16', 'uint32', 'float', 'int8', 'int16',
               %  or 'int32'.
               
               order  = size(datafield,1);
               if     isa(datafield,'double')
                  data_type = 'double';
                  fieldname = ['double from matlab version: ',version,' as HDF ',data_type]; % or name the class like this.
               elseif isa(datafield,'char')
                  data_type = 'char8'; % only valid for first 127 (WRONG IN FUNCTION HTYPE !!)
                  data_type = 'uchar'; % only valid for first 256
                  fieldname = ['char from matlab version: ',version,' as HDF ',data_type]; % or name the class like this.
               else
                  disp('Field is neither numeric nor char, not saved;')
               end
               
               status = hdfvs('fdefine',vdata_id,fieldname,data_type,order);
      
            %% 6.07 Initialize fields for writing.
            
               % status = hdfvs('setfields',vdata_id,fields)
               % Specifies the vdata fields to be written to
               % Field names must be a string.
               % The parameter fieldname_list is a comma-separated list of the field
               % names, with no white space included. The fields can be either the 
               % predefined fields or the fields that have been previously introduced 
               % by VSfdefine. VSfdefine allows a user to declare a field, along with 
               % its data type and order, but VSsetfields finalizes the definition by 
               % allowing the user to select the fields that are to be included in the 
               % vdata. Thus, any fields created by VSfdefine that are not in the parameter 
               % fieldname_list of VSsetfields will be ignored. This feature was originally 
               % intended for interactive-mode users. The combined width of the fields in the 
               % parameter fieldname_list is also the length of the record and must be less 
               % than MAX_FIELD_SIZE (or 65535). An attempt to create a larger record 
               % will cause VSsetfields to return FAIL (or -1).   
               
               status = hdfvs('setfields',vdata_id,fieldname);
              
            %% 6.08 Set the interlace mode.
            
               % status = hdfvs('setinterlace',vdata_id,interlace)
               %  Sets the interlace mode for a vdata; interlace can be
               %  'full' or 'no'      

               status = hdfvs('setinterlace',vdata_id,'no');
               
               %% INSERT VDATA INTO VGROUP
               
                  %% When VGROUP_ID is empty, vdata is added on 
                  %% the highest level in file,
                  %% otherwise it is added to a vgroup
                  
                  if ~isempty(VGROUP_ID)
                  ref = hdfv('insert',VGROUP_ID, vdata_id);
                  end
                  
               %% ACTUALLY ADD DATA VALUES
               %  NOTE that all data of 3 and more dimensions are squeezed to 2 dimensions

                  data{1,1} = datafield;
                % data{2,1} = rand(3,5,2); % will be a 2D array
                  
                  hdfvs('write',vdata_id,data);

            %% 6.09 Dispose of the vdata identifier.
      
               status = hdfvs('detach',vdata_id);
               %  Terminates access to a specified vdata
      
            %% 6.10 Terminate access to the Vdata interface.
      
               % ???????????
               status = hdfv('end',file_id);
               
            %% 6.10b Terminate access to the Vgroup file and interface ??
               
               % close vgroup interface ??
               % there are always warnings to open vgroups
               % is in principle done 1 level up in hdfvsave_struct2vgroup
               % where the vgroup is also created

               %status = hdfv('detach',vgroup_id);
               %status = hdfv('end',file_id);
            
            %% 6.11 Close the file.      
                    
               % to be done at highest level of hdfvsave.m

% disp('finished append_matrix2vdata')