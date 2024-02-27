function handles=PlotCurVec(handles,i,j,k,mode)

DeleteObject(i,j,k);

Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

% xmin0=Ax.XMin; xmax0=xmin0+0.01*Ax.Position(3)*Ax.Scale;
% ymin0=Ax.YMin; ymax0=ymin0+0.01*Ax.Position(4)*Ax.Scale;
xmin0=Ax.XMin; xmax0=Ax.XMax;
ymin0=Ax.YMin; ymax0=Ax.YMax;

xmin=xmin0-0.1*(xmax0-xmin0);
xmax=xmax0+0.1*(xmax0-xmin0);

ymin=ymin0-0.1*(ymax0-ymin0);
ymax=ymax0+0.1*(ymax0-ymin0);

dx=Plt.DxCurVec;
nt=20;

hdthck=Plt.HeadThickness;
arthck=Plt.ArrowThickness;
lifespan=Plt.LifeSpanCurVec;

pos=[];    
if exist(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat'],'file')
    pos=load(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat']);
end

x1=Data.x;
y1=Data.y;
u=Data.u;
v=Data.v;

% x1(isnan(x1))=-999.0;
% y1(x1==-999.0)=-999.0;
% u(x1==-999.0)=-999.0;
% v(x1==-999.0)=-999.0;

timestep=0;
if ~isempty(handles.AnimationSettings.timeStep)
    timestep=handles.AnimationSettings.timeStep;
end
%Ax.coordinateSystem.type='geographic';
[polx,poly,xax,yax,len,pos]=curvec(x1,y1,u,v,'dx',dx,'length',Plt.DtCurVec,'nrvertices',nt,'nhead',4, ...
    'xlim',[xmin xmax],'ylim',[ymin ymax],'position',pos,'lifespan',lifespan,'timestep',timestep, ...
    'headthickness',hdthck,'arrowthickness',arthck,'cs',Ax.coordinateSystem.type,'relativespeed',Plt.RelSpeedCurVec);
polz=zeros(size(polx))+100;

% Ax.MaxZ=n2*10;

edgeColor=FindColor(Plt.LineColor);

if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')
    % get rgb values
    speed=len/Plt.DtCurVec;
    speed=min(speed,Plt.CMax);
    speed=max(speed,Plt.CMin);
    clmap=GetColors(handles.ColorMaps,Plt.ColorMap,20);
    lmin=Plt.CMin;
    lmax=Plt.CMax;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
    x=lmin:((lmax-lmin)/(length(r)-1)):lmax;
    r1=min(max(interp1(x,r,speed),0),1);
    g1=min(max(interp1(x,g,speed),0),1);
    b1=min(max(interp1(x,b,speed),0),1);
    cl(1,:,1)=r1;    
    cl(1,:,2)=g1;    
    cl(1,:,3)=b1;    
    fl=patch(polx,poly,polz,cl);
    set(fl,'EdgeColor',edgeColor);    
else
    faceColor=FindColor(Plt.FillColor);
    fl=patch(polx,poly,polz,'r');
    set(fl,'FaceColor',faceColor);%hold on;
    set(fl,'EdgeColor',edgeColor);%hold on;
end

SetObjectData(fl,i,j,k,'curvedarrow');

%if Plt.DDtCurVec>0
if ~isempty(timestep)
    save(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat'],'pos','-ascii');
end

