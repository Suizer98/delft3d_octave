clear all;close all;
fclose all;

% addpath(genpath('SuperTrans'));

load('CoordinateSystems.mat');
load('Operations.mat');

outd='D:\OperationalModelSystem\code\OMS\misc\xbeach\sb9x\';

load('sb9xlines3mFinal.mat');

mdl.longName='Santa Barabara 9';
mdl.name='sb9x';
mdl.runid='sb9x';
mdl.continent='northamerica';
mdl.coordSys='WGS 84 / UTM zone 11N';
mdl.coordSysType='projected';
mdl.flowNested='santabarbaracoast';
mdl.waveNested='santabarbaracoast';
mdl.webSite='SoCalCoastalHazards';

mdl.tstop=10000;
mdl.nt=120;
mdl.morfac=10;

mdl.dx=5;
mdl.dy=5;

zmax=10;

fid2=fopen([outd 'sb9x.dat'],'wt');
fprintf(fid2,'%s\n',['Model "' mdl.longName '"']);
fprintf(fid2,'%s\n','   Type        "XBeachCluster"');
fprintf(fid2,'%s\n',['   Abbr        ' mdl.name]);
fprintf(fid2,'%s\n',['   Runid       ' mdl.runid]);
fprintf(fid2,'%s\n',['   Continent   "' mdl.continent '"']);
fprintf(fid2,'%s\n',['   CoordSys     "' mdl.coordSys '"']);
fprintf(fid2,'%s\n',['   CoordSysType "' mdl.coordSysType '"']);
fprintf(fid2,'%s\n','   Size        1');
fprintf(fid2,'%s\n','   Priority    0');
fprintf(fid2,'%s\n',['   Nested      "' mdl.flowNested '"']);
fprintf(fid2,'%s\n',['   WaveNested  "' mdl.waveNested '"']);
fprintf(fid2,'%s\n','   FlowSpinUp  0');
fprintf(fid2,'%s\n','   WaveSpinUp  0');
% fprintf(fid2,'%s\n','   RunTime     72');
%fprintf(fid2,'%s\n','   TimeStep    2');
%fprintf(fid2,'%s\n','   MapTimeStep 180');
%fprintf(fid2,'%s\n','   HisTimeStep 10');
%fprintf(fid2,'%s\n','   ComTimeStep 30');
fprintf(fid2,'%s\n','   UseMeteo    none');
fprintf(fid2,'%s\n','   MorFac      10');
fprintf(fid2,'%s\n',['   WebSite     "' mdl.webSite '"']);

fid3=fopen([outd 'nesting\sb9x.loc'],'wt');

for i=1:length(prf)
    
    id=prf(i).id;
    
    idstr=num2str(id,'%0.5i');
    
    np=length(prf(i).x);
    
    nx=floor(prf(i).dist(end)/mdl.dx)+1;
    xx=0:mdl.dx:(nx-1)*mdl.dx;
    
    zz=interp1(prf(i).dist,prf(i).z,xx);

    imax=find(zz>zmax, 1 );
    
    mdl.nx=imax+1;
    
    d=zz(1:imax);
    d(end+1)=d(end);
    d(end+1)=d(end);
    
    mdl.xori=prf(i).xori;
    mdl.yori=prf(i).yori;
    mdl.alpha=180*prf(i).alpha/pi;
    
    mdl.depfile=[idstr '.dep'];

    mkdir([outd 'input'],idstr);

    inpdir=[outd 'input\' idstr '\'];

    writeParams(mdl,inpdir);

    % write dep file
    fid=fopen([inpdir idstr '.dep'],'wt');
    fmt=[repmat(' %13.5e',[1,mdl.nx+1]) '\n'];
    fprintf(fid,fmt,d);
    fprintf(fid,fmt,d);
    fprintf(fid,fmt,d);
    fclose(fid);

    % nesting

    mkdir([outd 'nesting'],idstr);    
    nstdir=[outd 'nesting\' idstr '\'];

    % bnd file
    fid=fopen([nstdir 'xb.bnd' ],'wt');
    fprintf(fid,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
    fclose(fid);
    
    % grd file
    xg(1,1)=mdl.xori;
    xg(1,2)=mdl.xori-sin(prf(i).alpha)*0.5*mdl.dy;
    xg(1,3)=mdl.xori-sin(prf(i).alpha)*mdl.dy;

    xg(2,1)=xg(1,1)+cos(prf(i).alpha)*mdl.dx;
    xg(2,2)=xg(1,2)+cos(prf(i).alpha)*mdl.dx;
    xg(2,3)=xg(1,3)+cos(prf(i).alpha)*mdl.dx;

    yg(1,1)=mdl.yori;
    yg(1,2)=mdl.yori+cos(prf(i).alpha)*0.5*mdl.dy;
    yg(1,3)=mdl.yori+cos(prf(i).alpha)*mdl.dy;

    yg(2,1)=yg(1,1)+sin(prf(i).alpha)*mdl.dx;
    yg(2,2)=yg(1,2)+sin(prf(i).alpha)*mdl.dx;
    yg(2,3)=yg(1,3)+sin(prf(i).alpha)*mdl.dx;

%    [xg,yg]=ConvertCoordinates(xg,yg,'WGS 84 / UTM zone 11N','xy','WGS 84','geo',CoordinateSystems,Operations);

    fid=fopen([nstdir 'xb.grd' ],'wt');
    fprintf(fid,'%s\n','*');
    fprintf(fid,'%s\n','* WL | Delft Hydraulics, Delft3D-RGFGRID, Version 4.15.04.00, win32, Release, Jan 24 2008, 16:49:5');
    fprintf(fid,'%s\n','* File creation date: 23:58:00, 11-05-2009');
    fprintf(fid,'%s\n','*');
    fprintf(fid,'%s\n','Coordinate System = Cartesian');
    fprintf(fid,'%s\n','       2       3');
    fprintf(fid,'%s\n',' 0 0 0');
    fprintf(fid,'%s\n',[' ETA=    1   ' num2str(xg(1,1),'%15.8e') ' '   num2str(xg(2,1),'%15.8e')]);
    fprintf(fid,'%s\n',[' ETA=    2   ' num2str(xg(1,2),'%15.8e') ' '   num2str(xg(2,2),'%15.8e')]);
    fprintf(fid,'%s\n',[' ETA=    3   ' num2str(xg(1,3),'%15.8e') ' '   num2str(xg(2,3),'%15.8e')]);
    fprintf(fid,'%s\n',[' ETA=    1   ' num2str(yg(1,1),'%15.8e') ' '   num2str(yg(2,1),'%15.8e')]);
    fprintf(fid,'%s\n',[' ETA=    2   ' num2str(yg(1,2),'%15.8e') ' '   num2str(yg(2,2),'%15.8e')]);
    fprintf(fid,'%s\n',[' ETA=    3   ' num2str(yg(1,3),'%15.8e') ' '   num2str(yg(2,3),'%15.8e')]);
    fclose(fid);
    
    % enc file
    fid=fopen([nstdir 'xb.enc' ],'wt');
    fprintf(fid,'%s\n','     1     1   *** begin external enclosure ');
    fprintf(fid,'%s\n','     3     1');
    fprintf(fid,'%s\n','     3     4');
    fprintf(fid,'%s\n','     1     4');
    fprintf(fid,'%s\n','     1     1   *** end external grid enclosure');
    fclose(fid);

    % nesthd1.inp
    fid=fopen([nstdir 'nesthd1.inp' ],'wt');
    fprintf(fid,'%s\n',['E:\work\OperationalModelSystem\xbeach\sb9x\nesting\' mdl.flowNested '.grd']);
    fprintf(fid,'%s\n',['E:\work\OperationalModelSystem\xbeach\sb9x\nesting\' mdl.flowNested '.enc']);
    fprintf(fid,'%s\n','xb.grd');
    fprintf(fid,'%s\n','xb.enc');
    fprintf(fid,'%s\n','xb.bnd');
    fprintf(fid,'%s\n','xb.nst');
    fprintf(fid,'%s\n',[mdl.flowNested '.obs']);
    fclose(fid);

    curdir=pwd;
    cd(nstdir);
    str='c:\delft3d\w32\flow\bin\nesthd1.exe < nesthd1.inp';
    system(str);
    delete('xb.grd');
    delete('xb.enc');
    delete('nesthd1.inp');
    cd(curdir);

    [x0,y0]=ConvertCoordinates(mdl.xori,mdl.yori,'WGS 84 / UTM zone 11N','xy','WGS 84','geo',CoordinateSystems,Operations);

    fprintf(fid2,'%s\n',['   XBProfile ' num2str(id,'%0.5i')]);
    fprintf(fid2,'%s\n',['      PrfOrigin   ' num2str(mdl.xori) ' ' num2str(mdl.yori)]);
    fprintf(fid2,'%s\n',['      PrfAlpha    ' num2str(mdl.alpha)]);
    fprintf(fid2,'%s\n',['      PrfLocation ' num2str(x0) ' ' num2str(y0)]);
    fprintf(fid2,'%s\n','   EndXBProfile');
    
    fprintf(fid3,'%s\n',[num2str(mdl.xori,'%15.8e') ' ' num2str(mdl.yori,'%15.8e')]);
    
end

fprintf(fid2,'%s\n','EndModel');
fclose(fid2);
fclose(fid3);
