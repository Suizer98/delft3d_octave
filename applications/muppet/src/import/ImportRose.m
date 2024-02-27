function DataProperties=ImportRose(DataProperties,i)
 
%a=load([DataProperties(i).PathName DataProperties(i).FileName]);

FileInfo=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName]);
 
nrblocks=size(FileInfo.Field,2);
nrcolumns=FileInfo.Field(1).Size(2);

dat=FileInfo.Field.Data;

% Directions
DataProperties(i).x=dat(1:end,1);

% Wave heights/wind speeds/periods
str=FileInfo.Field.ColLabels;
for j=1:nrcolumns-1
%    DataProperties(i).y(j)=str2num(str{j+1});
    DataProperties(i).y(j)=0;
    DataProperties(i).Class{j}=str{j+1};
end

% Percentages
DataProperties(i).z=dat(1:end,2:end);
 
DataProperties(i).Type = 'Rose';

DataProperties(i).TC='c';
