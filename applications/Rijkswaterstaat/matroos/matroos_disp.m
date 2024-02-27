function varargout = matroos_disp(varargin)
%MATROOS_DISP   display contents of matroos timeseries
%
% matroos_disp(<keyword,value>);
%
% displays three columsn with quantities, sources and stations
%
% where the following <keyword,value> are defined:
% - loc       : The location as known by Matroos (see MATROOS_LIST).
% - source    : The source as known by Matroos (see MATROOS_LIST).
% - unit      : A unit as known by Matroos (see MATROOS_LIST).
% * disp      : whetehr to display [locs,sources,units] columns
%
% [locs,sources,units] = matroos_disp(<keyword,value>);
%
% returns a selection of the the compete set of MATROOS_LIST 
% determined by combinations of the above keywords. 
%
% Example:
%
%   [locs,sources,units] = matroos_disp('unit','wave_height','source','observed');
%
%see also: matroos

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

% $Id: matroos_disp.m 7773 2012-12-04 08:58:17Z huism_b $
% $Date: 2012-12-04 16:58:17 +0800 (Tue, 04 Dec 2012) $
% $Author: huism_b $
% $Revision: 7773 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_disp.m $
% $Keywords: $

%% Options

   OPT.server   = matroos_server;
   OPT.loc      = ''; % always
   OPT.source   = ''; % always
   OPT.unit     = ''; % always
   OPT.disp     = 1; 

   OPT = setproperty(OPT,varargin{:});

%% get TOC

   [D.loc,D.source,D.units] = matroos_list('server',OPT.server);

%% subset TOC

   indexu   = strmatch(OPT.unit  ,D.units );
   indexs   = strmatch(OPT.source,D.source);
   indexl   = strmatch(OPT.loc  ,D.loc );
   index    = intersect(indexu,indexs);
   index  = intersect(index,indexl);
   
   locs    = {D.loc{index}}';
   sources = {D.source{index}}';
   units   = {D.units{index}}';

%% make table

   if OPT.disp
   
      if isempty(index)
         disp('matroos_disp: nothing found')
         return
      end
   
      l = char(unique(units  ));
      s = char(unique(sources));
      u = char(unique(locs   ));
      
      n = max([size(u,1) size(s,1) size(l,1)]);
      
      l = strvcat(l,repmat(' ',[(n-size(l,1)) size(l,2)]));
      s = strvcat(s,repmat(' ',[(n-size(s,1)) size(s,2)]));
      u = strvcat(u,repmat(' ',[(n-size(u,1)) size(u,2)]));
      
      sep = repmat(' | ',[n 1]);
      top = [' | ',pad('LOC:  '  ,size(l,2)),' | ',...
                   pad('SOURCE: ',size(s,2)),' | ',...
                   pad('UNITS: ' ,size(u,2)),' | '];
      com = [' | ',pad(' chosen:',size(l,2)),' | ',...
                   pad(' chosen:',size(s,2)),' | ',...
                   pad(' chosen:',size(u,2)),' | '];
      sel = [' | ',pad(OPT.loc   ,size(l,2)),' | ',...
                   pad(OPT.source,size(s,2)),' | ',...
                   pad(OPT.unit  ,size(u,2)),' | '];
      bar = [' +-',pad('-','-'   ,size(l,2)),'-+-',...
                   pad('-','-'   ,size(s,2)),'-+-',...
                   pad('-','-'   ,size(u,2)),'-+ '];
      
      disp(bar);
      disp(top);
      disp(com);
      disp(sel);
      disp(bar);
      disp([sep l sep s sep u sep]);
      disp(bar);
      disp(['  contents from ',OPT.server]);
      disp(bar);
   
   end % disp
   
   if nargout==3
      varargout = {locs,sources,units};
   elseif nargout==1 | nargout==2 
      error('syntax: [locs,sources,units] = matroos_disp(<keyword,value>);')
   end

%% EOF