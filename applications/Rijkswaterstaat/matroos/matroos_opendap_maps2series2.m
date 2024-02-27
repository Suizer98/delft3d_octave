function [time,value,OPT] = matroos_opendap_maps2series2(varargin)
%MATROOS_OPENDAP_MAPS2SERIES2  timeseries from OPeNDAP maps at (x,y) using meta-data cache (TEST!!!)
%
%   [time,value,ind] = matroos_opendap_maps2series2('datenum',<...>,'source',<...>,'x',<...>,'y',<...>)
%
% where ind contains the indices requested from the OPeNDAP server.
%
% This client side function has the same functionality as the server side
% matroos.deltares.nl/direct/get_map2series.php? functionality. This client
% side function is slower the 1st time because it needs to gather meta-data,
% but it can be much faster any subsequent time because it can cache some 
% part of the 'state' of the request, for instance the [m,n] mapping.
%
%See also: MATROOS_OPENDAP_MAPS2SERIES1, MATROOS_OPENDAP_MAPS2SERIES2MN, nc_harvest, 
%          matroos_get_series, matroos.deltares.nl/direct/get_map2series.php?

warning('very preliminary test version')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: matroos_opendap_maps2series2.m 10039 2014-01-20 09:25:44Z boer_g $
% $Date: 2014-01-20 17:25:44 +0800 (Mon, 20 Jan 2014) $
% $Author: boer_g $
% $Revision: 10039 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2.m $
% $Keywords: $

warning('data location changed: https://opendap-matroos.deltares.nl/thredds/catalog/archive/catalog.html')   
warning('https://opendap-matroos.deltares.nl/thredds/catalog/archive/maps2d/YYYY/',OPT.source,'/YYYYMM/history/catalog.html')

%% initialize

   OPT.basePath = 'http://opendap-matroos.deltares.nl/thredds/dodsC/'; % same server as catalog.xml
   OPT.source   = 'hmcn_kustfijn';
   OPT.datenum  = datenum([2010 2010],[11 12],[1 1]);
   OPT.x        = [];
   OPT.y        = [];
   OPT.Rmax     = 1e3; % max 1 km off by default
   OPT.var      = 'SEP';
   OPT.filename = 'matroos_opendap_maps2series2.tim';
   OPT.debug    = 0;
   OPT.test     = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-TEXNZE.nc';
   OPT.test     = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-HOEKVHLD.nc';
   
   if nargin==0
      varargout = {OPT};return
   end

   OPT = setproperty(OPT,varargin);
   
%% load cached meta-data from matroos_opendap_maps2series1

   if ~(exist([OPT.source,'.mat'],'file')==2)
      matroos_opendap_maps2series1('source',OPT.source,'basePath',OPT.basePath)
   else
      D = load(OPT.source);
   end

if OPT.debug
   [T,TM] = nc2struct(OPT.test);
   [~,T.zone]=udunits2datenum(TM.time.units);
   OPT.x       = T.x;
   OPT.y       = T.y;
end

%% process temporal OPeNDAP slice indices
%  add 2 extra ones due to small mismatch (few hour) filenames and time content in GMT

   OPT.t = find(D.datenum >= OPT.datenum(1) & D.datenum <= OPT.datenum(end)); % approximate
   
   if OPT.t(  1) > 1                ;OPT.t = [(OPT.t(1)-1);   OPT.t];end
   if OPT.t(end) < length(D.urlPath);OPT.t = [OPT.t; (OPT.t(end)+1)];end

%% process spatial OPeNDAP slice indices

   [OPT.m,OPT.n] = xy2mn(D.x,D.y,OPT.x,OPT.y,'Rmax',OPT.Rmax);
   
   if isnan(OPT.m)
   error(['Requested location (',num2str(OPT.x),',',num2str(OPT.y),') outside "',OPT.source,'" domain'])
   end

%% request data slices
%  loop over relevant files (OPT.t are indices of that subset of files)

   time  = [];
   value =  [];
  [user,passwd]  = matroos_user_password;
   for j=1:length(OPT.t)
     disp([num2str(j,'%0.4d'),' / ',num2str(length(OPT.t),'%0.4d')])
    [dtime,zone] = nc_cf_time(['https://',user,':',passwd,'@',D.urlPath{OPT.t(j)}(8:end)],'time');
     dval = nc_varget(['https://',user,':',passwd,'@',D.urlPath{OPT.t(j)}(8:end)],OPT.var,[1 OPT.m OPT.n]-1,[Inf 1 1]);
     time  = [time(:)'  dtime(:)'];
     value = [value(:)'  dval(:)'];
     % TO DO : do smart preallocation
     % TO DO : get entire grid line
   end
  
%% plot test data 

if OPT.debug
   figure
   plot(T.datenum - timezone_code2datenum(T.zone),T.sea_surface_height); % CET
   timeaxis(OPT.datenum)
   hold on
   plot(time  - timezone_code2datenum(zone) ,value,'r'); % GMT
   grid on
   xlabel(['time UTC ',datestr(OPT.datenum(1),'yyyy-dd-mm'),'  \leftrightarrow  ',datestr(OPT.datenum(end),'yyyy-dd-mm')])
   title(['source=',mktex(OPT.source),' x=',num2str(OPT.x),' y=',num2str(OPT.y)])
   
   print2screensize([OPT.source,'_',datestr(OPT.datenum(1),'yyyy-dd-mm'),'_',datestr(OPT.datenum(end),'yyyy-dd-mm'),'_',num2str(OPT.x),'_',num2str(OPT.y)]);
end

%% save
if ~isempty(OPT.filename)
headerlines = {'# ----------------------------------------------------------------',...
               '# ',...
              ['# Timeseries created at ',datestr(now),' by $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2.m $ $Id: matroos_opendap_maps2series2.m 10039 2014-01-20 09:25:44Z boer_g $'],...
               '# Values retrieved from mapdata interpolated with nearest neigherbor in space',...
               '# ',...
              ['# Source           : ',OPT.source],...
               '# Analysis time    : ????????????',...
               '# Time zone        : GMT',...
               '# Coordinate system: RD',...
              ['# x-coordinate     : ',num2str(OPT.x),' # requested, but de facto ',num2str(D.x(OPT.m,OPT.n)),' in ',OPT.source,' grid.'],...
              ['# y-coordinate     : ',num2str(OPT.y),' # requested, but de facto ',num2str(D.y(OPT.m,OPT.n)),' in ',OPT.source,' grid.'],...
               '# ',...
               '# ---------------------------------------------------------------',...
               '# ',...
               '# Variable     : sep',...
               '# long_name    : waterlevel',...
               '# units        : m',...
               '# missing value: NaN',...
               '#'};
           
noos_write(time,value,'filename',OPT.filename,'headerlines',headerlines)           
end
