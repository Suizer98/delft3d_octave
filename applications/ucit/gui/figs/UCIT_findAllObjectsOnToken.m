function objectTags = UCIT_findAllObjectsOnToken(token)
%UCIT_FINDALLOBJECTSONTOKEN finds transect line handles
%
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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

%Find all rays
objectTags=findobj(gca,'type','line','LineStyle','-');
dpTs=strvcat(get(objectTags,'tag'));
for ii=1:size(dpTs,1);
    if strfind(dpTs(ii,:),token)
        res(ii)=1;
    end
end
objectTags=objectTags(find(res==1));

if isempty(objectTags)
    errordlg('No rays found!','');
    return
end