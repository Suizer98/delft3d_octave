function fig=cmgadcpview(varargin)
%View profile of ADCP data in 1). workspace or 2). a NetCDF file
% 
% Syntax:  cmgadcpview(jdaytime,east,north [,dep,angle]);
% 					or
% 			cmgadcpview(fname,uname,vname [,dname,angle])
% 
% ## Syntax 2 require NetCDF capability on your system, use ncdump
% 	to see the names U, V, and depth
% 
% Input:
% 	jdaytime = time in true julian dates
% 	east,north = the east and north components of ADCP data matrices 
% 			of size (M x N) where M = length of jdaytime
% 	dep = array of water depths where measurements are made, OPTIONAL
% 
% 		or
% 		
% 	fname = a text string of the NetCDF file name
% 	uname, vname = the text strings of the east and north velocity
% 			components. (make sure they exist in the file)
% 	dname = a text string of the depth, OPTIONAL
% 	angle = rotate this angle (in degrees) before viewing, OPTIONAL
% Output:
% 	none	
% 
% jpx, USGS, 01-03-01
% jpx, USGS, 03-12-01
% jpx @ usgs, 03-19-01

global yhand adcp

if nargin<3 
	if nargin>0
		fprintf('\nAt least 3 input arguments are needed.\n');
	else
		help(mfilename);
	end;
	return; 
end;

[jdaytime,east,north,dep,ang]=inparse(varargin);

if isempty(jdaytime)
	msg=['Make sure the NetCDF files have time variable(s),'...
			'i.e. ''time'',''time2'', or ''TIM'' !'];
	error(msg);
end;
if isempty(east) | isempty(north)
	return;
end;
[m,n]=size(east);
if n>m & n==length(jdaytime)
	east=east';
	north=north';
	[m,n]=size(east);
end;
if ~isempty(ang)
	[east,north]=cmgrotate(east,north,ang);
end;
	
if ~isempty(dep) & diff(dep([1 end]))>0 % if row 1 is not bin 1
	east=fliplr(east);
	north=fliplr(north);
end;

colordepth=100;
east(east>1e5)=nan;
north(north>1e5)=nan;
adcp.data{2,1}=east;
adcp.data{2,2}=north;
spd=sqrt(east.*east + north.*north);
spd(spd>1e5)=nan;
adcp.data{1,1}=spd;
direc=atan2(east, north)*180/pi;
indx=find(direc<0);
direc(indx)=360+direc(indx);
adcp.data{1,2}=direc;
adcp.time=jdaytime;
adcp.ylab='Bin #';
if nargin<4
	dep=flipud(1:n);
	adcp.ylab='Bin #';
end;
adcp.depth=dep;
adcp.choice=1;

adcp.scale{1}=25:25:100;
adcp.scale{2}=[-50:50:100]/2;

adcp.cbar{1,1}='Speed';
adcp.cbar{1,2}='Direction';
adcp.cbar{2,1}='U velocity';
adcp.cbar{2,2}='V velocity';

margins=0;
adcp.max(1,1)=maxfinder(spd);
adcp.max(1,2)=360;
adcp.max(2,1)=maxfinder(east)+margins;
adcp.max(2,2)=maxfinder(north)+margins;

adcp.min(1,1)=0;
adcp.min(1,2)=0;
adcp.min(2,1)=-adcp.max(2,1);
adcp.min(2,2)=-adcp.max(2,2);

adcp.offset(1,1)=0;
adcp.offset(1,2)=0;
adcp.offset(2,1)=adcp.max(2,1);
adcp.offset(2,2)=adcp.max(2,2);

yhand.adcp=figure('Integerhandle','off',...
	'NumberTitle','off', ...
	'name','ADCP VIEW',...
	'unit','norm',...
	'colormap',jet(colordepth),...
	'Tag','fig adcpview 1');
b = uimenu(    'Parent',yhand.adcp, ...
        'Label','[Save As]', ...
         'Tag','File Menu');
c = uimenu (    'Parent', b, ...
            'Label', 'Save as M-file', ...
            'Callback', 'timeplt_command print_to_mfile', ...
            'Tag', 'print to mfile menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as JPEG', ...
            'Callback', 'timeplt_command print_jpeg', ...
            'Tag', 'print jpeg menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as PS', ...
            'Callback', 'timeplt_command print_ps', ...
            'Tag', 'print ps menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as EPS', ...
            'Callback', 'timeplt_command print_eps', ...
            'Tag', 'print eps menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Print to Printer', ...
            'Callback', 'timeplt_command print_to_printer', ...
            'Tag', 'print to printer menu item' );

set(yhand.adcp,'DoubleBuffer','on');
yhand.spdprofile=axes('parent',yhand.adcp,...
	'position',[1/32 19/32 6/32 12/32],...
	'xgrid','on');
yhand.dirprofile=axes('parent',yhand.adcp,...
	'position',[1/32 5/32 6/32 12/32],...
	'xgrid','on');
yhand.spdimage=axes('parent',yhand.adcp,...
	'position',[9/32 19/32 22/32 12/32],...
	'xticklabel','');
yhand.dirimage=axes('parent',yhand.adcp,...
	'position',[9/32 5/32 22/32 12/32]);
yhand.adcptxtbox=axes('parent',yhand.adcp,...
	'position',[1/32 0 6/32 2/32],'visible','off');
yhand.adcptxt=text(0.1,0.6,'');
yhand.ensambleslide = uicontrol('Parent',yhand.adcp,...
	'units','norm',...
	'Position',[9/32 2/32 22/32 3/32], ...
	'Style','slider',...
	'callback','adcpviewing(1)','value',0);

uvsdstr={'[U,V]','[spd,dir]'};
uvsdpos={[18/32 0 3/32 2/32],[22/32 0 4/32 2/32]};
prenxtstr={'<<Prev.','Next>>'};
prenxtpos={[8/32 0 3/32 2/32],[12/32 0 3/32 2/32]};

for i=1:2
	yhand.uvsdradio(i)=uicontrol('parent',yhand.adcp,...
		'units','norm',...
		'callback','adcpviewing(10);',...
		'style','radio',...
		'value',i-1,...
		'string',uvsdstr{i},...
		'Position',uvsdpos{i});
	yhand.prenxt(i) = uicontrol('Parent',yhand.adcp, ...
		'Units','norm', ...
		'Callback','adcpviewing(4);', ...
		'Style','pushbutton',...
		'String',prenxtstr{i},...
		'position',prenxtpos{i});
end;
for i=1:2
	set(yhand.uvsdradio(i),'UserData',yhand.uvsdradio(:,[1:i-1, i+1:2]));
end;
yhand.windl = uicontrol('Parent',yhand.adcp, ...
	'units','norm',...
	'callback','adcpviewing(11);',...
	'HorizontalAlignment','left', ...
	'Position',[27/32 0 4/32 2/32], ...
	'String',{'3 days','1 day','7 days','30 dyas','Whole'}, ...
	'Style','popupmenu', ...
	'Value',1,...
	'TooltipString','Window Length');

wl=24*[3 1 7 30 floor(max(adcp.time)-min(adcp.time))];
adcp.wl=wl(get(yhand.windl,'value'));
adcpviewing(1);

function mymax=maxfinder(mydata)
% find max using histogram, called from ADCPVIEW
[m,n]=size(mydata);
if n>10
	cols=n-5;
else
	cols=n;
end;
mydata=abs(mydata);
maxspd=max(mydata(:,1:cols)');
histbins=10;
[histvalue,histpos]=hist(maxspd,histbins);
indx=find(cumsum(histvalue)/sum(histvalue)>.99);
mymax=10*ceil(histpos(min(indx))/10);

return;

function [t,u,v,d,a]=inparse(cellin)
% Parse the input varargin
t=[];u=[];v=[];d=[];a=[];
n=length(cellin);
if ischar(cellin{1})	%syntax #2
	nc=netcdf(cellin{1});
	if isempty(nc)
		error('File not found.');
	end;
	varlist=ncnames(var(nc));
	u=nc{cellin{2}}(:,:);
	v=nc{cellin{3}}(:,:);
	if isempty(u) | isempty(v)
		error('Variables not found, names are case-sensitive...');
	end;
	stru={'millisec','sec','min','hour'};
	facu=[36e5, 3600, 60, 1];
	if any(strcmp('time2',varlist)),
		t=nc{'time'}(:)+nc{'time2'}(:)*1e-3/(24*3600);
	elseif any(strcmp('time',varlist))
		t=nc{'time'}(:);
		test=lower(nc{'time'}.units(:));
		indxu=strmatch(test,stru);
		if isempty(test) | isempty(indxu)
			msg=['The ''units'' attribute of ''time'' doesn''t exist.'...
				'True Julian date assumed.'];	
			warning(msg);
		else
			t=t/24/facu(indxu);
		end;
	elseif any(strcmp('TIM',varlist))
		t=nc{'TIM'}(:);
		test=lower(nc{'TIM'}.units(:));
		indxu=strmatch(test,stru);
		if isempty(test) | isempty(indxu)
			msg=['The ''units'' attribute of ''TIM'' doesn''t exist.'...
				'True Julian date assumed.'];	
			warning(msg);
		else
			t=t/24/facu(indxu);
		end;
	else
		error('NetCDF files must have time variable(s), i.e. ''time'',''time2'', or ''TIM'' !');
		return;
	end;
	
	switch n
	case 4
		if ischar(cellin{4})
			d=nc{cellin{4}}(:);
		else
			a=cellin{4};
		end;
	case 5
		if ischar(cellin{4})
			d=nc{cellin{4}}(:);
			a=cellin{5};
		elseif ischar(cellin{5})
			d=nc{cellin{5}}(:);
			a=cellin{4};
		end;
	end;
	if isempty(d)
		warning('The depth parameter was not found');
	end;
else
	t=cellin{1};
	u=cellin{2};
	v=cellin{3};
	switch n
	case 4
		if length(cellin{4})>1
			d=cellin{4};
		else
			a=cellin{4};
		end;
	case 5
		if length(cellin{4})>1
			d=cellin{4};
			a=cellin{5};
		elseif length(cellin{5})>1
			d=cellin{5};
			a=cellin{4};
		end;
	end;
end;

return;