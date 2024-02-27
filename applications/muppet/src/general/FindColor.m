function Color=FindColor(varargin)

if nargin==1
    name=varargin{1};
    h=guidata(findobj('Name','Muppet'));
    for i=1:length(h.DefaultColors)
        Colors{i}=lower(h.DefaultColors(i).Name);
    end
    ii=strmatch(lower(name),Colors,'exact');
    if length(ii)>0
        Color=h.DefaultColors(ii).Val;
    else
        Color=name;
    end
else
    PlotOptions=varargin{1};
    Prop=varargin{2};
    DefaultColors=varargin{3};
    ifound=0;
    if isfield(PlotOptions,Prop);
        Color=getfield(PlotOptions,Prop);
        g=getfield(PlotOptions,Prop);
        if ischar(g)
            if ~strcmp(lower(Color),'none') & ~strcmp(lower(Color),'auto')
                for i=1:size(DefaultColors,2)
                    same=strcmp(lower(g),lower(DefaultColors(i).Name));
                    if same==1
                        Color=DefaultColors(i).Val;
                        ifound=1;
                    end
                end
                if ifound==0
                    warn=['Color ' g ' not found in default colors!']
                    Color=[0 0 0];
                end
            end
        end
    else
        Color=0;
    end
end
