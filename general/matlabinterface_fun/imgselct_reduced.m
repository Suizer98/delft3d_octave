function [X, Y] = imgselct_reduced
%IMGSLCT Select an area on an image
flag = 1;
k = 0;
ish = ishold;
hold on
while flag == 1
  [x,y] = ginput(1);
  if ~isempty(x)
    k = k+1;
    plot(x,y,'or','linewidth',2)
    if k == 1
      X = x;
      Y = y;
    else
      X = [X; x];
      Y = [Y; y];
      plot(X(k-1:k),Y(k-1:k),'-r','linewidth',2)
    end
  else
    flag = 0;
  end
end
X = [X; X(1)];
Y = [Y; Y(1)];
plot(X(k:k+1),Y(k:k+1),'-r','linewidth',2)