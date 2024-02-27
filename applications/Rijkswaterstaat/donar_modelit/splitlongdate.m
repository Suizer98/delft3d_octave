function [datum, time] = splitlongdate(longdate)
% Split one or more dates of the form yyyymmddHHMM into 
% date: yyyymmdd and time: HHMM.
% 
% CALL:
%  [datum, time] = splitlongdate(longdate)
% 
% INPUT:
%  longdate: Vector of integers of format YYYYMMDDHHMM.
% 
% OUTPUT:
%  datum: Vector of integers of format yyyymmdd.
%   time:  Vector of integers of format HHMM.
% 
% EXAMPLE:
%  [datum, time] = splitlongdate(200808141200)
% 
% See also: long2datenum, datenum, datestr, datenum2long

datum = floor(longdate/10000);
time = longdate - datum*10000;
