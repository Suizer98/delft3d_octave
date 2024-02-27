function taxis = long2datenum(taxisdatum, taxistime, timeunit)
% Convert two Longs with date with format yyyymmdd and time 
% with format HHMM to Matlab datenum format.
%
% CALL:
%  taxis = long2datenum(taxisdatum, taxistime, timeunit)
%
% INPUT:
%  taxisdate: Vector of Long with format yyyymmdd.
%  taxistime: Vector of Long with format HHMM.
%  timeunit: 
%
% OUTPUT:
%  taxis: Vector with corresponding values in Matlab datenum format.
%
% APPROACH:
%  Using the Matlab 'rem' en 'round' operators Year, Month, Day, Hour and 
%  minute are extracted, followed by a call to datenum to get the Matlab 
%  datenum format of the specified dates.
% 
% EXAMPLE:
%  taxis = long2datenum('20110327','1135');
%  datestr(taxis)
% 
% See also: datenum2long

%WIJZ KJH 20070214 aanpassing ivm maand tijdstap

if nargin<3|~strcmp(timeunit,'mnd')
    dag=round(100*rem(taxisdatum/100,1));
    taxisdatum=floor(taxisdatum/100);
    maand=round(100*rem(taxisdatum/100,1));
    jaar=floor(taxisdatum/100);
    minuut=round(100*rem(taxistime/100,1));
    uur=floor(taxistime/100);
else  
%     dag=1*ones(size(taxisdatum));
%     maand=round(100*rem(taxisdatum/100,1));
%     jaar=floor(taxisdatum/100);
    
    dag=1*ones(size(taxisdatum));
    taxisdatum=floor(taxisdatum/100);
    maand=round(100*rem(taxisdatum/100,1));
    jaar=floor(taxisdatum/100);
    
    minuut=0*taxistime;
    uur=0*taxistime;
end

taxis=datenum(jaar,maand,dag,uur,minuut,0);
