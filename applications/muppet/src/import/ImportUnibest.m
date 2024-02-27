function DataProperties=ImportUnibest(DataProperties,i)
 
FileInfo=qpfopen([DataProperties(i).PathName DataProperties(i).FileName]);

DataProps=FileInfo.Quant.LongName;
NTimes=FileInfo.NTimes;
MMax=size(FileInfo.X,2);
Times=qpread(FileInfo,DataProps{1},'times');

if Times(1)<100000
    Times=Times+730486;
end

if DataProperties(i).M1==0
    M1=1;
    M2=MMax;
    MStep=1;
else
    M1=DataProperties(i).M1;
    M2=DataProperties(i).M2;
    MStep=DataProperties(i).MStep;
end

if DataProperties(i).T1==0 & DataProperties(i).DateTime==0
    T1=1;
    T2=NTimes;
    TStep=1;
else
    if DataProperties(i).DateTime>100000
        T1=find(Times>DataProperties(i).DateTime-1.0e-6 & Times<DataProperties(i).DateTime+1.0e-6);
        T2=T1;
        TStep=1;
    else
        T1=DataProperties(i).T1;
        T2=DataProperties(i).T2;
        TStep=DataProperties(i).TStep;
    end
end

if T2>T1
    % Time series
    Data=qpread(FileInfo,DataProperties(i).Parameter,'data',T1:TStep:T2,M1);
    DataProperties(i).x=Data.Time;
    if Data.Time(1)<100000
        DataProperties(i).x=DataProperties(i).x+730486;
    end
    DataProperties(i).y=Data.Val;
    DataProperties(i).Type='TimeSeries';
    DataProperties(i).TC='c';
else
    % XY series
    Data=qpread(FileInfo,DataProperties(i).Parameter,'data',T1,M1:MStep:M2);
    DataProperties(i).x=FileInfo.X;
    DataProperties(i).y=Data.Val;
    DataProperties(i).Type='XYSeries';
    DataProperties(i).TC='t';
end

clear FileInfo Data DataProps Times
