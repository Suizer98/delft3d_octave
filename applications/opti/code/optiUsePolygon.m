function this=optiUsePolygon(this,dataGroup)

% OPTIUSEPOLYGON - interpolates data to specified transects
% 
% Usage:
% 
%     optiStruct=optiUsePolygon(optiStruct,dataGroup)
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
if isempty(this.input(dataGroup).dataPolygon)
    error('Cannot interpolate; no transects specified in optiStruct!');
    return
end

[ldbCell, dum,dum,dum]=disassembleLdb(this.input(dataGroup).dataPolygon);
inpoly=[];
for ii=1:length(ldbCell)
    inpoly=[inpoly; find(inpolygon(this.input(dataGroup).coord(:,1),this.input(dataGroup).coord(:,2),ldbCell{ii}(:,1),ldbCell{ii}(:,2)))];
end

%For now, save original data&coordinates
this.input(dataGroup).origData=this.input(dataGroup).data;
this.input(dataGroup).origCoord=this.input(dataGroup).coord;

%Replace data with interpolated data in tempData
%X and Y dependent data can now be distinguished by comparing
%size(this.data,1) with size(this.dataTransect,3) instead of size(this.xCoord,1)
if xy==1
    this.input(dataGroup).data=this.input(dataGroup).data(inpoly,:);
elseif xy==2
    this.input(dataGroup).data=this.input(dataGroup).data([inpoly inpoly+size(this.input(dataGroup).coord(:,1),1)],:)
end

this.input(dataGroup).coord=this.input(dataGroup).coord(inpoly,:);
