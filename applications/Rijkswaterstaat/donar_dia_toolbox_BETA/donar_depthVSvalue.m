function [thefit] = donar_depthVSvalue(donarMat,variable,depth_threshold)
    
    % Load the donarMat structure
    if ischar(donarMat),         donarMat = importdata(files_of_interest{ifile});
    elseif ~isstruct(donarMat),  error('First argument shoulc be either the path to a donarmat file or a donar mat structure.')
    end
    
    % Find the variable in the file
    allfields = fields(donarMat);
    thefield = allfields(strcmpi(allfields,variable));
    if isempty(thefield)
        disp('Variable not found in file.')
        return;
    else
        thefield = thefield{1};
    end
    disp(['Looking for values of ',thefield]);
        
    
    [unique_campaigns,~,campaign_index] = unique(donarMat.(thefield).data(:,6));
    cont = 1;
    for icampaign = 1:1:length(unique_campaigns)
        
        y = donarMat.(thefield).data( campaign_index == icampaign,3 )/100;
        value = donarMat.(thefield).data( campaign_index == icampaign,5 );
        lon = mean(donarMat.(thefield).data( campaign_index == icampaign,1 ));
        lat = mean(donarMat.(thefield).data( campaign_index == icampaign,2 ));
        day = yearday(mean(   donarMat.(thefield).data( campaign_index == icampaign,4 )    ));
        
        if max(value) > depth_threshold
            temp = polyfit(log(y),log(value),2);
            
            thefit(cont,2) = temp(1);
            thefit(cont,3) = temp(2)/(-2*thefit(cont,2));
            thefit(cont,1) = exp(temp(3)-thefit(cont,2)*thefit(cont,3)^2);
            thefit(cont,4) = lon;
            thefit(cont,5) = lat;
            thefit(cont,6) = day;
            thefit(cont,7) = unique_campaigns(icampaign);
            
            cont =cont+1;
        end
        
        %plot(y,a*exp(b*(log(y)-c).^2),'b-',y,value,'.r')
    end
end