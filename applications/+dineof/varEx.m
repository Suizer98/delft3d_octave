function [varex,labels] = varEx(fname,varargin)
%varEx read explained variances and formats them (or others)
%
% [varex,labels] = dineof.varEx(fname,<varex>)
%
% if you supply varex, it will overwrite
% the found varex, and update the labels.
%
%See also: dineof

if ~isempty(fname)
[labels]=textread(fname,'%s','whitespace','\n');
end
try
  if nargin==1
   [number,varex,~]=textread(fname,'Mode %d=%f %s');
  else
   varex = varargin{1};
  end
  for i=1:length(varex)
    labels{i} = ['Mode ',num2str(i,'%d'),' = ',num2str(varex(i),'%0.1f'),' %'];
  end
catch
  varex(1:length(labels)) = nan; % in case of ***
end
