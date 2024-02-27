function catalog = mvbCatalog(varargin)
%MVBCATALOG Retreives catalog of parameters from Meetnet Vlaamse Banken API.
%
%   This script retreives the catalog from the API of Meetnet Vlaamse
%   Banken (Flemish Banks Monitoring Network API). The catalog is returned
%   in a struct. The catalog contains an inventory of all measurement
%   locations and parameters with meta-data.
%
%   A login token is required, which can be obtained with MVBLOGIN. A login
%   can be requested freely from https://meetnetvlaamsebanken.be/
%
%   Syntax:
%   Catalog = mvbCatalog(token);
%   Catalog = mvbCatalog('token',token);
%
%   Input: For <keyword,value> pairs call mvbCatalog() without arguments.
%   varargin  =
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. Generate this
%           token via mvbLogin.
%       apiurl: url to Meetnet Vlaamse Banken API.
%
%   Output:
%       catalog: struct
%           Contains overview of locations, parameters and meta-data.
%
%   Example:
%   Catalog = mvbCatalog('token',token);
%   var2evalstr(Catalog);
%
%   See also: MVBLOGIN, MVBMAP, MVBTABLE, MVBGETDATA.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be 
%       l.w.m.roest@tudelft.nl
%
%       KU Leuven campus Bruges,
%       Spoorwegstraat 12,
%       8200 Bruges,
%       Belgium
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
% Created: 02 May 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id: mvbCatalog.m 17765 2022-02-15 09:57:04Z l.w.m.roest.x $
% $Date: 2022-02-15 17:57:04 +0800 (Tue, 15 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17765 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/meetnetvlaamsebanken/mvbCatalog.m $
% $Keywords: $

%% Input arguments
OPT.apiurl='https://api.meetnetvlaamsebanken.be/V2/';
OPT.token=weboptions;

% return defaults (aka introspection)
if nargin==0;
    catalog = {OPT};
    return
elseif mod(nargin,2)==1;
    OPT.token=varargin{end};
else
    % overwrite defaults with user arguments
    OPT = setproperty(OPT, varargin);
end

%% Login Check
% Check if login is still valid!
response=webread([OPT.apiurl,'ping'],OPT.token);
if isempty(response.Customer) %Check if login has expired.
    fprintf(1,['Your login token is invalid, please login using mvbLogin \n'...
        'Use the obtained token from mvbLogin in this function. \n']);
    catalog=cell(nargout);
    return
end

%% GET catalog
% GET catalog from API
catalog=webread([OPT.apiurl,'catalog'],OPT.token);

end
%EOF