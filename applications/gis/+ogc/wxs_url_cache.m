function xml = wxs_url_cache(url,suffix,cachedir)
%WXS_URL_CACHE  load xml from cache or load from web and save to cache
%
%  xml = wxs_url_cache(url,suffix,cachedir)
%
% where url is stripped after ?, and suffix is added
%
%See also: wms, wcs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares - gerben.deboer@deltares.nl
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% chop
   k = strfind(url,'?');
   if isempty(k)
       error('OGC WxS url should have a trailing ?');
   end
   url = url(1:k(1));

%%   
   ind0 = strfind(url,'//'); % remove http:// or https://
   ind1 = strfind(url,'?' ); % cleanup, keep untill and incl ?
   if ~(length(ind1)==1)
       error(['OGC WxS url must have exactly 1 "?", found: ',num2str(length(ind1))])
   end
   server = url(1:ind1);
   if ~exist(cachedir);mkdir(cachedir);end
   cachename = [cachedir,filesep,mkvar([server(ind0+2:end),suffix])]; % remove leading http[s]://
   xmlname   = [cachename,'.xml'];
   url       = [server,suffix];
   if ~exist(xmlname)
      urlwrite(url,xmlname);
      urlfile_write([cachename,'.url'],url,now);   
   else
      %if OPT.disp;
      disp(['used WxS cache:',xmlname]);
      %end % load last access time too
   end
   xml   = xml_read(xmlname,struct('Str2Num',0,'KeepNS',0)); % prevent parsing of 1.1.1 or 1.3.0 to numbers
