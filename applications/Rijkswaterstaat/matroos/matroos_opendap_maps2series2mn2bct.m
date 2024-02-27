function varargout = matroos_opendap_maps2series2mn2bct(R,varargin)
%MATROOS_OPENDAP_MAPS2SERIES2MN2BCT subsidiary of matroos_opendap_maps2series2mn
%
% You can reload the netCDF file written by MATROOS_OPENDAP_MAPS2SERIES2MN
% and save the Delt3D bct files again, with another refdate for instance.
%
% fname = 'hmcn_kustfijn_m1,n1_m2,n2_m3,n3.nc';
% R = nc2struct(fname)
% matroos_opendap_maps2series2mn2bct(R,'filename','hmcn_kustfijn')
%
%See also: MATROOS_OPENDAP_MAPS2SERIES2MN, DFLOWFM, NOOS_WRITE

warning('beta version')

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
%   along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: matroos_opendap_maps2series2mn2bct.m 7698 2012-11-16 14:50:34Z boer_g $
% $Date: 2012-11-16 22:50:34 +0800 (Fri, 16 Nov 2012) $
% $Author: boer_g $
% $Revision: 7698 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2mn2bct.m $
% $Keywords: $

   OPT.RefDate     = datenum(2009,12,1); % if not 'NOOS' or datenum(), else ISO8601 'yyyy-mm-dd HH:MM:SS'
   OPT.filename    = '';
   OPT.debug       = 0;
   OPT.grd         = ''; % delft3d grd file for boundary positions
   OPT.bnd         = ''; % delft3d bnd file for boundary positions
   OPT.bct         = ''; % delft3d bct file whose tables will be updated
   OPT.varname     = 'elev';
   
   if nargin==0
      varargout = {OPT};return
   end

   OPT = setproperty(OPT,varargin);

%% load BCT locations

   G                = delft3d_io_grd('read',[OPT.grd]);
   B                = delft3d_io_bnd('read',[OPT.bnd],G);
  [B.PI,B.RI,B.WI] = griddata_near1(R.x,R.y,B.x,B.y,2); % griddata_near2 below

%% debug plot for spatial interpolation (before making BCT)
   if OPT.debug
      close all
      h = pcolorcorcen(G.cor.x,G.cor.y,G.cen.x.*nan,[.5 .5 .5]);
      set(h,'displayname','corners')
      hold on
      plot(G.cen.x(:),G.cen.y(:),'.','color',[.5 .5 .5],'displayname','centers')
      axis equal
      plot(Inf,Inf,'r.-','displayname','boundary (ghost centers)')
      plot(Inf,Inf,'b.-','displayname','boundary (source coordinates)')
      plot(R.x,R.y,'g.-','displayname','HMCN data','linewidth',2)
      legend('Location','southeast')
      plot(B.x',B.y','r.-')
      for ibnd=1:length(B.DATA)
        for iside=1:2
          h1 = plot(B.x(ibnd,iside),B.y(ibnd,iside),'s');
          hold on
          h2 = plot(R.x(B.PI(:,ibnd,iside)),R.y(B.PI(:,ibnd,iside)),'mo');
          pausedisp
          delete(h1);
          delete(h2);
        end
      end
   end % debug
   
%% interpolate to BCT locations and save into BCT template

   BCT   = bct_io('read',OPT.bct);
   tmask = R.datenum >= OPT.RefDate;
   ZI              = griddata_near2(R.x,R.y,R.(OPT.varname)(:,tmask),B.x,B.y,B.PI,B.WI);
   nbct  = sum(tmask);
   np    = size(B.WI,1);
   for ibnd=1:length(B.DATA)
      if ~isequal(time2datenum(BCT.Table(ibnd).ReferenceTime),OPT.RefDate)
      warning('ReferenceTime BCT overwritten')
      BCT.Table(ibnd).ReferenceTime = str2num(datestr(OPT.RefDate,'yyyymmdd'));
      end
      BCT.Table(ibnd).Data             = repmat(0,[nbct 3]);
      BCT.Table(ibnd).Data(:,1      )  = (R.datenum(tmask) - OPT.RefDate)*24*60; % time
      for iside=1:2
      BCT.Table(ibnd).Data(:,1+iside)  = ZI(ibnd,iside,:);
      end
      BCT.Table(ibnd).Format = '% 6g % .3f % .3f';
     %sum(B.WI(:,ibnd,iside)) % should be 1
   end
   bct_io('write',OPT.filename,BCT);

varargout = {BCT};