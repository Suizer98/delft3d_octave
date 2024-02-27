function msg=dsprintf(varargin)
% dsprintf - shortcut for disp(sprintf(formatstr,arg1,arg2,..arg14))
%
%CALL
%  dsprintf(formatstr,arg1,arg2,..arg14)
%
%INPUT
%  formatstr        : format string (char array)
%  arg1,arg2,..arg14: 
%
%OUTPUT
% a string is displayed in the command window
%
%See also:
% SPRINTF, DISP, EPRINTF, DDPRINTF dprintfb
%

%Nanne van der Zijpp
%Modelit

%WIJZ ZIJPP NOV 2007: prepare future version 
%NOTE that ";" after dprintf will be required in future versions
% 
% WIJZ ZIJPP 20100929
%     output argument "msg" added
    
if nargout
    msg=sprintf(varargin{:});
    disp(msg)
else
    disp(sprintf(varargin{:}));
end

