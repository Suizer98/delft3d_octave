function UCIT_fncResizeUSGS
%UCIT_FNCRESIZEUSGS  resizefunction of gui of plotAlongshore
%
%
%   See also plotAlongshore

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
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
scrn = get(gcf,'Position');
Heightscr = scrn(4);

if Heightscr<30&Heightscr>24
    for i=1:6
        set(findobj('tag',['text',num2str(i)]), 'fontsize',8)
        set(findobj('tag','beginTransect'), 'fontsize',8)
        set(findobj('tag','endTransect'), 'fontsize',8)
        set(findobj('tag','Input'), 'fontsize',8)
        set(findobj('tag','Toppanel'), 'fontsize',10)
        set(findobj('tag','Bottompanel'), 'fontsize',10)
    end
elseif Heightscr<24
        for i=1:6
        set(findobj('tag',['text',num2str(i)]), 'fontsize',7)
        set(findobj('tag','beginTransect'), 'fontsize',7)
        set(findobj('tag','endTransect'), 'fontsize',7)
        set(findobj('tag','Input'), 'fontsize',7)
        set(findobj('tag','Toppanel'), 'fontsize',8)
        set(findobj('tag','Bottompanel'), 'fontsize',8)
        
        end
else
    for i=1:6
        set(findobj('tag',['text',num2str(i)]), 'fontsize',10)
        set(findobj('tag','beginTransect'), 'fontsize',10)
        set(findobj('tag','endTransect'), 'fontsize',10)
        set(findobj('tag','Input'), 'fontsize',10)
        set(findobj('tag','Toppanel'), 'fontsize',12)
        set(findobj('tag','Bottompanel'), 'fontsize',12)
    end
end


