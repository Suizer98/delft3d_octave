function val = ddb_interpolateInitialConditions(dp, thick, pars, opt)
%DDB_INTERPOLATEINITIALCONDITIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   val = ddb_interpolateInitialConditions(dp, thick, pars, opt)
%
%   Input:
%   dp    =
%   thick =
%   pars  =
%   opt   =
%
%   Output:
%   val   =
%
%   Example
%   ddb_interpolateInitialConditions
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
nlayers=length(thick);

pars=pars';

depths=pars(1,:);
temps=pars(2,:);

depths=[-100000 depths 100000];
temps =[temps(1) temps temps(end)];

thick=thick*0.01;
sig(1)=0.5*thick(1);
for i=2:nlayers
    sig(i)=sig(i-1)+0.5*thick(i-1)+0.5*thick(i);
end

if ndims(dp)==2
    % Initial Conditions
    % Make sure that boundary points are also computed. This is necessary
    % for Domain Decomposition.
    mmax=size(dp,1);
    nmax=size(dp,2);
    %     mmax=mmax+1;
    %     nmax=nmax+1;
    %     dp0=zeros(mmax,nmax);
    %     dp0(dp0==0)=NaN;
    %     dp0(1:end-1,1:end-1)=dp;
    %     dp=dp0;
    for i=1:mmax
        for j=1:nmax
            if isnan(dp(i,j))
                % Find neighbors
                nn=0;
                % Right
                if i<mmax
                    dpr=dp(i+1,j);
                    if isnan(dpr)
                        dpr=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpr=0;
                end
                % Left
                if i>1
                    dpl=dp(i-1,j);
                    if isnan(dpl)
                        dpl=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpl=0;
                end
                % Top
                if j<nmax
                    dpt=dp(i,j+1);
                    if isnan(dpt)
                        dpt=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpt=0;
                end
                % Bottom
                if j>1
                    dpb=dp(i,j-1);
                    if isnan(dpb)
                        dpb=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpb=0;
                end
                if nn>0
                    dp(i,j)=(dpr+dpl+dpt+dpb)/nn;
                else
                    dp(i,j)=NaN;
                end
            end
        end
    end
    for i=1:nlayers
        dplayer(:,:,i)=dp*sig(i);
    end
else
    % Boundary Conditions
    for i=1:nlayers
        dplayer(:,i)=dp*sig(i);
    end
end

templayers=interp1(depths,temps,dplayer);
val=templayers;

