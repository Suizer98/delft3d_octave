function DataProperties=ImportXBeach(DataProperties,nr)


%% Dimensions
XBdims=getdimensions(DataProperties(nr).PathName);

nx=XBdims.nx;
ny=XBdims.ny;
nt=XBdims.nt;

handles.ngd=XBdims.ngd;       
handles.nd=XBdims.nd;        
handles.ntp=XBdims.ntp;
handles.ntc=XBdims.ntc;
handles.ntm=XBdims.ntm;  

handles.tsglobal=XBdims.tsglobal;
handles.tspoints=XBdims.tspoints;
handles.tscross=XBdims.tscross;
handles.tsmean=XBdims.tsmean;

%% Times
refdat=20000101;
reftim=0;
TRef=MatTime(refdat,reftim);

handles.tsglobal=TRef+handles.tsglobal/86400;
handles.tsmean=TRef+handles.tsmean/86400;

%% Grid
xg=XBdims.x;
yg=XBdims.y;

Size(1)=nt;
Size(2)=0;
Size(3)=nx+1;
Size(4)=ny+1;
Size(5)=0;

DataProps=getXBDataProps;

for i=1:length(DataProps)
    pars{i}=DataProps(i).Name;
end

ii=strmatch(lower(DataProperties(nr).Parameter),lower(pars),'exact');

fname=[DataProperties(nr).PathName DataProps(ii).FileName1];
%[Data info]=readvar(fname,XBdims,'double',2);
[Data info]=readvar(fname,XBdims,'2D');

if DataProps(ii).NVal==2
    xcomp=Data;
    clear Data
    fname=[DataProperties(nr).PathName DataProps(ii).FileName2];
    [ycomp info]=readvar(fname,XBdims,'double',2);
end

Times=handles.tsglobal;

DateTime=DataProperties(nr).DateTime;
DateTime=1e-6*ceil(DateTime*1e6);

if DataProperties(nr).DateTime>0
    ITime=find(abs(Times-DateTime)<1e-6);
else
    ITime=0;
end

if DataProperties(nr).Block>0
    ITime=DataProperties(nr).Block;
end

if DataProperties(nr).M1==0
    M1=1;
    M2=Size(3);
else
    M1=DataProperties(nr).M1;
    M2=DataProperties(nr).M2;
end

if DataProperties(nr).N1==0
    N1=1;
    N2=Size(4);
else
    N1=DataProperties(nr).N1;
    N2=DataProperties(nr).N2;
end

if DataProperties(nr).K1==0 && Size(5)>0
    K1=1;
    K2=Size(5);
else
    K1=DataProperties(nr).K1;
    K2=DataProperties(nr).K2;
end

% if isfield(Data,'Val')
%     Val=Data.Val;
% else
%     if NVal(NrParameter)>1
%         switch lower(DataProperties(nr).Component),
%             case('magnitude')
%                 Val=sqrt(Data.XComp.^2+Data.YComp.^2);
%             case('angle (radians)')
%                 Val=mod(0.5*pi-atan2(Data.YComp,Data.XComp),2*pi);
%             case('angle (degrees)')
%                 Val=mod(90-atan2(Data.YComp,Data.XComp),2*pi)*180/pi;
%             case('m-component')
%                 Val=Data.XComp;
%             case('n-component')
%                 Val=Data.YComp;
%             case('u-component')
%                 Val=Data.XComp;
%             case('v-component')
%                 Val=Data.YComp;
%         end
%     end
% end
% 

x=0;
y=0;
z=0;
if DataProperties(nr).DateTime==0
    DataProperties(nr).Type='TimeSeries';
    x=Times;
    y=Data(:,M1,N1);
else
    if M2>M1 && N2>N1
        % 2D
        x=xg;
        y=yg;
        if exist('xcomp')
            DataProperties(nr).Type='2DVector';
            u=squeeze(xcomp(:,:,ITime));
            v=squeeze(ycomp(:,:,ITime));
        else
            DataProperties(nr).Type='2DScalar';
            z=squeeze(Data(:,:,ITime));
        end
        
    elseif ((M2>M1 && N2==N1) || (M2==M1 && N2>N1))
        % CrossSection
        DataProperties(nr).Type='XYSeries';

        switch(lower(DataProperties(nr).XCoordinate)),
            case{'x'}
                x=squeeze(xg(M1:M2,N1:N2));
            case{'y'}
                x=squeeze(yg(M1:M2,N1:N2));
            case{'pathdistance'}
                x=pathdistance(squeeze(xg(M1:M2,N1:N2)),squeeze(yg(M1:M2,N1:N2)));
            case{'revpathdistance'}
                x=pathdistance(squeeze(xg(M1:M2,N1:N2)),squeeze(yg(M1:M2,N1:N2)));
                x=x(end:-1:1);
        end                
        y=squeeze(Data(M1:M2,N1:N2,ITime));
    end
end

DataProperties(nr).x=squeeze(x);
DataProperties(nr).y=squeeze(y);
DataProperties(nr).u=0;
DataProperties(nr).v=0;
DataProperties(nr).z=0;
DataProperties(nr).zz=0;
if exist('xcomp')
    DataProperties(nr).u=squeeze(u);
    DataProperties(nr).v=squeeze(v);
else
    DataProperties(nr).z=squeeze(z);
    DataProperties(nr).zz=squeeze(z);
end
        
if DataProperties(nr).DateTime==0 || Size(1)<2
    DataProperties(nr).TC='c';
else
    DataProperties(nr).TC='t';
    DataProperties(nr).AvailableTimes=Times;
    DataProperties(nr).AvailableMorphTimes=Times;
end    

clear x y z Data Times
