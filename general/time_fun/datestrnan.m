function S = datestrnan(D,varargin)
%DATESTRNAN   datestr-version that does not crash on NaNs
%
%    S = DATESTRNAN(D,varargin) where varargin are the 
%    usual input arguments to DATESTR,
%    
%    S = DATESTRNAN(...,FillSymbol) where FillSymbol 
%    is the symbol returned in case of NaNs,
%
%    S = DATESTRNAN(D) uses default FillSymbol =' ' (space)
%
%    Example
%    S = datestrnan([nan now],'yyyy','*')
%
% See also: DATESTR

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for NMDC.eu
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: datestrnan.m 15374 2019-04-30 12:50:21Z l.w.m.roest.x $
% $Date: 2019-04-30 20:50:21 +0800 (Tue, 30 Apr 2019) $
% $Author: l.w.m.roest.x $
% $Revision: 15374 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/datestrnan.m $
% $Keywords: $

   if length(varargin) <=1
       FillValue = ' ';
   else
       FillValue = varargin{end};
       varargin  = varargin(1:end-1);
   end
   if length(FillValue)>1
       error(['FillValue should be only one character, not:',FillValue])
   end
   mask      = ~isnan(D);
   S2        = datestr(D(mask),varargin{:});
   sz        = size(S2); sz(1) = length(D);
   S         = repmat(FillValue,sz);
   S(mask,:) = S2;
end
   %EOF