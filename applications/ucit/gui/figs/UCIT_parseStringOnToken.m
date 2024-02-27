function [parts]=UCIT_parseStringOnToken(string,token)
%PARSESTRINGONTOKEN   separates <string> into <parts> based on a separation <token>
%
% input:
%   string
%   token
%
% output:
%   parts
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

for i=1:size(string,1)
    if i==1 & size(string,1)==1
        if iscell(string)
            toparse=string{i};
        else
            toparse=string;
        end
    else
        toparse=string{i};
    end
    partnr=1;
    while ~isempty(toparse)
        [part,toparse]=strtok(toparse,token);
        parts{i,partnr} = part;
        partnr=partnr+1;
    end
end