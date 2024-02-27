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

if ~isempty(find(~isnan(z)))
    z=fillValues(z,mask,'quickndirty');
    %z=fillValues(z,mask,'notquickndirty');
    z=smoothing(z,isn,mask,nsteps,fac);
end

%%
function z1=fillValues(z1,mask,opt)

switch opt
    case{'quickndirty'}
        % Take average on matrix
        zmean=mean(z1(~isnan(z1)));
        z1(isnan(z1))=zmean;
    otherwise

        nx=size(z1,2);
        ny=size(z1,1);

        % Add nan rows and columns
        zz=zeros(ny+2,nx+2);
        zz(zz==0)=NaN;
        n=0;
        
        while 1

            n=n+1;

            zz(2:end-1,2:end-1)=z1;
            
            % Left
            v1=zz(1:end-2,2:end-1);
            n1=zeros(size(v1));
            n1(~isnan(v1))=1;
            v1(isnan(v1))=0;
            % Right
            v2=zz(3:end,2:end-1);
            n2=zeros(size(v2));
            n2(~isnan(v2))=1;
            v2(isnan(v2))=0;
            % Bottom
            v3=zz(2:end-1,1:end-2);
            n3=zeros(size(v3));
            n3(~isnan(v3))=1;
            v3(isnan(v3))=0;
            % Top
            v4=zz(2:end-1,3:end);
            n4=zeros(size(v4));
            n4(~isnan(v4))=1;
            v4(isnan(v4))=0;
            
            sumn=n1+n2+n3+n4;
            sumn(sumn==0)=0.1;
            
            z2=(n1.*v1+n2.*v2+n3.*v3+n4.*v4)./sumn;
            z2(sumn<0.5)=NaN;
            z1(isnan(z1))=z2(isnan(z1));
            
            z1(mask==0)=NaN;

            % Check to see if any nans are left
            inan=find(isnan(z1)&mask==1);
            
            if isempty(inan)
                break
            end
            
        end
        
        
        

%         while 1
% 
%             icont=0;
%             z2=z1;
%             
%             for i=1:ny
%                 for j=1:nx
%                     if isnan(z1(i,j)) && mask(i,j)
% 
%                         if i>1
%                             v(1)=z1(i-1,j);
%                         else
%                             v(1)=NaN;
%                         end
%                         if i<ny
%                             v(2)=z1(i+1,j);
%                         else
%                             v(2)=NaN;
%                         end
%                         if j>1
%                             v(3)=z1(i,j-1);
%                         else
%                             v(3)=NaN;
%                         end
%                         if j<nx
%                             v(4)=z1(i,j+1);
%                         else
%                             v(4)=NaN;
%                         end
% 
%                         for k=1:4
%                             if ~isnan(v(k))
%                                 n(k)=1;
%                             else
%                                 n(k)=0;
%                                 v(k)=0;
%                             end
%                         end
% 
%                         if sum(n)>0
%                             z2(i,j)=(v(1)*n(1)+v(2)*n(2)+v(3)*n(3)+v(4)*n(4))/sum(n);
%                             icont=1;
%                         end
%                     end
%                 end
%             end
%             z1=z2;
%             if icont==0
%                 break;
%             end
%         end
end

%%
function z1=smoothing(z1,isn0,mask,nmax,ffac)

ni=size(z1,1);
nj=size(z1,2);

[ii,jj]=find(isn0 & mask);

%if length(ii)<0.2*ni*nj
if length(ii)<1

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

%    while 1

        % Fluxes
        fx=zeros(ni,nj+1);
        fy=zeros(ni+1,nj);

        fx(:,2:end-1)=z1(:,1:end-1)-z1(:,2:end);
        fy(2:end-1,:)=z1(1:end-1,:)-z1(2:end,:);
        
        fx(isnan(fx))=0;
        fy(isnan(fy))=0;

        fx=fx*ffac;
        fy=fy*ffac;

        dz=fx(:,1:end-1)-fx(:,2:end)+fy(1:end-1,:)-fy(2:end,:);

        % New matrix z2
        z2=z1+mask.*isn0.*dz;
        
%         
%         mndif(nn)=nanmean(nanmean(abs(z2-z1)));
% %        disp(mndif(nn))
%         
%         if nn>3
%             df1=mndif(nn-2)-mndif(nn-1);
%             df2=mndif(nn-1)-mndif(nn);
%             rat=df1/df2;
%             disp(rat)
%         end
%         
%         figure(3)
%         plot(mndif)

        z1=z2;

    end

end
