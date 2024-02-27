function str = nums2str(X,varargin)
%NUMS2STR   NUM2STR for whole array with specified seperation symbol.
%
% str = nums2str(...) same as num2str, but puts
% '_' between succesive numbers.
%
% E.g. nums2str([1,2]) = '1_2'
%
% NUM2STR(X,SEPARATOR) puts separator between numbers rather than '_'.
% NUM2STR(X,SEPARATOR,FORMAT) puts separator
%
% Example: % to get '(1),(2),(3)'
% ['(',nums2str([1 2 3],'),('),')']
%
% See also: num2str

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: nums2str.m 7276 2012-09-24 06:12:52Z boer_g $
% $Date: 2012-09-24 14:12:52 +0800 (Mon, 24 Sep 2012) $
% $Author: boer_g $
% $Revision: 7276 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/nums2str.m $
% $Keywords$

   separator        = '_';
if nargin==1
   str =                num2str(X(1));
   for i=2:length(X)
   str = [str,separator,num2str(X(i))];
   end
elseif nargin==2
   separator        = varargin{1};
   str =                num2str(X(1));
   for i=2:length(X)
   str = [str,separator,num2str(X(i))];
   end
elseif nargin==3
   separator        = varargin{1};
   format           = varargin{2};
   str =                num2str(X(1),format);
   for i=2:length(X)
   str = [str,separator,num2str(X(i),format)];
   end
end

% EOF