function this=optiReadTransect(this,dataGroup,fName)

%OPTIREADTRANSECT - reads transects from LDB in optiStruct for use in transports
%
% Usage:
% 
%   optiStruct=optiReadTransect(optiStruct,filename,dataGroup)
%
% in which:
%  filename =   landboundary filename with 2-point transects separated by
%               999.999's
%
%

if nargin==2|~exist(fName,'file')
    [name,pat]=uigetfile({'*.ldb;*.pol', 'transects files (*.ldb, *.pol)'},'Select file with transects');
    if name==0
        return
    end
    fName=[pat name];
end

[lx,ly]=landboundary('read',fName);

%remove leading and trailing nans
while isnan(lx(1))
    lx=lx(2:end);
    ly=ly(2:end);
end
while isnan(lx(end))
    lx=lx(1:end-1);
    ly=ly(1:end-1);
end

%Add one to beginning and end
lx=[nan ; lx ; nan];
ly=[nan ; ly ; nan];
id=find(isnan(lx));

for ii=1:length(id)-1
    this.input(dataGroup).dataTransect(:,:,ii)=[lx(id(ii)+1) ly(id(ii)+1);lx(id(ii)+2) ly(id(ii)+2)];
end


    