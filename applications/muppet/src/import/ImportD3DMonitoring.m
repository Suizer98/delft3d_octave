function DataProperties=ImportD3DMonitoring(DataProperties,i)
 
filename=[DataProperties(i).PathName DataProperties(i).FileName];
fil=vs_use(filename,'quiet');

if strcmp(lower(DataProperties(i).Type),'annotation')

    Stations=vs_get(fil,'his-const','NAMST','quiet');
    XY=vs_get(fil,'his-const','XYSTAT','quiet');

    for k=1:size(Stations,1)
        DataProperties(i).x(k)=XY(1,k);
        DataProperties(i).y(k)=XY(2,k);
        DataProperties(i).z(k)=1000.0;
        DataProperties(i).Annotation{k}=deblank(Stations(k,:));
        DataProperties(i).Rotation(k)=0;
        DataProperties(i).Curvature(k)=0;
    end

    DataProperties(i).Type='Annotation';
    DataProperties(i).TC='c';

else

    CrossSections=vs_get(fil,'his-const','NAMTRA','quiet');
    XY=vs_get(fil,'his-const','XYTRA','quiet');
    j=1;
    for k=1:size(CrossSections,1);
        DataProperties(i).Annotation{k}=deblank(CrossSections(k,:));
        DataProperties(i).x(j)=XY(1,k);
        DataProperties(i).y(j)=XY(2,k);
        DataProperties(i).x(j+1)=XY(3,k);
        DataProperties(i).y(j+1)=XY(4,k);
        DataProperties(i).x(j+2)=NaN;
        DataProperties(i).y(j+2)=NaN;
        DataProperties(i).z=1000.0;
        DataProperties(i).Rotation(k)=0;
        DataProperties(i).Curvature(k)=0;
        j=j+3;
    end

    DataProperties(i).Type='CrossSections';
    DataProperties(i).TC='c';

end
