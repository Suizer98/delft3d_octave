function eprintf(varargin)
% eprintf - shortcut for error(sprintf(formatstr,arg1,arg2,..arg14))
%
% CALL:
%  eprintf(formatstr,arg1,arg2,..arg14)
%
% INPUT:
%  formatstr        : format string (char array)
%  arg1,arg2,..arg14: 
%
% OUTPUT:
% a string is displayed in the command window
%
% See also: sprintf, disp, dsprintf

%Nanne van der Zijpp
%MobiData

error(sprintf(varargin{:}));