function [xt,yt] = detran_uvData2xyData(ut,vt,alfa)
%DETRAN_UVDATA2XYDATA Converts uv data 2 xy data
%
% Converts u and v transport components at grid cell interfaces to x and y components in cell centres
%
%   Syntax:
%   [xt,yt] = detran_uvData2xyData(ut,vt,alfa)
%
%   Input:
%   ut		= transport in m-direction [M x N]
%   vt		= transport in n-direction [M x N]
%   alfa	= grid orientation [M x N]
%
%   Output:
%   xt		= transport in x-direction [M x N]
%   yt		= transport in y-direction [M x N]
%
%   See also detran, detran_TransArbCSEngine

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.


ut=0.5*(ut(:,1:end-1)+ut(:,2:end));
vt=0.5*(vt(1:end-1,:)+vt(2:end,:));
ut=[repmat(nan,size(ut,1),1) ut];
vt=[repmat(nan,1,size(vt,2)); vt];
xt = -vt.*sin(alfa/360*2*pi)+ut.*cos(alfa/360*2*pi);
yt =  vt.*cos(alfa/360*2*pi)+ut.*sin(alfa/360*2*pi);
