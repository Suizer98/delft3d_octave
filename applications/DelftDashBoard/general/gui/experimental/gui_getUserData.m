function h=gui_getUserData(varargin)
figh=gcf;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'tag'}
                tag=varargin{ii+1};
                figh=findobj('Tag',tag);
            case{'handle'}
                figh=varargin{ii+1};
        end
    end
end
h=get(figh,'UserData');

