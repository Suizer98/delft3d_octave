function [t,hs,tp,wavdir]=ww3_read_tab33_02(fname)

% First determine tstart, dt, and nr stations

fid=fopen(fname,'r');
str=fgetl(fid);
tstr=str(9:27);
t1=datenum(tstr,'yyyy/mm/dd HH:MM:SS');
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
str=fgetl(fid); % dummy
ns=0;
while 1
    str=fgetl(fid);
    if isempty(deblank2(str))
        break;
    else
        ns=ns+1;
    end
end
str=fgetl(fid); % dummy

str=fgetl(fid);
tstr=str(9:27);
t2=datenum(tstr,'yyyy/mm/dd HH:MM:SS');
fclose(fid);
dt=t2-t1;

fid=fopen(fname,'r');

nt=0;
while 1
    str=fgetl(fid);
    if str==-1
        break;
    end
    nt=nt+1;
    t(nt,1)=t1+(nt-1)*dt;
    str=fgetl(fid);
    str=fgetl(fid);
    str=fgetl(fid);
    str=fgetl(fid);
    fmt=[repmat('%f ',1,10)];
    v=textscan(fid,fmt,ns);
    
    hs(nt,:)=v{3}';
    wavdir(nt,:)=v{6}';
    f=v{8}';
    tp(nt,:)=1./f;
    
    str=fgetl(fid); % dummy
    str=fgetl(fid); % dummy
    str=fgetl(fid); % dummy
end

fclose(fid);


