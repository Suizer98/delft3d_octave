function [c,v] = classify2unique(x,varargin) 
%CLASSIFY2UNIQUE  make matrix with indexes into vector with unique values
%
% [C,V] = classify2unique(X) where X is a matrix, C is
% an integer matrix with 1-based matlab pointers into the 
% sorted vector V that contains the unique values of X such 
% that: X(X==V(i))==V(i) for i=1:length(V). 
% NaN values in X get index 0, but can be set with keyword 'nanval'
% [C,V] = classify2unique(x,<keyword,value>). V is sorted, so
% the value for nan determines where it ends up in V (start or end).
% Use '-Inf' or 'Inf' to ensure leading or trailing position for NaN.
%
% Example: plotting fields of unique datenum values
% as returned by nc_cf_gridset_getData, incl. NaNs:
%
%   [x,y,z]=peaks;z(z<0)=nan; % make some NaNs
%   [t,v] = classify2unique(roundoff(z,0)+now);
%   nv = length(v);
%   pcolor(x,y,t)
%
%   caxis   ([0.5 nv+0.5])
%   vmap = jet(nv);vmap(1,:) = [.5 .5 .5]; % account for NaN-color
%   colormap(vmap);
%   [ax,c1] =  colorbarwithtitle('',1:nv+1);
%   vstr = datestr(v,29);vstr(1,:) = ' ';  % account for NaN-label
%   set(ax,'yticklabel',vstr)
%
%See also: unique, hist

   OPT.nanval = 0;
   
   OPT = setproperty(OPT,varargin);
   
   m = ~isnan(x);
   v  = unique(x(find(m)));
   
   if any(~m(:))
       v = sort([OPT.nanval v(:)']);
   end
   nv = length(v);

   c = repmat(OPT.nanval,size(x));
   for iv=1:nv
       mask = (x==v(iv));
       c(mask)=iv;
   end
