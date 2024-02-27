function varargout=delft3d_io_eva(cmd,varargin),
%DELFT3D_IO_EVA   read/write Delft3D meteo time series <<beta version!>>
%
% delft3d_io_eva(..) reads Delftd3D flow meteo timetable file.
%
% DAT  = delft3d_io_eva('read',wndfile)
%    returns a DAT where subfield data has the fields:
%    - minutes
%    - precipitation
%    - evaporation
%    - rain_temperature
%
%   [DAT,<iostat>] = delft3d_io_eva('read' ,evafilename,mdffile   );	
%   [DAT,<iostat>] = delft3d_io_eva('read' ,evafilename,keywords  );	
%   [DAT,<iostat>] = delft3d_io_eva('read' ,evafilename,refdatenum);
%
%    returns DAT with field
%    - datenum which contains the matlab datenumbers of the wind times
%      instead of minutes
%    using 
%    (1) mdffilename, string being the file name, from which keyword itdate is read.
%    (2) keywords field from struct read by DELFT3D_IO_MDF.
%    (3) refdatenum, being the matlab datenumber of the reference date (E.g. datenum(2004,1,1))
%
%   <iostat> = delft3d_io_eva('write',filename,DAT.data,mdffile   );	
%   <iostat> = delft3d_io_eva('write',filename,DAT.data,keywords  );	
%   <iostat> = delft3d_io_eva('write',filename,DAT.data,refdatenum);	
%
%   saves DAT.data to a *.eva file in WINDOWS file format (\r\n) where
%   DAT.data is a struct with the above fieldnames
%
%   iostat=1/0/-1/-2/-3 when successfull/cancelled/ error finding/opening/reading file.
%
% where DAT.data has field names as described above.
% * it asks confirmation before overwriting a file (cannot be turned off).
% * it writes WINDOWS end-of-line ASCII characters (\r\n).
%
% DAT  = delft3d_io_eva('write',wndfilename,##,<keyword,value>)
% where the following <keyword,value> pairs are implemented (not case sensitive):
% * userfieldnames: boolean to swith to writing the fieldnames as present in DAT.data, 
%   rather than the pre-defined names. Make sure the field is 
%   the time in minutes since midnight at reference date.
%
%   © G.J. de Boer, Nov 2006, TU Delft.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
     
% >>> same m file structure as delft3d_io_wnd.m
     
%   --------------------------------------------------------------------
%   Copyright (C) 2006-2008 Delft University of Technology
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

% $Id: delft3d_io_eva.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_eva.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_eva(''read''/''write'',filename)'])
end

%% Switch read/write
%% ------------------

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

function varargout=Local_read(fname,varargin)

D.filename       = fname;
iostat           = -1;
D.refdatenum     = [];
H.parameternames = {'precipitation','evaporation','rain_temperature'};
H.units          = {'mm/hour'      ,'mm/hour'    ,'°C'              };

   %% Options
   %% ------------------------

   if nargin>1
      if     ischar   (varargin{1})
      
         %% Use mdf filename
         %% ------------------------

         mdffilename = varargin{1};
         
         [MDF,iostat2] = delft3d_io_mdf('read',mdffilename,'case','lower');
         
         if (iostat2<0)
         
            if nargout==1
               error('??? Error using ==> delft3d_io_eva')
            else
               disp('??? Error using ==> delft3d_io_eva')
               disp(['Cannot find *.mdf file: ''',mdffilename,''''])
               varargout = {[],-1};
               return
            end
         end
         
         D.refdatenum   = time2datenum(MDF.keywords.itdate);
      
      elseif isstruct(varargin{1})
      
         %% Use mdf filename data directly
         %% ------------------------

         MDF.keywords    = varargin{1};
         D.refdatenum    = time2datenum(MDF.keywords.itdate);

      elseif iscell(varargin{1})
      
         %% User specified meta data
         %% ------------------------

         D.refdatenum   = varargin{1};
      
      end

   else
      warning('No reference time passed.')
   end

   D.refdatestr    = datestr(D.refdatenum,1);
   D.ReferenceTime = datestr(D.refdatenum,'yyyymmdd');
   
   %% Keywords
   %% -----------------
   
   H.pol2cart = 0;

   if nargin>2
      if isstruct(varargin{2})
         H = mergestructs(H,varargin{2});
      else
         iargin = 2;
         %% remaining number of arguments is always even now
         while iargin<=nargin-1,
             switch lower ( varargin{iargin})
             % all keywords lower case
             case 'parameternames';iargin=iargin+1;H.parameternames = varargin{iargin};
             otherwise
               error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
             end
             iargin=iargin+1;
         end
      end  
   end

   %% Locate
   %% ------------------------
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      D.iostat = -1;
      disp (['??? Error using ==> delft3d_io_eva'])
      disp (['Error finding meteo file: ',fname])
      
   elseif length(tmp)>0
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
      %% Read
      %% ------------------------
         
      %try
      
         rawdata = load(fname);
         
         minutes = rawdata(:,1);
         
         if isempty(D.refdatenum)
         D.data.minutes       = minutes;
         else
         D.data.datenum       = D.refdatenum + minutes./(60*24);
         D.data.datenum_units = 'days';
         end
         
         for ipar=1:length(H.parameternames)
            parametername               = char(H.parameternames{ipar});
            D.data.(parametername)      = rawdata(:,ipar+1);
            parameternameunits          = [parametername,'_units'];
            D.data.(parameternameunits) = H.units{ipar};
         end
   
         %% Finished succesfully
         %% --------------------------------------
   
         D.iostat    = 1;
         D.read_by   = 'delft3d_io_eva.m';
         D.read_at   = datestr(now);
         
      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> delft3d_io_eva'])
      %   disp (['Error reading meteo file: ',fname])
      %
      %end % catch
   
   end %elseif length(tmp)>0

if nargout==1
   varargout = {D};   
else
   varargout = {D,D.iostat};   
end

end % function varargout=Local_read(fname,varargin)

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(fname,DAT,varargin),

   iostat = 0;
   %if nargin==3
   %   OS = varargin{1};
   %else
   %   OS = computer;
   %end

   if ischar(varargin{1})
      mdffilename  = varargin{1};
     [MDF,iostat2] = delft3d_io_mdf('read',mdffilename);
     
      if iostat2<0
         if nargout==1
            disp('??? Error using ==> delft3d_io_eva')
            disp(['Cannot find *.mdf file: ''',mdffilename,''''])
            varargout = {[],-1};
            return
         end
      end     
     
      D.refdatenum = time2datenum(MDF.keywords.itdate);
   else
      D.refdatenum = varargin{1};
   end

   %% Keywords
   %% -----------------

      H.userfieldnames = false;

      if nargin>2
         if isstruct(varargin{2})
            H = mergestructs(H,varargin{2});
         else
            iargin = 2;
            %% remaining number of arguments is always even now
            while iargin<=nargin-1,
                switch lower ( varargin{iargin})
                % all keywords lower case
                case 'userfieldnames';iargin=iargin+1;H.parameternames = varargin{iargin};
                otherwise
                  error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
                end
                iargin=iargin+1;
            end
         end  
      end

   %% Locate
   %% ------------------------
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
         disp(['Meteo time series already exists: ''',fname,'''']);
         writefile    = input('o<verwrite> / c/<ancel>: ','s');
         if strcmpi(writefile(1),'o')
            writefile = true;
         elseif strcmpi(writefile(1),'c')
            writefile = false;
            iostat    = 0;
         end
      end

   end % length(tmp)==0
   
   if writefile

     %% Open
     %% ------------------------

      %switch lower(OS);
      %case {'pc','pcwin','dos','windows','l','ieee-le'},
      %  fid=fopen(fname,'w','l');
      %case {'hp','sg','sgi','sgi64','unix','b','sol','sol2','ieee-be'},
      %  fid=fopen(fname,'w','b');
      %otherwise,
      %  error(sprintf('Unsupported file format: %s.',PC));
      %end;

      %if fid < 0
      %   
      %   iostat = -2;
      %   disp (['??? Error using ==> delft3d_io_mdf'])
      %   disp (['Error opening file: ',fname])
      %
      %elseif fid > 2
      
         %try
         
            %% Write
            %% ------------------------
	    
            if H.userfieldnames
            
               fldnames = fieldnames(DAT);

               %% find number of columns for pre alocation
               %% ----------------------------------------
               ncol     = length(fldnames);
               
               %% preallocate
               %% ----------------------------------------
               rawdata = nan.*zeros(length(DAT.datenum,ncol));

               %% Insert data
               %% this gives always the correct column order
               %% ----------------------------------------
               for ifld=1:length(fldnames)
                  fldname = char(fldnames{ifild});
                  rawdata(:,ifld) = DAT.(fldname);
               end
            
            else
            
               %{'RH','airtemperature','incoming_solar_radiation'};
               %{'RH','airtemperature','net_solar_radiation'     };
               %{     'airtemperature'                           };
               %{'RH','airtemperature','net_solar_radiation'     };end;
               %{'RH','airtemperature','net_solar_radiation','vapour_pressure'};end;
               %{'RH','airtemperature','cloudcover'              };
               
               %% find number of columns for pre alocation
               %% ----------------------------------------
               ncol = 1;
               if isfield(DAT,'RH'                      );ncol = ncol + 1;end
               if isfield(DAT,'airtemperature'          );ncol = ncol + 1;end
               if isfield(DAT,'incoming_solar_radiation');ncol = ncol + 1;end
               if isfield(DAT,'net_solar_radiation'     );ncol = ncol + 1;end
               if isfield(DAT,'vapour_pressure'         );ncol = ncol + 1;end
               if isfield(DAT,'cloudcover'              );ncol = ncol + 1;end
               
               %% preallocate
               %% ----------------------------------------
               rawdata = nan.*zeros(length(DAT.datenum),ncol);
               
               %% Insert data
               %% this gives always the correct column order
               %% ----------------------------------------
                                                          rawdata(:,1) = (DAT.datenum-D.refdatenum).*24.*60 ;icol = 2;
               if isfield(DAT,'RH'                      );rawdata(:,icol) = DAT.RH                      ;icol = icol + 1;end
               if isfield(DAT,'airtemperature'          );rawdata(:,icol) = DAT.airtemperature          ;icol = icol + 1;end
               if isfield(DAT,'incoming_solar_radiation');rawdata(:,icol) = DAT.incoming_solar_radiation;icol = icol + 1;end
               if isfield(DAT,'net_solar_radiation'     );rawdata(:,icol) = DAT.net_solar_radiation     ;icol = icol + 1;end
               if isfield(DAT,'vapour_pressure'         );rawdata(:,icol) = DAT.vapour_pressure         ;icol = icol + 1;end
               if isfield(DAT,'cloudcover'              );rawdata(:,icol) = DAT.cloudcover              ;icol = icol + 1;end
               
            end % H.userfieldnames
            
            save(fname,'rawdata','-ascii');
            iostat = 1;

         %catch
         %   iostat = -3;
         %end
      
      %end % fid
      
   end % writefile
   
end % function iostat=Local_write(fname,DAT,varargin),

end % function varargout=delft3d_io_eva(cmd,varargin),
   
%% EOF   

