function varargout = P06(varargin);
%P061   read/search BODC P06 parameter vocabulary
%
%    L = P06()
%    L = P06('read',1)
%
%  P06(...) = P01('listReference','P061',...) wrapper
%
%See also: P01

varargout = {P01('listReference',mfilename,varargin{:})};
