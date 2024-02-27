function d0=pathAngle(x0,y0,varargin)

opt='projected';

for i=1:length(varargin)
    if ischar(varargin{i})
        if strcmpi(varargin{i},'geographic')
            opt='geographic';
        end
    end
end

d0=repmat(NaN,size(x0));

% iprev is first node that's not nan
for i=1:length(x0)-1
    if  isnan(x0(i)) || isnan(y0(i)) || isnan(x0(i+1)) || isnan(y0(i+1))
        d0(i)=NaN;
    else
        dx=x0(i+1)-x0(i);
        dy=y0(i+1)-y0(i);
        if strcmpi(opt,'geographic')
            dx=dx*111111*cos(pi*0.5*(y0(i)+y0(i+1))/180);
            dy=dy*111111;
        end
        d0(i)=atan2(dy,dx);
    end
end
