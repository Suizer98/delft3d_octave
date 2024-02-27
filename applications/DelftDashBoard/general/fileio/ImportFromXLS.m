function [data ok] = ImportFromXLS
%IMPORTFROMXLS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [data ok] = ImportFromXLS
%
%   Input:

%
%   Output:
%   data =
%   ok   =
%
%   Example
%   ImportFromXLS
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
[filename, pathname, filterindex] = uigetfile('*.xls', 'Select *.xls File');
[num,txt] = xlsread(filename, -1);
nrow=size(num,1);
ok=0;
if nrow>=2
    if length(txt)>0
        if size(num,2)==2 & size(txt,2)==1
            for i=1:nrow
                data{i,1}=datenum(txt{i});
                data{i,2}=num(i,1);
                data{i,3}=num(i,2);
            end
            ok=1;
        end
    else
        if size(num,2)==3
            for i=1:nrow
                data{i,1}=datenum('30-Dec-1899') + num(i,1);
                data{i,2}=num(i,2);
                data{i,3}=num(i,3);
            end
            ok=1;
        end
    end
end

