function [Date, Time, LongTime] = datenum2long(D, timeunit)
% Convert Matlab datenum to date with format yyyymmdd, 
% time with format HHmm and time with format HHMMSS.
%
% CALL:
%  [Date, Time, LongTime] = datenum2long(D, timeunit)
%
% INPUT:
%  D: Scalar, vector or matrix with datenum data.
%  timeunit: Optional argument with possible values:
%            - 'mnd': Donar uses different format for months.
%            - otherwise: Use standard Donar date format.
% 
% OUTPUT:
%  Date:     Corresponding date(s) in yyyymmdd.
%  Time:     Corresponding time(s) in HHMM.
%  LongTime: Corresponding time(s) in HHMMSS.
%
% EXAMPLE:
%  [Date, Time] = datenum2long(now)
% 
% APPROACH:
%  Round D to whole minutes:
%  - Add 30 seconds to D and call datevec.
%  - Ignore 'second' output argument.
% 
% NOTE:
%  .m source of this function is used in mwritedia.c.
% 
% See also: long2datenum

%Opgenomen als onderdeel Melissa GUI getijspecials
%tbv exporteren NE reeksen

%April 2001
%auteur       : N.J. van der Zijpp
%firma        : MobiData
%datum        : April 2000
%project      : exporteren NE reeksen
%Matlab versie: 6.1


if nargin==0
   %test of hele minuten niet door afronding afronding fout worden weergegeven
   N=1440*365*2000;
   tv=(N:(N+1440*365*.1))/1440;
   tv=round(1440*tv)/1440;
   [y,m,d,h,mi,s]=datevec(tv);
   disp(max(s));
   disp(min(s));
   %test of 10.59.99 als 11.00 i.p.v. 10.60 wordt weergegeven
   n=datenum(2000,1,1,10,59,5999);
   [dt,tm]=datenum2long(n);
   disp(dt)
   disp(tm)
else   
   if nargout<3
       %pas afronding op hele minuut toe
       [y,m,d,h,mi,s]=datevec(D+1/2880); %tel 30 sec op bij tijd
       if nargin<2 |~strcmp(timeunit,'mnd')
           Date=10000*y+100*m+d;
           Time=floor(100*h+mi+s/60); %time in minutes
       else
           %Let op! In DONAR wordt bij tijdstap == maand  een alternatieve opslagwijze gebruikt!
           %YYYYMM
           Date=100*y+m;
           Time=0*y; %time in minutes
       end    
   else
      [y,m,d,h,mi,s]=datevec(D); 
      if nargin<2 |~strcmp(timeunit,'mnd')
          Date=10000*y+100*m+d;
          Time=[];
          LongTime=round(10000*h+100*mi+s);
      else
          %Let op! In DONAR wordt bij tijdstap == maand  een alternatieve opslagwijze gebruikt!
          %YYYYMM
          Date=100*y+m;
          Time=0*y; %time in minutes
          LongTime=0*y;
      end    
   end
   
end
