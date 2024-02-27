function rc = checkRKS(RKS)
% Check validaty of RKS data
% 
% CALL:
%  rc = checkRKS(RKS)
%     
% INPUT:
%  RKS: structure with RKS data
% 
% OUTPUT:
%  rc: integer, possible values:
%       -0     : ok
%       -20001 : lBegdat not ok
%       -20002 : lEnddat not ok
%       -20003 : iBegtyd not ok
%       -20004 : iEndtyd not ok
%       -20005 : end before start

rc=0;
if isempty(RKS)
    return
end

if ~isvalidDate(RKS.lBegdat) 
    warning('RKS.lBegdat=%d ==> invalid date',RKS.lBegdat);
    rc=-20001;
    return
end
if ~isvalidDate(RKS.lEnddat)     
    warning('RKS.lEnddat=%d ==> invalid date',RKS.lEnddat);
    rc=-20002;
    return
end
if ~isvalidTime(RKS.iBegtyd) 
    warning('RKS.iBegtyd=%d ==> invalid time',RKS.iBegtyd);
    rc=-20003;
    return
end
if ~isvalidTime(RKS.iEndtyd) 
    warning('RKS.iEndtyd=%d ==> invalid time',RKS.iBegtyd);
    rc=-20004;
    return
end

if (RKS.lBegdat*10000+RKS.iBegtyd)>(RKS.lEnddat*10000+RKS.iEndtyd)
    warning('RKS: end date before begin');
    rc=-20005;
    return
end
%__________________________________________________________________________
function ok=isvalidDate(t)
%check if date is of format YYYYMMDD
ok=false;
yyyy=floor(t/10000);
if yyyy<1500 || yyyy>2300
    return
end
mmdd=rem(t,10000);
mm=floor(mmdd/100);
dd=rem(mmdd,100);
str2=datestr(datenum(yyyy,mm,dd),'yyyymmdd');
str1=sprintf('%d',t);
if ~strcmp(str1,str2)
    return
end
ok=true;    
%__________________________________________________________________________
function ok=isvalidTime(t)
%check if time is of format HHMM
ok=false;
hh=floor(t/100);
if hh<0 || hh>23
    return
end
mm=rem(t,100);
if mm<0|| mm>59
    return
end
ok=true;
