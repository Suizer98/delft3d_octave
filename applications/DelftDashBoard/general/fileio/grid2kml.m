function grid2kml(gridFile,clr,varargin)

if ~exist('gridFile')
    g=ddb_wlgrid('read');
elseif isempty(gridFile)
    g=ddb_wlgrid('read');
else
    g=ddb_wlgrid('read',gridFile);
end

% Third argument can be EPGS code
if length(varargin) == 1 && isnumeric(varargin{1})
    try
        [g.X,g.Y]=convertCoordinates(g.X,g.Y,'CS1.code',varargin{1},'CS2.code',4326);
        g.CoordinateSystem = 'Spherical';
    end
end

[fPat fName]=fileparts(g.FileName);
if isempty(fPat)
fPat=cd;
end

fid=fopen([fPat filesep fName '.kml'],'w');

if ~exist('clr')
    clr=[];
end

if isempty(clr)
    clr=str2num(char(inputdlg({'Red','Green','Blue'},'Specify RGB color',1,{'255','0','0'})));
    if isempty(clr)
        clr=[255;0;0];
    end
end

clr=[min(255,clr(1)); min(255,clr(2)); min(255,clr(3))];
clr=[max(0,clr(1)); max(0,clr(2)); max(0,clr(3))];

fprintf(fid,'%s \n','<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'%s \n','<!--x=x+                  -->');
fprintf(fid,'%s \n','<!--y=y+                  -->');
fprintf(fid,'%s \n','<kml xmlns="http://earth.google.com/kml/2.1">');
fprintf(fid,'%s \n','<Document>');
fprintf(fid,'%s \n',['	<name>' fName '</name>']);
fprintf(fid,'%s \n','	<Style id="style_1">');
fprintf(fid,'%s \n','		<LineStyle>');
fprintf(fid,'%s \n',['			<color>FF' dec2hex(clr(3),2) dec2hex(clr(2),2) dec2hex(clr(1),2) '</color>']);
fprintf(fid,'%s \n','		</LineStyle>');
fprintf(fid,'%s \n','		<PolyStyle>');
fprintf(fid,'%s \n','			<fill>0</fill>');
fprintf(fid,'%s \n','		</PolyStyle>');
fprintf(fid,'%s \n','	</Style>');

teller=1;

hW=waitbar(0,'Writing m-lines');
for im=1:size(g.X,1)
    id=find(isnan(g.X(im,:)));
    if isempty(id) %if array contains no nans
        id=length(g.X(im,:))+1;
    end
    if id(end)~=length(g.X(im,:)); %if last number in array is no nan
        id(end+1)=length(g.X(im,:))+1;
    end
    startId=1;
    for ii=1:length(id)
        if id(ii)>startId
            endId=id(ii)-1;
            data(:,1)=g.X(im,startId:endId)';
            data(:,2)=g.Y(im,startId:endId)';
            grid2kmlWrite(fid,data,teller);
            clear data;
            teller=teller+1;
        end
        startId=id(ii)+1;
    end
    waitbar(im/size(g.X,1),hW);
end
close(hW);

hW=waitbar(0,'Writing n-lines');
for in=1:size(g.X,2)
    id=find(isnan(g.X(:,in)));
    if isempty(id) %if array contains no nans
        id=length(g.X(:,in))+1;
    end
    if id(end)~=length(g.X(:,in)); %if last number in array is no nan
        id(end+1)=length(g.X(:,in))+1;
    end
    startId=1;
    for ii=1:length(id)
        if id(ii)>startId
            endId=id(ii)-1;
            data(:,1)=g.X(startId:endId,in);
            data(:,2)=g.Y(startId:endId,in);
            grid2kmlWrite(fid,data,teller);
            clear data;            
            teller=teller+1;            
        end
        startId=id(ii)+1;
    end
    waitbar(in/size(g.X,2),hW);
end
close(hW);

fprintf(fid,'%s \n','	</Document>');
fprintf(fid,'%s \n','</kml>');
fclose(fid);


function grid2kmlWrite(fid,data,name)
fprintf(fid,'%s \n','	<Placemark>');
fprintf(fid,'%s \n',['		<name>' num2str(name) '</name>']);
fprintf(fid,'%s \n','		<styleUrl>style_1</styleUrl>');
fprintf(fid,'%s \n','		<Polygon>');
fprintf(fid,'%s \n','			<tessellate>1</tessellate>');
fprintf(fid,'%s \n','			<outerBoundaryIs>');
fprintf(fid,'%s \n','				<LinearRing>');
fprintf(fid,'%s \n','					<coordinates>');
for ii=1:size(data,1)
    fprintf(fid,'%s \n',[num2str(data(ii,1),'%15.6f') ',' num2str(data(ii,2),'%15.6f') ',0']);
end
fprintf(fid,'%s \n','</coordinates>');
fprintf(fid,'%s \n','				</LinearRing>');
fprintf(fid,'%s \n','			</outerBoundaryIs>');
fprintf(fid,'%s \n','		</Polygon>');
fprintf(fid,'%s \n','	</Placemark>');
