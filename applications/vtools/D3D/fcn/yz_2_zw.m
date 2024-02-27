function [width, levels] = yz_to_zw(y,z)
    debug = false; 
    % Initialisation
    missing_low = -999999.999;
    missing_high = 999999.999;
    y2 = []; 
    z2 = []; 
    width = [];
    levels = unique(z); % get levels
   
    % add arbitrary high points at sides
    y = [y(1), y, y(end)]; 
    z = [missing_high, z, missing_high]; 

    %     
    for j = 1:(length(z)-1);
        yt = y(j:j+1);
        zt = z(j:j+1);
        if zt(1) < zt(2)
            levels_s = levels;
        else
            levels_s = fliplr(levels);
        end
        for level = levels_s;
            if zt(1) == zt(2); 
                yfound = max(yt); 
            else
                yfound = interp1(zt,yt,level); %,missing_low,missing_high)
            end    
            if ~isnan(yfound);
                y2 = [y2, yfound];
                z2 = [z2, level];
            end
        end
    end
    
    % Sort all entries 
    s2 = [0,cumsum(sqrt(diff(y2).^2 + diff(z2).^2))];
    [~, idx] = unique(s2);
    
    y2 = y2(idx); 
    z2 = z2(idx);
    
    % add arbitrary high points for loop below
    y2 = [y2(1),y2,y2(end)]; 
    z2 = [missing_high,z2,missing_high]; 
    
    % Now loop through the new y,z table to determine the width which is wet
    for level = levels;
        j = 1;
        k = 1;       
        w = 0;
        if debug
           disp(level)
           disp(':')
        end
        while (k < length(y2))
            if level < z2(j)
               % this point is under the bed level, move to next
               j = j + 1;
               k = k + 1;
            else
               % we have the left point, now find the right one
               if level < z2(k+1)
                   % we now found the next point below the bed level
                   % k is the right point
                   if debug
                     disp([j,k,y2(j),y2(k)])
                   end
                   w = w + y2(k) - y2(j); % increase width 
                   % initialise j and k again to find possible next wet section
                   k = k + 1;
                   j = k + 1;
               end
               k = k + 1;    
            end
        end
        width = [width,w]; 
    end
%         if debug:
%             print 
%     return width, levels