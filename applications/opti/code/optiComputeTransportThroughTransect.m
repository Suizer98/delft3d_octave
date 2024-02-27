function tt=optiComputeTransportThroughTransect(tt,dataGroup)

% OPTICOMPUTECROSSTRANSECTTRANSPORT - computes cross/parallel transect transports from X/Y components in optiStruct
% 
% Usage:
% 
%     transport=optiComputeCrossTransectTransport(optiStruct,dataGroup)
%     
% in which:
% 
% transport = [Nx2] array with cross and parallel transports over the N transects

data=tt.input(dataGroup).data;

for cond=1:size(data,2)
    trData=reshape(data(:,cond),length(data(:,cond))/2,2);
    
    for ii=1:size(tt.input(dataGroup).dataTransect,3)
        
        phi=mod(atan2(diff(tt.input(dataGroup).dataTransect(:,2,ii)),diff(tt.input(dataGroup).dataTransect(:,1,ii))),2*pi);
        rot = [cos(phi) -sin(phi); sin(phi) cos(phi)];
        
        trans(ii,:)=round((trData(ii,:)*rot).*(3600.*24.*365));
        disp(['Transport cross transect: ' num2str(trans(ii,2)) ' m^3/year']);
        %         disp(['Transport along transect: ' num2str(trans(ii,1)) ' m^3/year']);
        %         disp(['Transport magnitude: ' num2str(sqrt(sum(trans(ii,:).^2))) ' m^3/year']);
    end
    newData(:,cond)=trans(:,2);
end

% new feature: use gross transport data instead of nett rates
% add extra fields with gross and nett transport data
transPos=newData;
transPos(transPos<0)=0;

transNeg=newData;
transNeg(transNeg>0)=0;

tt.input(dataGroup).nettData=[newData];
tt.input(dataGroup).grossData=[transPos ; transNeg];

% check for existence of transportMode field (backward compatible)
if isfield(tt.input(dataGroup),'transportMode')&&~isempty(tt.input(dataGroup).transportMode)
    switch tt.input(dataGroup).transportMode
        case 'nett'
            tt.input(dataGroup).data=tt.input(dataGroup).nettData;
        case 'gross'
            tt.input(dataGroup).data=tt.input(dataGroup).grossData;
    end
else
    tt.input(dataGroup).data=tt.input(dataGroup).nettData;
    tt.input(dataGroup).transportMode='nett';
end