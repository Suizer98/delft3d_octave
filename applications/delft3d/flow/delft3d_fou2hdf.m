function varargout = delft3d_fou2hdf(directory,RUNID,varargin);
%DELFT3D_FOU2HDF  rewrite ascii fourier file as hdf file
%
%          delft3d_fou2hdf(directory,RUNID)
% status = delft3d_fou2hdf(directory,RUNID)
%
% Parses Delft3D fourier tekal file 'fourier.$RUNID'
% to HDF4 V groups file 'fourier_$RUNID.hdf'.
% Handy for LAAAARGE fourier files.
%
% It also saves to intermediate matfiles
%  fourier_tek_$RUNID.mat and 'fourier_$RUNID.mat'. 
% When something fails during fou2hdf, at next call to fou2hdf 
% these  files are used if they exist to save time. Especially 
% reading a large (> 500 Mb) ascii tekal file takes long.
% Delete these files yourselve. 
%
% E.g.: A 1.5 Gb ASCII file becomes a 330 Mb HDF files after 1 hour processing.
%
% delft3d_fou2hdf(directory,RUNID    ) prompts for confirmation if there's any exisitng hdf
% delft3d_fou2hdf(directory,RUNID,'o') overwrites any exisitng hdf
% delft3d_fou2hdf(directory,RUNID,'c') cancels when there's an any exisitng hdf
%
% Limitation: When one parameter is calculated form multiple sub periods
% * Starttime fourier analysis :    25200.000
% * Stoptime  fourier analysis :    25920.000
% only the first is processed to hdf.
%
% Note that Delft3D averages vector quantities to zeta points and 
% rotated to global directions (see flow\output\wrfouv.f90).
%
% See also: DELFT3D_IO_FOU, FFT_ANAL, T_TIDE

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
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: delft3d_fou2hdf.m 11455 2014-11-26 18:09:49Z youngtoti.x $
% $Date: 2014-11-27 02:09:49 +0800 (Thu, 27 Nov 2014) $
% $Author: youngtoti.x $
% $Revision: 11455 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_fou2hdf.m $
% $Keywords:

%% Initialisation

   % To save memory with large 3D files
   % - data are stored as single precision
   % - the data struct are defined global
   
   OPT.single = 1;
   
   global MAT TEK
   
   % TEK and MAT are defined as global variables,
   % to save memory with large 3D files so Matlab does not make
   % a copy when passing these variables to fou2struct3d.

%% Definitions
   
   tekfile    = path2os([directory,filesep,'fourier.',    RUNID]);
   tekmatfile = path2os([directory,filesep,'fourier_tek_',RUNID,'.mat']);
   matfile    = path2os([directory,filesep,'fourier_',    RUNID,'.mat']);
   hdffile    = path2os([directory,filesep,'fourier_',    RUNID,'.hdf']);
   mdffile    = path2os([directory,filesep,               RUNID,'.mdf']);

%% Read data

if exist(matfile,'file')==2
   
   disp(['Loading mat fourier file, please wait ...'])
   MAT = load(matfile);

else
   
   if exist(tekmatfile,'file')==2
      
      disp(['Loading mat version of ASCII fourier file, please wait ...'])
      t0  = clock;
      TEK = load(tekmatfile);
      dt  = etime(clock,t0);
      disp([' ,, in ',num2str(dt),' sec.'])
      
      %% Transform all data to single:
      %% - to save matlab memory (Noter that when casting later to MAT 
      %    we have a temporary duplication of all fourier info.)
      %  - to save hdf disk space
      %  The ASCII TEKAL file has 7 digits per number,
      %  which is effectively also single precision, so there's no loss of data.
      %  In earlier versions of fou2hdf we did not do this casting, so 
      %  we perform it anyway here now.
      %  --------------------------------
      
      if OPT.single
         for ifield=1:length(TEK.Field)
            TEK.Field(ifield).Data = single(TEK.Field(ifield).Data);
         end
      end
      
   else
      
      disp(['Reading ASCII fourier file, please wait ...'])
      t0  = clock;
      TEK = tekal('open',tekfile,'loaddata');
      dt  = etime(clock,t0);
      dt  = etime(clock,t0);
      disp([' ,, in ',num2str(dt),' sec.'])

      %% Transform all data to single:
      %  - to save matlab memory (Note that when casting later to MAT 
      %    we have a temporary duplication of all fourier info.)
      %  - to save hdf disk space
      %  The ASCII TEKAL file has 7 digits per number,
      %  which is effectively also single precision, so there's no loss of data.
      %  --------------------------------

      if OPT.single
         for ifield=1:length(TEK.Field)
            TEK.Field(ifield).Data = single(TEK.Field(ifield).Data);
         end
      end
      
      save(tekmatfile,'-STRUCT','TEK','-V6');
   
   end
   
   %% Cast TEK to MAT
   %  In fou2struct3d MAT and TEK are also defined global
   %  Other solution is to include fou2struct3d to this file and 
   %  make it a nested function.
   %  --------------------------------
   
   disp(['Parsing ASCII fourier file data to matlab struct, please wait ...'])
   t0  = clock;
   MAT = delft3d_fou2struct3d(TEK);
   dt  = etime(clock,t0);
   disp([' ,, in ',num2str(dt),' sec.'])
   
   clear global TEK %TEK = struct([]);
   
   save(matfile,'-STRUCT','MAT','-V6');

end

%% Add meta information

   MAT.directory   = directory;
   MAT.RUNID       = RUNID;
   
   MAT.Id          = '$Id: delft3d_fou2hdf.m 11455 2014-11-26 18:09:49Z youngtoti.x $';
   MAT.Date        = '$Date: 2014-11-27 02:09:49 +0800 (Thu, 27 Nov 2014) $';
   MAT.Author      = '$Author: youngtoti.x $';
   MAT.Revision    = '$Revision: 11455 $';
   MAT.HeadURL     = '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_fou2hdf.m $';
   
   %% Obtain reference date from mdf file, otherwise 
   %% phase information is utterly useless (due to nodal corrections).
   
   try
      mdf                   = delft3d_io_mdf('read',[directory,filesep,RUNID,'.mdf'],'case','lower');
      MAT.reference_datenum = time2datenum(mdf.keywords.itdate);
      MAT.reference_date    = datestr     (MAT.reference_datenum);
   catch
      disp(['Cannot add reference time, because '])
      warning(['mdf file ',RUNID,'.mdf is not found in ',directory])
   end

%% Save to HDF

   status        = hdfvsave(hdffile,MAT,varargin{:});

%% Output

   if status >= 0
      disp(['Saved ',hdffile,' succesfully.']);
   else
      disp(['Error saving ',hdffile,'']);
   end
   
   if nargout==1
      varargout = {status};
   elseif nargout==2
      varargout = {MAT,status};
   end
   
   clear global MAT %MAT = struct([]);

