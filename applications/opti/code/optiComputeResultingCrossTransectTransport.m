function trans=optiComputeResultingCrossTransectTransport(tt,dataGroup,iteration)

% OPTICOMPUTECROSSTRANSECTTRANSPORT - computes cross/parallel transect transports from X/Y components in optiStruct
% 
% Usage:
% 
%     transport=optiComputeCrossTransectTransport(optiStruct,dataGroup)
%     
% in which:
% 
% transport = [Nx2] array with cross and parallel transports over the N transects

data=tt.input(dataGroup).data*tt.iteration(iteration).weights';
trData=reshape(data,length(data)/2,2);

for ii=1:size(tt.input(dataGroup).dataTransect,3)
    
    phi=mod(atan2(diff(tt.input(dataGroup).dataTransect(:,2,ii)),diff(tt.input(dataGroup).dataTransect(:,1,ii))),2*pi);
    rot = [cos(phi) -sin(phi); sin(phi) cos(phi)];
  
    trans(ii,:)=round((trData(ii,:)*rot).*(3600.*24.*365));
        disp(['Transport cross transect: ' num2str(trans(ii,2)) ' m^3/year']);
%         disp(['Transport along transect: ' num2str(trans(ii,1)) ' m^3/year']);
%         disp(['Transport magnitude: ' num2str(sqrt(sum(trans(ii,:).^2))) ' m^3/year']);
end

