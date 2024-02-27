function [xv,yv] = UCIT_WS_polydraw
warning('UCIT_WS_polydraw deprecated in favour of poly_draw')
%UCIT_WS_POLYDRAW  gets coordinates of used defined polygon
%
%
% See also: polydraw

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

% Draw polygon (from Argus IBM)
% pick some boundaries

uo = []; vo = []; button = [];

[uo,vo,lfrt] = ginput(1);
button = lfrt;
hold on; hp = plot(uo,vo,'+g');

while lfrt == 1
    [u,v,lfrt] = ginput(1);
     uo = [uo;u]; 
     vo = [vo;v]; button=[button;lfrt];      
    delete(hp);
    hp = plot(uo,vo,'color','g','linewidth',2);
end

% Bail out at ESCAPE = ascii character 27
if lfrt == 27
    delete(hp);
    return
end

% connect
if(exist('hp'))
    xv = [uo(:);uo(1)];
    yv = [vo(:);vo(1)];
end

delete(hp); %Delete poly
