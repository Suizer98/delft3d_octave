function varargout=nc_cf_gridset_getData(xi,yi,varargin)
%nc_cf_gridset_getData   interpolate data in space (and time) from a netCDF tile set
%
% [...] = nc_cf_gridset_getData(xi,yi,   <keyword,value>)
% creates zi from scratch
%
% [...] = nc_cf_gridset_getData(xi,yi,zi,<keyword,value>)
% fills only the holes (NaN's) in zi
%
% [zi,ti             ] = nc_cf_gridset_getData(...)
% [zi,ti,fi,fi_legend] = nc_cf_gridset_getData(...)
%
% where fi is the nc sequence nr from which the data were interpolated.
%
% Example: Slufter Texel using one file
%
%    nc_cf_gridset_getData(116e3,573e3,'bathy',{'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/09bn2.nc'})
%
% Example: Slufter Texel using all files
%
%    nc_cf_gridset_getData(116e3,573e3,'bathy','http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%
%See also: grid_orth_getDataFromNetCDFGrids, grid_orth_getDataOnLine, nc_cf_gridset_getData_example,
%          classify2unique for plotting date fields

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
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

% $Id: nc_cf_gridset_getData.m 8596 2013-05-08 16:08:39Z boer_g $
% $Date: 2013-05-09 00:08:39 +0800 (Thu, 09 May 2013) $
% $Author: boer_g $
% $Revision: 8596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_gridset_getData.m $
% $Keywords: $

OPT.bathy       ='http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
% can be cellstr of ncfiles as well, with last one being topex/gebco to fill holes

OPT.xname       = 'x'; % search for projection_x_coordinate, or longitude, or ...
OPT.yname       = 'y'; % search for projection_x_coordinate, or latitude , or ...
OPT.varname     = 'z'; % search for altitude, or ...

OPT.poly        = [];
OPT.method      = 'linear'; % spatial
OPT.ddatenummax = datenum(3,1,1); % temporal search window in years
OPT.datenum     = datenum(1998,7,1); % ti
OPT.order       = '{''backward'',''forward'',''|nearest|''}'; % RWS: Specifieke Operator Laatste/Dichtsbij/Prioriteit
OPT.disp        = 0;
OPT.debug       = 0;

if nargin==0
    varargout = {OPT};
    return
end

if ~isnumeric(varargin{1})
   zi  = xi.*nan; % set increment to nan
   ti  = xi.*nan; % set increment to nan
   fi  = xi.*nan; % set increment to nan
else
   zi  = varargin{1};
   varargin = {varargin{2:end}};
   % TO DO
   ti  = xi.*nan; % set increment to nan
   fi  = xi.*0;   % set increment to nan
end
OPT = setproperty(OPT,varargin);

%% get spatial limits

   if ~isempty(OPT.poly)
      polygon_selection = inpolygon(xi,yi,OPT.poly{1},OPT.poly{2});
   else
      polygon_selection = ones(size(xi));
   end

%% get data sources

   if iscell(OPT.bathy) % already list of nc files
       list = OPT.bathy;
   else
       list = opendap_catalog(OPT.bathy);
   end

%% fill holes with samples of nearest/latest/first time

   xmin = min(xi(:));
   xmax = max(xi(:));
   ymin = min(yi(:));
   ymax = max(yi(:));

   for ifile=1:length(list)
      
      if OPT.disp
          fprintf(1,['Inquiring file ', num2str(ifile,'%0.4d'),' of ', num2str(length(list),'%0.4d'),': ',filenameext(list{ifile})]);
      end
   
%% find valid spatial tiles

      BB.X  = nc_actual_range(list{ifile},OPT.xname);BB.X = BB.X([1 2 2 1 1]);
      if ~(BB.X(2) < xmin | BB.X(1) > xmax)
      BB.Y  = nc_actual_range(list{ifile},OPT.yname);BB.Y = BB.Y([1 1 2 2 1]);
      if ~(BB.Y(3) < ymin | BB.Y(1) > ymax)
      bb_selection = inpolygon(xi,yi,BB.X,BB.Y);
      
      if any(bb_selection(:))

      if OPT.disp
          %fprintf(1,[': ',filenameext(list{ifile})]);
      end          

%% find valid dates within tile
       
       L.datenum  = nc_cf_time(list{ifile});
       if any(strfind(OPT.order,'|')) % extract default
          ind = strfind(OPT.order,'|');
          OPT.order = OPT.order(ind(1)+1:ind(2)-1);
       end
       if     strcmpi(OPT.order,'backward');L.ddatenum =   -(L.datenum - OPT.datenum);
       elseif strcmpi(OPT.order,'forward' );L.ddatenum =   +(L.datenum - OPT.datenum);
       elseif strcmpi(OPT.order,'nearest' );L.ddatenum = abs(L.datenum - OPT.datenum);
       elseif strcmpi(OPT.order,'linear'  );error('TO DO')
       else                                 L.ddatenum = abs(L.datenum - OPT.datenum);
       end
       L.ddatenum(L.ddatenum < 0              ) = nan;
       L.ddatenum(L.ddatenum > OPT.ddatenummax) = nan;

      [dummy,ind]                 = sort(L.ddatenum);
       
    %% remove invalid dates
       
       ind2go = find(isnan(dummy)); % nans are last in dummy
       if ~isempty(ind2go)
          ind = ind(1:ind2go(1)-1);
          if OPT.disp
          fprintf(1,[' # dates found: ' num2str(length(ind)),'\n']);
          disp(datestr(L.datenum(ind)))
          end
       end
      
    %% cycle valid dates
       
       for idt=1:length(ind)

          mask             = isnan(zi) & polygon_selection  & bb_selection; % only empty points

          if any(mask(:)) % only continue when there are still points to be done within the BB of this file

          %% get source data for one timestep

             if idt==1
             X   = nc_varget(list{ifile},OPT.xname);
             Y   = nc_varget(list{ifile},OPT.yname);
             end

             dzi = xi.*nan; % set increment to nan
             
% warning('TO DO: permute Z automatically into [T x Y x X]')

% nc_index.x = nc_varfind(list{ifile}, 'attributename','standard_name','attributevalue','projection_x_coordinate');
% nc_index.y = nc_varfind(list{ifile}, 'attributename','standard_name','attributevalue','projection_y_coordinate');
% nc_index.t = nc_varfind(list{ifile}, 'attributename','standard_name','attributevalue','time');

             start = permute([(ind(idt)-1)  0  0],[1 2 3]); % @timedim
             count = permute([           1 -1 -1],[1 2 3]); % @timedim

             Z   = nc_varget(list{ifile},OPT.varname,start,count); % most time consuming code line
             T   = L.datenum(ind(idt));
             dt2fmt = L.datenum(ind(idt)) - OPT.datenum;
             disp(['file: ',num2str(ifile,'%0.3d '),...
                    ' it: ',num2str(idt,'%0.1d '),...
                    ' dt: ',num2str(dt2fmt        ,'%+05.0f'),...
                  ' day = ',num2str(dt2fmt./365.25,'%+03.1f'),...
                  ' yr in ',filename(list{ifile})]);
                 % ' days (#',num2str(sum(~isnan(Z(:))),'%+0.5d'),' data points)'

          %% extract remaining destination data
%          %  use interp2 tabel when source dxata is orthogonal
             %F = TriScatteredInterp(X(:),Y(:),Z(:),OPT.method);
             %dzi(mask) = F(xi(mask),yi(mask));
%             
%             if isvector(X) & isvector(Y)
             dzi(mask) = interp2(X,Y,Z,... % Z should be [y by x]
                                  xi(mask),yi(mask),OPT.method); 
%             elseif strcmpi(OPT.method,'nearest')
%             dzi(mask) = griddata_nearest(X,Y,Z, xi(mask),yi(mask)); 
%             else
%             dzi(mask) = griddata        (X,Y,Z, xi(mask),yi(mask),OPT.method); 
%             end
             
          %% find and add increment
          
             extra     = ~isnan(dzi) & isnan(zi); % new data and not yet filled
             zi(extra) = dzi(extra);
             ti(extra) = T;
             fi(extra) = ifile;

             if OPT.debug & (ifile <= length(list))
                 %%
                 clf
                 plot(BB.X,BB.Y,'-','color',[.9 .9 .9],'DisplayName','source data bounding box') % scatter takes too long !!!!
                 hold on
                 if ~isempty(OPT.poly)
                 plot(OPT.poly{1},OPT.poly{2},'-','color','r','DisplayName','search polygon') % scatter takes too long !!!!
                 end
                 if idt==1
                [X,Y]=meshgrid(X,Y);
                 end
                 M = ~isnan(Z);
                 plot(X(M),Y(M),'.','color',[.9 .9 .9],'DisplayName','source data') % scatter takes too long !!!!
                 plot(xi,yi                      ,'k.','DisplayName','destination data requested')
                 hold on
                 
                 mask2 = ~isnan(zi) & polygon_selection; % only empty points

                 h = plotc(xi(mask2),yi(mask2),zi(mask2),'o','markersize',20);
                 set(h,'DisplayName','destination data filled')
                 axis equal
                 tickmap('xy')
                 colorbarwithtitle('zi')
                 title(['data: ',datestr(T),' requested: ',datestr(OPT.datenum)])
                 legend show
                 pausedisp

             end % plot
          end % any(mask)
       end % idt
       end % bb_selection
       end % Y
       end % X
       if OPT.disp
       fprintf(1,['\n']);
       end
       end % files
       
varargout = {zi,ti,fi,list};