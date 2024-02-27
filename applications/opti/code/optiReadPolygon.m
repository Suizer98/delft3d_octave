function this=optiReadPolygon(this,dataGroup,fName)

%OPTIREADPOLYGON - reads polygon from POL-file in optiStruct. Only data points 
% within polygon(s) will be used in opti
%
% Usage:
% 
%   optiStruct=optiReadPolygon(optiStruct,dataGroup,filename)
%
% in which:
%  filename =   polygon filename
%
%

if nargin==2|~exist(fName,'file')
    [name,pat]=uigetfile('*.pol','Select landboundary file with transects');
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
this.input(dataGroup).dataPolygon=[lx ly];
