function DataProperties=mp_combineDataset(DataProperties,CombinedDatasetProperties,nr,nrc)

name=CombinedDatasetProperties(nrc).Name;
unif=CombinedDatasetProperties(nrc).UniformValue;
NameA=CombinedDatasetProperties(nrc).DatasetA.Name;
NameB=CombinedDatasetProperties(nrc).DatasetB.Name;
a1=CombinedDatasetProperties(nrc).DatasetA.Multiply;
a2=CombinedDatasetProperties(nrc).DatasetB.Multiply;
operation=CombinedDatasetProperties(nrc).Operation;
m=CombinedDatasetProperties(nrc).UnifOpt;

for i=1:size(DataProperties,2)
    if strcmp(DataProperties(i).Name,NameA)
        k1=i;
    end
    if strcmp(DataProperties(i).Name,NameB)
        k2=i;
    end
end

switch lower(DataProperties(k1).Type)
 
    case{'2dscalar','3dcrosssectionscalar'}
        DataProperties(nr).x=DataProperties(k1).x;
        DataProperties(nr).y=DataProperties(k1).y;

        if m==0
            
            % Combine with other dataset

            data1z=DataProperties(k1).z;
            data2z=DataProperties(k2).z;
            data1zz=DataProperties(k1).z;
            data2zz=DataProperties(k2).z;
%             data1z(data1z==-999.0)=NaN;
%             data2z(data2z==-999.0)=NaN;
%             data1z(data1z==999.999)=NaN;
%             data2z(data2z==999.999)=NaN;
%             data1zz(data1zz==-999.0)=NaN;
%             data2zz(data2zz==-999.0)=NaN;
%             data1zz(data1zz==999.999)=NaN;
%             data2zz(data2zz==999.999)=NaN;
 
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).z=a1*data1z+a2*data2z;
                    DataProperties(nr).zz=a1*data1zz+a2*data2zz;
                case{'subtract'}
                    DataProperties(nr).z=a1*data1z-a2*data2z;
                    DataProperties(nr).zz=a1*data1zz-a2*data2zz;
                case{'multiply'}
                    DataProperties(nr).z=(a1*data1z).*(a2*data2z);
                    DataProperties(nr).zz=(a1*data1zz).*(a2*data2zz);
                case{'divide'}
                    DataProperties(nr).z=(a1*data1z)./(a2*data2z);
                    DataProperties(nr).zz=(a1*data1zz)./(a2*data2zz);
                case{'max'}
                    DataProperties(nr).z=max(a1*data1z,a2*data2z);
                    DataProperties(nr).zz=max(a1*data1zz,a2*data2zz);
                case{'min'}
                    DataProperties(nr).z=min(a1*data1z,a2*data2z);
                    DataProperties(nr).zz=min(a1*data1zz,a2*data2zz);
                case{'isnan(a<b)'}
                    DataProperties(nr).z=a1*data1z;
                    DataProperties(nr).zz=a1*data1zz;
%                     Test for Jakarta flood animation
%                     DataProperties(nr).z(data1z<0.05 & data2z<3.0)=NaN;
%                     DataProperties(nr).zz(data1zz<0.05 & data2zz<3.0)=NaN;
                    DataProperties(nr).z(data1z<data2z)=NaN;
                    DataProperties(nr).zz(data1zz<data2zz)=NaN;
                case{'isnan(a>b)'}
                    DataProperties(nr).z=a1*data1z;
                    DataProperties(nr).zz=a1*data1zz;
                    DataProperties(nr).z(data1z>data2z)=NaN;
                    DataProperties(nr).zz(data1zz>data2zz)=NaN;
            end

        else

            % Combine with uniform value

            switch lower(operation),
                case{'add'}
                    DataProperties(nr).z=a1*DataProperties(k1).z+unif;
                    DataProperties(nr).zz=a1*DataProperties(k1).zz+unif;
                case{'subtract'}
                    DataProperties(nr).z=a1*DataProperties(k1).z-unif;
                    DataProperties(nr).zz=a1*DataProperties(k1).zz-unif;
                case{'multiply'}
                    DataProperties(nr).z=a1*DataProperties(k1).z*unif;
                    DataProperties(nr).zz=a1*DataProperties(k1).zz*unif;
                case{'divide'}
                    DataProperties(nr).z=a1*DataProperties(k1).z/unif;
                    DataProperties(nr).zz=a1*DataProperties(k1).zz/unif;
                case{'max'}
                    DataProperties(nr).z=max(a1*DataProperties(k1).z,unif);
                    DataProperties(nr).zz=max(a1*DataProperties(k1).zz,unif);
                case{'min'}
                    DataProperties(nr).z=min(a1*DataProperties(k1).z,unif);
                    DataProperties(nr).zz=min(a1*DataProperties(k1).zz,unif);
                case{'isnan(a<b)'}
                    DataProperties(nr).z=a1*DataProperties(k1).z;
                    DataProperties(nr).zz=a1*DataProperties(k1).zz;
                    DataProperties(nr).z(DataProperties(nr).z<unif)=NaN;
                    DataProperties(nr).zz(DataProperties(nr).zz<unif)=NaN;
                case{'isnan(a>b)'}
                    DataProperties(nr).z(a1*DataProperties(k1).z>unif)=NaN;
                    DataProperties(nr).zz(a1*DataProperties(k1).zz>unif)=NaN;
            end
        end
 
    case{'2dvector'}
        DataProperties(nr).x=DataProperties(k1).x;
        DataProperties(nr).y=DataProperties(k1).y;
        DataProperties(nr).z=DataProperties(k1).z;
        if m==0
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).u=(a1*DataProperties(k1).u)+(a2*DataProperties(k2).u);
                    DataProperties(nr).v=(a1*DataProperties(k1).v)+(a2*DataProperties(k2).v);
                case{'subtract'}
                    DataProperties(nr).u=(a1*DataProperties(k1).u)-(a2*DataProperties(k2).u);
                    DataProperties(nr).v=(a1*DataProperties(k1).v)-(a2*DataProperties(k2).v);
                    %                 case{'multiply'}
                    %                     DataProperties(nr).z=a1*DataProperties(k1).z*a2*DataProperties(k2).z;
                    %                 case{'divide'}
                    %                     DataProperties(nr).z=a1*DataProperties(k1).z/a2*DataProperties(k2).z;
                    %                 case{'max'}
                    %                     DataProperties(nr).z=max(a1*DataProperties(k1).z,a2*DataProperties(k2).z);
                    %                 case{'min'}
                    %                     DataProperties(nr).z=min(a1*DataProperties(k1).z,a2*DataProperties(k2).z);
            end
        else
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).u=a1*DataProperties(k1).u+unif;
                    DataProperties(nr).v=a1*DataProperties(k1).v+unif;
                case{'subtract'}
                    DataProperties(nr).u=a1*DataProperties(k1).u-unif;
                    DataProperties(nr).v=a1*DataProperties(k1).v-unif;
                case{'multiply'}
                    DataProperties(nr).u=a1*DataProperties(k1).u*unif;
                    DataProperties(nr).v=a1*DataProperties(k1).v*unif;
                case{'divide'}
                    DataProperties(nr).u=a1*DataProperties(k1).u/unif;
                    DataProperties(nr).v=a1*DataProperties(k1).v/unif;
                case{'max'}
                    DataProperties(nr).u=max(a1*DataProperties(k1).u,unif);
                    DataProperties(nr).v=max(a1*DataProperties(k1).v,unif);
                case{'min'}
                    DataProperties(nr).u=min(a1*DataProperties(k1).u,unif);
                    DataProperties(nr).v=min(a1*DataProperties(k1).v,unif);
 
            end
        end
 
    case{'timeseries','xyseries'}
        DataProperties(nr).x=DataProperties(k1).x;
        if m==0
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).y=a1*DataProperties(k1).y+a2*DataProperties(k2).y;
                case{'subtract'}
                    DataProperties(nr).y=a1*DataProperties(k1).y-a2*DataProperties(k2).y;
                case{'multiply'}
                    DataProperties(nr).y=(a1*DataProperties(k1).y).*(a2*DataProperties(k2).y);
                case{'divide'}
                    DataProperties(nr).y=(a1*DataProperties(k1).y)./(a2*DataProperties(k2).y);
                case{'max'}
                    DataProperties(nr).y=max(a1*DataProperties(k1).y,a2*DataProperties(k2).y);
                case{'min'}
                    DataProperties(nr).y=min(a1*DataProperties(k1).y,a2*DataProperties(k2).y);
            end
        else
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).y=a1*DataProperties(k1).y+unif;
                case{'subtract'}
                    DataProperties(nr).y=a1*DataProperties(k1).y-unif;
                case{'multiply'}
                    DataProperties(nr).y=a1*DataProperties(k1).y*unif;
                case{'divide'}
                    DataProperties(nr).y=a1*DataProperties(k1).y/unif;
                case{'max'}
                    DataProperties(nr).y=max(a1*DataProperties(k1).y,unif);
                case{'min'}
                    DataProperties(nr).y=min(a1*DataProperties(k1).y,unif);
            end
        end
 
    case{'image'}
        DataProperties(nr).x=DataProperties(k1).x;
        DataProperties(nr).y=DataProperties(k1).y;
        DataProperties(nr).z=DataProperties(k1).z;
        if m==0
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).c=a1*DataProperties(k1).c+a2*DataProperties(k2).c;
                case{'subtract'}
                    DataProperties(nr).c=a1*DataProperties(k1).c-a2*DataProperties(k2).c;
                    DataProperties(nr).c=DataProperties(nr).c+0.5;
                case{'multiply'}
                    DataProperties(nr).c=(a1*DataProperties(k1).c).*(a2*DataProperties(k2).c);
                case{'divide'}
                    DataProperties(nr).c=(a1*DataProperties(k1).c)./(a2*DataProperties(k2).c);
                case{'max'}
                    DataProperties(nr).c=max(a1*DataProperties(k1).c,a2*DataProperties(k2).c);
                case{'min'}
                    DataProperties(nr).c=min(a1*DataProperties(k1).c,a2*DataProperties(k2).c);
            end
            DataProperties(nr).c=max(DataProperties(nr).c,0.0);
            DataProperties(nr).c=min(DataProperties(nr).c,1.0);
        else
            switch lower(operation),
                case{'add'}
                    DataProperties(nr).c=a1*DataProperties(k1).c+unif;
                case{'subtract'}
                    DataProperties(nr).c=a1*DataProperties(k1).c-unif;
                case{'multiply'}
                    DataProperties(nr).c=a1*DataProperties(k1).c*unif;
                case{'divide'}
                    DataProperties(nr).c=a1*DataProperties(k1).c/unif;
                case{'max'}
                    DataProperties(nr).c=max(a1*DataProperties(k1).c,unif);
                case{'min'}
                    DataProperties(nr).c=min(a1*DataProperties(k1).c,unif);
            end
        end
 
end
 
DataProperties(nr).Name=name;
DataProperties(nr).Type=DataProperties(k1).Type;
DataProperties(nr).Block=0;
DataProperties(nr).File='none';
DataProperties(nr).FileType='none';
DataProperties(nr).CombinedDataset=1;

if m==0
    if DataProperties(k1).TC=='t'
        DataProperties(nr).TC='t';
        if isfield(DataProperties(k1),'AvailableTimes')
            DataProperties(nr).AvailableTimes=DataProperties(k1).AvailableTimes;
        end
    elseif DataProperties(k2).TC=='t'
        DataProperties(nr).TC='t';
        if isfield(DataProperties(k1),'AvailableTimes')
            DataProperties(nr).AvailableTimes=DataProperties(k2).AvailableTimes;
        end
    else
        DataProperties(nr).TC='c';
    end
else
    if DataProperties(k1).TC=='t'
        DataProperties(nr).TC='t';
        if isfield(DataProperties(k1),'AvailableTimes')
            DataProperties(nr).AvailableTimes=DataProperties(k1).AvailableTimes;
        end
    end 
end
 
