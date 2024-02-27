function cmgmat2nc(varargin)
% CMGMAT2NC: to convert matlab files into netcdf files
%
% SYNTAX:
%	cmgmat2nc(batchname); -used for batch processing
%		or
%	cmgmat2nc(ss,[matname],[cdfname]); -used for single file conversion
%
% INPUT:
%	batchname - the name of a text file that contains all information of the source
%		files/variables that will be written into netcdf files. The format of the batch
%		file must be strictly followed. Example batch file:
%			[1] test.mat	%the input mat file
%			time, velU, velV, temperature %name of variables (the first one MUST be the time variable)
%			GMT %time zone
%			PMEL epic %format
%			33 34.784 %latitude
%			-117 57.660 %longitude
%			55 %water depth
%			USGS %data origin
%			659 %mooring number
%			OCSD, M011 subsurface, branker at 25 M below surface %description
%			Marlene Noble %PI
%			13.75East %Magnetic variation
%			Branker %instrument
%			012345 %serial number
%			Time Series %data type
%			Geographical %coordinate system
%			data chopped from head and tail %data comment
%			Created using RDBRANKER and MAT2NETCDF %history
%			newfile.nc %output netcdf file name
%			[2] test2.mat %
%				.
%				.
%			[3] test3.mat %
%				.
%
% 	ss - a cell array that lists the names of all variables ( the first one MUST be
% 		the time variable) that will be saved into the new netcdf file. Strings
% 		may be case-sensitive depending on platform. an example of ss reads like
% 			ss={'time','velU','velV','temperature'}
% 	matname - optional, the name of the matlab file containing all the variables. If omitted
%				the function will try to load variables from the 'base' workspace.
% 	cdfname - optional, a string designates the netcdf file name. ONLY used when 
%				when there is a 'matname' entry.
% 
% OUTPUT:
% 	The output file(s) is saved.
%
% jpx@usgs, 12-7-01

if nargin<1
	help(mfilename)
	return;
end;
gattname1={'Time_Zone','Time_Format','Latitude','Longitude','Water_Depth',...
      'DataOrigin','Mooring','Description'};
gattname2={'Start_Time','Stop_Time','Creation_Date'};
gattname3={'PI','Mag_Var','DataType','CoordSystem','Data_Comnt',...
      'Instument','Inst_Serial_Num','History'};
vattname={'name','units','atDepth','Fillvalue'};
f=varargin{1};
if ischar(f)
	[sdata,satt]=rdbatch(f);
else
   if nargin<2
      satt.cdfname='MYncfile.nc';
      for i=1:length(f) 
         c{i}=evalin('base',f{i});
      end;
      sdata{1}=cell2struct(c,f,2);
   elseif nargin<3
      matname=varargin{2};
		if ~ischar(matname)
		   error(['File name input needs to be a string']);
		end;
		sdata{1}=load(matname,f{:});
	   [s1,s2,s3]=fileparts(matname);
		satt.cdfname=[s2 '.nc'];
	else
      matname=varargin{2};
      satt.cdfname=varargin{3};
	   if ~ischar(satt.cdfname) | ~ischar(matname)
      	error(['File name input needs to be a string']);
   	end;
		sdata{1}=load(matname,f{:});
	end;
eval(['tt=sdata{1}.' f{1} ';']);
sdata{1}.trecord=tt;
t0=datestr(tt(1)-1721059);
t1=datestr(tt(end)-1721059);
def1={'GMT','PMEL epic','33 34.784','-117 57.660','55',...
      'USGS','659','OCSD, M011 subsurface, branker at 25 M below surface'};
def3={'Marlene Noble','13.75East','Time Series','Geographical','data chopped from head and tail',...
      'Branker','012345','Created using RDBRANKER and MAT2NETCDF'};
tit='Global Attribute';
lineno=1;
satt.gatt1=inputdlg(gattname1,tit,lineno,def1);
satt.gatt3=inputdlg(gattname3,tit,lineno,def3);
satt.gatt2={t0,t1,datestr(now)};

ss=f(2:end);
satt.vname=ss;
for i=1:length(ss)
	def={ss{i},'degC','xx M','1E+35'};
   tit=['Attributes for <' ss{i} '>'];
   satt.vari(i).att=inputdlg(vattname,tit,lineno,def);
end;
end;

for ifn=1:length(sdata)
   fprintf('Writing file # %d\n',ifn);
latitude=str2num(satt(ifn).gatt1{3});
nnn=length(latitude);
switch nnn
case 3
   latitude=sign(latitude(1))*abs(latitude)*[1;1/60;1/3600];
case 2
   latitude=sign(latitude(1))*abs(latitude)*[1;1/60];
case 0
   latitude=9999;
end;

longitude=str2num(satt(ifn).gatt1{4});
nnn=length(longitude);
switch nnn
case 3
   longitude=sign(longitude(1))*abs(longitude)*[1;1/60;1/3600];
case 2
   longitude=sign(longitude(1))*abs(longitude)*[1;1/60];
case 0
   longitude=-9999;
end;

waterd=str2num(satt(ifn).gatt1{5});
if isempty(waterd)
   waterd=9999;
end;

time=sdata{ifn}.trecord;
mytime=floor(time);
mytime2=(time-mytime)*86400000;
limits=length(mytime);

cdf=netcdf(satt(ifn).cdfname,'clobber');
for i=1:length(satt(ifn).gatt1)
   eval(['cdf.' gattname1{i} '=ncchar(satt(ifn).gatt1{i});']);
end;
for i=1:length(satt(ifn).gatt2)
   eval(['cdf.' gattname2{i} '=ncchar(satt(ifn).gatt2{i});']);
end;
for i=1:length(satt(ifn).gatt3)
   eval(['cdf.' gattname3{i} '=ncchar(satt(ifn).gatt3{i});']);
end;

cdf('time')=0;
cdf('dep')=1;
cdf('lat')=1;
cdf('lon')=1;

cdf{'time'}=nclong('time');
cdf{'time'}.name='epic time';
cdf{'time'}.units='true julian day';
cdf{'time'}.epic_code=624;

cdf{'time2'}=nclong('time');
cdf{'time2'}.name='epic time2';
cdf{'time2'}.units='milliseconds';
cdf{'time2'}.epic_code=624;

cdf{'lat'}=ncfloat('lat');
cdf{'lat'}.name=ncchar('Latitude');
cdf{'lat'}.units=ncchar('deg');

cdf{'lon'}=ncfloat('lon');
cdf{'lon'}.name=ncchar('Longitude');
cdf{'lon'}.units=ncchar('deg');

cdf{'dep'}=ncfloat('dep');
cdf{'dep'}.name=ncchar('water depth');
cdf{'dep'}.units=ncchar('M');

ss=satt(ifn).vname;
for i=1:length(ss)
   myarray=getfield(sdata{ifn},ss{i});
	[m,n]=size(myarray);
   if m<limits
      cdf('depth')=m;
   	if n>1
	 	 	cdf('depth2')=n;
    		cdf{ss{i}}=ncfloat('depth','depth2');
      else
         cdf{ss{i}}=ncfloat('depth'); 
      end;
   else
      if n>1
         cdf('depth')=n;
	       cdf{ss{i}}=ncfloat('time','depth','lat','lon');
	   else
	       cdf{ss{i}}=ncfloat('time','dep','lat','lon');
		   
     end;
   end;
   for j=1:length(vattname)
      eval(['cdf{ss{i}}.' vattname{j} '=satt(ifn).vari(i).att{j} ;']);
   end;
end;
cdf{'time'}(1:limits,1)=mytime;
cdf{'time2'}(1:limits,1)=mytime2;
cdf{'lat'}(1)=latitude;
cdf{'lon'}(1)=longitude;
cdf{'dep'}(1)=waterd;

for i=1:length(ss)
   myarray=getfield(sdata{ifn},ss{i});
   myarray=nan2fillv(myarray,1e+35);
	[m,n]=size(myarray);
   cdf{ss{i}}(1:m,1:n)=myarray;

end;
close(cdf);
end;
fprintf('\nCompleted...\n');
return;

function vv=nan2fillv(vv,fillv)
indx=find(isnan(vv)==1);
vv(indx)=fillv;
return;

function [sdata,satt]=rdbatch(fn)
fid=fopen(fn);
k=0;
while ~feof(fid)
   k=k+1;
   matname=strtok(fgetl(fid),'%');
   indx=findstr(']',matname);
   matname=cmgspacebuster(matname(indx(1)+1:end));
   for jj=1:3
   	vv=strtok(fgetl(fid),'%');
		i=0;
		while ~isempty(vv) | isequal(cmgspacebuster(vv),',')
	 	  i=i+1;
    	  [vname{i,jj},vv]=strtok(vv,',');
    	  vname{i,jj}=cmgspacebuster(vname{i,jj});
   	end;
   end;
   sdata{k}=load(matname,vname{:,1});
   tt=getfield(sdata{k},vname{1,1});
   sdata{k}.trecord=tt;
   vn=vname(2:end,1);
   units=vname(2:end,2);
   atdep=vname(2:end,3);
   
   satt(k).vname=vn;
   
   for mm=1:length(units)
      satt(k).vari(mm).att={vn{mm},units{mm},[atdep{mm} 'M'],'1E+35'};
   end;
	for i=1:17
	   ss{i}=strtok(fgetl(fid),'%');
	end;
	satt(k).gatt1=ss(1:8);
   satt(k).gatt3=ss(9:16);
   satt(k).cdfname=ss{17};
   tt=getfield(sdata{k},vname{1});
	t0=datestr(tt(1)-1721059);
	t1=datestr(tt(end)-1721059);
   satt(k).gatt2={t0,t1,datestr(now)};

end;
fclose(fid);
return;