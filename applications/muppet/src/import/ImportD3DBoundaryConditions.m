function DataProperties=ImportD3DBoundaryConditions(DataProperties,i)

Info=bct_io('read',[DataProperties(i).PathName DataProperties(i).FileName]);
NTables=Info.NTables;

for j=1:NTables
    if strcmp(lower(Info.Table(j).Location),lower(DataProperties(i).Location))
        isec=j;
    end
end

n=length(Info.Table(isec).Parameter);
for j=2:n
    if strcmp(lower(Info.Table(isec).Parameter(j).Name),lower(DataProperties(i).Parameter))
        ipar=j;
    end
end

reftim=MatTime(Info.Table(isec).ReferenceTime,0);
times=Info.Table(isec).Data(:,1);


DataProperties(i).y=Info.Table(isec).Data(:,ipar);

DataProperties(i).x=reftim+times/1440;

DataProperties(i).y(DataProperties(i).y==999.999)=NaN;

DataProperties(i).Type='TimeSeries';

DataProperties(i).TC='c';
