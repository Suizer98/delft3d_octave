function indices = vs_trih_station_index(ncfile,varargin)
%indexHis   Read/show index of history station (obs point)
%
%   index = dflowfm.indexHis(ncfile,station_name)
%
% returns the index of a station called stationname.
%
% Leading and trailing blanks of the station name are ignored,
% both in the specified names, as in the names as present
% in the history file.
%
% When the specified name is not found, an empty value
% (0x0 or 0x1) is returned.
%
% dflowfm.indexHis(ncfile,stationname,method)
% to choose a method:
% - 'strcmp'   gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern
%              stationname is present (default).
%
% dflowfm.indexHis(ncfile) prints a list with all
% station names and indices on screen with 7 columns:
% index,name,x,y and for Delft3D vs_trih2nc files: m,n,angle.
%
% S = dflowfm.indexHis(ncfile) returns a struct S.
%
% Vectorized over 1st dimension of station_name.
%
% See also: vs_trih2nc, vs_trih_station_index, adcp_plot, nc2struct

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: indexHis.m 9020 2013-08-09 13:52:56Z boer_g $
% $Date: 2013-08-09 21:52:56 +0800 (Fri, 09 Aug 2013) $
% $Author: boer_g $
% $Revision: 9020 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/indexHis.m $
% 2009 sep 28: added implementation of WAQ hda files [Yann Friocourt]

   method = 'strcmp';
   method = 'strmatch';

if nargin==1
   method = 'list';
end

if nargin > 1
   stationname = varargin{1};
end

if nargin > 2
   method = varargin{2};
end

%% Do we work with a FLOW or WAQ file?

   if any(strfind(nc_attget(ncfile,nc_global,'source'),'UNSTRUC'))
   OPT.type = 'i';
   ST.Description = 'DFLOW monitoring point (*.obs) time serie.';
   else
   OPT.type = 'mn';
   ST.Description = 'Delft3D-FLOW monitoring point (*.obs) time serie.';
   end

%% Load all station names

   namst = nc_varget(ncfile,'station_name');
   nstat = size(namst,1);

%% Cycle all stations and quit immediatlety
%  when a match has been found

switch method

case 'list' %this one should be first in case

   if nc_isvar(ncfile,'station_longitude')
   lon  = nc_varget(ncfile,'station_longitude');
   lat  = nc_varget(ncfile,'station_latitude');
   else
   lon  = repmat(nan,[nstat 1]);
   lat  = repmat(nan,[nstat 1]);
   end
   if nc_isvar(ncfile,'station_x_coordinate')
   x   = nc_varget(ncfile,'station_x_coordinate');
   y   = nc_varget(ncfile,'station_y_coordinate');
   else
   x = repmat(nan,[nstat 1]);
   y = repmat(nan,[nstat 1]);
   end
   
   if strcmpi(OPT.type,'mn');
   m   = nc_varget(ncfile,'station_m_index');
   n   = nc_varget(ncfile,'station_n_index');   
   ang = nc_varget(ncfile,'station_angle');
   else
   ind = nan.*x;
   ang = nan.*x;
   end

   if nargout==0

       disp(['| ',ncfile])
       if strcmpi(OPT.type,'mn');
       disp('+------------------------------------------------------------------------->')
       disp('| index         name         m    n     angle  (lon,lat) (x,y)')
       disp('+-----+--------------------+-----------+-----+---------------------------->')
       else
       disp('+--------------------------------------------------------------------------->')
       disp('| index         name                            (lon,lat) (x,y)')
       disp('+-----+----------------------------------------+---------------------------->')
       end

       for istat=1:nstat

       if strcmpi(OPT.type,'mn');
           disp([' ',...
               pad(num2str(      istat           ), -5,' '),' ',...
               pad(        namst(istat,:)         , 20,' '),' ',...
               pad(num2str(m    (istat)          ),-5 ,' '),' ',...
               pad(num2str(n    (istat)          ),-5 ,' '),' ',...
               pad(num2str(ang  (istat),'%+3.1f' ),-5 ,' '),' ',...
               pad(num2str(lon  (istat),'%+9.5f' ),-10,' '),' ',...
               pad(num2str(lat  (istat),'%+9.5f' ), 10,' '),' ',...
               pad(num2str(x    (istat),'%+16.6f'),-14,' '),' ',...
               pad(num2str(y    (istat),'%+16.6f'), 14,' ')]);
       else
           disp([' ',...
               pad(num2str(      istat           ), -5,' '),' ',...
               pad(        namst(istat,:)         , 40,' '),' ',...
               pad(num2str(lon  (istat),'%+9.5f' ),-10,' '),' ',...
               pad(num2str(lat  (istat),'%+9.5f' ), 10,' '),' ',...
               pad(num2str(x    (istat),'%+16.6f'),-14,' '),' ',...
               pad(num2str(y    (istat),'%+16.6f'), 14,' ')]);
       end

       end

       istat = nan;

   elseif nargout==1

       indices.namst = namst;
       if strcmpi(OPT.type,'mn');
       indices.m     = m   ;
       indices.n     = n   ;
       else
       indices.ind   = ind;
       end
       indices.ang   = ang  ;
       indices.x     = x   ;
       indices.y     = y   ;

   end

case 'strcmp'

   indices = [];

   for i=1:size(stationname,1)

      for istat=1:nstat

         if strcmp(strtrim(stationname(i,:)),...
                   strtrim(namst(istat,:)))

            indices = [indices istat];

         end

      end

   end


case 'strmatch'

   indices = [];

   for i=1:size(stationname,1)

      istat = strmatch(stationname(i,:),namst); % ,'exact'

      indices = [indices istat];

   end

end

%% EOF