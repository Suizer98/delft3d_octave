function str = datenum2str(datum)
% Convert a Matlab datenum to a string with format: yyyymmddHHMM.
% 
% CALL:
%  str = datenum2str(datum)
% 
% INPUT:
%  datum: Matlab datenum represention of date.
% 
% OUTPUT:
%  str: String with date of form: yyyymmddHHMM.
% 
% EXAMPLE:
%  str = datenum2str(now)
% 
% See also: datestr, datenum, datenum2long

[datum,tijd] = datenum2long(datum);
datumstr = num2str(datum/10^8,'%0.8f');
tijdstr = num2str(tijd/10^4,'%0.4f');
str = [datumstr tijdstr];
str(:,[1 2 11 12]) = [];