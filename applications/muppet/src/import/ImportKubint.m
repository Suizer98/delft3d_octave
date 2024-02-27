function DataProperties=ImportKubint(DataProperties,i)
 
block=DataProperties(i).Block;
 
parameter=DataProperties(i).Parameter;
 
FileInfo=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName]);
kub=tekal('read',FileInfo,1);
sz=size(kub,1);
 
switch lower(parameter),
    case {'number','areanumber'}
        icol=2;
    case {'volumes','volume'}
        icol=3;
    case {'average','averages'}
        icol=4;
     case {'positive volumes','positive volume'}
        icol=5;
    case {'negative volumes','negative volume'}
        icol=6;
    case {'area','areas'}
        icol=7;
end
 
[x,y]=landboundary('read',DataProperties(i).PolygonFile);
 
DataProperties(i).x(1)=min(min(x));
DataProperties(i).x(2)=max(max(x));
DataProperties(i).y(1)=min(min(y));
DataProperties(i).y(2)=max(max(y));
 
DataProperties(i).z=kub(:,icol);
 
DataProperties(i).Type='Kubint';

DataProperties(i).TC='c';

