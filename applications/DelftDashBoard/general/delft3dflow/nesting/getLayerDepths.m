function dplayer = getLayerDepths(dp, thick, varargin)
%GETLAYERDEPTHS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   dplayer = getLayerDepths(dp, thick, varargin)
%
%   Input:
%   dp       =
%   thick    =
%   varargin =
%
%   Output:
%   dplayer  =
%
%   Example
%   getLayerDepths
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

% $Id: getLayerDepths.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/getLayerDepths.m $
% $Keywords: $

%%
nlayers=length(thick);
thick=thick*0.01;

mmax=size(dp,1);
nmax=size(dp,2);

if nargin==2
    
    % Sigma layers
    
    sig(1)=0.5*thick(1);
    for i=2:nlayers
        sig(i)=sig(i-1)+0.5*thick(i-1)+0.5*thick(i);
    end
    
    if ndims(dp)==2
        % Initial Conditions
        % Make sure that boundary points are also computed. This is necessary
        % for Domain Decomposition.
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
    
else
    % Z-layers
    zbot=varargin{1};
    ztop=varargin{2};
    
    dpth=ztop-zbot;
    
    thick=fliplr(thick);
    
    d(1)=ztop-0.5*thick(1)*dpth;
    
    for k=2:nlayers
        d(k)=d(k-1)-0.5*thick(k-1)*dpth-0.5*thick(k)*dpth;
    end
    
    if ndims(dp)==2
        for i=1:mmax
            for j=1:nmax
                dplayer(i,j,:)=-d;
            end
        end
    else
        for i=1:length(dp)
            dplayer(i,:)=-d;
        end
    end
    
end

