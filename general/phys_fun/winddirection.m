function [umag, udir] = winddirection(u10, v10)
% Simple fuction to calculate umag and udir based on u10 and v10
% Nederhoff     June-16
umag = (u10.^2 + v10.^2).^0.5;

% Direction
for ii = 1:length(u10);
    if u10(ii) <= 0 & v10(ii) <= 0;
        udir(ii) = abs(atand(u10(ii) / v10(ii)));
    elseif u10(ii) >=0 & v10(ii) >= 0
        udir(ii) = abs(atand(u10(ii) / v10(ii))) + 180;
    elseif u10(ii) >=0 & v10(ii) <=0 
        udir(ii) = abs(atand(v10(ii) / u10(ii))) + 270;
    else
        udir(ii) = abs(atand(v10(ii) / u10(ii))) + 90;
    end
end    

end

