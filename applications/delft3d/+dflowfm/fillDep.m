function varargout = fillDep(varargin)
%fillDep fill depth values from netCDF/OPeNDAP data source (single grid or gridset of tiles)
%
%     <out> = dflowfm.fillDep(<keyword,value>) 
%
% where  the following keywords mean:
% * bathy   data sources: (i)cellstr of files, (ii) directory or (iii) opendap catalog url
% * ncfile  input nc mapfile, of which any existing depth data will be ignored
% * out     input nc mapfile (same as 'ncfile' with depth + timestamps added)
% * ...
%
% The output file of dflowfm.writeNet can be used as input for dflowfm.fillDep.
%
%   See also dflowfm, delft3d, nc_cf_gridset_getData, opendap_catalog, writeNet

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

% $Id: fillDep.m 7469 2012-10-12 10:05:04Z boer_g $
% $Date: 2012-10-12 18:05:04 +0800 (Fri, 12 Oct 2012) $
% $Author: boer_g $
% $Revision: 7469 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/fillDep.m $
% $Keywords: $

   OPT.ncfile      = 'precise4k_net.nc';
   OPT.out         = 'precise4k_vaklodingen2filled_net.nc';

   OPT.bathy       = opendap_catalog('H:\opendap.deltares\thredds\dodsC\opendap\rijkswaterstaat\vaklodingen\');
   OPT.xname       = 'x'; % search for projection_x_coordinate, or longitude, or ...
   OPT.yname       = 'y'; % search for projection_x_coordinate, or latitude , or ...
   OPT.varname     = 'z'; % search for altitude, or ...

   OPT.poly        = '';
   OPT.method      = 'linear'; % only for 1st step, second step is nearest
   OPT.datenum     = datenum(2010,7,1); % get from mdu
   OPT.ddatenummax = datenum(10,1,1); % temporal search window in years (for direction see 'order')
   OPT.order       = ''; % RWS: Specifieke Operator Laatste/Dichtsbij/Prioriteit
   OPT.xname       = 'NetNode_x';
   OPT.yname       = 'NetNode_y';
   OPT.zname       = 'NetNode_z';
   OPT.tname       = 'NetNode_t';
   OPT.fname       = 'NetNode_file';

   OPT.debug       = 0;

   OPT = setproperty(OPT,varargin);
   
   if strcmpi(OPT.ncfile,OPT.out)
      error(['specify different name for ncfile and out: ',OPT.ncfile])
   end
   
%% Load grid
   G.cor.x       = nc_varget(OPT.ncfile, OPT.xname)';
   G.cor.y       = nc_varget(OPT.ncfile, OPT.yname)';
   G.cor.z       = G.cor.x.*nan; % G.cor.z       = nc_varget(OPT.ncfile,OPT.zname)';
   G.cor.datenum = G.cor.x.*nan; % G.cor.datenum = nc_varget(OPT.ncfile,OPT.tname)';
   
   if ~isempty(OPT.poly)
      [P.x,P.y]         = landboundary('read',OPT.poly);
      polygon_selection = inpolygon(G.cor.x,G.cor.y,P.x,P.y);
   else
      polygon_selection = ones(size(G.cor.x));
   end

%% data

   if ischar(OPT.bathy)
   list = opendap_catalog(OPT.bathy);
   end
   
   OPT2 = OPT;
   OPT2 = rmfield(OPT2,'ncfile');
   OPT2 = rmfield(OPT2,'out');
   OPT2.xname = 'x';
   OPT2.yname = 'y';
   OPT2 = rmfield(OPT2,'zname');
   OPT2 = rmfield(OPT2,'tname');
   OPT2 = rmfield(OPT2,'fname');

   %% fill holes with samples of nearest/latest/first in time
   [zi,ti,fi,fi_legend]=nc_cf_gridset_getData(G.cor.x,G.cor.y,   OPT2);
   
   G.cor.z       = zi;
   G.cor.datenum = ti;
   G.cor.files   = fi;
   
   % internal interpolation to fill missing bands between input tiles

   OPT.method           = 'nearest';
   [zi,ti,fi,fi_legend] = nc_cf_gridset_getData(G.cor.x,G.cor.y,zi,OPT2);
   extra = isnan(G.cor.z) & ~isnan(zi);
   G.cor.z(extra)       = zi(extra);
   G.cor.datenum(extra) = nan;
   G.cor.files(extra)   = 0;
       
%% save

   copyfile(OPT.ncfile,OPT.out)
   
   G.cor.z(isnan(G.cor.z))=-999; % implicity default value of DFlow-FM

   nc_varput(OPT.out,OPT.zname,G.cor.z);
   nc_attput(OPT.out,OPT.zname,'actual_range',[min(G.cor.z) max(G.cor.z)]);
   
%% add date of sample points to ncfile (not in unstruc output)
   
   clear nc
   nc.Name      = OPT.tname;
   nc.Nctype    = 'double';
   nc.Dimension = { 'nNetNode' };
   nc.Attribute(1).Name  = 'units';
   nc.Attribute(1).Value = 'days since 1970-01-01 00:00:00';
   nc.Attribute(2).Name  = 'standard_name';
   nc.Attribute(2).Value = 'time';
   nc.Attribute(3).Name  = 'long_name';
   nc.Attribute(3).Value = 'recording time of depth sounding';
   nc.Attribute(4).Name  = 'actual_range';
   nc.Attribute(4).Value = [datestr(min(G.cor.datenum)) ' ' datestr(max(G.cor.datenum))];
   % TO DO: perhaps turn this into flagged data too?
   nc_addvar(OPT.out,nc);  
  
   nc_varput(OPT.out,OPT.tname,G.cor.datenum - datenum(1970,1,1));

%% add data source to ncfile (not in unstruc output)

   clear nc
   nc.Name      = OPT.fname;
   nc.Nctype    = 'int';
   nc.Dimension = { 'nNetNode' };
   nc.Attribute(1).Name  = 'files';
   nc.Attribute(1).Value = [num2str([1:length(fi_legend)]') addrowcol(addrowcol(char(fi_legend),0,-1,' = '),0,1,';')]';
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#flags
   % you can unwrap flag_meanings with strtokens2cell()
   nc.Attribute(2).Name  = 'flag_values';
   nc.Attribute(2).Value = unique(G.cor.files);
   nc.Attribute(3).Name  = 'flag_meanings';
   nc.Attribute(3).Value = str2line(fi_legend,'s',' ');
   nc.Attribute(4).Name  = 'actual_range';
   nc.Attribute(4).Value = [min(G.cor.files) max(G.cor.files)];
   nc_addvar(OPT.out,nc);  
  
   nc_varput(OPT.out,OPT.fname,int8(G.cor.files));
   
