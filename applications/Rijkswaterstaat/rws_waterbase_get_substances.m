function D = rws_waterbase_get_substances(varargin)
%RWS_WATERBASE_GET_SUBSTANCES   list of waterbase substances from live.waterbase.nl
%
%    S = rws_waterbase_get_substances()
%    S = rws_waterbase_get_substances(<keyword,value>)
%
% where keyword is 'FullName','CodeName' or 'Code' resurns only
% selected substance, e.g.:
%
%    S = rws_waterbase_get_substances('Code',209)
%
% gets list of all SUBSTANCES available for queries at <a href="http://live.waterbase.nl">live.waterbase.nl</a>.
% Saves list to csv for drill-down and offline use by rws_waterbase_get_substances.
%
% struct S has fields:
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. 22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% See also: rws_waterbase_get_substances_csv, <a href="http://live.waterbase.nl">live.waterbase.nl</a>, rijkswaterstaat

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: rws_waterbase_get_substances.m 14590 2018-09-17 12:57:02Z kaaij $
% $Date: 2018-09-17 20:57:02 +0800 (Mon, 17 Sep 2018) $
% $Author: kaaij $
% $Revision: 14590 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_get_substances.m $
% $Keywords: $

   OPT.debug    = 0;
   OPT.baseurl  = 'http://live.waterbase.nl';

   %% Special HTML symbols to be encodied as hex value with ISO 8859-1 Latin alphabet No. 1
   % http://www.ascii.cl/htmlcodes.htm:ISO 8859-1 Latin alphabet No. 1
   % %      25
   % ' '    20 space
   % |      7C
   % /      2F
   % <      3C
   % ,      2C
   % (      28
   % )      29
   % '      27
   OPT.symbols  = {'%',' ','|','/','<',',','(',')',''''};  % NOTE do '%' first, as all are replaced by %hex

   OPT.FullName = '';
   OPT.CodeName = '';
   OPT.Code     = [];
   OPT.csv      = '';

   OPT = setproperty(OPT,varargin{:});

   %% Get page
   url = [OPT.baseurl,'/waterbase_wns.cfm?taal=nl'];
   [s status]    = urlread(url);
   if (status == 0)
      fprintf(2,[url,' may be offline or you are not connected to the internet: Online source not available']);
      OutputName = [];
      D = [];
      return;
   end

%% Get substances from page

   ind0 = strfind(s,'<option value="');
   ind1 = strfind(s,'</option>');
   for ii=1:length(ind1)
      if OPT.debug
      disp([num2str(ii,'%0.3d'),'  ',s(ind0(ii)+15:ind1(ii)-1)])
      end

      str  = s(ind0(ii)+15:ind1(ii)-1);
      sep0 = strfind(str,'|');
      sep1 = strfind(str,'">');

      D.Code(ii)     = str2num(str(     1:sep0-1));
      D.FullName{ii} =         str(sep0+1:sep1-1);
      D.CodeName{ii} =         str(     1:sep1-1);
      D.CodeName{ii} = strrep(D.CodeName{ii},' ','+');

      for isymbol=1:length(OPT.symbols)
      symbol = OPT.symbols{isymbol};
      D.CodeName{ii} = strrep(D.CodeName{ii},symbol,['%',dec2hex(unicode2native(symbol, 'ISO-8859-1'))]);
      end
   end

%% save to csv

%   if isempty(OPT.csv)
%       [path,~,~] = fileparts (mfilename('fullpath'));
%       OPT.csv = [path filesep 'rws_waterbase_substances.csv'];
%   end
%   struct2csv(OPT.csv,D,'overwrite','o');
%   disp('saved to')
%   disp(OPT.csv)

%% check substances from website by comparing with csv file.

   if OPT.debug
      E = rws_waterbase_get_substances_csv;
      for ii=1:length(D.Code)
         if ~strcmpi(D.CodeName{ii},E.CodeName{ii})
            disp(num2str(ii))
            disp(['>',D.CodeName{ii},'<'])
            disp(['>',E.CodeName{ii},'<'])
            disp('------------------------')
            % 284
            % >713%7CExtinctiecoefficient+in+%2Fm+in+oppervlaktewater<
            % >713%7CExtinctie+in+%2Fm+in+oppervlaktewater<
         end
      end
   end

%% subset (optionally)

   if ~isempty(OPT.Code)
      indSub = find(D.Code==OPT.Code);
      D.CodeName = D.CodeName{indSub};
      D.FullName = D.FullName{indSub};
      D.Code     = D.Code    (indSub);
   elseif ~isempty(OPT.CodeName)
      indSub = strmatch(OPT.CodeName,D.CodeName);
      D.CodeName = D.CodeName{indSub};
      D.FullName = D.FullName{indSub};
      D.Code     = D.Code    (indSub);
   elseif ~isempty(OPT.FullName)
      indSub = strmatch(OPT.FullName,D.FullName);
      D.CodeName = D.CodeName{indSub};
      D.FullName = D.FullName{indSub};
      D.Code     = D.Code    (indSub);
   end


%% EOF
