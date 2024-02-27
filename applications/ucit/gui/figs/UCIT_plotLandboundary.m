function UCIT_plotLandboundary(filename,color)
%UCIT_PLOTLANDBOUNDARY   plots a landboundary with an optional fill color
%
%   syntax:
%   UCIT_plotLandboundary(filename,fillcolor)
%
%   input:
%       filename: either local or on the internet
%       fill color: color or 'none'
%
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%   Ben de Sonneville
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

try
%% load landboundary from server
X	=  nc_varget(filename,'x');
Y	=  nc_varget(filename,'y');

%% plot it (either filled or not filled)
if nargin < 2 
    fillpolygon([X,Y],'b',[1 1 0.6],100,-100); hold on;
    set(gca,'color',[0.4 0.6 1])
elseif nargin == 2 && strcmp(color,'none')
    plot(X,Y,'b','linewidth',1);hold on;
elseif nargin == 2 
    fillpolygon([X,Y],'k',color,100,-100); hold on;
    set(gca,'color',[0.4 0.6 1])
end
catch
    disp(['dataset broken: ',filename])
end