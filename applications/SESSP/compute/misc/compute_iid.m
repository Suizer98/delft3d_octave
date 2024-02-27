function iid=compute_iid(x,z,maxdepth,xoff)

if size(x,1)>1
    % Make row vector
    x=x';
    z=z';
end

% if z(1)<z(end)
%     % vector must start at the shore
%     x=fliplr(x);
%     z=fliplr(z);
% end

dx1=x(2:end-1)-x(1:end-2);
dx2=x(3:end)-x(2:end-1);
dx0=0.5*(dx1+dx2);
dx=zeros(size(x));
dx(2:end-1)=dx0;
dx(1)=dx1(1);
dx(end)=dx2(end);
i1=find(z<0,1,'first');
i2=find(z>=maxdepth,1,'last');
if isempty(i2)
    i2=length(z);
end
x=x(i1:i2);
z=z(i1:i2);
dx=dx(i1:i2);

i1=find(x>=xoff,1,'first');
x=x(i1:end);
z=z(i1:end);
dx=dx(i1:end);

z=z*-1;
%z=max(z,0.001);

% z is now a water depth

% Do not include land points
%dx(z<0.1)=0;
dx(z<1.0)=0; % do not include very shallow water
%z(z<0.1)=1;
z=max(z,1.0);
%z=max(z,0.1);

iid=sum(dx./z);
