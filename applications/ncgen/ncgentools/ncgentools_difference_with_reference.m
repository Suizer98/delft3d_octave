function varargout = ncgentools_difference_with_reference(source,reference,destination,varargin)
%NCGENTOOLS_FILL_AND_SORT_ALONG_DIMENSION  One line description goes here.
%
% If this function fails, this is probabluy due to a known matlab bug in ncwriteschema. A fix for theis bug can be found here:
%   http://www.mathworks.com/support/bugreports/819646
% TODO: Create posibility for source and destination are the same.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgentools_fill_and_sort_along_dimension(source,destination,varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgentools_fill_and_sort_along_dimension
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 07 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgentools_difference_with_reference.m 7889 2013-01-09 17:12:29Z tda.x $
% $Date: 2013-01-10 01:12:29 +0800 (Thu, 10 Jan 2013) $
% $Author: tda.x $
% $Revision: 7889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgentools/ncgentools_difference_with_reference.m $
% $Keywords: $

%% settings
% variable
OPT.dimension_name = 'z';


OPT = setproperty(OPT,varargin);

if nargin==0;
    varargout = OPT;
    return;
end
%% code

mkpath(destination);
delete2(dir2(destination,'no_dirs',1));
D = dir2(source,'depth',0,'no_dirs',1,'file_incl','\.nc$','file_excl','catalog');

for ii = 1:length(D)
    source_file      = [D(ii).pathname D(ii).name];
    reference_file   = fullfile(reference,D(ii).name);
    destination_file = fullfile(destination,D(ii).name);
    if ~exist(reference_file,'file')
        continue
    end
    ncschema         = ncinfo(source_file);
    % work around for bug http://www.mathworks.com/support/bugreports/819646
    [ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Length] = deal(inf);
    [ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Unlimited] = deal(false);
    
    ncwriteschema(destination_file,ncschema);
    variable_names   = {ncschema.Variables.Name};
    for iVariable = 1:length(variable_names)
        % read variable
        c = ncread(source_file,variable_names{iVariable});
        if strcmpi(variable_names{iVariable},OPT.dimension_name)
            c = -c + repmat(ncread(reference_file,variable_names{iVariable}),[1,1,size(c,3)]);
        end
        ncwrite(destination_file,variable_names{iVariable},c);
    end
    multiWaitbar('processing...',ii/length(D));
end
multiWaitbar('processing...','close');

