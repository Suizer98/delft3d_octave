function [check] = UCIT_focusOn_Window(objTag)
%UCIT_FOCUSON_WINDOW  make a figure the current figure based on an objecttag
%
% input:
%   objTag = 
% output:
%   check  = 1: operation succesful, 0: operation unsuccesful 
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


if nargin==0
    mapW=findobj('tag','mapWindow');
else
    mapW=findobj('tag',objTag);
end

if isempty(mapW)
    check = 0;
    switch objTag
        case 'plotWindow'
            errordlg('First make a plot!','No plot found');
            return

        case 'mapWindow'
            errordlg('First make an overview plot (with plotTransectOutlines)','No map found');
            return

        case 'mapWindowPoints'
            errordlg('First make a Points Overview!','No map found');
            return
    end
else
    check = 1;
end

figure(mapW);
% Reset current object (set the current object to be the figure itself)
set(mapW,'CurrentObject',mapW);