function fig=MakeNewWindow(Name,sz,varargin)
%MAKENEWWINDOW No description

modal=0;
ico=[];
resize = 'on';

if ~isempty(varargin)
    % Modal or not
    ii=strmatch('modal',varargin,'exact');
    if ~isempty(ii)
        modal=1;
    end
    % Icon
    ii=strmatch('icon',lower(varargin),'exact');
    if ~isempty(ii)
        ico=varargin{ii+1};
    end
    % Resize
    ii=strmatch('resize',lower(varargin),'exact');
    if ~isempty(ii)
        resize=varargin{ii+1};
    end    
end

fig=figure;

if ~isempty(ico)
    fh = get(fig,'JavaFrame'); % Get Java Frame 
    fh.setFigureIcon(javax.swing.ImageIcon(ico));
end

set(fig,'menubar','none');
set(fig,'toolbar','none');
if modal
    set(fig,'windowstyle','modal');
end
set(fig,'Units','pixels');
set(fig,'Position',[0 0 sz(1) sz(2)]);
set(fig,'Name',Name,'NumberTitle','off');
set(fig,'Tag',Name);
set(fig,'Resize',resize);
PutInCentre(fig);
