function [dpu,dpv] = compute_dpuv(d,dpsopt,dpuopt)
%compute dpuv Computes values for dpu and dpv from depth matrix.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getxuyu.m 5573 2011-12-05 14:56:01Z boer_we $
% $Date: 2011-12-05 15:56:01 +0100 (Mon, 05 Dec 2011) $
% $Author: boer_we $
% $Revision: 5573 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/misc/getxuyu.m $
% $Keywords: $

dpu=d;
dpv=d;

switch lower(dpsopt)
    case{'dp'}
        % depths defined in cell centres
        switch lower(dpuopt)
            case{'mean_dps'}

                d1=d(1:end-2,:);
                d2=d(2:end-1,:);
                d3=0.5*(d1+d2);
                dpu(1:end-2,:)=d3;

                d1=d(:,1:end-2);
                d2=d(:,2:end-1);
                d3=0.5*(d1+d2);
                dpv(:,1:end-2)=d3;
            
            case{'min','mor'}
        end
end
