function [Xnew,Ynew] = polygon_linear(X,Y,distancereq)
% Simple function to refine polylines
Xnew = X(1); Ynew = Y(1);
for ii = 1:length(X)-1
    distance(ii) = ((X(ii+1) - X(ii)).^2 + (Y(ii+1) - Y(ii)).^2).^0.5;
    if distance(ii) > 0
        if distance(ii) < distancereq
            Xnew = [Xnew X(ii)];
            Ynew = [Ynew Y(ii)];
        else
            ratio = ceil(distance(ii)/distancereq);
            distanceTMP = distance(ii)/ratio;
            Xnews = linspace(X(ii), X(ii+1), ratio+1);
            Ynews = linspace(Y(ii), Y(ii+1), ratio+1);
            Xnew = [Xnew Xnews(2:end)];
            Ynew = [Ynew Ynews(2:end)];
        end
    else
    end
end
end

