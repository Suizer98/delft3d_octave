function z=internaldiffusion(z,varargin)
%INTERNALDIFFUSION fills up missing data (NaNs) in matrices and
%applies smoothing a la Quickin.
%
%   z = internalDiffusion(z,'keyword','value')
%
%   Example
%     z=rand(100,100)
%     z(40:50,70:80)=NaN
%     z=internalDiffusion(z)
%
%   It is possible to apply a mask for the operation by specifying
%   a matrix (same size as z) containing ones and zeros. Cells in
%   the mask that have a value of zero will not be filled.
%
%   Example
%      z=rand(100,100)
%      z(40:80,20:80)=NaN
%      msk=ones(size(z))
%      msk(60:70,40:50)=0
%      z=internalDiffusion(z,'Mask',msk)

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
%
%       Deltares
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

mask=ones(size(z));
nsteps=100;
fac=0.2;

for i=1:nargin-1
    if ischar(varargin{i})
        switch lower(varargin{i}(1:3))
            case{'mas'}
                mask=varargin{i+1};
            case{'nst'}
                nsteps=varargin{i+1};
            case{'fac'}
                fac=varargin{i+1};
        end
    end
end

isn=isnan(z);

z=fillValues(z,mask);

z=smoothing(z,isn,mask,nsteps,fac);

%%
function z1=fillValues(z1,mask)

nx=size(z1,2);
ny=size(z1,1);

while 1

    icont=0;
    z2=z1;
    
    for i=1:ny
        for j=1:nx
            if isnan(z1(i,j)) && mask(i,j)

                if i>1
                    v(1)=z1(i-1,j);
                else
                    v(1)=NaN;
                end
                if i<ny
                v(2)=z1(i+1,j);
                else
                v(2)=NaN;
                end
                if j>1
                v(3)=z1(i,j-1);
                else
                v(3)=NaN;
                end
                if j<nx
                v(4)=z1(i,j+1);
                else
                    v(4)=NaN;
                end

                for k=1:4
                    if ~isnan(v(k))
                        n(k)=1;
                    else
                        n(k)=0;
                        v(k)=0;
                    end
                end

                if sum(n)>0
                    z2(i,j)=(v(1)*n(1)+v(2)*n(2)+v(3)*n(3)+v(4)*n(4))/sum(n);
                    icont=1;
                end
            end
        end
    end
    z1=z2;
    if icont==0
        break;
    end
end

%%
function z1=smoothing(z1,isn0,mask,nmax,ffac)

ni=size(z1,1);
nj=size(z1,2);

[ii,jj]=find(isn0 & mask);

if length(ii)<0.2*ni*nj

    % Less than 20 percent missing points
    % Point by point
    
    for n=1:nmax

        z2=z1;

        for k=1:length(ii)
            
            i=ii(k);
            j=jj(k);

            % Fluxes

            if j>1 && mask(i,j-1)
                fx1=z1(i,j-1)-z1(i,j);
            else
                fx1=0;
            end
            if j<nj && mask(i,j+1)
                fx2=z1(i,j)-z1(i,j+1);
            else
                fx2=0;
            end

            if i>1 && mask(i-1,j)
                fy1=z1(i-1,j)-z1(i,j);
            else
                fy1=0;
            end
            if i<ni && mask(i+1,j)
                fy2=z1(i,j)-z1(i+1,j);
            else
                fy2=0;
            end

            dz=ffac*(fx1-fx2+fy1-fy2);

            z2(i,j)=z1(i,j)+dz;
        end

        z1=z2;

    end

else

    % Whole matrix

    for n=1:nmax

        % Fluxes
        fx=zeros(ni,nj+1);
        fy=zeros(ni+1,nj);

        fx(:,2:end-1)=z1(:,1:end-1)-z1(:,2:end);
        fy(2:end-1,:)=z1(1:end-1,:)-z1(2:end,:);

        fx=fx*ffac;
        fy=fy*ffac;

        dz=fx(:,1:end-1)-fx(:,2:end)+fy(1:end-1,:)-fy(2:end,:);

        z2=z1+isn0.*dz;

        z1=z2;

    end

end
