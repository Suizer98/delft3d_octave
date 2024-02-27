function DataProperties=ImportAnnotation(DataProperties,i)
 
filename=[DataProperties(i).PathName DataProperties(i).FileName];
 
fid=fopen(filename);
 
DataProperties(i).Type='Bar';

icol=DataProperties(i).Column;

k=0;
for j=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        k=k+1;
        v0=strread(tx0,'%q');
        sz=size(v0);
        DataProperties(i).XTickLabel{k}=v0{1};
        DataProperties(i).x(k)=k;
        DataProperties(i).y(k)=str2num(v0{icol});
    end
end

DataProperties(i).TC='c';

