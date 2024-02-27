function cmgax(infile,varargin)
% CMGAX - Chop off the gaps and save the data into separate NetCDF files
% Syntax:	cmgax(infile,[len]);
% 
% Input:	infile = name of the input netcdf file
% 			len = (optional) an integer value to identify at least how many HOURS your
% 				shortest chunk should be. Chunks shorter than this are not save.
% 				default is 300 hours.
% 		
% Output: New files are named as follows: [orignial_name + _axed_ + chunk number + .nc]
% 
% jpx@usgs, 11/28/01
% 
if nargin<1
	help(mfilename);
	return;
end;
len=300;
if length(varargin)>0
	len=varargin{1};
end;
nvarout = 0;
% vardesc = '';
epname{1} = '';
calatts = '';
varcomment = '';
calcomment = '';
[s1,s2,s3]=fileparts(infile);

nc=netcdf(infile);
vname=ncnames(var(nc));
if any(strcmp('time2',vname)),
	tjulian=nc{'time'}(:)+nc{'time2'}(:)*1e-3/(24*3600);
elseif any(strcmp('time',vname))
	tjulian=nc{'time'}(:);
elseif any(strcmp('TIM',vname))
	tjulian=nc{'TIM'}(:); %for ADCP files
end;
dt=diff(tjulian(1:2))*24;
len=round(len/dt);

time=floor(tjulian);
time2=(tjulian-time)*24*36e5;

depthname='depth';
latname='latitude';
lonname='longitude';
k=[];
tvari={'time','time2','depth','dep','lat','latitude','lon','longitude'};
for mm=1:length(tvari)
	num=strmatch(tvari{mm},lower(vname));
	if ~isempty(num)
		switch mm
		case {3,4}
			depthname=vname{num};
		case {5,6}
			latname=vname{num};
		case {7,8}
			lonname=vname{num};
		end;
		k=[k; num];
	end;
end;
vname(k)=[];
data=nc{vname{1}}(:);
data=cmgdataclean(data,9999);
[ngaps,heads,tails,lgap]=cmgidgaps(data);
tails=[1 tails];
heads=[heads length(data)];
k=0;
chunk=[];
for i=1:length(heads)
	indx=tails(i)+1:heads(i)-1;
	if length(indx)>=len
		k=k+1;
		chunk{k}=indx;
	end;
end;
tconv=1721059;
vnum=length(vname);
if k>0
	fprintf('\n\nThere are %d chunks.\n',k);
end;
for j=1:length(chunk)
	fprintf('\nSaving chunck %d...\n',j);
	ntimes=length(chunk{j});
	t0=time(chunk{j});
	t1=time2(chunk{j});
	att_start_time = datestr(t0(1)+t1(1)/24/36e5 -tconv,0);
	att_stop_time = datestr(t0(end)+t1(end)/24/36e5-tconv,0);
	for i = 1:vnum
		ivar = nc{vname{i}};
		epname{i} = name(ivar);
		inname{i} = name(ivar);
		indims = size(ivar);
		newsize{i} = ['1:' num2str(ntimes) ];
		for idims = 2:length(indims)
			newsize{i} = [newsize{i} ',1:' num2str(indims(idims))];
		end
% 		vardesc = [ vardesc ':' ivar.name(:)];
		if indims(2)>1
			ivar2d(1:ntimes,:)=ivar(chunk{j},:,1);
		else
			ivar2d=ivar(chunk{j});
		end;
		newvar{i} = ivar2d;
		newvar{i}(isnan(newvar{i})==1)=1e35;
	end
	depth = nc{depthname}(:);
	if isempty(depth)
		ndepths=1;
	elseif ischar(depth)
		ndepths=length(str2num(depth));
	else
		ndepths = length(depth);
	end;
	
% Open output cdf
	outfile=[s2 '_axed_' num2str(j) '.nc'];
	outc = netcdf(outfile,'clobber');
	if isempty(outc)
		disp (['Cannot open output file ' outfile]);
		disp (['Data will be parked in temporary.nc']);
		outc = netcdf('temporary.nc','clobber');
	end
	copy(att(nc),outc);
%Update global attributes and variables in output file.
% 	vardesc(1) = '';
% 	outc.VAR_DESC = ncchar(vardesc);
	outc.start_time = att_start_time;
	outc.stop_time = att_stop_time;

% 	%% Dimensions:
 	outc('time') = 0;
	outc(depthname) = ndepths;
	outc(lonname) = 1;
	outc(latname) = 1;

%% Variables and attributes:
	outc{'time'}=nclong('time');
	outc{'time2'}=nclong('time');
	outc{depthname}=ncfloat(depthname);
	outc{latname}=ncfloat(latname);
	outc{lonname}=ncfloat(lonname);
	for i=1:vnum
		outc{vname{i}}=ncfloat('time',depthname);
	end;

	copy(nc{'time'},outc,0,1);
	copy(nc{'time2'},outc,0,1);
	
	if ~isempty(nc{depthname})
		copy(nc{depthname},outc,1,1);
	end;
	if ~isempty(nc{latname})
		copy(nc{latname},outc,1,1);
	end;
	if ~isempty(nc{lonname})
		copy(nc{lonname},outc,1,1);
	end;
	
	for i=1:vnum
		ivar=nc{vname{i}};
		copy(ivar,outc,0,1);
	end;	

	for i = 1:vnum
		ovar = outc{vname{i}};
		ivar = nc{inname{i}};
		ovar.minimum = ncfloat(min(cmgdataclean(newvar{i})));
		ovar.maximum = ncfloat(max(cmgdataclean(newvar{i})));
	end
	endef(outc)

	outc{'time'}(1:ntimes) = t0;
	outc{'time2'}(1:ntimes) = t1;

	for i = 1:vnum
	   ovar = outc{epname{i}};
	   eval (['ovar(' newsize{i} ') = newvar{' num2str(i) '};' ]);
   end;

   histcomnt=['Chopped by CMGAX.M from ' infile];
	thishistory=nc.history(:);
	if ~isempty(thishistory) & isempty(findstr(thishistory, char(13)))
		thishistory=strrep(thishistory,':', [char(13) ':']);
	end;
	history =[histcomnt char(13) ':' thishistory];  
	outc.history = history;
	outc.CREATION_DATE = ncchar(datestr(now,0));
   
   close(outc);

end;
close(nc);

return;
	
	