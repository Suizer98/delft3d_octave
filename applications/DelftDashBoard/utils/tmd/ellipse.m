% ellipse Calculate tidal ellipse parameters at given locations using a model
%
% USAGE
% [umajor,uminor,uphase,uincl]=ellipse(Model,lat,lon,constit);
% 
% PARAMETERS
%
% INPUT
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
%
% lat(L),lon(L) - coordinates (degrees)
% constit - constituent name, char length <=4
%
% OUTPUT
% umajor,uminor,uphase,uincl - tidal ellipse parameters (cm/s,o) in
%                              lat,lon
%
% Dependencies: u_in,grd_in,XY,rd_con,BLinterp,TideEl,checkTypeName
%
% Sample call:
% [umaj,umin,uph,uinc]=ellipse('DATA/Model_Ross_prior',-73,186,'k1');
%
%See also: get_ellipse, TideEl

% Last update: June 21, 2006


function [umajor,uminor,uphase,uincl]=ellipse(Model,lat,lon,constit);
[ModName,GridName,Fxy_ll]=rdModFile(Model,2);
km=1;
if isempty(Fxy_ll)>0,km=0;end
[Flag]=checkTypeName(ModName,GridName,'u');
if Flag>0,return;end
while length(constit)<4,constit=[constit ' '];end
L=length(lon);
if km==1,
    eval(['[xt,yt]=' Fxy_ll '(lon,lat,''F'');']);
else
    xt=lon;yt=lat;
end
[ll_lims,H,mz,iob]=grd_in(GridName);
[n,m]=size(H);
[x,y]=XY(ll_lims,n,m);
dx=x(2)-x(1);dy=y(2)-y(1);
conList=rd_con(ModName);
[nc,dum]=size(conList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xu=x-dx/2;yv=y-dy/2;
D=BLinterp(x,y,H,xt,yt);
%
for ic=1:nc
    if constit==conList(ic,:) | lower(constit)==conList(ic,:) ...
            | upper(constit)==conList(ic,:),
        ic1=ic;break
    end
end
%
[u,v,th_lim,ph_lim]=u_in(ModName,ic1);
[nn,mm]=size(u);
if nn~=n | mm~=m,TMDcrash(n,m,nn,mm);
    return;
end
u(find(u==0))=NaN;v(find(v==0))=NaN;
u1=BLinterp(xu,y,u,xt,yt);
v1=BLinterp(x,yv,v,xt,yt);
u1=u1./D*100;v1=v1./D*100;
[umajor,uminor,uincl,uphase]=TideEl(u1,v1);
return
