function data=mp_importTekalHistogram(data,i)

fid=fopen([data(i).PathName data(i).FileName],'r');

goon=1;
nr=0;
while goon
    nr=nr+1;
    s=fgetl(fid);
    if ~strcmpi(s(1),'*')
        goon=0;
    end
end

fclose(fid);

nr=nr-1;

fid=fopen([data(i).PathName data(i).FileName],'r');
for j=1:nr
    s=fgetl(fid);
end
    
% Block name
s=fgetl(fid);

s=fgetl(fid);
sz=str2num(s);
nrrows=sz(1);
nrcolumns=sz(2);

fmt=['%s' repmat('%s',1,nrcolumns-1)];
for k=1:nrrows
    s=fgetl(fid);    
    a=textscan(s,'%s');
    b=a{1};
    b=b{1};
    data(i).XTickLabel{k}=b;
    col=data(i).Column;
    data(i).x(k)=k;
    b=a{1};
    b=b{col};
    data(i).y(k)=str2num(b);
end

fclose(fid);

data(i).Type='Bar';
data(i).TC='c';
