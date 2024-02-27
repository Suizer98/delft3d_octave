function DataProperties=ImportAnnotation(DataProperties,i)
 
filename=[DataProperties(i).PathName DataProperties(i).FileName];
 
fid=fopen(filename);
 
DataProperties(i).Type='Annotation';
 
k=0;
for j=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        if ~strcmp(v0{1}(1),'#')
            k=k+1;
            if ~isnan(str2double(v0{1})) && ~isempty(str2double(v0{1}))
                DataProperties(i).x(k)=str2double(v0{1});
                DataProperties(i).y(k)=str2double(v0{2});
                DataProperties(i).z(k)=0;
                DataProperties(i).Annotation{k}=v0{3};
            else
                DataProperties(i).x(k)=str2double(v0{2});
                DataProperties(i).y(k)=str2double(v0{3});
                DataProperties(i).z(k)=0;
                DataProperties(i).Annotation{k}=v0{1};
            end
            if size(v0,1)>=4
                DataProperties(i).Rotation(k)=str2double(v0{4});
            else
                DataProperties(i).Rotation(k)=0;
            end
            if size(v0,1)>=5
                DataProperties(i).Curvature(k)=str2double(v0{5});
            else
                DataProperties(i).Curvature(k)=0;
            end
        end

    end
end

DataProperties(i).TC='c';

fclose(fid);
