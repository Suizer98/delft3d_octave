function [struc iac nr] = UpDownDeleteStruc(struc, iac, opt)
%UPDOWNDELETESTRUC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [struc iac nr] = UpDownDeleteStruc(struc, iac, opt)
%
%   Input:
%   struc =
%   iac   =
%   opt   =
%
%   Output:
%   struc =
%   iac   =
%   nr    =
%
%   Example
%   UpDownDeleteStruc
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
nr=length(struc);

switch lower(opt)
    case{'up','moveup'}
        if nr>1 && iac>1
            a=struc(iac-1);
            struc(iac-1)=struc(iac);
            struc(iac)=a;
            iac=iac-1;
        end
    case{'down','movedown'}
        if nr>1 && iac<nr
            a=struc(iac+1);
            struc(iac+1)=struc(iac);
            struc(iac)=a;
            iac=iac+1;
        end
    case{'delete'}
        if nr>0
            if nr>iac
                for k=iac:nr-1
                    struc(k)=struc(k+1);
                end
            else
                iac=iac-1;
            end
            struc=struc(1:nr-1);
        end
end

nr=length(struc);

