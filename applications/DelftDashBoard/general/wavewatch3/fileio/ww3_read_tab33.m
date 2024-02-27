function [t,hs,tp,wavdir]=ww3_read_tab33(fname,ns)

fid=fopen(fname,'r');

i=0;
while 1
    i=i+1;
    str=fgetl(fid);
    if str==-1
        break;
    end
    tstr=str(9:27);
    t(i,1)=datenum(tstr,'yyyy/mm/dd HH:MM:SS');
    str=fgetl(fid);
    str=fgetl(fid);
    str=fgetl(fid);
    str=fgetl(fid);
    for j=1:ns
        str=fgetl(fid);
        pars=strread(str);
        hs(i,j)=pars(3);
        wavdir(i,j)=pars(6);
        tp(i,j)=1/pars(8);
        tp(i,j)=min(tp(i,j),50);
    end
    str=fgetl(fid);
    str=fgetl(fid);
end

fclose(fid);
