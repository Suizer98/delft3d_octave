function DataProperties=ImportMAT(DataProperties,i)

fname=[DataProperties(i).PathName DataProperties(i).FileName];
t=DataProperties(i).DateTime;
par=DataProperties(i).Parameter;

a=load(fname);
b=fieldnames(a);

%data=a.(b{1});
data=a;
data=data.data;

DataProperties(i).x=data.X;
DataProperties(i).y=data.Y;
DataProperties(i).AvailableTimes=data.Time;

it=find(data.Time==t);

if isfield(data,'XComp')
    % Vector
    DataProperties(i).Type='2DVector';
    DataProperties(i).u=squeeze(data.XComp(it,:,:));
    DataProperties(i).v=squeeze(data.YComp(it,:,:));
    DataProperties(i).z=0;
    disp('vector');
else
    % Scalar
    if ndims(data.Val)==2
        DataProperties(i).z=squeeze(data.Val);
    else
        DataProperties(i).z=squeeze(data.Val(it,:,:));
    end
    DataProperties(i).Type='2DScalar';
    DataProperties(i).zz=DataProperties(i).z;
end

DataProperties(i).AvailableMorphTimes=[];

DataProperties(i).TC='t';
