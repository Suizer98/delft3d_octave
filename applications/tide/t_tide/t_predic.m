function [yout,centraltime]=t_predic(tim,varargin);
% T_PREDIC Tidal prediction
% YOUT=T_PREDIC(TIM,NAMES,FREQ,TIDECON) makes a tidal prediction
% using the output of T_TIDE at the specified times TIM in decimal 
% days (from DATENUM). Optional arguments can be specified using
% property/value pairs: 
%
%       YOUT=T_PREDIC(...,TIDECON,property,value,...)
%
% Available properties are:
%
%    In the simplest case, the tidal analysis was done without nodal
%    corrections, and thus neither will the prediction. If nodal 
%    corrections were used in the analysis, then it is likely we will
%    want to use them in the prediction too and these are computed 
%    using the latitude, if given. Set 'start time' to empty if
%    nodal corrections are NOT to be taken into account. By default
%    t_predic does take nodal corrections into account if only latitude 
%    is specified (because default 'start time' is 0).
%
%       'start time'     [year,month,day,hour,min,sec]
%                        - min,sec are optional OR decimal day (matlab 
%                        DATENUM scalar), When [], no nodal corrections are 
%                        used (default: 0, unlike t_tide).
%       'latitude'       decimal degrees (+north) (default: none).
%       'centraltime'    central time used in analysis, nan = automatic (default)
%                        No central time is used if 'start time' is empty.
%
%    If the original analysis was >18.6 years satellites are
%    not included and we force that here:
%
%     'anallength'      'nodal' (default)
%                       'full'  For >18.6 years.
%
%    The tidal prediction may be restricted to only some of the 
%    available constituents:
%
%     'synthesis'    0 - Use all selected constituents.  (default)
%                    scalar>0 - Use only those constituents with a SNR
%                               greater than that given (1 or 2 are
%                               good choices).
%
%
%  It is possible to call t_predic without using property names, in
%  which case the assumed calling sequence is
%
%    YOUT=T_PREDIC(TIM,NAMES,FREQ,TIDECON,LATITUDE,SYNTHESIS);
%
%  T_PREDIC can be called using the tidal structure available as an 
%  optional output from T_TIDE
%
%    YOUT=T_PREDIC(TIM,TIDESTRUC,...)
%
%  This is in fact the recommended calling procedure (and required
%  when the analysis results are from series>18.6 years in length)
%
%    [YOUT,centraltime]=T_PREDIC(...) returns automatic central time used
%
%See also: t_tide

% R. Pawlowicz 11/8/99
% Version 1.0

%  8/2/03 - Added block processing to generate prediction (to
%           avoid memory overflows for long time series).
% 29/9/04 - small bug with undefined ltype fixed
% 25/7/12 - added stime to allow switching off nodal corrections

% Version 1.3
% $Id: t_predic.m 17584 2021-11-12 09:24:56Z chavarri $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tide/nc_t_tide
           
if nargin<2,  % Not enough
  error('Not enough input arguments');
end;

longseries=0;
ltype='nodal';

if isstruct(varargin{1}),
  names   = varargin{1}.name;
  freq    = varargin{1}.freq;
  tidecon = varargin{1}.tidecon;
  if isfield(varargin{1},'ltype') & strcmp(varargin{1}.ltyp(1:3),'ful'),
    longseries=1;
  end;  
  varargin(1)=[];
else
  if length(varargin)<3,
    error('Not enough input arguments');
  end;
  names   = varargin{1};
  freq    = varargin{2};
  tidecon = varargin{3};
  varargin(1:3)=[];
end;

lat   = [];
synth = 0;
stime = 0; % stime=[] would have meant that no nodal corrections are taken into account, but by default we want to, so we use stime=0
centraltime = nan;

k=1;
while length(varargin)>0,
  if ischar(varargin{1}),
    switch lower(varargin{1}(1:3)),
      case 'lat',
         lat=varargin{2};
      case 'syn',
         synth=varargin{2};
      case 'sta',
        stime=varargin{2};
      case 'cen',
         centraltime=varargin{2};
      case 'ana',
         if isstr(varargin{2}),
	   ltype=varargin{2};
	   if strcmp(varargin{2}(1:3),'ful'),
	      longseries=1;
	   end;   
	 end;  	 
      otherwise,
         error(['Can''t understand property:' varargin{1}]);
    end;
    varargin([1 2])=[]; 
  else
    switch k,
      case 1,
        lat=varargin{1};
      case 2,
        synth=varargin{1};
      otherwise
        error('Too many input parameters');
     end;
     varargin(1)=[];
  end;
  k=k+1;
end;

% Do the synthesis.        

snr=(tidecon(:,1)./tidecon(:,2)).^2;  % signal to noise ratio
if synth>0,
   I=snr>synth;
   if ~any(I),
     warning('No predictions with this SNR');
     yout=NaN+zeros(size(tim));
     return;
   end;  
   tidecon=tidecon(I,:);
   names=names(I,:);
   freq=freq(I);  
end;    

    
if size(tidecon,2)==4,  % Real time series
  ap=tidecon(:,1)/2.*exp(-i*tidecon(:,3)*pi/180);
  am=conj(ap);
else
  ap=(tidecon(:,1)+tidecon(:,3))/2.*exp( i*pi/180*(tidecon(:,5)-tidecon(:,7)));
  am=(tidecon(:,1)-tidecon(:,3))/2.*exp( i*pi/180*(tidecon(:,5)+tidecon(:,7)));
end;

% Mean at central point (get rid of one point at end to take mean of
% odd number of points if necessary).
if isnan(centraltime)
    if ~isempty(stime)
       centraltime=mean(tim(1:2*fix((length(tim)-1)/2)+1));
    else
       centraltime=[];
    end
end
%check consistency with t_tide's centraltime

if longseries,
%   const=t_get18consts;
  load('t_18constituents.mat','const')
  ju=zeros(size(freq));
  for k=1:size(names,1),
    inam=strmatch(names(k,:),const.name);
    if length(inam)==1,
      ju(k)=inam;
    elseif length(inam)>1,
      [minf,iminf]=min(abs(freq(k)-const.freq(inam)));
      ju(k)=inam(iminf);
    end;  
  end;  

else
  const=t_getconsts;
  ju=zeros(size(freq));

  % Check to make sure names and frequencies match expected values.

  for k=1:size(names,1),
    ju(k)=strmatch(names(k,:),const.name);
  end;
  %if any(freq~=const.freq(ju)),
  %  error('Frequencies do not match names in input');
  %end;
end;

% Get the astronical argument with or without nodal corrections.  
if ~isempty(lat) & ~isempty(centraltime),				  
  [v,u,f]=t_vuf(ltype,centraltime,ju,lat);				  
elseif ~isempty(centraltime), % keep consistent with t_tide variable dt implementation
  [v,u,f]=t_vuf(ltype,centraltime,ju);				  
else								  
   v=zeros(length(ju),1);					  
   u=v; 							  
   f=ones(length(ju),1);					  
end;								  


ap=ap.*f.*exp(+i*2*pi*(u+v));
am=am.*f.*exp(-i*2*pi*(u+v));

if ~isempty(centraltime)
tim=tim-centraltime;
end

[n,m]=size(tim);
tim=tim(:)';
ntim=length(tim);

nsub=10000; % longer than one year hourly.
for j1=1:nsub:ntim
  j2=min(j1 + nsub - 1,ntim);
  yout(j1:j2)=sum(exp( i*2*pi*freq*tim(j1:j2)*24).*ap(:,ones(1,j2-j1+1)),1)+ ...
              sum(exp(-i*2*pi*freq*tim(j1:j2)*24).*am(:,ones(1,j2-j1+1)),1);
end;
     
yout=reshape(yout,n,m);

  