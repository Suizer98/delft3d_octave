function Spec=readSP2(fname)

fid=fopen(fname,'r');

f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
% 
f=fgetl(fid);

Spec.NPoints=str2double(deblank(f));

for j=1:Spec.NPoints
    f=fgetl(fid);
    [Spec.x(j) Spec.y(j)]=strread(f);
end

f=fgetl(fid);

f=fgetl(fid);
Spec.NFreq=str2double(deblank(f));

for j=1:Spec.NFreq
    f=fgetl(fid);
    Spec.Freqs(j)=strread(f);
end

f=fgetl(fid);

f=fgetl(fid);
Spec.NDir=str2double(deblank(f));

for j=1:Spec.NDir
    f=fgetl(fid);
    Spec.dirs(j)=strread(f);
end

f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);

f=fgetl(fid);
f=f(1:15);

it=1;

Spec.time(it).time=datenum(f,'yyyymmdd.HHMMSS');

nbin=Spec.NDir*Spec.NFreq;

for j=1:Spec.NPoints
%     disp([num2str(j) ' of ' num2str(Spec.NPoints)]);
    f=fgetl(fid);
    deblank(f);
    if strcmpi(deblank(f),'factor')
        f=fgetl(fid);
        Spec.time(it).points(j).Factor=strread(f);
        data=textscan(fid,'%f',nbin);
        data=data{1};
        data=reshape(data,Spec.NDir,Spec.NFreq);
        data=data';
        
        Spec.time(it).points(j).energy=single(data);
        f=fgetl(fid);
    else
        Spec.time(it).points(j).Factor=0;
        Spec.time(it).points(j).energy=0;
    end
end

fclose(fid);
