function ww3_write_wnd(fname, s, varargin)
%write_meteo_file_ww3  Generates WAVEWATCH III wind file
%
% Generates WAVEWATCH III wind file and return vectors of longitude and
% latitude (needed to write ww3_prep.inp)
%
%   More detailed description goes here.
%
%   Syntax:
%   write_meteo_file_ww3(fname, s, par, varargin)
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
%   Example
%   writeD3Dmeteo
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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

for ii=1:length(s.parameter)
    if strcmpi(s.parameter(ii).name,'u')
        iparu=ii;
    end
    if strcmpi(s.parameter(ii).name,'v')
        iparv=ii;
    end
end

fid=fopen(fname,'wt');

for it=1:length(s.parameter(iparu).time)

    t=s.parameter(iparu).time(it);
    u=squeeze(s.parameter(iparu).val(it,:,:));
    v=squeeze(s.parameter(iparv).val(it,:,:));
    
    ncols=size(u,2);
    
    u=flipud(u);
    v=flipud(v);

    fprintf(fid,'%s\n',datestr(t,'yyyymmdd HHMMSS'));

    fmt=[repmat('%13.5e ',1,ncols) '\n'];

    fprintf(fid,fmt,u');
    fprintf(fid,fmt,v');

%     if usedtairsea
% %        dtairsea=zeros(size(u));
% %        dtairsea=dtairsea+1;
%         for i=1:size(u,2)
%             dtairsea(:,i)=10*cos(flipud(lat)*pi/180);
%         end
%         fprintf(fid,fmt,dtairsea');
%     end
    
end

fclose(fid);
