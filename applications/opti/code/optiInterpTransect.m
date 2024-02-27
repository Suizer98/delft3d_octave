function this=optiInterpTransect(this,dataGroup)

% OPTIINTERPTRANSECT - interpolates data to specified transects
% 
% Usage:
% 
%     optiStruct=optiInterpTransect(optiStruct,dataGroup)
%     
% in which the interpolation method can be specified in optiStruct.optiSettings.transectInterpMethod
% This interpolation function should take (optiStruct,X,Y,Z,XL(1:2),YL(1:2)) as input. The resulting output array ZI, 
% is summed.
%

%Check if we have X-Y data
if size(this.input(dataGroup).data,1)>size(this.input(dataGroup).coord(:,1),1)
    xy=2;
elseif size(this.input(dataGroup).data,1)==size(this.input(dataGroup).coord(:,1),1)
    xy=1;
else
    error('Cannot interpolate; fewer optiStruct.data points than optiStruct.xCoord. Already interpolated?');
    return
end

%Peform checks
if isempty(this.input(dataGroup).dataTransect)
    error('Cannot interpolate; no transects specified in optiStruct!');
    return
end
hW=waitbar(0,'Interpolating transports, please wait...');
tempData=[];
for xx=1:xy
    
    for ii=1:size(this.input(dataGroup).dataTransect,3)
    
        for cc=1:size(this.input(dataGroup).data,2)
            %disp(['Interpolating transect ' num2str(ii) ' of ' num2str(size(this.input(dataGroup).dataTransect,3)) ' for condition ' num2str(cc) ' of ' num2str(size(this.input(dataGroup).data,2))]);
            eval(['tempData(ii+(xx-1)*size(this.input(dataGroup).dataTransect,3),cc)=' this.optiSettings.transectInterpMethod ...
                    '(this,this.input(dataGroup).coord(:,1),this.input(dataGroup).coord(:,2),this.input(dataGroup).data( (xx-1)*size(this.input(dataGroup).coord(:,1),1)+1:xx*size(this.input(dataGroup).coord(:,1),1) ,cc),'...
                    'this.input(dataGroup).dataTransect(1:2,1,ii),this.input(dataGroup).dataTransect(1:2,2,ii),dataGroup);']);
            waitbar(xx*ii*cc/(xy*size(this.input(dataGroup).dataTransect,3)*size(this.input(dataGroup).data,2)),hW);        
        end
    end
end
close(hW);
%For now, save original data
this.input(dataGroup).origData=this.input(dataGroup).data;

%Replace data with interpolated data in tempData
%X and Y dependent data can now be distinguished by comparing
%size(this.data,1) with size(this.dataTransect,3) instead of size(this.xCoord,1)
this.input(dataGroup).data=tempData;