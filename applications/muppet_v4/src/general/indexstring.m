function v=indexstring(opt,varargin)

switch lower(opt)
    case{'read'}
        str=varargin{1};
        v=str2double(str);
    case{'write'}
        val=varargin{1};
        v=num2str(val);
end
