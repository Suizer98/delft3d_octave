function varargout=DELFT3D_IO_RESTART(cmd,varargin),
%DELFT3D_IO_RESTART   Read/write Delft3D binary restart file 
%
% [DAT,<iostat>] = DELFT3D_IO_RESTART('read' ,restartfilename,mdffile)
%
%   reads a Delft3D binary restart file, and needs also to read the mdffile to be able
%   to infer the contents of the restart, that contains no meta-information whatsoever.
%   The requires meta-information can also be supplied by the user instead:
%
%   [DAT,<iostat>] = DELFT3D_IO_RESTART('read' ,filename,[mmax nmax],nlayers,parameternames);	
%   [DAT,<iostat>] = DELFT3D_IO_RESTART('read' ,filename,GRID       ,nlayers,parameternames);	
%
%   where [mmax nmax], nlayers and parameternames are normally determined from
%   the 5 *.mdf fields mnkmax, sub1, tkemod, namc1, .., namc5.
%
%   Alternatively, parameternames can be supplied as a struct with 2 fields, 
%   where all possible names and layers combinations are (<..> being optional):
%
%   nlayers:        [  1            16   16  
%                    <16>               <16>
%                    <16>           ... <16>           
%                     17                 17 
%                      1                 1 ]
%   parameternames: {'waterlevel'   'u' 'v' 
%                   <'salinity'>       <'temperature'>
%                   <'constituent1' ... 'constituent5'> 
%                    'tke'              'dissipation'          
%                    'ufiltered'        'vfiltered'}
%
% iostat = DELFT3D_IO_RESTART('write',filename,DAT.data,<platform>);
%
%   where DAT is a struct with the above fieldnames, of which the order 
%   is irrelevant, because only the names are relevant.
%
%   iostat = DELFT3D_IO_RESTART('write',filename,DAT.data,<platform>,1);	
%   where DAT is a struct with any fieldname, that are written in the order
%   the fields are present in the struct, rather than in the fixed order 
%   assumed by delft3d (not recommended).
%
%   Where platform can be
%   - u<nix>   , l<inux>
%   - p<c>     , w<indows>, d<os>
%
%   Where iostat=1/0/-1/-2/-3 when successfull/cancelled/ error finding/opening/reading file.
%
%   DELFT3D_IO_RESTART does not overwrite an existing file, but asks for confirmation.
%
%   The restart file is a flat binary file where every 2D matrix is stored as
%   a Fortran unformatted binary record: [(int32) (mmax x nmax float32) (int32)]
%   It contains the following information:
%   1. Water elevation                                          1 matrix  .
%   2. U-velocities                                        Kmax   matrices.
%   3. V-velocities                                        Kmax   matrices.
%   4. Salinity,    only if selected as an active process <Kmax   matrices>.
%   5. Temperature, only if selected as an active process <Kmax   matrices>.
%   6. Constituent number 1, 2, 3 to the last constituent
%           chosen, only if selected                      <Kmax   matrixes>.
%   7. Turbulence quantities, only TKE when k-l model is
%      is selected and TKE and dissipation when k-epsilon 
%      model is selected as the turbulence model          <Kmax+1 matrices>.
%      NOTE: turbulence info cannot be passed in the ASCII *.ini file.
%   8. Secondary flow                                           1 matrix   .
%
% See also: delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, 
%           delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_src, delft3d_io_thd, 
%           delft3d_io_wnd, trirst
     
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

% $Id: delft3d_io_restart.m 16161 2020-01-02 17:16:02Z kaaij $
% $Date: 2020-01-03 01:16:02 +0800 (Fri, 03 Jan 2020) $
% $Author: kaaij $
% $Revision: 16161 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_restart.m $

if nargin<3
   error('Syntax: delft3d_io_restart(''read/write'' ,filename ,mdffile,...')
end

%% Switch read/write

switch lower(cmd)

case 'read'

  [DAT,iostat] = Local_read(varargin{1:end});

  if     nargout <2

     varargout  = {DAT};
     
     if iostat<1
        error('Error reading.')
     end
  
  elseif nargout  == 2
  
     varargout  = {DAT,iostat};
  
  elseif nargout >2
  
     error('too much output parameters: 1 or 2')
  
  end

case 'write'

  iostat = Local_write(varargin{1:end});
  
  if nargout ==1
  
     varargout = {iostat};
  
  elseif nargout >1
  
     error('too much output parameters: 0 or 1')
  
  end
  
end;

% ------------------------------------
% --READ------------------------------
% ------------------------------------

function varargout=Local_read(fname,varargin),

D.filename  = fname;
D.iostat    = -3;
OPT.debug   = 1;

if nargin==1
   error('At least 3 arguments required for reading restart file.')
end
   
%% Get info on contents of restart file

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
      if D.kmax > 1
      MDF.keywords.tkemod = char(lower(MDF.keywords.tkemod));
      else
      MDF.keywords.tkemod = [];    
      end
   
      j=0;
      j=j+1;PAR.nlayers(j)= [     1];PAR.names{j} = 'waterlevel';
      j=j+1;PAR.nlayers(j)= [D.kmax];PAR.names{j} = 'u'         ;
      j=j+1;PAR.nlayers(j)= [D.kmax];PAR.names{j} = 'v'         ;
      
      if ~(isempty(strfind(char(MDF.keywords.sub1(1)),'S'       )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'salinity'     ;end
      if ~(isempty(strfind(char(MDF.keywords.sub1(2)),'T'       )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'temperature'  ;end
      
      if  (isfield(             MDF.keywords,'namc1')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc1 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent1' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc2')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc2 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent2' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc3')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc3 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent3' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc4')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc4 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent4' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc5')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc5 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent5' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc6')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc6 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent6' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc7')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc7 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent7' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc8')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc8 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent8' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc9')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc9 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent9' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc10')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc10 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent10' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc11')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc11 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent11' ;end
      end
      
      if  (isfield(             MDF.keywords,'namc12')             );
      if ~(isempty(strtrim(char(MDF.keywords.namc12 )            )));j=j+1;PAR.nlayers(j)= [D.kmax  ];PAR.names{j} = 'constituent12' ;end
      end
      
      if ~(isempty(strfind (char(MDF.keywords.tkemod),'k-epsilon')));j=j+1;PAR.nlayers(j)= [D.kmax+1];PAR.names{j} = 'tke'          ;
                                                                     j=j+1;PAR.nlayers(j)= [D.kmax+1];PAR.names{j} = 'dissipation'  ;end
      if ~(isempty(strfind (char(MDF.keywords.tkemod),'k-l'      )));j=j+1;PAR.nlayers(j)= [D.kmax+1];PAR.names{j} = 'tke'          ;end
     %if ~(isempty( strfind(char(MDF.keywords.sub1  ),'I'        )));j=j+1;PAR.nlayers(j)= [       1];PAR.names{j} = 'secondaryflow';end
   
      j=j+1;PAR.nlayers(j)= [   1];PAR.names{j} = 'ufiltered' ;
      j=j+1;PAR.nlayers(j)= [   1];PAR.names{j} = 'vfiltered' ;
   
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
   
         elseif fid > 2
   
            %  Test for platform (and reopen)
            % ------------------------
            %  Unformated binary access fortran files as the ones written by 
            %  Delft3D FLOW contain a one 4bytes header and one 4 bytes 
            %  trailer (being equal to the header) per 2D mxn matrix.
            %  The total file size is thus kmax x (mmax x nmax + 8)
            %  See: http://local.wasp.uwa.edu.au/~pbourke/dataformats/fortran/
            %  The header can be tested to see what platform the file was written on.
            %  It should also eb skipped when reading data.
            %  ------------------------
            
            header = fread(fid,1,'int32');
            
            if (4*D.mmax*D.nmax)~=header,     % If not a match ...
              fclose(fid);
              fid     = fopen(fname,'r','l'); % Try PC format ...
              header2 = header;
              header  = fread(fid,1,'int32');
            end;
            if (4*D.mmax*D.nmax)~=header,     % If not a match ...
              fclose(fid);
              disp('??? Error using ==> delft3d_io_restart')
              disp(['Specified grid size ',num2str(D.mmax),'x',num2str(D.nmax),'=',num2str(D.mmax.*D.nmax),...
                    ' does not match nrecord length in file that is ',...
                    num2str(header2/4),' or ',num2str(header/4)]);
              D.iostat= -4;
              fid     = -1 ;
            end;
            
         end
            
         if fid > 2
   
      %% Read
            
         try
            
            mask      =  PAR.nlayers > 0;
            D.nlayers =  PAR.nlayers(mask);
            D.names   = {PAR.names{mask}};
            
            D.number_of_mapfields = D.filebytes./4./(D.mmax*D.nmax+ 2);
         
            if ~(sum(D.nlayers) == D.number_of_mapfields )
               warning(['Requested ',num2str(sum(D.nlayers)),' 2D map fields, while file contains ',num2str(D.number_of_mapfields),...
                        ' map fields of ',num2str(D.mmax),' x ',num2str(D.nmax)])
            end
            
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
   
                  ARRAY = fread(fid,SIZE,'float32');
                  
                  if ~isequal(size(ARRAY),SIZE)
                     break
                     D.iostat = -4;
                  else
                     D.data.(name)(1:D.mmax,1:D.nmax,k) = ARRAY;
                  end
                  
               %% Fortran trailer
                  
                  trailer = fread(fid,1,'int32');
                  
               %% Subsequent fortran footer when not EOF
                  
                  if ~(iname==length(D.names ) & ...
                       k    ==D.nlayers(iname))
                     
                  footer = fread(fid,1,'int32');
                  end
                  
               end % for k=1:D.nlayers(iname)
            
            end % for iname=1:length(D.names)
      
         %% Finished succesfully
      
            D.iostat    = 1;
            D.read_by   = 'delft3d_io_restart';
            D.read_at   = datestr(now);
            
            fclose(fid);
            
         catch
         
            D.iostat = -3;
            disp (['??? Error using ==> delft3d_io_restart'])
            disp (['Error reading restart file: ',fname])
         
         end % catch
      
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

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(fname,DAT,varargin),

   iostat  = 0;
   OPT.ask = true;
   
   if nargin==3 && ~isempty(varargin{3})
      OS = varargin{1};
   else
      OS = computer;
   end

   if nargin==4
      userfieldnames = varargin{1};
   else
      userfieldnames = false;
   end
   
   if nargin >= 5
       OPT = setproperty(OPT,varargin{3:end});
   end

%% Locate
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
          if OPT.ask
              writefile    = input('File already exists, o<verwrite> / c/<ancel>: ','s');
              if strcmpi(writefile(1),'o')
                  writefile = true;
              elseif strcmpi(writefile(1),'c')
                  writefile = false;
                  iostat    = 0;
              end
          else
              writefile = true;
          end
      end

   end
   
   if writefile

  %% Open

      switch lower(OS);
      case {'pc','pcwin','pcwin64','dos','windows','l','linux','ieee-le'},
        fid=fopen(fname,'w','l');
      case {'hp','sg','sgi','sgi64','unix','b','sol','sol2','ieee-be'},
        fid=fopen(fname,'w','b');
      otherwise,
        error(sprintf('Unsupported file format: %s.',OS));
      end;

      if fid < 0
         
         iostat = -2;
         disp (['??? Error using ==> delft3d_io_restart'])
         disp (['Error opening file: ',fname])
      
      elseif fid > 2
      
         try
         
         %% Write
	    
            if userfieldnames
            
               fldnames = fieldnames(DAT);
               for ifld=1:length(fldnames)
                  fldname = char(fldnames{ifild});
                  WRITEfortranbinaryrecord(fid,DAT.(fldname));
               end
            
            else
            
               if isfield(DAT,'waterlevel'  );WRITEfortranbinaryrecord(fid,DAT.waterlevel  );end
               if isfield(DAT,'u'           );WRITEfortranbinaryrecord(fid,DAT.u           );end
               if isfield(DAT,'v'           );WRITEfortranbinaryrecord(fid,DAT.v           );end
               if isfield(DAT,'salinity'    );WRITEfortranbinaryrecord(fid,DAT.salinity    );end
               if isfield(DAT,'temperature' );WRITEfortranbinaryrecord(fid,DAT.temperature );end
               if isfield(DAT,'constituent1');WRITEfortranbinaryrecord(fid,DAT.constituent1);end
               if isfield(DAT,'constituent2');WRITEfortranbinaryrecord(fid,DAT.constituent2);end
               if isfield(DAT,'constituent3');WRITEfortranbinaryrecord(fid,DAT.constituent3);end
               if isfield(DAT,'constituent4');WRITEfortranbinaryrecord(fid,DAT.constituent4);end
               if isfield(DAT,'constituent5');WRITEfortranbinaryrecord(fid,DAT.constituent5);end
               if isfield(DAT,'constituent6');WRITEfortranbinaryrecord(fid,DAT.constituent6);end
               if isfield(DAT,'constituent7');WRITEfortranbinaryrecord(fid,DAT.constituent7);end
               if isfield(DAT,'constituent8');WRITEfortranbinaryrecord(fid,DAT.constituent8);end
               if isfield(DAT,'constituent9');WRITEfortranbinaryrecord(fid,DAT.constituent9);end
               if isfield(DAT,'constituent10');WRITEfortranbinaryrecord(fid,DAT.constituent10);end
               if isfield(DAT,'constituent11');WRITEfortranbinaryrecord(fid,DAT.constituent11);end
               if isfield(DAT,'constituent12');WRITEfortranbinaryrecord(fid,DAT.constituent12);end
               if isfield(DAT,'tke'         );WRITEfortranbinaryrecord(fid,DAT.tke         );end
               if isfield(DAT,'dissipation' );WRITEfortranbinaryrecord(fid,DAT.dissipation );end
               if isfield(DAT,'ufiltered'   );WRITEfortranbinaryrecord(fid,DAT.ufiltered   );end
               if isfield(DAT,'ufiltered'   );WRITEfortranbinaryrecord(fid,DAT.ufiltered   );end
            
            end
            
            fclose(fid);
            iostat = 1;

         catch
            iostat = -3;
         end
      
      end % fid
      
   end % writefile


% ------------------------------------
% --WRITEfortranbinaryrecord----------
% ------------------------------------

function WRITEfortranbinaryrecord(fid,MAP) % different for 64 bit?

   dim    =  size(MAP);
   header = 4*prod(dim(1:2));

   for k=1:size(MAP,3)
     fwrite(fid,header    ,'int32');
     fwrite(fid,MAP(:,:,k),'float32');
     fwrite(fid,header    ,'int32');
   end;


% ------------------------------------
% --FILE STRUCTURE INFO---------------
% ------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subroutine wrirst(lundia    ,runid     ,itrstc    ,nmaxus    ,mmax      , &
%                & nmax      ,kmax      ,lstsci    ,ltur      ,s1        , &
%                & u1        ,v1        ,r1        ,rtur1     ,umnldf    , &
%                & vmnldf    ,gdp       )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%!--description-----------------------------------------------------------------
% This routine writes the relevant output arrays to
% the restart file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   !
%   !-----New file => open file
%   !
%   open (lunrst, file = filrst(:8 + lrid + 16), form = 'unformatted',          &
%        & status = 'new')
%   !
%   !-----write restart values S1, U1, V1, R1 and RTUR1
%   !
%   write (lunrst) ((s1(n, m), m = 1, mmax), n = 1, nmaxus)
%   !
%   do k = 1, kmax
%      write (lunrst) ((u1(n, m, k), m = 1, mmax), n = 1, nmaxus)
%   enddo
%   !
%   do k = 1, kmax
%      write (lunrst) ((v1(n, m, k), m = 1, mmax), n = 1, nmaxus)
%   enddo
%   !
%   do l = 1, lstsci
%      do k = 1, kmax
%         write (lunrst) ((r1(n, m, k, l), m = 1, mmax), n = 1, nmaxus)
%      enddo
%   enddo
%   !
%   do l = 1, ltur
%      do k = 0, kmax
%         write (lunrst) ((rtur1(n, m, k, l), m = 1, mmax), n = 1, nmaxus)
%      enddo
%   enddo
%   !
%   !-----write filtered velocities to restart file to allow for
%   !     restarts using subgrid viscosity model
%   !
%   write (lunrst) ((umnldf(n, m), m = 1, mmax), n = 1, nmaxus)
%   write (lunrst) ((vmnldf(n, m), m = 1, mmax), n = 1, nmaxus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subroutine turclo(j         ,nmmaxj    ,nmmax     ,kmax      ,ltur      , &
%                & icx       ,icy       ,tkemod    ,vicoww    ,dicoww    , &
%                & kcs       ,kfu       ,kfv       ,kfs       ,s0        , &
%                & dps       ,hu        ,hv        ,u0        ,v0        , &
%                & rtur0     ,thick     ,sig       ,rho       ,vicuv     , &
%                & vicww     ,dicuv     ,dicww     ,windsu    ,windsv    , &
%                & z0urou    ,z0vrou    ,bruvai    ,rich      ,dudz      , &
%                & dvdz      ,gdp       )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%!!--description-----------------------------------------------------------------
%! Computes eddy viscosity and eddy diffusivity.
%! dependent of closure model (ltur).
%! ltur=0    algebraic model
%! ltur=1    k-L model
%! ltur=2    k-epsilon model  (SANCTUM-model)
%! For ltur=1,2 transport equations are solved.
%! - For tkemod = 'Constant   ' user input is
%! used (special TAISEI)
%!
%! Reference: R.E. Uittenbogaard, J.A.Th.M. van
%! Kester, G.S. Stelling, Implementation of three
%! turbulence models in 3D-TRISULA for rectangular
%! grids, WL-rapport Z81, april 1992)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EOF