function [locs,sources,units] = matroos_list(varargin)
%MATROOS_LIST   available locations, sources and units combinations from RWS MATROOS database
%
%    [locs,sources,units] = matroos_list(<keyword,value>);
%
% matroos_list caches the results and does not connect again to the 
% <a href="http://matroos.deltares.nl">MATROOS</a> server until i) the next matlab session, ii) a "clear global" 
% is issued, or iii) matroos_list is altered.
%
%See also: matroos

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: matroos_list.m 10281 2014-02-25 10:03:40Z huism_b $
% $Date: 2014-02-25 18:03:40 +0800 (Tue, 25 Feb 2014) $
% $Author: huism_b $
% $Revision: 10281 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_list.m $
% $Keywords: $

%% Options
   
   OPT.server   = matroos_server;
   OPT.disp     = 1;
   OPT.fmt      = 'yyyymmdd'; % for matroos_list cache: max every day a new one is OK. overwrites previous ones.

   OPT = setproperty(OPT,varargin{:});

%% cache matroos_list as server call is very slow
%  preference is to cache in matroos toolbox
%  tempdir (userpath) is for when matroos toolbox is read-only.

   persistent matroos_list_cache

   if isempty(matroos_list_cache) % it is initialized []
       matroos_list_cache.saved  = 0;

       matroos_list_cache.name1  = [fileparts(mfilename('fullpath')) filesep 'matroos_list_cache.',datestr(now,OPT.fmt)];
       p = userpath;p(1:end-1); % remove trailing ;
       p = tempdir;
       matroos_list_cache.name2  = [p filesep 'matroos_list_cache.',datestr(now,OPT.fmt)];
   end

%% read up-to-date list from matroos server 
%  and save it to cache

   if ~isempty(OPT.server) & ~matroos_list_cache.saved
   
      fprintf(1,['matroos_list: downloading list, please wait ... \n'])
   
      serverurl  = [OPT.server,'/direct/get_series.php?list=1'];
      file       = urlread_basicauth(serverurl);
      COLUMNS    = textscan(file,'%s%s%s','Delimiter',char(9)); % list is tab-delimited, names can contain spaces !!!
      
      try
      fid = fopen(matroos_list_cache.name1,'w');
      matroos_list_cache.name = matroos_list_cache.name1;
      catch
      fid = fopen(matroos_list_cache.name2,'w');
      matroos_list_cache.name = matroos_list_cache.name2;
      end
      
      fprintf(fid,file);
      fclose(fid);
      matroos_list_cache.saved = 1;
      fprintf(1,['matroos_list: saved cache for all subsequent use in current Matlab session %s:\n'],matroos_list_cache.name)
      
   else
   
%% read cached version of list, MUCH FASTER
   
      fid       = fopen(matroos_list_cache.name,'r');
      COLUMNS   = textscan(fid,'%s%s%s','Delimiter',char(9)); % list is tab-delimited, names can contain spaces !!!
      fclose(fid);

      if OPT.disp
      fprintf(2,['matroos_list: read cache for current Matlab session %s:\n'],matroos_list_cache.name)
      end
      
   end

%% parse

   locs      = COLUMNS{1};
   sources   = COLUMNS{2};
   units     = COLUMNS{3};

%% EOF

