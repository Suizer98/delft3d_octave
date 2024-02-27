function [lon,lat]=writeMeteoFileWW3(meteodir,meteoname,rundir,xlim,ylim,tstart,tstop,dt,usedtairsea)
% Generates WAVEWATCH III wind file and return vectors of longitude and
% latitude (needed to write ww3_prep.inp)

fclose all;

fid=fopen([rundir 'ww3.wnd'],'wt');

dt=dt/24;

nt=(tstop-tstart)/dt+1;

for it=1:nt
    t=tstart+(it-1)*dt;
    tstr=datestr(t,'yyyymmddHHMMSS');
    fstru=[meteodir meteoname '.u.' tstr '.mat'];
    fstrv=[meteodir meteoname '.v.' tstr '.mat'];
    if exist(fstru,'file')
        su=load(fstru);
        sv=load(fstrv);
    else
        % find first available file
        for n=1:1000
            t0=t+n*dt;
            tstr=datestr(t0,'yyyymmddHHMMSS');
            fstru=[meteodir meteoname '.u.' tstr '.mat'];
            fstrv=[meteodir meteoname '.v.' tstr '.mat'];
            if exist(fstru,'file')
                su=load(fstru);
                sv=load(fstrv);
                break
            end
        end
    end

    [u,lon,lat]=getMeteoMatrix(su.u,su.lon,su.lat,xlim,ylim);
    [v,lon,lat]=getMeteoMatrix(sv.v,sv.lon,sv.lat,xlim,ylim);
    
    % Work around (must be fixed in getMeteoMatrix!!!)
    if lon(end)==359
        u(:,end)=u(:,1);
        lon(end)=360;
    end

    nrows=size(u,1);
    ncols=size(u,2);
    
    
%    if xlim(1)<0
%        s.lon=[s.lon-360;s.lon];
%        s.u=[s.u s.u];
%        s.v=[s.v s.v];
%    end

%     s.lon=[s.lon-360;s.lon;s.lon+360];
%     s.u=[s.u s.u s.u];
%     s.v=[s.v s.v s.u];
% 
% 
%     i1=find(s.lon>xlim(1), 1 )-1;
%     i2=find(s.lon<xlim(2), 1, 'last' )+1;
%     
% %     i2=i2-1;
%     
%     j1=find(s.lat>ylim(1), 1 )-1;
%     j2=find(s.lat<ylim(2), 1, 'last' )+1;
%     ncols=(i2-i1)+1;
%     nrows=(j2-j1)+1;
%     xllcentre=s.lon(i1);
%     yllcentre=s.lat(j1);
%    
%     u=s.u(j1:j2,i1:i2);
%     v=s.v(j1:j2,i1:i2);
% 
    u=flipud(u);
    v=flipud(v);

    fprintf(fid,'%s\n',datestr(t,'yyyymmdd HHMMSS'));

    fmt=[repmat('%13.5e ',1,ncols) '\n'];

    fprintf(fid,fmt,u');
    fprintf(fid,fmt,v');

    if usedtairsea
%        dtairsea=zeros(size(u));
%        dtairsea=dtairsea+1;
        for i=1:size(u,2)
            dtairsea(:,i)=10*cos(flipud(lat)*pi/180);
        end
        fprintf(fid,fmt,dtairsea');
    end
    
end

fclose(fid);


clear s

