function varargout=delft3d_io_ini(cmd,varargin)
%DELFT3D_IO_INI   read/write Delft3D initial fields file
%
%     DATA = delft3d_io_ini('read',filename,mdffilename);
%
%   reads a struct with fields: waterlevel,u,v, salinity,temperature
%   constituent1,...,constituent5, secondaryflow
%
%     delft3d_io_ini('write',filename,DATA) % or delft3d_io_ini(..,DATA.data);
%     delft3d_io_ini('write',filename,PLATFORM,DATA);
%
%   where platform can be
%   - u<nix>   , l<inux>
%   - p<c>     , w<indows>, d<os>
%
%   and where data can be a struct, where the data are 
%   written to the *.ini file in the order of the fieldnames
%   where the fieldnames ORDER should be (actual names does not matter, use ORDERFIELDS)
%   1. Water elevation                                    (   1 matrix  ).
%   2. U-velocities                                       (Kmax matrices).
%   3. V-velocities                                       (Kmax matrices).
%   4. Salinity,    only if selected as an active process (Kmax matrices).
%   5. Temperature, only if selected as an active process (Kmax matrices).
%   6. Constituent number 1, 2, 3 to the last constituent
%           chosen, only if selected                      (Kmax matrixes).
%   7. Secondary flow (for 2D simulations only),
%                   only if selected as an active process (   1 matrix  ).
%
%   or it operates similar to trirst by passing a list of matrices:
%      delft3d_io_ini('write',filename,PLATFORM,waterlevel,u,v,...);
%
% tke and dissipation can not be used as inpout with ini files,
% use delft3d_io_restart instead.
%
% See also: ORDERFIELDS, delft3d_io_restart, delft3d

% $Id: delft3d_io_ini.m 14700 2018-10-15 12:54:15Z schrijve $
% $Date: 2018-10-15 20:54:15 +0800 (Mon, 15 Oct 2018) $
% $Author: schrijve $
% $Revision: 14700 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_ini.m $
     
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   USA
%   --------------------------------------------------------------------

%% checks and agr passing
if nargin<3
   error('Syntax: delft3d_io_ini(''read/write'' ,filename, mdffilename/DATA, ...')
end
if nargin < 3
   error(['At least 3 input arguments required: delft3d_io_ini(''write'',filename,INI)'])
end

switch lower(cmd),
case 'read',
  [INI,iostat]=Local_read_ini(varargin{:});
  if nargout ==1
     varargout = {INI};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write_ini(varargin{1:end});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

%% READ

function varargout=Local_read_ini(fname,varargin),

D.filename  = fname;
D.iostat    = -3;
OPT.debug   = 0;
   
if nargin==1
   error('At least 3 arguments required for reading ini file.')
end

%% Get info on contents of ini file
   
   if ischar(varargin{1})
   
      mdffilename = varargin{1};
      
      %% Size and layers
   
      [MDF,iostat2] = delft3d_io_mdf('read',mdffilename,'case','lower');
      
      if iostat2<0
         if nargout==1
            error('??? Error using ==> delft3d_io_restart')
         else
            disp('??? Error using ==> delft3d_io_restart')
            disp(['Cannot find *.mdf file: ''',mdffilename,''''])
            varargout = {[],-1};
            return
         end
      end
      
      SIZE   = MDF.keywords.mnkmax(1:2);
      D.mmax = MDF.keywords.mnkmax(1);
      D.nmax = MDF.keywords.mnkmax(2);
      D.kmax = MDF.keywords.mnkmax(3);
      
      %% Parameters
   
      MDF.keywords.sub1   = char(upper(MDF.keywords.sub1  ));
      MDF.keywords = orderfields(MDF.keywords);
   
      j=0;
      j=j+1;PAR.nlayers(j)= [     1];PAR.names{j} = 'waterlevel';
      j=j+1;PAR.nlayers(j)= [D.kmax];PAR.names{j} = 'u'         ;
      j=j+1;PAR.nlayers(j)= [D.kmax];PAR.names{j} = 'v'         ;
      
      if ~(isempty(strfind (char(MDF.keywords.sub1(1)),'S'       )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'salinity'     ;end
      if ~(isempty(strfind (char(MDF.keywords.sub1(2)),'T'       )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'temperature'  ;end
      if ~(isempty(strfind (char(MDF.keywords.sub2(2)),'C'       )))
          nconsts= sum(~cellfun('isempty',regexp(fieldnames(MDF.keywords),'namc*')));
          for constituent = 1:nconsts
              j = j+1;
              PAR.nlayers(j)= [D.kmax  ];
              PAR.names{j} = sprintf('constituent%i',constituent);
          end
      end
      if ~(isempty(strfind (char(MDF.keywords.sub1(4)),'I'       )));j=j+1;PAR.nlayers(j)= [       1];PAR.names{j} = 'secondaryflow';end
      if ~(isempty(strfind (char(MDF.keywords.sub1(4)),'I'       )));disp('Not tested for secondary flow yet .......');end
   
   elseif isstruct (varargin{1})
   
      %% Size and layers
   
      GRID        = varargin{1};
      D.mmax      = size(GRID.X,1)+1;
      D.nmax      = size(GRID.X,2)+1;
      SIZE        = [D.mmax D.nmax];
      D.kmax      = varargin{2};
      PAR         = varargin{3};
   
   elseif isnumeric(varargin{1})
   
      %% Size and layers
   
      SIZE        = varargin{1};
      D.kmax      = varargin{2};
      PAR         = varargin{3};
   
   end % if ischar(varargin{1})
   
   PAR.nparameters = length(PAR.nlayers > 0);
%% Read restart file

   if ~isempty(SIZE)
   
      %% Locate
      
      tmp = dir(fname);
      
      if length(tmp)==0
         
         D.iostat = -1;
         disp (['??? Error using ==> delft3d_io_restart'])
         disp (['Error finding restart file: ',fname])
         
      elseif length(tmp)>0
      
         D.filedate  = tmp.date;
         D.filebytes = tmp.bytes;
      
         %% Open
   
         fid = fopen(fname,'r','b'); % Try UNIX format ...
   
         if fid < 0
            
            D.iostat = -2;
            disp (['??? Error using ==> delft3d_io_restart'])
            disp (['Error opening restart file: ',fname])
            
         end
            
         if fid > 2
   
         %% Read
            
      %-%try
            
            mask      =  PAR.nlayers > 0;
            D.nlayers =  PAR.nlayers(mask);
            D.names   = {PAR.names{mask}};
            
            %% Loop over variables
            
            for iname=1:length(D.names)
            
               name          = char(D.names{iname});
               D.data.(name) = zeros([D.mmax D.nmax D.nlayers(iname)]);
               
            %% Loop over layers
   
               for k=1:D.nlayers(iname)
               
                  if OPT.debug
                    disp(['Reading: ',name,' k: ',num2str(k)])
                  end
              
                  %% Data
   
                  for n=1:D.nmax
                     if OPT.debug
                       disp(['n/nmax:  ',num2str(n),'/',num2str(D.nmax)])
                      end
                      D.data.(name)(:,n,k) = fscanf(fid,'%e',D.mmax);
                  end
                  D.data.(name)(D.data.(name)==-999)=nan;
                  
               end % for k=1:D.nlayers(iname)
            
            end % for iname=1:length(D.names)
      
            %% Finished succesfully
      
            D.iostat    = 1;
            D.read_by   = 'delft3d_io_restart';
            D.read_at   = datestr(now);
            
      %-%catch
      %-%
      %-%   D.iostat = -3;
      %-%   disp (['??? Error using ==> delft3d_io_restart'])
      %-%   disp (['Error reading restart file: ',fname])
      %-%
      %-%end % catch
      
      end % if fid < 0
   
      end %elseif length(tmp)>0
      
   else
   
      D.iostat = -4;
      disp (['??? Error using ==> delft3d_io_restart'])
      
      if     ischar   (varargin{1})
      disp (['MDFFILE wrong : ',varargin{1}])
      elseif isstruct (varargin{1})
      disp (['GRID wrong    : fieldnames:'])
         fieldnames(varargin{1})
      elseif isnumeric(varargin{1})
      disp (['SIZEE wrong   : ',str2num(varargin{1})])
      end
      
   
   end % SIZE   
   
%% Output
   if nargout==1
      varargout = {D};   
   else
      varargout = {D,D.iostat};   
   end

%% WRITE

function iostat=Local_write_ini(filename,varargin),

   %OPT.fillvalue = 0; % -999
   OPT.fillvalue =  -999;
   
   iostat        = 1;
   fid           = fopen(filename,'w');
   if isstr(varargin{1})
      OS           = varargin{1};
      nextarg      = 2;
   else
      OS           = 'windows'; % or 'unix'
      nextarg      = 1;
   end
   
   
   if isstruct(varargin{nextarg})
   %% delft3d_io_ini('write',filename,PLATFORM,DATA);
   
      DATASTRUCT = varargin{nextarg};
      
   %% make sure you can write both DATA as read by
   %% delft3d_io_ini('read',..) as well as substruct DATASTRUCT.data
      if ~isfield(DATASTRUCT,'data')
          DATASTRUCT0 = DATASTRUCT;
          DATASTRUCT.data = DATASTRUCT0;
          clear DATASTRUCT0
      end
      
      fldnames   = fieldnames(DATASTRUCT.data);
      ndata      = length(fldnames);
      datatype   = 'struct';
   else
   %% delft3d_io_ini('write',filename,PLATFORM,waterlevel,u,v,...);
   
      ndata      = length(varargin) - nextarg + 1;
      datatype   = 'arguments';
   end
   
   for idata = 1:ndata
   
      if strcmp(datatype,'arguments')
         dataset = varargin{nextarg + idata - 1};
      elseif strcmp(datatype,'struct')
         fldname = fldnames{idata};
         dataset = DATASTRUCT.data.(fldname);
      end
      
      mmax    = size(dataset,1);
      nmax    = size(dataset,2);
      kmax    = size(dataset,3);
      
      for k=1:kmax
         fprintf_one_layer(fid,dataset(:,:,k),OS,OPT.fillvalue);
      end

      %% extra empty line after every parameter
      fprinteol(fid,OS)
      
   end

   iostat = fclose  (fid);
   
   if iostat==0
      disp(['   delft3d_io_ini: Initialisation file ',filename,' successfully written'])
   else
      disp(['   delft3d_io_ini: Error: Initialisation file ',filename,' NOT successfully written'])
   end

%% fprintf_one_layer

function fprintf_one_layer(fid,dataset,OS,fillvalue,varargin)

   mmax   = size(dataset,1);
   nmax   = size(dataset,2);
   kmax   = size(dataset,3);
   
   % write data set
   % --------------------------------
   for k=1:kmax
      for n=1:nmax
         oneline = dataset(:,n,k);
         oneline(isnan(oneline))= fillvalue;
         fprintf (fid,'%12.4f ',oneline);
         fprinteol(fid,OS);
      end
   end
  %% extra empty line after every layer
  fprinteol(fid,OS);
   
