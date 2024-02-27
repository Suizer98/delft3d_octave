function p = mesh2d(x, y, varargin)
% p = mesh2d(x,y,'color','r')

col=[0 0 0];
tag=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
        end
    end
end

x1=zeros(size(x,1)+1,size(x,2)+1);
x1(x1==0)=NaN;
y1=x1;
x1(1:end-1,1:end-1)=x;
y1(1:end-1,1:end-1)=y;

x2a=reshape(x1,[1 size(x1,1)*size(x1,2)]);
y2a=reshape(y1,[1 size(x1,1)*size(x1,2)]);
x2b=reshape(x1',[1 size(x1,1)*size(x1,2)]);
y2b=reshape(y1',[1 size(x1,1)*size(x1,2)]);
x2=[x2a x2b];
y2=[y2a y2b];

p=plot(x2,y2,'k');
set(p,'Color',col);
if ~isempty(tag)
    set(p,'Tag',tag);
end

