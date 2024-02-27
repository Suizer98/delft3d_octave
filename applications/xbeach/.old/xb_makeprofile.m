function xb_makeprofile
%XB_MAKEPROFILE generate xbeach profile
%
%See also: xbeach

dx=5;
profname='profile.dat';

xz=load(profname)
xdata=xz(:,1);
zdata=xz(:,2);

xgrid=[xdata(1):dx:xdata(end)];
zgrid=interp1(xdata,zdata,xgrid);

fi=fopen('griddata.txt','wt');
fprintf(fi,'nx      = %3i \n',length(xgrid)-1);
fprintf(fi,'ny      = %3i \n',2);
fprintf(fi,'dx      = %6.1f \n',dx);
fprintf(fi,'dy      = %6.1f \n',dx);
fprintf(fi,'xori    = %10.2f \n',xdata(1));
fprintf(fi,'yori    = %10.2f \n',0);
fprintf(fi,'alfa    = %10.2f \n',0);
fprintf(fi,'depfile = profile.dep \n')
fprintf(fi,'posdwn  = -1 \n')
fclose(fi);

fi=fopen('profile.dep','wt');
for i=1:3
    fprintf(fi,'%7.3f ',zgrid);
    fprintf(fi,'\n');
end
fclose(fi);
