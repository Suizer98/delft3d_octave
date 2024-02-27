function varargout = delft3d_io_bca(cmd,varargin)
%DELFT3D_IO_BCA   read/write astronomical boundary table (*.bca) <<beta version!>>
%
%       delft3d_io_bca('write',bcafile,BCA)
% Ok  = delft3d_io_bca('write',bcafile,BCA)
%
% BCA = delft3d_io_bca('read' ,bcafile,BND)
%
% where the BND struct comes from BND = delft3d_io_bnd(...)
% and the BCA struct looks like this, with subfields 
% amp [m] and phi [deg]:
%
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).amp      (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).phi      (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).names    (1:ncomponents)
% BCA.DATA(1 x nboundary_segments,[sideA side_B]).label
%
% where the indices in DATA are in the order of the *.bnd file.
%
% NOTE:
% Currently it is not possible to have a different number of components 
% per boundary. The reason for this is that boundary names and 
% component names cannot be distuinguished from another.
%
% a1) we need to include a table with possible names for that in delft3d_io_bca
% a2) we need the guarantee that labels cannot have the same name as 
%     components (checked by GUI).
% b1) Or we can try to see whether we have a component by looking if
%     there are any numeric data past character 8 on a line in the *.bca file.
% c1) we can try to convince DHS to adapt the *.bca file by incorporating one
%     line with the number of components after the line with the label....
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
%           bct2bca

% 2008 Jul 11: removed error in writing labels (%c instead of %12s to prevent leading blanks) [Anton de Fockert]
% 2008 Jul 21: more decimals in output for Nuemann boundary [Anton de Fockert]
% TO DO: make struct with BCA info only
% TO DO: add correct table to relevant boundary in BND struct
%         BCA      = delft3d_io_bca('read' ,bcafile)
%        [BCA,BND] = delft3d_io_bca('read' ,bcafile,BND)

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_bca.m 17736 2022-02-04 15:35:37Z kimberley.koudstaal.x $
% $Date: 2022-02-04 23:35:37 +0800 (Fri, 04 Feb 2022) $
% $Author: kimberley.koudstaal.x $
% $Revision: 17736 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_bca.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_bca(''read''/''write'',filename)'])
end

switch lower(cmd),

case 'read',
  [BCA,BND]=Local_read(varargin{:});
  if nargout==1
     varargout = {BCA};
  elseif nargout==2
     varargout = {BCA,BND};
  elseif nargout >2
    error('too much output paramters: 0 or 1')
  end
  if BCA.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;

case 'write',
  iostat=Local_write(varargin{:});
  if nargout==1
     varargout = {iostat};
  elseif nargout >1
    error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function varargout=Local_read(bcafile,BND)

OPT.debug = 0;
fid       = fopen(bcafile,'r');
v = version;

if fid > 0 

   BCA.filename = bcafile;
   BCA.phi_unit = 'deg';
   
%% Load all astronomic component sets
   
   iset = 0;

   rec     = fgetl(fid); if OPT.debug;disp(rec);end
   
   while 1   
   
      iset    = iset + 1;
      if ~ischar(rec) || isempty(rec), break, end % eof

      if length(v) > 23 
         v = v(1:end-9); %2021
      end
      
      if str2num(v(end-5:end-2)) >= 2019
          rec = pad(rec,12);%2019
      else
          rec = pad(rec,' ',12);%2015
      end
      
      BCA.DATA(iset).label   = strtrim(rec(1:12));

      rec     = fgetl(fid); if OPT.debug;disp(rec);end
      if ~ischar(rec) || isempty(rec), break, end % eof
      C       = textscan(rec,'%s %f %f',1);

      icomp = 0;
      while ~isempty(C{2})
         icomp = icomp + 1;
         BCA.DATA(iset).names{icomp} = strtrim(C{1});
         BCA.DATA(iset).amp  (icomp) = C{2};
         
         if ~isempty(C{3})
             BCA.DATA(iset).phi(icomp) = C{3};
         else
             BCA.DATA(iset).phi(icomp) = 0;
         end
             
         rec     = fgetl(fid); if OPT.debug;disp(rec);end
         if ~ischar(rec) || isempty(rec), break, end % eof
         C       = textscan(rec,'%s %f %f',1);
         
      end% while still amp + phase
   
   end % while no eof

%% Assign correct set to each boundary

      %% For every boundary segment in the bca file, check 3 things
   
      if nargin > 1
      for ibnd = 1:BND.NTables
         
         endpoint = 0; % 1,2 or 0=none

      %% 1) whether is defined as astronomical, and if yes
   
         if ~lower(BND.DATA(ibnd).datatype)=='a'
   
            %% This warning should not appears for every block in the bca file
            %  as we scroll through the bca file ....
            %  Check for existance field name "displayed_warning"
   
            if ~(BND.DATA(ibnd).displayed_warning)
               disp(['Boundary ''',BND.DATA(ibnd).name,''' in *.bnd not defined as astronomical, ignored.'])
               BND.DATA(ibnd).displayed_warning = true;
            end
            endpoint = 0;
            disp (['Boundary ''',BND.DATA(ibnd).name,''' with label ',deblank(labelAB),', has no table in *.bca file.'])
            break;
            
      %% 2) ... whether is has labels, and if yes
   
            if ~isfield(BND.DATA(ibnd),'labelA') | ...
               ~isfield(BND.DATA(ibnd),'labelB')
   
               error(['Boundary ''',BND.DATA(ibnd).name,''' in *.bnd defined as astronomical, but has no point labels.'])
   
            end
   
         end
   
      %% 3) ... what is the associated set in the bca file.
         
         for endpoint=1:2

            for iset=1:length(BCA.DATA)
            
               if     endpoint==1
                  if strcmp(strtrim(BND.DATA(ibnd).labelA),BCA.DATA(iset).label)
                     break
                  end
               elseif endpoint==2
                  if strcmp(strtrim(BND.DATA(ibnd).labelB),BCA.DATA(iset).label)
                     break
                  end
               end
            
            end
	    
            disp(['Note that every Table (label) in the bca file can be used by 1 boundary, boundaries segment can only share labels when they overlap 1 gridcell ...'])
            
            %% Everything is OK, now read the data
   	    
               BND.DATA(ibnd).label{endpoint}   = BCA.DATA(iset).label;
               BND.DATA(ibnd).names{endpoint}   = BCA.DATA(iset).names;
               BND.DATA(ibnd).amp  {endpoint}   = BCA.DATA(iset).amp;
               BND.DATA(ibnd).phi  {endpoint}   = BCA.DATA(iset).phi;
               
            end

            if ~(length(BND.DATA(ibnd).amp{1})==...
                 length(BND.DATA(ibnd).amp{2}))
               error(['2 endpoints require same number of components for boundary segment:"',BND.DATA(ibnd).name,'"'])
            end

      end % for ibnd = 1:BND.NTables
      end % any BND at all
      
   fclose(fid);
   
   BCA.iostat = 1;
   
   if nargout==1 | nargin==1
      varargout = {BCA,[]};
   else
      varargout = {BCA,BND};
   end

else   

   error(['Opening file ',bcafile])

end % if fid > 0 

%% ------------------------------------

function varargout = Local_write(bcafile,BCA)

iostat = 0;

fid = fopen(bcafile,'w');

if fid > 0 

   for ibnd = 1:length(BCA.DATA)
   
         fprintf(fid,'%c'  ,strtrim(BCA.DATA(ibnd).label)); % format '%12s' results in leading spaces
         
         fprintf(fid,'\n');
   
         for icomp=1:length(BCA.DATA(ibnd).amp)
         
            % mapping t_tide and delf3d outsourced to other functon
            % if strmatch('RHO' ,component); component = 'RO1'     ; end
            % if strmatch('SIG' ,component); component = 'SIGMA1'  ; end
            % if strmatch('THE1',component); component = 'THETA1'  ; end
            % if strmatch('PHI1',component); component = 'FI1'     ; end
            % if strmatch('UPS1',component); component = 'UPSILON1'; end
            % if strmatch('EPS2',component); component = 'EPSILON2'; end            
            % if strmatch('LDA2',component); component = 'LABDA2'  ; end
            % if strmatch('2MK5',component); component = '3MO5'    ; end            
            % if strmatch('3MK7',component); component = '2MSO7'   ; end          
       
            if        iscell(BCA.DATA(ibnd).names)
            component = char(BCA.DATA(ibnd).names{icomp});
            elseif    ischar(BCA.DATA(ibnd).names)
            component = char(BCA.DATA(ibnd).names(icomp,:));
            end
            
            amp       =      BCA.DATA(ibnd).amp  (icomp);
            phase     =      BCA.DATA(ibnd).phi  (icomp);
   	 
            if strmatch('A0' ,component)
                fprintf(fid,'%8s %15.7e %8s',pad(component,8,' '),amp,' '); % 15 = enough decimals to get sufficient decimals for Neumann boundary
            else
				fprintf(fid,'%8s %15.7e %15.7e',pad(component,8,' '),amp,phase); % 15 = enough decimals to get sufficient decimals for Neumann boundary
            end
			fprintf(fid,'\n');
            
         end % for icmp=1:length(BCA.components)
   
   end % for ibnd = 1:BCA.DATA
   
   fid = fclose(fid);
   
end % if fid > 0 
   
if ~(fid==-1)
  iostat = 1;
end

if nargout == 1
   
   varargout = {iostat};
   
end

%% EOF