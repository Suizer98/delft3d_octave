function [varargout]=cmgcolock(t,varargin)

%a function to check if there is time gap.
% gaps in time are rebuilt and gaps in data are filled with NANs
% 
% [t,data]=cmgcolock(t,[data],[dt])
% 
% t = time
% data = data, vector or matrix. The same rows of each column are
% 	filled with NANs
% dt = optional, delta_t in second
% 
% jpx@usgs, 12-14-00
% revised by jpx, 11/16/01
% revised by jpx, 01/06/02

if nargin<1
	help(mfilename);
	return;
end;

fac=24*36000;

if nargin<2
	data=t(:);
	dt1=getdt(t);
end;

ops=length(varargin);
if ops>2
	error('Too many inputs. Program aborted.');
end;
if ops==1
	if length(varargin{1})==1
		dt1=varargin{1}*10/fac;
		data=t(:);
	else
		data=varargin{1};
		dt1=getdt(t);
	end;
elseif ops==2
	if length(varargin{1})==1
		dt1=varargin{1};
		data=varargin{2};
	else
		dt1=varargin{2};
		data=varargin{1};
	end;
	dt1=dt1*10/fac;
end;	

dt2=mean(diff(t));

dt1=round(dt1*fac)/fac;
dt2=round(dt2*fac)/fac;

if isequal(dt1,dt2)
	fprintf('\nThere is no time gap.\n');
	return;
end;

t=t(:);
t=t';
pos=find(size(data)==length(t));
if isempty(pos)
	fprintf('\nThe two variables must have the same length\n')
	return;
elseif pos==2
	data=data';
end;
[m,n]=size(data);

fprintf('\nGaps in colock are rebuilt. Gaps in data are filled with NANs.\n');

newt=t(1):dt1:t(end);
newdata=nan*ones(length(newt),size(data,2));
indx=round((t - t(1))/dt1) +1;
newdata(indx,:)=data;

dis=length(newdata)-length(newt);
if dis>0
	newt=[newt (1:dis)*dt1+newt(end)];
end;
if dis<0
	newt(end+dis : end)=[];
end;

varargout(1)={newt(:)};
if nargin>1
	varargout(2)={newdata};
end;

return;

function dt1=getdt(t)

fac=24*36000;
ok='No';
while isequal(ok,'No')
	num=ceil(rand(1)*length(t));
	
	if num<=2
		dt0=diff(t(1:5));
	elseif num>=length(t)-2
		dt0=diff(t(end-4:end));
	else
		dt0=diff(t(num-2:num+2));
	end;
	if ~any(round(fac*diff(dt0))/fac)
		dt1=dt0(1);
		ok='Yes';
	end;
end;
return;