function intdiv = div(x,y)
%DIV   Number of times y fits into x
%
%   DIV(x,y) floor(x./y) if y < 0.
%            ceil (x./y) if y > 0.
% - Number of times y fits into x.
% - Limits x to largets integer multiple of y 
%
% Note that rem  = mod in fortran
%           mod ~= mod in fortran
%
%See also:  REM, MOD, REMCOUNT, DIVCOUNT

%  if x>=0
%   intdiv = floor(x./y);
%  elseif x<0
%   intdiv = ceil(x./y);
%  end

   % SAME AS
     intdiv = sign(x).*sign(y).*floor(abs(x./y));
  
%% EOF