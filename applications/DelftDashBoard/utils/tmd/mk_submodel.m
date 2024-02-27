% function to make a submodel from a model ModName (TMD format)
% calculated on bathymetry grid Gridname
%
% usage:
% ()=mk_submodel(Name_old,Name_new,limits);
%
% PARAMETERS
%
% INPUT
% Name_old - root in "DATA/Model_root" control file for EXISTING
%            tidal model. File Model_* consists of lines:
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in TMD format
%
% Name_new - root in "DATA/Model_root" control file for SUBMODEL of
%            tidal model. The submodel is defined by
% limits - [lon1,lon2,lat1,lat2] OR [x1 x2 y1 y2] for a model in km;  
%          might be slightly CHANGED to adjust to original model grid
%
% OUTPUT:
%
% in TMD/DATA
% Model_<Name_new> - control file of 3 or 4 lines
%                    (as in old)
%       h.<Name_new> - elevation file   
%       UV.<Name_new> - transports file
%       grid_<Name_new> - grid file
%
% sample call:
% 
% mk_submodel('AntPen','AntPen1',[290,300,-70,-60]);
%
function []=mk_submodel(Name_old,Name_new,lims);

slash='/';
if computer=='PCWIN',slash='\';end

[hname,gname,Fxy_ll]=rdModFile(['DATA' slash 'Model_' Name_old],1);
[uname,gname,Fxy_ll]=rdModFile(['DATA' slash 'Model_' Name_old],2);
cons=rd_con(hname);
[nc,i4]=size(cons);
cid=reshape(cons',1,nc*i4);
[ll_lim,hz,mz,iob]=grd_in(gname);
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
else
  fprintf('Requested limits are out of Model area\n');
  fprintf('%s limits: %10.4f %10.4f %10.4f %10.4f\n',...
            Name_old,ll_lim);
  fprintf('Your limits: %10.4f %10.4f %10.4f %10.4f\n',lims);
  return
end
%
cname1=['DATA' slash 'Model_' Name_new];
gname1=['grid_' Name_new];
hname1=['h.' Name_new];
uname1=['UV.' Name_new];

fprintf('Writing control file %s\n',cname1);
fid=fopen(cname1,'w');
fprintf(fid,'%s\n',hname1);
fprintf(fid,'%s\n',uname1);
fprintf(fid,'%s\n',gname1);
if isempty(Fxy_ll)==0,
 fprintf(fid,'%s\n',Fxy_ll);
end
fclose(fid);

fprintf('Writing grid file DATA%s%s...', slash,gname1);
grd_out(['DATA/' gname1],new_lims,hz1,mz1,[],12.);
fprintf('done\n');

fprintf('Reading elevation file %s\n',hname);
H=zeros(n1,m1,nc);
for ic=1:nc
 [h1,th_lim,ph_lim]=h_in(hname,ic);
 H(:,:,ic)=h1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing elevation file DATA%s%s...',slash,hname1);
h_out(['DATA' slash hname1],H,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

fprintf('Reading transports file %s\n',uname);
U=zeros(n1,m1,nc);V=U;
for ic=1:nc
 [u1,v1,th_lim,ph_lim]=u_in(uname,ic);
 U(:,:,ic)=u1(i1:i2,j1:j2);V(:,:,ic)=v1(i1:i2,j1:j2);
 fprintf('Constituent %s done\n',cons(ic,:));
end
fprintf('Writing trasnport file DATA%s%s...',slash,uname1);
uv_out(['DATA' slash uname1],U,V,new_lims(3:4),new_lims(1:2),cid);
fprintf('done\n');

return
