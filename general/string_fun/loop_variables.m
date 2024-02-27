function varargout = loop_variables(varargin)
%LOOP_VARIABLES  create names for loop variables
%
%   loop_variables(n) creates n names for loop variables
%   such as a,b,c,...,x,y,z,aa,bb,cc,...,xx,yy,zz,aaa,bbb,ccc,...etc.
%
% Syntax:
%       loop_variables
%       loop_vars = loop_variables(n)
if length(varargin)>0
    if isnumeric(varargin{1})
        num = varargin{1};
    else
        error('Unknown input')
    end
    if length(varargin)>1
        warning('Only the first input variable is considered');
    end
else
    num = 260;
end

varargout{1} = [];
for ii = 1:ceil(max([1 num])/26)
    varargout{1} = [varargout{1}; cellstr(char(repmat(repmat('a',1,ii),26,1) + repmat([0:25]',1,ii)))];
end
varargout{1} = varargout{1}(1:num);

end