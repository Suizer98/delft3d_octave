function [x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new)
% ADDXVALUESEXACTCROSSINGS function to add x-values at crossings
%
% routine to find the x-values of the intersections of 2 lines
%
% Syntax:
% [x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new)
%
% Input:
% x_new  = 
% z1_new = 
% z2_new = 
%
% Output:
% x2add  = 
%
% See also: , POLYINTERSECT

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: addXvaluesExactCrossings.m 5075 2011-08-17 10:32:38Z boer_g $ 
% $Date: 2011-08-17 18:32:38 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5075 $

%%
x2add = [];
id = find(diff(z1_new>=z2_new)~=0);
for i = 1 : length(id)
    % NaN values generate extra id points, which do not represent
    % crossings. ("~=" statement automatically gives 0 if NaN is present).
    % For each id determine whether neighbouring values are NaN. If not, a
    % crossing is found.
    if ~isnan(z2_new(id(i)+1)) && ~isnan(z1_new(id(i)+1))
        if id(i)==1 || (~isnan(z2_new(id(i))) && ~isnan(z1_new(id(i))))
            % create a line using polyfit based on x-indices rather than
            % actual x-values. (this prevents problems (warnings) in case
            % of x2add-values which are very close to an original x-value)
            pn = polyfit((id(i):id(i)+1)', z1_new(id(i):id(i)+1)-z2_new(id(i):id(i)+1), 1);
            % create the x-index to add
            id2add = (0-pn(2))/pn(1);
            % translate x-index to actual x-value to add
            x2add = [x2add; x_new(id(i))+diff(x_new(id(i):id(i)+1))*(id2add-id(i))];
        end
    end
end
x2add = x2add(~isnan(x2add));