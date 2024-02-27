function [varargout]=cmglowpass(u,dt,varargin)
% CMGLOWPASS  Low-pass filters time-series data, modified from a routine
% first developed by Rich Signell. It also deals with non-hourly data by
% interplating the original pl33 or OSU60 filter. 
%
% SYNTAX: [ufilt, jdf]=cmglowpass(u, dt, [jd], [nsub], [ftype]);
%
% INPUT:  u =  matrix with time series in each column
% 		  dt = delta-T in **SECONDS**
%         jd =  julian day time vector
%         nsub =  subsampling interval for the output low-pass data (optional)
% 		  ftype = 'pl' or 'osu', default is 'pl' - using the pl33 weights
%  
% OUTPUT: ufilt = low-pass filtered data with data points (of half filter length) removed at each end.
%         jdf = julian time vector corresponding to the data ulp.
%
% Example:   [ufilt,jdf]=cmglowpass(u,3600,jd,4,'osu');   %jdlp and ulp at 4 hour intervals, using OSU60. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0 (12/4/96) Rich Signell (rsignell@usgs.gov)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Modified by jpx on 03-04-02 to include the OSU60 filter
% 
% jpx @ usgs, 2002-11-27
% 
if nargin<1, help(mfilename); return; end;
	
fac=dt/3600;
if fac>1
	fprintf('\nThe delta-t (%d seconds) is greater than one hour.\n',delt);
	fprintf('\nYou my use CMGSMOOTHIE to smooth the data.\n');
	ufilt=-1;
	jdf=-1;
	return;
end;

	
ops={0,1,'pl'};
while length(varargin)>0
	dum=varargin{1};
	if ischar(dum)
		ops{3}=dum;
	elseif length(dum)==1
		ops{2}=dum;
	else
		ops{1}=dum;
	end;
	varargin(1)=[];
end;

%half the filter weights
if isequal(lower(ops{3}), 'osu')
	flen=60;
	pl33=[	
		0.000000E+00    0.224482E-05    0.101382E-04    0.269017E-04    0.552832E-04 ...
	    0.972726E-04    0.153843E-03    0.224728E-03    0.308265E-03    0.401287E-03 ...
	    0.499108E-03    0.595586E-03    0.683272E-03    0.753646E-03    0.797444E-03 ...
	    0.805050E-03    0.766951E-03    0.674250E-03    0.519196E-03    0.295727E-03 ...
	    0.000000E+00   -0.369122E-03   -0.809640E-03   -0.131607E-02   -0.187920E-02 ...
	   -0.248599E-02   -0.311952E-02   -0.375924E-02   -0.438118E-02   -0.495844E-02 ...
	   -0.546179E-02   -0.586035E-02   -0.612246E-02   -0.621655E-02   -0.611216E-02 ...
	   -0.578090E-02   -0.519754E-02   -0.434092E-02   -0.319491E-02   -0.174920E-02 ...
	    0.000000E+00    0.204941E-02    0.438837E-02    0.699864E-02    0.985452E-02 ...
	    0.129230E-01    0.161646E-01    0.195334E-01    0.229786E-01    0.264454E-01 ...
	    0.298760E-01    0.332112E-01    0.363914E-01    0.393586E-01    0.420574E-01 ...
	    0.444366E-01    0.464503E-01    0.480592E-01    0.492317E-01    0.499447E-01 ...
	    0.501840E-01 ]';
	
else
	flen=33;	
	pl33=[  
	  -0.00027 -0.00114 -0.00211 -0.00317 -0.00427 ...
	  -0.00537 -0.00641 -0.00735 -0.00811 -0.00864 ...
	  -0.00887 -0.00872 -0.00816 -0.00714 -0.00560 ...
	  -0.00355 -0.00097  0.00213  0.00574  0.00980 ...
	   0.01425  0.01902  0.02400  0.02911  0.03423 ...
	   0.03923  0.04399  0.04842  0.05237  0.05576 ...
	   0.05850  0.06051  0.06174  0.06215  ]';
end;

if fac<1
	plx=interp1(0:flen,pl33,0:fac:flen);
	pl33=plx(:);
	flen=round(flen/fac);
end;
	
% symmetric filter
pl33=[pl33; pl33(flen:-1:1)];
pl33=pl33/sum(pl33); %re-normalize the weights.

[m,n]=size(u);
if(min(m,n)==1),
	m=length(u);
	n=1;
	u=u(:);
end
if (m<length(pl33)),
	errordlg('data too short for this filter!','Error');
	ufilt=-1;
	jdf=-1;
	return
end
ufilt=zeros(m-2*flen,n);
jdf=ufilt(:,1);
for i=1:n,
	uf=conv(u(:,i),pl33);
	ufilt(:,i)=uf(2*flen +1 : length(uf)-2*flen);
end
[m,n]=size(ufilt);

if length(ops{1})>1,
	jdf=ops{1}(flen+1 : flen+m);
end
if ops{2}>1
	ufilt=ufilt([1:ops{2}:m],:);
	if any(jdf)
		jdf=jdf([1:ops{2}:m]);
	end;
end
varargout(1)={ufilt};
if nargout>1;
	varargout(2)={jdf};
end;

return;