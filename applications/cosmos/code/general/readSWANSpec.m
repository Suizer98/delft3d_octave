function spec=readSWANSpec(fname)

fid=fopen(fname,'r');

f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);

f=fgetl(fid);

nchar=min(length(f),12);
spec.nPoints=str2double(f(1:nchar));

for j=1:spec.nPoints
    f=fgetl(fid);
    [spec.x(j) spec.y(j)]=strread(f);
end

f=fgetl(fid);

f=fgetl(fid);
nchar=min(length(f),12);
spec.nFreq=str2double(f(1:nchar));

for j=1:spec.nFreq
    f=fgetl(fid);
    spec.freqs(j)=strread(f);
end

f=fgetl(fid);

f=fgetl(fid);
nchar=min(length(f),12);
spec.nDir=str2double(f(1:nchar));

for j=1:spec.nDir
    f=fgetl(fid);
    spec.dirs(j)=strread(f);
end

f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);


it=0;

while 1
    
    f=fgetl(fid);
    
    if f==-1
        break
    end
    
    f=f(1:15);
    
    it=it+1;
    
    spec.time(it).time=datenum(f,'yyyymmdd.HHMMSS');
    
    % if spec.time(it).time>=starttime && spec.time(it).time<=stoptime
    
    nbin=spec.nDir*spec.nFreq;
    
    for j=1:spec.nPoints
        f=fgetl(fid);
        deblank(f);
        if strcmpi(deblank(f),'factor')
            f=fgetl(fid);
            spec.time(it).points(j).factor=strread(f);
            data=textscan(fid,'%f',nbin);
            data=data{1};
            data=reshape(data,spec.nDir,spec.nFreq);
            data=data';
            spec.time(it).points(j).energy=data;
            f=fgetl(fid);
        else
            spec.time(it).points(j).factor=0;
            spec.time(it).points(j).energy=zeros(spec.nFreq,spec.nDir);
        end
    end
    
end

fclose(fid);
