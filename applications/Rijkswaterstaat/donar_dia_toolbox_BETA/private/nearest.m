function ind = nearest(x1,y1,x2,y2)

% 
% clc
% x1 = rand(1000,1000);
% y1 = rand(1000,1000);
% 
% x2 = rand(1000,1);
% y2 = rand(1000,1);
%


x1 = x1(:);
x2 = x2(:);

y1 = y1(:);
y2 = y2(:);

yi = nan(size(x2));
xi = nan(size(x2));
ind = nan(size(x2));
% tic
for i = 1:length(x2)
    d = sqrt((x1 - x2(i)).^2 + (y1 - y2(2)).^2);
    mind = min(d(:));
    imin = find(d==mind,1);
    ind(i) = imin;
    xi(i) = x1(imin);
    yi(i) = y1(imin);
    
    if mod(i,1000)==0, disp(['Iteration ',num2str(i),' out of ',num2str(length(x2))]),  end
end
% toc