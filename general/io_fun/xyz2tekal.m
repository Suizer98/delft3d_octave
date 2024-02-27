function xyz2tekal(xyz_fname,tekal_fname,varargin)
%XYZ2TEKAL converts an xyz file to tekal format
%
%   XYZ2TEKAL converts an xyz file to a tekal file.
%   The xyz file should contain a Nx3 array with NaN separated segments
%
%   Syntax:
%   xyz2tekal(xyz_fname,tekal_fname)
%
%   Input:
%   xyz_fname = xyz filename (string)
%   tekal_fname = tekal filename (string)
%
%   Output:
%   tekal file
%
%   Example
%   xyz2tekal(xyz_fname,tekal_fname
%
%   See also landboundary, tekal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 06 Jun 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: xyz2tekal.m 10819 2014-06-06 09:12:44Z bartgrasmeijer.x $
% $Date: 2014-06-06 17:12:44 +0800 (Fri, 06 Jun 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 10819 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/xyz2tekal.m $
% $Keywords: $

%%
% OPT.keyword=value;
% return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code

RemoveLengthOne=0;
XYSep=1;
DoSplit=0;
Format='%4i';

a1 = load(xyz_fname);
data1 = a1(:,1);
data2 = a1(:,2);
data3 = a1(:,3);

I=[0; find(isnan(data1(:,1))); size(data1,1)+1];

j = 0;
for i=1:(length(I)-1)
    if I(i+1)>(I(i)+1+RemoveLengthOne)
        % remove lines of length 0 (and optionally 1)
        j=j+1;
        if j==1
            T.Field(1).Comments = { ...
                '*column 1 = x coordinate'
                '*column 2 = y coordinate'
                '*column 3 = z coordinate'};
        end
        T.Field(j).Name = sprintf(Format,j);
        T.Field(j).Size = [I(i+1)-I(i)-1 3];
        if XYSep
            T.Field(j).Data = [data1((I(i)+1):(I(i+1)-1)) data2((I(i)+1):(I(i+1)-1)) data3((I(i)+1):(I(i+1)-1))];
        else
            T.Field(j).Data = data1((I(i)+1):(I(i+1)-1),:);
        end
    end
end

tekal('write',tekal_fname,T);