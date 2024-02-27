function fy = filterwindow(y,window,iterations,nanhandle,method,direction)
% fy = filterwindow(y,window,iterations,nanhandle,method,direction)

if ~exist('iterations','var') || isempty(iterations)
    iterations = 1;
end
if ~exist('nanhandle','var') || isempty(nanhandle)
    nanhandle = 0;
end
if ~exist('method','var') || isempty(method)
    method = 'mean';
end
if ~exist('direction','var') || isempty(direction)
    direction = 'center';
end

[r,c]=size(y);

if r>c
    y=y';  % force into row vector
end


fy=zeros(size(y));
iw = floor(window/2);
switch direction
    case 'center'
        il = -iw;
        ir = +iw;
    case 'backwards'
        il = -2*iw;
        ir = 0;
    case 'forwards'
        il = 0;
        ir = 2*iw;
end
for j=1:iterations
    switch method
        case 'mean'
            if nanhandle==0
                for i=1:length(y)
                    fy(i)=mean(y(max(1,i+il):min(length(y),i+ir)));
                end
            else
                for i=1:length(y)
                    fy(i)=nanmean(y(max(1,i+il):min(length(y),i+ir)));
                end
            end
        case 'min'
            if nanhandle==0
                for i=1:length(y)
                    fy(i)=min(y(max(1,i+il):min(length(y),i+ir)));
                end
            else
                for i=1:length(y)
                    fy(i)=nanmin(y(max(1,i+il):min(length(y),i+ir)));
                end
            end
        case 'max'
            if nanhandle==0
                for i=1:length(y)
                    fy(i)=max(y(max(1,i+il):min(length(y),i+ir)));
                end
            else
                for i=1:length(y)
                    fy(i)=nanmax(y(max(1,i+il):min(length(y),i+ir)));
                end
            end            
        case 'var'
            if nanhandle==0
                for i=1:length(y)
                    fy(i)=var(y(max(1,i+il):min(length(y),i+ir)));
                end
            else
                for i=1:length(y)
                    fy(i)=nanvar(y(max(1,i+il):min(length(y),i+ir)));
                end
            end
        case 'std'
            if nanhandle==0
                for i=1:length(y)
                    fy(i)=std(y(max(1,i+il):min(length(y),i+ir)));
                end
            else
                for i=1:length(y)
                    fy(i)=nanstd(y(max(1,i+il):min(length(y),i+ir)));
                end
            end
    end
    y=fy;
end

if r>c
    fy=y';  % back to column
else
    fy=y;
end