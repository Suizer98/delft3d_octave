function thestruct=cmgfbuild(infoname,varargin)
% A function to load variable(s) from different NetCDF files and to form a [M x N]
% matrix. N is the number of variables.
% 
% 	thestruct=cmgfbuild(infoname,[dtflag],[tflag])
% 	
% infoname: a string that contains the name of file-building information.
% 
% 	The format of the text file must be strictly followed.
% 	See the following example
% 	-------example file------------
% 	5121-a.cdf,5124-q.nc, 5125-a.nc,5126-a.nc,5127-a.cdf  % the names of input files
% 	2,2,2,2,2  % the number of variables in each file
% 	east,north,u_1205, v_1206, u_1205, v_1206, u_1205, v_1206,east,north  % the name of variables
% 	3600  % delta-t in seconds
% 	20-Nov-1997 09:00:00  % start time
% 	04-Oct-1998 09:00:00  % end time
% 	------end of example file-------
% 
% dtflag: optional, when time-series of different dt are loaded, dtflag helps 
% 	determine either the smallest (=0, default) or largest (=1) dt to use to form a
% 	new timebase. If dt is provided in the infoname file, dtflag is not used.
% 
% tflag: optional, when time-series of different lengths are loaded, tflag helps 
% 	determine either to shrink (=0, default) or expand (=1) in forming a new timebase
% 
% thestruct: a structure array that contains the following fields:
% 	.time: time in julian days
% 	.data: the data matrix (M x N)
% 	.fname: a [1 x N] cell array providing the name of source files for each variable
% 	.vname: a [1 x N] cell array of variable names
% 
% jpx @ usgs, 01-18-01
% 
if nargin<1
	help(mfilename);
	return;
end;
if length(varargin)<1
	dtflag=0;
	tflag=0;
elseif length(varargin)<2
	dtflag=varargin{1};
	tflag=0;
else
	dtflag=varargin{1};
	tflag=varargin{2};
end;

fid=fopen(infoname);
fname=fgetl(fid);
[fname,dum]=strtok(fname,'%');
j=0;s=[];
while ~isempty(spacebuster(fname))
	j=j+1;
	[dum,fname]=strtok(fname,', ');
	s{j}=dum;
end;
fname=s;

[fv,dum]=strtok(fgetl(fid),'%');
fv=str2num(fv);

if ~isequal(length(fname),length(fv))
	ermsg=['The number of entries in line 1 and 2 should be the same in file ',infoname];
	fclose(fid);
	error(ermsg);
end;

vname=fgetl(fid);
[vname,dum]=strtok(vname,'%');
j=0;s=[];
while ~isempty(spacebuster(vname))
	j=j+1;
	[dum,vname]=strtok(vname,', ');
	s{j}=dum;
end;
if ~isequal(length(s),sum(fv))
	ermsg=['The sum of line 2 should equal the number of entries in line 3 in file ',infoname];
	fclose(fid);
	error(ermsg);
end;
thestruct.vname=s;

k=0;s=[];
for i=1:length(fv)
	for j=k+1 : k+fv(i)
		s{j}=fname{i};
	end;
	k=j;
end;
thestruct.fname=s;

[dt,dum]=strtok(fgetl(fid),'%');
dt=str2num(dt);

[tstart,dum]=strtok(fgetl(fid),'%');
tstart=1721059+datenum(tstart);

[tstop,dum]=strtok(fgetl(fid),'%');
tstop=1721059+datenum(tstop);
fclose(fid);

tstart=tstart*24*3600;  % unit is seconds
tstop=tstop*24*3600;

k=0;
for i=1:length(fname)
	nc=netcdf(fname{i});
	tt=nc{'time'}(:)*24*3600 +nc{'time2'}(:) /1000; % now unit is seconds
	for j=1:fv(i)
		k=k+1;
		jday{k}=tt;
		ss{k}=nc{thestruct.vname{k}}(:);
		ss{k}=cmgdataclean(ss{k});
	end;
	close(nc);
end;

dtarray=[];
t0array=[];
t1array=[];
for i=1:length(jday)
	dtarray=[dtarray mean(diff(jday{i}))];
	t0array=[t0array min(jday{i})];
	t1array=[t1array max(jday{i})];
end;
if isempty(dt)
	dtdiff=diff(dtarray);
	if any(dtdiff)
		if dtflag
			mydt=max(dtarray);
		else
			mydt=min(dtarray);
		end;
	else
		mydt=dtarray(1);
	end;
else
	mydt=dt;
end;

if isempty(tstart) & isempty(tstop)
	t0diff=diff(t0array);
	t1diff=diff(t1array);
	if any(t0diff) | any(t1diff)
		if tflag
			myt0=min(t0array);
			myt1=max(t1array);
		else
			myt0=max(t0array);
			myt1=min(t1array);
		end;
	else
		myt0=t0array(1);
		myt1=t1array(1);
	end;
else
	myt0=tstart;
	myt1=tstop;
end;

timebase=myt0 : mydt : myt1;
timebase=timebase(:);  % into column 

for i=1:length(jday)
	data(:,i)=interp1(jday{i},ss{i},timebase,'*linear');
end;
k=0;
for i=1:length(fname)
	for j=1:fv(i)
		fprintf([fname{i} ' - ']);
		k=k+1;
		fprintf([thestruct.vname{k} ': ']);
		ngaps=cmgidgaps(data(:,k));
		if ngaps<1 fprintf('.....OK\n'); end;
	end;
end;

thestruct.time=timebase/24/3600; %julian days

thestruct.data=data;

return;
