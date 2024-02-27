function []=mk_submodel_lp;
% =====================================================================
% Function to make a submodel from a model ModName (TMD format)
%   calculated on bathymetry grid Gridname
%
% PARAMETERS
%
% INPUT: User specified interactively
%
% OUTPUT:
% Model_<Name_new> - control file of 3 or 4 lines
%                    (as in old)
%       h.<Name_new> - elevation file   
%       UV.<Name_new> - transports file
%       grid_<Name_new> - grid file
%
% sample call:    mk_submodel_lp;
%
% Written by:  Lana Erofeeva (OSU): serofeeva@coas.oregonstate.edu
% Modified by: Laurie Padman (ESR): padman@esr.org
%
% This Version:   October 1, 2004
%
% ======================================================================

slash='/';
if computer=='PCWIN',slash='\';end

% Select the input model to trim down
[fname,fpath] = uigetfile('Model*','Model file to process ...');
if(~fname) % user pressed Cancel in file dialog box
    return;
end;
Model=fullfile(fpath,fname);
i1=findstr(fname,'_');
len=length(fname);
Name_old=fname((i1+1):len);

% Create new file name (will be placed temporarily in same directory)
Name_new=input('Enter name of new model ...','s')

[hname,gname,Fxy_ll]=rdModFile(Model,1);
[uname,gname,Fxy_ll]=rdModFile(Model,2);

cons=rd_con(hname);
[nc,i4]=size(cons);
cid=reshape(cons',1,nc*i4);
[ll_lim,hz,mz,iob]=grd_in(gname);

% Enter new limits
disp(' ')
disp('Grid limits on old file are ...')
disp(ll_lim')
disp(' ')
lims=input('Enter lon, lat limits ( [lon1 lon2 lat1 lat2] ) ... ')

% check limits
if ll_lim(1)<=lims(1) & ll_lim(2)>=lims(2) &...
   ll_lim(3)<=lims(3) & ll_lim(4)>=lims(4),
   [n,m]=size(hz);
   [lon,lat]=XY(ll_lim,n,m);
   stlon=lon(2)-lon(1);stlat=lat(2)-lat(1);
   i1=min(find(lon>lims(1))); i2=max(find(lon<lims(2)));
   j1=min(find(lat>lims(3))); j2=max(find(lat<lims(4)));
   new_lims=[lon(i1)-stlon/2,lon(i2)+stlon/2,...
             lat(j1)-stlat/2,lat(j2)+stlat/2];
   n1=i2-i1+1;m1=j2-j1+1;
   hz1=hz(i1:i2,j1:j2);mz1=mz(i1:i2,j1:j2);
   disp([i1 i2 j1 j2])
else
  fprintf('Requested limits are out of Model area\n');
  fprintf('%s limits: %10.4f %10.4f %10.4f %10.4f\n',...
            Name_old,ll_lim);
  fprintf('Your limits: %10.4f %10.4f %10.4f %10.4f\n',lims);
  return
end
%
cname1=['Model_' Name_new];
gname1=['grid_' Name_new];
hname1=['h_' Name_new];
uname1=['UV_' Name_new];

fprintf('Writing control file %s\n',fullfile(fpath,cname1));
fid=fopen(fullfile(fpath,cname1),'w');
fprintf(fid,'%s\n',hname1);
fprintf(fid,'%s\n',uname1);
fprintf(fid,'%s\n',gname1);
if isempty(Fxy_ll)==0,
 fprintf(fid,'%s\n',Fxy_ll);
end
fclose(fid);

fprintf('Writing grid file %s...', gname1);
grd_out(fullfile(fpath,gname1),new_lims,hz1,mz1,[],12.);
fprintf('done\n');

fprintf('Reading elevation file %s\n',hname);
H=zeros(n1,m1,nc);
for ic=1:nc
 [h1,th_lim,ph_lim]=h_in(hname,ic);
 H(:,:,ic)=h1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing elevation file ...',hname1);
h_out(fullfile(fpath,hname1),H,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

fprintf('Reading transports file %s\n',uname);
U=zeros(n1,m1,nc);V=U;
for ic=1:nc
 [u1,v1,th_lim,ph_lim]=u_in(uname,ic);
 U(:,:,ic)=u1(i1:i2,j1:j2);V(:,:,ic)=v1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing transport file ...',uname1);
uv_out(fullfile(fpath,uname1),U,V,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

return
