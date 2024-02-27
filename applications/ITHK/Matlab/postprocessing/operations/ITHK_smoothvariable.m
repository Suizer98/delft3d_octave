function [VARsmoothed]=ITHK_smoothvariable(VAR,smoothingsteps)
% function [VARsmoothed]=ITHK_smoothvariable(VAR,smoothingsteps)
%
% INPUT:
%       VAR               Variable
%       smoothingsteps    Number of smoothing steps
%

if nargin<2
    smoothingsteps=100;
end

%% rotate (if necessary)
rotatevar=0;
if size(VAR,2)>size(VAR,1)
    VAR=VAR';rotatevar=1;
end

%% perform smoothing by avereging neighbouring cells n-times
A = {VAR};
for ii=1:smoothingsteps
    B=[(A{ii}(1:end-1)+A{ii}(2:end))/2];
    A{ii+1}=[(A{ii}(1)+B(1))/2;(B(1:end-1)+B(2:end))/2;(A{ii}(end)+B(end))/2];
end
VARsmoothed=A{smoothingsteps+1};

%% rotate back (if necessary)
if rotatevar==1;
    VARsmoothed=VARsmoothed';
end

% figure;
% nn=[1,2,3,6,20,100];
% colour={'b','r','g','m','c','y'};
% plot(alpha,'k.-');hold on;
% for ii=1:length(nn);
%     plot(A{nn(ii)}',[colour{ii},'.-']);
% end