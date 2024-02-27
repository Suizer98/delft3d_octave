function tc=readgdacs(fname)

fid=fopen(fname,'r');

% Read header
str=fgetl(fid); % dummy

it=0;

t0=datenum(2013,11,3,6,0,0);

tc.name='Haiyan';

while 1
    
    str=fgetl(fid);
    
    if str==-1
        break
    end
    
    it=it+1;
    
    f=str2num(str);
    
    tc.time(it)=t0+f(1)/24;
    
    tc.lat(it)=f(2);
    tc.lon(it)=f(3);
    
    tc.vmax(it,1:4)=f(4)*1.94;

    tc.r34(it,1:4)=[NaN NaN NaN NaN];
    tc.r50(it,1:4)=[NaN NaN NaN NaN];
    tc.r64(it,1:4)=[NaN NaN NaN NaN];
    tc.r100(it,1:4)=[NaN NaN NaN NaN];
    
    tc.r64(it,1)=f(5);
    tc.r64(it,2)=f(6);
    tc.r64(it,3)=f(7);
    tc.r64(it,4)=f(8);
    
    tc.r50(it,1)=f(9);
    tc.r50(it,2)=f(10);
    tc.r50(it,3)=f(11);
    tc.r50(it,4)=f(12);
    
    tc.r34(it,1)=f(13);
    tc.r34(it,2)=f(14);
    tc.r34(it,3)=f(15);
    tc.r34(it,4)=f(16);
    
    tc.r64(tc.r64==0)=NaN;
    tc.r50(tc.r50==0)=NaN;
    tc.r34(tc.r34==0)=NaN;
    
end


fclose(fid);

tc.r34(isnan(tc.r34))=-999;
tc.r50(isnan(tc.r50))=-999;
tc.r64(isnan(tc.r64))=-999;
tc.r100(isnan(tc.r100))=-999;
