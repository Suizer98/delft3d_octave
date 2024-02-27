function varargout = XBRV_CB_Select(varargin)

varargout = {};

obj = hittest(varargin{1});
switch get(obj,'Type')
    case {'axes','line','surface'}
        XBRV_CB_ShowProperty(guidata(varargin{1}),obj);
    otherwise
        
end

