function Icon=MakeIcon(file,sz,varargin)
%MAKEICON No description
nanval=1000;
if ~isempty(varargin)
    nanval=varargin{1};
end

a=imread(file);
[r,c,d] = size(a);
r_skip = ceil(r/sz);
c_skip = ceil(c/sz);
% Create the thinxthin icon (RGB data)
Icon = a(1:r_skip:end,1:c_skip:end,:);
Icon=double(Icon);
Icon=Icon/255;
SumIcon=sum(Icon,3)/3;
icor=Icon(:,:,1);
icog=Icon(:,:,2);
icob=Icon(:,:,3);
icor(SumIcon>nanval)=NaN;
icog(SumIcon>nanval)=NaN;
icob(SumIcon>nanval)=NaN;
Icon(:,:,1)=icor;
Icon(:,:,2)=icog;
Icon(:,:,3)=icob;

