function datasets=muppet_combineDataset(datasets,nr)

% First
name=datasets(nr).dataset.dataseta;
for ii=1:length(datasets)
    if strcmpi(name,datasets(ii).dataset.name)
        nra=ii;
        break
    end
end
a1=datasets(nr).dataset.multiplya;

% Second
name=datasets(nr).dataset.datasetb;
nrb=[];
for ii=1:length(datasets)
    if strcmpi(name,datasets(ii).dataset.name)
        nrb=ii;
        break
    end
end
a2=datasets(nr).dataset.multiplyb;

unifval=datasets(nr).dataset.uniformvalue;

operation=datasets(nr).dataset.operation;

if isempty(nrb) && ~isempty(unifval)
    m=1; % Uniform value
else
    m=0; % Datasets
end
    
switch lower(datasets(nra).dataset.type)
 
    case{'scalar2dxy','scalar2dxz','scalar2dtz','scalar2duxy'}
        
        datasets(nr).dataset.x=datasets(nra).dataset.x;
        datasets(nr).dataset.y=datasets(nra).dataset.y;

        if m==0
            
            % Combine with other dataset

            data1z=datasets(nra).dataset.z;
            data2z=datasets(nrb).dataset.z;
            data1zz=datasets(nra).dataset.z;
            data2zz=datasets(nrb).dataset.z;
 
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.z=a1*data1z+a2*data2z;
                    datasets(nr).dataset.zz=a1*data1zz+a2*data2zz;
                case{'subtract'}
                    datasets(nr).dataset.z=a1*data1z-a2*data2z;
                    datasets(nr).dataset.zz=a1*data1zz-a2*data2zz;
                case{'multiply'}
                    datasets(nr).dataset.z=(a1*data1z).*(a2*data2z);
                    datasets(nr).dataset.zz=(a1*data1zz).*(a2*data2zz);
                case{'divide'}
                    datasets(nr).dataset.z=(a1*data1z)./(a2*data2z);
                    datasets(nr).dataset.zz=(a1*data1zz)./(a2*data2zz);
                case{'max'}
                    datasets(nr).dataset.z=max(a1*data1z,a2*data2z);
                    datasets(nr).dataset.zz=max(a1*data1zz,a2*data2zz);
                case{'min'}
                    datasets(nr).dataset.z=min(a1*data1z,a2*data2z);
                    datasets(nr).dataset.zz=min(a1*data1zz,a2*data2zz);
                case{'isnan(a<b)'}
                    datasets(nr).dataset.z=a1*data1z;
                    datasets(nr).dataset.zz=a1*data1zz;
                    datasets(nr).dataset.z(data1z<data2z)=NaN;
                    datasets(nr).dataset.zz(data1zz<data2zz)=NaN;
                case{'isnan(a>b)'}
                    datasets(nr).dataset.z=a1*data1z;
                    datasets(nr).dataset.zz=a1*data1zz;
                    datasets(nr).dataset.z(data1z>data2z)=NaN;
                    datasets(nr).dataset.zz(data1zz>data2zz)=NaN;
                case{'isnan(isnan(b))'}
                    datasets(nr).dataset.z=a1*data1z;
                    datasets(nr).dataset.zz=a1*data1zz;
                    datasets(nr).dataset.z(isnan(data2z))=NaN;
                    datasets(nr).dataset.zz(isnan(data2zz))=NaN;
            end

        else

            % Combine with uniform value

            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z+unifval;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz+unifval;
                case{'subtract'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z-unifval;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz-unifval;
                case{'multiply'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z*unifval;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz*unifval;
                case{'divide'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z/unifval;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz/unifval;
                case{'max'}
                    datasets(nr).dataset.z=max(a1*datasets(nra).dataset.z,unifval);
                    datasets(nr).dataset.zz=max(a1*datasets(nra).dataset.zz,unifval);
                case{'min'}
                    datasets(nr).dataset.z=min(a1*datasets(nra).dataset.z,unifval);
                    datasets(nr).dataset.zz=min(a1*datasets(nra).dataset.zz,unifval);
                case{'isnan(a<b)'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz;
                    datasets(nr).dataset.z(datasets(nr).dataset.z<unifval)=NaN;
                    datasets(nr).dataset.zz(datasets(nr).dataset.zz<unifval)=NaN;
                case{'isnan(a>b)'}
                    datasets(nr).dataset.z=a1*datasets(nra).dataset.z;
                    datasets(nr).dataset.zz=a1*datasets(nra).dataset.zz;
                    datasets(nr).dataset.z(a1*datasets(nra).dataset.z>unifval)=NaN;
                    datasets(nr).dataset.zz(a1*datasets(nra).dataset.zz>unifval)=NaN;
            end
        end
 
    case{'vector2d2dxy'}
        datasets(nr).dataset.x=datasets(nra).dataset.x;
        datasets(nr).dataset.y=datasets(nra).dataset.y;
        datasets(nr).dataset.z=datasets(nra).dataset.z;
        if m==0
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.u=(a1*datasets(nra).dataset.u)+(a2*datasets(nrb).dataset.u);
                    datasets(nr).dataset.v=(a1*datasets(nra).dataset.v)+(a2*datasets(nrb).dataset.v);
                case{'subtract'}
                    datasets(nr).dataset.u=(a1*datasets(nra).dataset.u)-(a2*datasets(nrb).dataset.u);
                    datasets(nr).dataset.v=(a1*datasets(nra).dataset.v)-(a2*datasets(nrb).dataset.v);
            end
        else
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.u=a1*datasets(nra).dataset.u+unifval;
                    datasets(nr).dataset.v=a1*datasets(nra).dataset.v+unifval;
                case{'subtract'}
                    datasets(nr).dataset.u=a1*datasets(nra).dataset.u-unifval;
                    datasets(nr).dataset.v=a1*datasets(nra).dataset.v-unifval;
                case{'multiply'}
                    datasets(nr).dataset.u=a1*datasets(nra).dataset.u*unifval;
                    datasets(nr).dataset.v=a1*datasets(nra).dataset.v*unifval;
                case{'divide'}
                    datasets(nr).dataset.u=a1*datasets(nra).dataset.u/unifval;
                    datasets(nr).dataset.v=a1*datasets(nra).dataset.v/unifval;
                case{'max'}
                    datasets(nr).dataset.u=max(a1*datasets(nra).dataset.u,unifval);
                    datasets(nr).dataset.v=max(a1*datasets(nra).dataset.v,unifval);
                case{'min'}
                    datasets(nr).dataset.u=min(a1*datasets(nra).dataset.u,unifval);
                    datasets(nr).dataset.v=min(a1*datasets(nra).dataset.v,unifval);
 
            end
        end
 
    case{'scalar1dtv','scalar1dxy','scalar1dxv'}
        datasets(nr).dataset.x=datasets(nra).dataset.x;
        if m==0
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y+a2*datasets(nrb).dataset.y;
                case{'subtract'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y-a2*datasets(nrb).dataset.y;
                case{'multiply'}
                    datasets(nr).dataset.y=(a1*datasets(nra).dataset.y).*(a2*datasets(nrb).dataset.y);
                case{'divide'}
                    datasets(nr).dataset.y=(a1*datasets(nra).dataset.y)./(a2*datasets(nrb).dataset.y);
                case{'max'}
                    datasets(nr).dataset.y=max(a1*datasets(nra).dataset.y,a2*datasets(nrb).dataset.y);
                case{'min'}
                    datasets(nr).dataset.y=min(a1*datasets(nra).dataset.y,a2*datasets(nrb).dataset.y);
                case{'isnan(a<b)'}
                    datasets(nr).dataset.y=datasets(nra).dataset.y;
                    datasets(nr).dataset.y(datasets(nra).dataset.y<datasets(nrb).dataset.y)=NaN;
                case{'isnan(a>b)'}
                    datasets(nr).dataset.y=datasets(nra).dataset.y;
                    datasets(nr).dataset.y(datasets(nra).dataset.y>datasets(nrb).dataset.y)=NaN;
                case{'isnan(isnan(b))'}
                    datasets(nr).dataset.y=datasets(nra).dataset.y;
                    datasets(nr).dataset.y(isnan(datasets(nrb).dataset.y))=NaN;
            end
        else
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y+unifval;
                case{'subtract'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y-unifval;
                case{'multiply'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y*unifval;
                case{'divide'}
                    datasets(nr).dataset.y=a1*datasets(nra).dataset.y/unifval;
                case{'max'}
                    datasets(nr).dataset.y=max(a1*datasets(nra).dataset.y,unifval);
                case{'min'}
                    datasets(nr).dataset.y=min(a1*datasets(nra).dataset.y,unifval);
                case{'isnan(a<b)'}
                    datasets(nr).dataset.y=datasets(nra).dataset.y;
                    datasets(nr).dataset.y(datasets(nra).dataset.y<unifval)=NaN;
                case{'isnan(a>b)'}
                    datasets(nr).dataset.y=datasets(nra).dataset.y;
                    datasets(nr).dataset.y(datasets(nra).dataset.y>unifval)=NaN;
            end
        end
 
    case{'image'}
        datasets(nr).dataset.x=datasets(nra).dataset.x;
        datasets(nr).dataset.y=datasets(nra).dataset.y;
        datasets(nr).dataset.z=datasets(nra).dataset.z;
        if m==0
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c+a2*datasets(nrb).dataset.c;
                case{'subtract'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c-a2*datasets(nrb).dataset.c;
                    datasets(nr).dataset.c=datasets(nr).dataset.c+0.5;
                case{'multiply'}
                    datasets(nr).dataset.c=(a1*datasets(nra).dataset.c).*(a2*datasets(nrb).dataset.c);
                case{'divide'}
                    datasets(nr).dataset.c=(a1*datasets(nra).dataset.c)./(a2*datasets(nrb).dataset.c);
                case{'max'}
                    datasets(nr).dataset.c=max(a1*datasets(nra).dataset.c,a2*datasets(nrb).dataset.c);
                case{'min'}
                    datasets(nr).dataset.c=min(a1*datasets(nra).dataset.c,a2*datasets(nrb).dataset.c);
            end
            datasets(nr).dataset.c=max(datasets(nr).dataset.c,0.0);
            datasets(nr).dataset.c=min(datasets(nr).dataset.c,1.0);
        else
            switch lower(operation)
                case{'add'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c+unifval;
                case{'subtract'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c-unifval;
                case{'multiply'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c*unifval;
                case{'divide'}
                    datasets(nr).dataset.c=a1*datasets(nra).dataset.c/unifval;
                case{'max'}
                    datasets(nr).dataset.c=max(a1*datasets(nra).dataset.c,unifval);
                case{'min'}
                    datasets(nr).dataset.c=min(a1*datasets(nra).dataset.c,unifval);
            end
        end
end
 
datasets(nr).dataset.type=datasets(nra).dataset.type;
datasets(nr).dataset.filename='Combined Dataset';
datasets(nr).dataset.filetype='combineddataset';
datasets(nr).dataset.combineddataset=1;
datasets(nr).dataset.time=datasets(nra).dataset.time;
datasets(nr).dataset.coordinatesystem=datasets(nra).dataset.coordinatesystem;
datasets(nr).dataset.tc='c';

if m==0
    if datasets(nra).dataset.tc=='t'
        datasets(nr).dataset.tc='t';
        if isfield(datasets(nra).dataset,'times')
            datasets(nr).dataset.times=datasets(nra).dataset.times;
        end
    elseif datasets(nrb).dataset.tc=='t'
        datasets(nr).dataset.tc='t';
        if isfield(datasets(nra).dataset,'times')
            datasets(nr).dataset.times=datasets(nrb).dataset.times;
        end
    else
        datasets(nr).dataset.tc='c';
    end
else
    if datasets(nra).dataset.tc=='t'
        datasets(nr).dataset.tc='t';
        if isfield(datasets(nra).dataset,'times')
            datasets(nr).dataset.times=datasets(nra).dataset.times;
        end
    end 
end
 
switch lower(datasets(nra).dataset.type) 
    case{'scalar2dxy','scalar2dxz','scalar2dtz','scalar2duxy'}
        datasets(nr).dataset.G=datasets(nra).dataset.G;
end
