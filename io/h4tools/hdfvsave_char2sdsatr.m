%HDFVSAVE_CHAR2SDSATR     save matlab character as SDS attribute
%
% See also: HDF,                        h4tools,
%           HDFVSAVE,                   HDFVLOAD,
%           HDFVSAVE_STRUCT2VGROUP,     HDFVLOAD_VGROUP2STRUCT,
%           HDFVSAVE_MATRIX2SDS,        HDFVLOAD_SDS2STRUCT,
%           HDFVSAVE_MATRIX2VDATA,      HDFVLOAD_VDATAS2STRUCT

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

function status = hdfvsave_char2sdsatr(file_id,FILE_NAME,vgroup_id,ATR_NAME,atr, varargin)
% now vgroup_id is not used yet ...

      %%  1 - Open a file.
      
         %% Create the HDF file.
         %% to be done at highest level of hdfvsave.m
         
         %  DFACC_CREATE = 4
         %  file_id = hopen(FILE_NAME, DFACC_CREATE, 0)
      
      %%  2 - Initialize the Vdata interface.
      %       This is done at one higher level.
      
         % Also required when NOT writing to a vgroup but to the highest
         % file level !!!!
         %if ~isempty(vgroup_id)
         %status = hdfv('start',file_id);
         %end

      %%  3 - Initialize SD interface. 
      
         sd_id = hdfsd('start',FILE_NAME, 'rdwr');
         if sd_id == -1
           error('HDF sdstart failed');
         end
         
      %%  4a- Create the SDS attribute

         status = hdfsd('setattr', sd_id, ATR_NAME, atr);
         if status == -1
           error('HDF sdsetattr failed')
         end

%      %%  4 - Create the SDS
%
%         sds_id = mat2sdsid(sd_id, SDS_NAME, dat, varargin{:});
%         
%      %%  5 - get sds ref
%      
%         sds_ref = hdfsd('idtoref',sds_id);
%
%         % disp(['sds_id,sds_ref'])
%         % disp([ sds_id,sds_ref ])
%
%      %%  6 - Add the SDS to the vgroup. 
%      %  Apparently only 1 SDS per Vgroup is allowed.
%
%         %% Note: the tag DFTAG_NDG is used when adding an SDS.
%         %  Refer to HDF Reference Manual, Section III, Table 3K,
%         %% (http://hdf.ncsa.uiuc.edu/UG41r3_html/Appndx1.html)
%         %% for the entire list of tags.
%         
%         if ~isempty(vgroup_id)
%         
%            %[tag,refs,count ] = hdfv('gettagrefs',vgroup_id,count)
%            %[tag,ref ,status] = hdfv('gettagref' ,vgroup_id,index)
%            
%            DFTAG_NDG = 720;
%            status    = hdfv('addtagref',vgroup_id,DFTAG_NDG,sds_ref);
%            
%            if opt.debug
%            vgroup_ref = hdfv('Queryref',vgroup_id);
%            count      = hdfv('ntagrefs',vgroup_id);
%            disp(['     vgroup_ref vgroup_id count status  sds_id sds_ref SDS_NAME'])
%            disp(['     ',pad(num2str(vgroup_ref),9),'  ',...
%                          pad(num2str(vgroup_id ),9),' ',...
%                          pad(num2str(count     ),6),' ',...
%                          pad(num2str(status    ),6),' ',...
%                          pad(num2str(sds_id    ),6),' ',...
%                          pad(num2str(sds_ref   ),7),' ',SDS_NAME])
%            end
%         
%         end
%
%      %%  7 - close the current SDS
%
%         status = hdfsd('endaccess',sds_id);
%         if status == -1
%           error('HDF sdendaccess failed')
%         end

      %%  8 - close the file
        

         status = hdfsd('end',sd_id);
         if status == -1
           error('HDF sdend failed')
         end

      %%  9 - Terminate access to the vgroup.
      
      % Done at higher level

         %if ~isempty(vgroup_id)
         %status = hdfv('detach',vgroup_id);
      
      %% 10 - Terminate access to the Vgroup interface.
      
      % Done at higher level

         %status = hdfv('end',file_id);
         %end

      %% 11 - Close the file.      
              
         % to be done at highest level of hdfvsave.m

