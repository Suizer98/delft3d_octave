function pnu = streakarrow(X0,Y0,U,V,np,arrow,colmap,varargin)

%H = STREAKARROW(X,Y,U,V,np,arrow) creates "curved" vectors, from 
% 2D vector data U and V. All vectors have the same length. The
% magnitude of the vector is color coded.
% The arrays X and Y defines the coordinates for U and V.
% The variable np is a coefficient >0, changing the length of the vectors.
%     np=1 corresponds to a whole meshgrid step. np>1 allows ovelaps like
%     streamlines.
% The parameter arrow defines the type of plot: 
%   arrow=1 draws "curved" vectors
%   arrow=0 draws circle markers with streaks like "tuft" in wind tunnel
%   studies

% Example:
    %load wind
    %N=5; X0=x(:,:,N); Y0=y(:,:,N); U=u(:,:,N); V=v(:,:,N);
    %H=streakarrow(X0,Y0,U,V,1.5,0); box on; 
    
% Bertrand Dano 10-25-08
% Copyright 1984-2008 The MathWorks, Inc. 

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jan 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: streakarrow.m 10054 2014-01-22 14:24:57Z bartgrasmeijer.x $
% $Date: 2014-01-22 22:24:57 +0800 (Wed, 22 Jan 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 10054 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/streakarrow.m $
% $Keywords: $
   
DX=abs(X0(1,1)-X0(1,2)); DY=abs(Y0(1,1)-Y0(2,1)); DD=min([DX DY]);
ks=DD/100;      % Size of the "dot" for the tuft graphs
np=np*10;   
alpha = 4; %5 % Size of arrow head relative to the length of the vector
beta = 0.25; %.25 % Width of the base of the arrow head relative to the length

XY=stream2(X0,Y0,U,V,X0,Y0);
%np=15;
Vmag=sqrt(U.^2+V.^2);
Vmin=min(Vmag(:)); Vmax=max(Vmag(:));
Vmag=Vmag(:); x0=X0(:); y0=Y0(:);

OPT.min = Vmin;
OPT.max = Vmax;
OPT = setproperty(OPT, varargin);
Vmin = OPT.min;
Vmax = OPT.max;

%ks=.1;
cmap=colmap;
% cmap=colormap;
pnu = 0;
for k=1:length(XY)
    if isempty(XY{k})
        pnu = pnu+1;
    end
    if ~isempty(XY{k})
    F=XY(k); [L M]=size(F{1});
        if L<np
            F0{1}=F{1}(1:L,:);
            if L==1
                F1{1}=F{1}(L,:);
            else
                F1{1}=F{1}(L-1:L,:);
            end
            
        else
            F0{1}=F{1}(1:np,:);
            F1{1}=F{1}(np-1:np,:);
        end
        
    P=F1{1};
    vcol=floor((Vmag(k)-Vmin)./(Vmax-Vmin)*64); if vcol==0; vcol=1; end
    COL=[cmap(vcol,1) cmap(vcol,2) cmap(vcol,3)];
    hh=streamline(F0);
%     set(hh,'color',COL,'linewidth',0.5);
    set(hh,'color',COL,'linewidth',0.5);

    if arrow==1&L>1
       x1=P(1,1); y1=P(1,2); x2=P(2,1); y2=P(2,2);
       u=x1-x2; v=y1-y2; u=-u; v=-v; 
       xa1=x2+u-alpha*(u+beta*(v+eps)); xa2=x2+u-alpha*(u-beta*(v+eps));
       ya1=y2+v-alpha*(v-beta*(u+eps)); ya2=y2+v-alpha*(v+beta*(u+eps));
%        plot([xa1 x2 xa2],[ya1 y2 ya2],'color',COL); hold on
       plot([xa1 x2 xa2],[ya1 y2 ya2],'color',COL,'LineWidth',1); hold on
   else
    rectangle('position',[x0(k)-ks/2 y0(k)-ks/2 ks ks],'curvature',[1 1],'facecolor',COL, 'edgecolor',COL)
    end   
    end
end
fprintf(strcat(num2str(pnu),'\n'))

axis image
%colorbar vert
%h=colorbar; 
%set(h,'ylim',[Vmin Vmax])

