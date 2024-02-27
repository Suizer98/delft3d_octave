function varargout = delft3d_io_wnd(cmd,varargin)
%DELFT3D_IO_WND   read/write Delft3D wind time series <<beta version!>>
%
% DELFT3D_IO_WND(..) reads Delftd3D flow wind timetable file.
%
% DAT  = DELFT3D_IO_WND('read',wndfile)
%    returns a DAT where subfield data has the fields:
%    - datenum / minutes
%    - speed
%    - direction (nautical convenction in degrees)
%
% [DAT,<iostat>] = DELFT3D_IO_WND('read',wndfilename,mdffilename)
% [DAT,<iostat>] = DELFT3D_IO_WND('read',wndfilename,keywords   )
% [DAT,<iostat>] = DELFT3D_IO_WND('read',wndfilename,refdatenum )
%
%    returns DAT with field
%    - datenum which contains the matlab datenumbers of the wind times
%      instead of minutes
%    using 
%    (1) mdffilename, string being the file name, from which keyword itdate is read.
%    (2) keywords field from struct read by DELFT3D_IO_MDF.
%    (3) refdatenum, being the matlab datenumber of the reference date (E.g. datenum(2004,1,1))
%
% DAT  = delft3d_io_wnd('read',wndfilename,##,<keyword,value>)
% where the following <keyword,value> pairs are implemented (not case sensitive):
% * pol2cart:       adds also u and v wind components to speed and direction
% * parameternames: renames field 'speed'     to parameternames{1}
%                   and     field 'direction' to parameternames{2}
%
% <iostat> = DELFT3D_IO_WND('write',wndfilename,DAT.data,mdffilename)
% <iostat> = DELFT3D_IO_WND('write',wndfilename,DAT.data,keywords)
% <iostat> = DELFT3D_IO_WND('write',wndfilename,DAT.data,refdatenum)
%
%   saves DAT.data to a *.wnd file in WINDOWS file format (\r\n) where
%   DAT.data is a struct with the above fieldnames
%
%   iostat=1/0/-1/-2/-3 when successfull/cancelled/ error finding/opening/reading file.
%
% where DAT.data has field names datenum, speed, direction as described above.
% * it asks confirmation before overwriting a file (cannot be turned off).
% * it writes WINDOWS end-of-line ASCII characters (\r\n).
%
% iostat = DELFT3D_IO_WND('write',wndfilename,DAT,<##>,<keyword,value>)
%
% writes struct with fieldnames
%
%    - datenum   / minutes
%    - speed     / UP          (m/s)
%    - direction / DD          (nautical convenction in degrees North)
%
% where UP and DD are the fieldnames in the KNMI files
%
% The following <keyword,value> pairs are implemented (not case sensitive):
%
% * userfieldnames: boolean to swith to writing the fieldnames as present in DAT.data, 
%   rather than the pre-defined names. Make sure the field is 
%   the time in minutes since midnight at reference date.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
%           KNMIHYDRA, HMCZ_WIND_READ

% >>> same m file structure as delft3d_io_tem.m

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2008 Delft University of Technology
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

% $Id: delft3d_io_wnd.m 8677 2013-05-24 13:03:13Z kaaij $
% $Date: 2013-05-24 21:03:13 +0800 (Fri, 24 May 2013) $
% $Author: kaaij $
% $Revision: 8677 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_wnd.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_wnd(''read''/''write'',filename)'])
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

D.filename       = fname;
iostat           = -1;
D.refdatenum     = [];
H.parameternames = {'speed','direction'};
H.units          = {'m/s'  ,'°'        };

%% Options

   if nargin>1
      
      if     ischar   (varargin{1})

         %% Use mdf filename
        
         mdffilename = varargin{1};
        
         [MDF,iostat2] = delft3d_io_mdf('read',mdffilename,'case','lower');
         
         if (iostat2<0)
            if nargout==1
               error('??? Error using ==> delft3d_io_wnd')
            else
               disp('??? Error using ==> delft3d_io_wnd')
               disp(['Cannot find *.mdf file: ''',mdffilename,''''])
               varargout = {[],-1};
               return
            end
         end     

         D.refdatenum   = time2datenum(MDF.keywords.itdate);

      elseif isstruct(varargin{1})
      
         %% Use mdf filename data directly

         MDF.keywords    = varargin{1};
         D.refdatenum    = time2datenum(MDF.keywords.itdate);

      elseif iscell(varargin{1})
      
         %% User specified meta data

         D.refdatenum   = varargin{1};
      
      end

   else
      warning('No reference time passed.')
   end

   D.refdatestr    = datestr(D.refdatenum,1);
   D.ReferenceTime = datestr(D.refdatenum,'yyyymmdd');
   
%% Keywords
   
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
             case 'pol2cart'      ;iargin=iargin+1;H.pol2cart       = varargin{iargin};
             case 'parameternames';iargin=iargin+1;H.parameternames = varargin{iargin};
             otherwise
               error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
             end
             iargin=iargin+1;
         end
      end  
   end
   
%% Locate
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      D.iostat = -1;
      disp (['??? Error using ==> delft3d_io_wnd'])
      disp (['Error finding meteo file: ',fname])
      
   elseif length(tmp)>0
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
   %% Read
         
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
   
         D.iostat    = 1;
         D.read_by   = 'delft3d_io_wnd.m';
         D.read_at   = datestr(now);
         D.directional_convention = 'nautical';
         D.comment                = '0° = from North, 90° = from the East ,...';
         
      %% Add u,v

         if H.pol2cart
           [D.data.u,...
            D.data.v] = pol2cart(deg2rad(degN2deguc(D.data.direction)),...
                                                    D.data.speed);
            D.data.u_units = 'm/s';
            D.data.v_units = 'm/s';
         end
         
      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> delft3d_io_wnd'])
      %   disp (['Error reading wind file: ',fname])
      %
      %end % catch
   
   end %elseif length(tmp)>0

if nargout==1
   varargout = {D};   
else
   varargout = {D,D.iostat};   
end

end % function varargout=Local_read(fname,varargin),

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(fname,DAT,time_option,varargin),

   D.refdatenum = [];
   iostat       = 0;
   
%% Options
   
   if odd(nargin)

      if     ischar   (time_option)

         %% Use mdf filename
        
         [MDF,iostat2] = delft3d_io_mdf('read',time_option,'case','lower');
         
         if (iostat2<0)
            if nargout==1
               error('??? Error using ==> delft3d_io_wnd')
            else
               disp('??? Error using ==> delft3d_io_wnd')
               disp(['Cannot find *.mdf file: ''',mdffilename,''''])
               varargout = {[],-1};
               return
            end
         end     

         D.refdatenum    = time2datenum(MDF.keywords.itdate);
         DAT.datenum = (DAT.minutes./60/24)+D.refdatenum;

      elseif isstruct(time_option)
      
         %% Use mdf filename data directly

         MDF.keywords    = time_option;
         D.refdatenum    = time2datenum(MDF.keywords.itdate);
         DAT.datenum = (DAT.minutes./60/24)+D.refdatenum;         

      elseif iscell(time_option)
      
         %% User specified meta data

         D.refdatenum    = time_option;
         
      elseif isnumeric(time_option)
      
         %% User specified meta data

         D.refdatenum    = time_option;
         DAT.datenum = (DAT.minutes./60/24)+D.refdatenum;
      
      elseif isstruct(time_option)
      
         %% Use already read mdf data

         error('Struct input of mdf not implemented yet.')
      
      end
      
   end % if odd(nargin)

%% Keywords

      H.userfieldnames = false;
      
      if nargin>3
         D.refdatenum = varargin{:};
      end

%% Locate
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
         disp(['Wind series already exists: ''',fname,'''']);
         writefile    = input('o<verwrite> / c<ancel>: ','s');
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

         %try
         
            %% Write
	    
            if H.userfieldnames
            
               fldnames = fieldnames(DAT);

               %% find number of columns for pre alocation
               ncol     = length(fldnames);
               
               %% preallocate
               rawdata = nan.*zeros(length(DAT.datenum,ncol));

               %% Insert data
               %  this gives always the correct column order
               for ifld=1:length(fldnames)
                  fldname = char(fldnames{ifild});
                  rawdata(:,ifld) = DAT.(fldname);
               end
            
            else
            
               %% find number of columns for pre alocation
               ncol = 3; % minutes, speed, direction
               
               %% preallocate
               if isfield(DAT,'datenum')
                   rawdata = nan.*zeros(length(DAT.datenum),ncol);
               elseif isfield(DAT,'minutes')
                   rawdata = nan.*zeros(length(DAT.minutes),ncol);
               end
               
               %% Insert data
               %  this gives always the correct column order
               
               if isempty(D.refdatenum)
                  if     isfield(DAT,'datenum')
                     D.refdatenum = DAT.datenum(1);
                  end
               end
               
               if     isfield(DAT,'datenum')
                  rawdata(:,1) = (DAT.datenum-D.refdatenum).*24.*60 ;
               elseif isfield(DAT,'minutes')
                  rawdata(:,1) = (DAT.minutes);
               end
               
               icol = 2;

               if     isfield(DAT,'speed'       );rawdata(:,icol) = DAT.speed                   ;icol = icol + 1;
               elseif isfield(DAT,'UP'          );rawdata(:,icol) = DAT.UP                      ;icol = icol + 1;
               end
               if     isfield(DAT,'direction'   );rawdata(:,icol) = DAT.direction               ;icol = icol + 1;
               elseif isfield(DAT,'DD'          );rawdata(:,icol) = DAT.DD                      ;icol = icol + 1;
               end
               
            end % H.userfieldnames
            
            save(fname,'rawdata','-ascii');
            iostat = 1;

      %end % fid
      
   end % writefile
   
end % function iostat=Local_write(fname,DAT,varargin),

end % function varargout=delft3d_io_tem(cmd,varargin),
   
%% EOF   

