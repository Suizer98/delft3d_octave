function [u10, v10] = winddirection_inverse(umag, udir)
% Simple fuction to calculate u10 and v10 based on umag and udir
% Nederhoff     July-16 

for ii =1:length(umag);
    
    % Calculate
    u10(ii) = sind(udir(ii))*umag(ii);
    v10(ii) = cosd(udir(ii))*umag(ii);
    
    % Change sign
    if udir(ii) >= 0 & udir(ii) <= 90
        u10(ii) = abs(u10(ii))*-1;
        v10(ii) = abs(v10(ii))*-1;
    elseif udir(ii) >= 90 & udir(ii) <= 180
        u10(ii) = abs(u10(ii))*-1;
        v10(ii) = abs(v10(ii));
    elseif udir(ii) >= 180 & udir(ii) <= 270
        u10(ii) = abs(u10(ii));
        v10(ii) = abs(v10(ii));
    elseif udir(ii) >= 270 & udir(ii) <= 360
        u10(ii) = abs(u10(ii));
        v10(ii) = abs(v10(ii))*-1;
    end

end



end

