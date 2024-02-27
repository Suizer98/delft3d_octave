function varargout=delft3d_io_dis(cmd,varargin),
%DELFT3D_IO_DIS   wrapper for BCT_IO to read discharge timeseries. <<beta version!>>
%
% DELFT3D_IO_DIS(..) reads Delftd3D flow discharge timetable file.
%
%   [DAT,<iostat>] = DELFT3D_IO_DIS('read' ,disfilename);	
%       [<iostat>] = DELFT3D_IO_DIS('write',disfilename,DAT);
%
% returns a struct DAT with subfield 'data' which has the essential fields:
%
%              Name: 'Discharge : 1'
%          Contents: 'regular'         , 'momentum' , 'walking' , 'power'
%          Location: 'Krabbersgat'
%      TimeFunction: 'non-equidistant' , 'equidistant'
%     ReferenceTime: '20070101'        ,  datenum
%     Interpolation: 'linear'          , 'block'
%           datenum: [nx1 double]
%                 Q: [nx1 double]
%            volume: [nx1 double]
%
% and non-essential fields:
%
%     datenum_units: 'days'
%           Q_units: '[m3/s]'
%      volume_units: '[m3/s]'
%
% and optional fields:
%
%          salinity: [nx1 double]
%       temperature: [nx1 double]
%
% where volume is the cumulative discharge since the start of teh time
% series, taking into account the block or linear interpolation.
%
% The *.bct and *.dis file are similar and can both be read by
% tekal. However, the distribution of information over the
% blocks differs:
%
%  *.bct file: one block has ONE quantity  , TWO support points
%  *.dis file: one block has ALL quantities, ONE support point
%
% The aim of this function is to provide a wrapper for BCT_IO
% such that when read into a struct, bct and dis files behave similar,
% with one substance amd one location per timeserie.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd,
%           delft3d_io_wnd, delft3d_io_tem, delft3d_io_mdf, d3d_attrib

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

% $Id: delft3d_io_dis.m 8847 2013-06-23 13:49:28Z kaaij $
% $Date: 2013-06-23 21:49:28 +0800 (Sun, 23 Jun 2013) $
% $Author: kaaij $
% $Revision: 8847 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_dis.m $

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_bct(''read''/''write'',filename)'])
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

function varargout=Local_read(fname,varargin),

D0.filename      = fname;
iostat           = -1;
D.refdatenum     = [];
H.parameternames = {};
H.units          = {};

   %% Keywords
   %% -----------------

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
      disp (['??? Error using ==> delft3d_io_dis'])
      disp (['Error finding meteo file: ',fname])

   elseif length(tmp)>0

      D0.filedate  = tmp.date;
      D0.filebytes = tmp.bytes;

      %% Read
      %% ------------------------

      %try

         RAW = bct_io('read',fname);
         D   = disunpack(RAW);

         D.ReferenceTime = D.data(1).ReferenceTime; % datestr(D.refdatenum,'yyyymmdd');
         D.refdatenum    = time2datenum(D.ReferenceTime);
         D.refdatestr    = datestr(D.refdatenum,1);
         D.ReferenceTime = num2str(D.ReferenceTime);

         %% check ReferenceDate with mdf file ??

         D.filename  = D0.filename ;
         D.filedate  = D0.filedate ;
         D.filebytes = D0.filebytes;


         % if isempty(D.refdatenum)
         % D.data.minutes       = minutes;
         % else
         % D.data.datenum       = D.refdatenum + minutes./(60*24);
         % D.data.datenum_units = 'days';
         % end
         %
         % for ipar=1:length(H.parameternames)
         %    parametername               = char(H.parameternames{ipar});
         %    D.data.(parametername)      = rawdata(:,ipar+1);
         %    parameternameunits          = [parametername,'_units'];
         %    D.data.(parameternameunits) = H.units{ipar};
         % end

         %% Finished succesfully
         %% --------------------------------------

         D.iostat    = 1;
         D.read_by   = 'delft3d_io_bct.m';
         D.read_at   = datestr(now);

      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> delft3d_io_dis'])
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

function iostat=Local_write(fname,DIS,varargin),

   %% Set defaults for keywords
   %% ----------------------

   OPT.ReferenceTimeMask = 0;

   %% Return defaults
   %% ----------------------

   if nargin==0
      varargout = {OPT};
      return
   end

   iargin = 1;
   while iargin<=nargin-2,
     if isstruct(varargin{iargin})
        OPT = mergestructs('overwrite',OPT,varargin{iargin});
     elseif ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'referencetimemask' ;iargin=iargin+1;OPT.referencetimemask  = varargin{iargin};
       otherwise
          error(['Invalid string argument: %s.',varargin{i}]);
       end
     end;
     iargin=iargin+1;
   end;

   %% Do
   %% ----------------------

   RAW = dispack(DIS,OPT);
   ddb_bct_io('write',fname,RAW);
   iostat = 1;

end % function iostat=Local_write(fname,DAT,varargin),

end % function varargout=delft3d_io_bct(cmd,varargin),

%% EOF

