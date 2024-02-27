function hg=fastscatter(x,y,z,varargin)

marker='.';
markersize=10;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'marker'}
                marker=varargin{ii+1};
            case{'markersize'}
                markersize=varargin{ii+1};            
        end
    end
end

if size(x,1)>1
    x=x';
    y=y';
    z=z';
end

hg=hggroup;

xn=x(isnan(z));
yn=y(isnan(z));

x=[x;x];
y=[y;y];
z=[z;z];

p1=patch(x,y,z);
set(p1,'EdgeColor','flat');
set(p1,'LineStyle','none');
set(p1,'Marker',marker,'MarkerSize',markersize);

xn=[xn;xn];
yn=[yn;yn];
p2=patch(xn,yn,'r');
% set(p2,'EdgeColor','r');
set(p2,'LineStyle','none');
set(p2,'Marker',marker,'MarkerSize',markersize,'MarkerEdgeColor','r');

set(p1,'Parent',hg);
set(p2,'Parent',hg);

