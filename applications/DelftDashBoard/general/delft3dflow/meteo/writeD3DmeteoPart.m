function writeD3DmeteoPart(fname, s, par, quantity, unit, gridunit, reftime)
%WRITED3DMETEO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writeD3Dmeteo(fname, s, par, quantity, unit, gridunit, reftime)
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

% $Id: writeD3DmeteoPart.m 5605 2011-12-08 17:02:57Z ormondt $
% $Date: 2011-12-09 01:02:57 +0800 (Fri, 09 Dec 2011) $
% $Author: ormondt $
% $Revision: 5605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3DmeteoPart.m $
% $Keywords: $

%%
ncols=length(s.x);
nrows=length(s.y);

% s.(par)(isnan(s.(par)))=-999;

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','*### All text on a line behind the first # is parsed as commentary');
fprintf(fid,'%s\n','*### Additional commments');
fprintf(fid,'%s\n','*FileVersion      =    1.03                                               # Version of meteo input file, to check if the newest file format is used');
fprintf(fid,'%s\n','*filetype         =    meteo_on_equidistant_grid                          # Type of meteo input file: meteo_on_flow_grid, meteo_on_equidistant_grid, meteo_on_curvilinear_grid or meteo_on_spiderweb_grid');
fprintf(fid,'%s\n',['n_cols  =             ' num2str(ncols)]);
fprintf(fid,'%s\n',['n_rows  =             ' num2str(nrows)]);
fprintf(fid,'%s\n',['x_llcorner =          ' num2str(min(s.x))]);
fprintf(fid,'%s\n',['y_llcorner =          ' num2str(min(s.y))]);
fprintf(fid,'%s\n',['cellsize  =            ' num2str(min(s.dx)) ' ' num2str(min(s.dy))]);
fprintf(fid,'%s\n','missing  =              -999');
fclose(fid);

for it=1:length(s.time)
    tim=24*(s.time(it)-reftime);
    % Test     if s.time(it)>datenum(2010,12,31,23,0,0)
    val=flipud(squeeze(s.(par)(:,:,it)));
    val(val>1e7)=NaN;
    if ~isnan(max(max(val)))
        val(isnan(val))=-999;
        fid = fopen(fname,'a');
        %         % Testje
        %         if s.time(it)<datenum(2011,3,2,23,0,0)
        %             if strcmpi(par,'u')
        %                 val=zeros(size(val))+10;
        %             else
        %                 val=zeros(size(val))+0;
        %             end
        %         else
        %             if strcmpi(par,'u')
        %                 val=zeros(size(val))+0;
        %             else
        %                 val=zeros(size(val))+10;
        %             end
        %         end
        fprintf(fid,'%s\n',['TIME   )   ' num2str(tim,'%10.2f') '   HRS since ' datestr(reftime,'yyyy-mm-dd HH:MM:SS') ' +00:00']);
        fclose(fid);
        dlmwrite(fname,val,'precision','%10.2f','delimiter','','-append');
    else
        disp([quantity ' at time ' datestr(s.time(it)) ' contains only NaNs! Block skipped.']);
    end
    % Test    end
end

