function out = D3DTimeString(in, varargin)
%D3DTIMESTRING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   out = D3DTimeString(in, varargin)
%
%   Input:
%   in       =
%   varargin =
%
%   Output:
%   out      =
%
%   Example
%   D3DTimeString
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
if nargin==1
    if ischar(in)
        a=strread(in);
        year=a(1);
        month=a(2);
        day=a(3);
        if length(a)==6
            hour=a(4);
            minute=a(5);
            second=a(6);
        else
            hour=0;
            minute=0;
            second=0;
        end
        out=datenum(year,month,day,hour,minute,second);
    else
        out=datestr(in,'yyyy mm dd HH MM SS');
        %        out=datestr(in,'yyyymmdd HHMMSS');
    end
else
    if strcmp(lower(varargin{1}),'itdatemdf')
        out=datestr(in,'yyyy-mm-dd');
    elseif strcmp(lower(varargin{1}),'itdate')
        out=datestr(in,'yyyy mm dd');
    end
end

