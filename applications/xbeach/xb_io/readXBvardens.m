function [S,f,d]=readXBvardens(filename)

fid=fopen(filename);

nf=str2num(fgetl(fid));
f=zeros(1,nf);
for i=1:nf
    f(i)=str2num(fgetl(fid));
end

nd=str2num(fgetl(fid));
d=zeros(1,nd);
for i=1:nd
    d(i)=str2num(fgetl(fid));
end

S=zeros(nf,nd);

for i=1:nf
    S(i,:)=str2num(fgetl(fid));
end

fclose(fid);





