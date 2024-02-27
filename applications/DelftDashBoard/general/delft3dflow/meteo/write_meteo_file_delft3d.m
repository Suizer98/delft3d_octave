function write_meteo_file_delft3d(fname, s, par, gridunit, reftime, varargin)
%WRITED3DMETEO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writeD3Dmeteo(fname, s, par, quantity, unit, gridunit, reftime, vsn)
%
%   Input:
%   fname    =
%   s        =
%   par      =
%   quantity =
%   unit     =
%   gridunit =
%   reftime  =
%
%
%
%
%   Example
%   writeD3Dmeteo
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: writeD3Dmeteo.m 9300 2013-09-30 14:31:09Z ormondt $
% $Date: 2013-09-30 16:31:09 +0200 (Mon, 30 Sep 2013) $
% $Author: ormondt $
% $Revision: 9300 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3Dmeteo.m $
% $Keywords: $

%%

vsn='1.03';
hcm=1;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'version'}
                vsn=varargin{ii+1};
            case{'headercomments'}
                hcm=varargin{ii+1};
        end
    end
end

for ii=1:length(s.parameter)
    if strcmpi(s.parameter(ii).name,par)
        ipar=ii;
    end
end

parameter=s.parameter(ipar);

switch par
    case{'u'}
        quantity='x_wind';
        unit='m s-1';
        ext='amu';
        fmt='%8.2f';
    case{'v'}
        quantity='y_wind';
        unit='m s-1';
        ext='amv';
        fmt='%8.2f';
    case{'p'}
        quantity='air_pressure';
        unit='Pa';
        ext='amp';
        fmt='%7.0f';
    case{'airtemp'}
        quantity='air_temperature';
        unit='Celsius';
        ext='amt';
        fmt='%7.1f';
    case{'relhum'}
        quantity='relative_humidity';
        unit='%';
        ext='amr';
        fmt='%7.1f';
    case{'cloudcover'}
        quantity='cloudiness';
        unit='%';
        ext='amc';
        fmt='%7.1f';
    case{'swrad'}
        quantity='sw_radiation_flux';
        unit='W/m2';
        ext='ams';
        fmt='%7.1f';
    case{'precip'}
        quantity='precipitation';
        unit='mm/h';
        ext='ampr';
        fmt='%7.1f';
end

ncols=length(parameter.x);
nrows=length(parameter.y);
dx=parameter.x(2)-parameter.x(1);
dy=parameter.y(2)-parameter.y(1);

tic
fid=fopen([fname '.' ext],'wt');
if hcm
    fprintf(fid,'%s\n','### START OF HEADER');
    fprintf(fid,'%s\n','### All text on a line behind the first # is parsed as commentary');
    fprintf(fid,'%s\n','### Additional commments');
end
fprintf(fid,'%s\n',['FileVersion      =    ' vsn '                                               # Version of meteo input file, to check if the newest file format is used']);
fprintf(fid,'%s\n','filetype         =    meteo_on_equidistant_grid                          # Type of meteo input file: meteo_on_flow_grid, meteo_on_equidistant_grid, meteo_on_curvilinear_grid or meteo_on_spiderweb_grid');
fprintf(fid,'%s\n','NODATA_value     =    -999                                               # Value used for undefined or missing data');
fprintf(fid,'%s\n',['n_cols           =    ' num2str(ncols) '                                                # Number of columns used for wind datafield']);
fprintf(fid,'%s\n',['n_rows           =    ' num2str(nrows) '                                                # Number of rows used for wind datafield']);
fprintf(fid,'%s\n',['grid_unit        =    ' gridunit]);
fprintf(fid,'%s\n',['x_llcorner       =   ' num2str(min(parameter.x))]);
fprintf(fid,'%s\n',['y_llcorner       =   ' num2str(min(parameter.y))]);
if strcmpi(vsn,'1.02')
    fprintf(fid,'%s\n','value_pos        =    corner');
end
fprintf(fid,'%s\n',['dx               =   ' num2str(min(dx))]);
fprintf(fid,'%s\n',['dy               =   ' num2str(min(dy))]);
fprintf(fid,'%s\n','n_quantity       =    1                                                  # Number of quantities prescribed in the file');
fprintf(fid,'%s\n',['quantity1        =    ' quantity '                                             # Name of quantity1']);
fprintf(fid,'%s\n',['unit1            =    ' unit '                                              # Unit of quantity1']);
if hcm
    fprintf(fid,'%s\n','### END OF HEADER');
end

fmt=[repmat(fmt,1,ncols) '\n'];
fmt=repmat(fmt,1,nrows);

for it=1:length(parameter.time)
    tim=1440*(parameter.time(it)-reftime);
    val=squeeze(parameter.val(it,:,:));
    val=val';
    val=fliplr(val);
    val(val>1e7)=NaN;
    if ~isnan(max(max(val)))
        val(isnan(val))=-999;
        fprintf(fid,'%s\n',['TIME             =   ' num2str(tim,'%10.2f') '   minutes since ' datestr(reftime,'yyyy-mm-dd HH:MM:SS') ' +00:00']);
        fprintf(fid,fmt,val);
    else
        disp([quantity ' at time ' datestr(parameter.time(it)) ' contains only NaNs! Block skipped.']);
    end
end
fclose(fid);

