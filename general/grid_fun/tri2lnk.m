function [ lnk ] = tri2lnk( tri )
%TRI2LNK Converts triangles to link
%
%  Example 1: 
%  tri = [1 2 3;
%         2 3 4] 
%  [ lnk ] = tri2lnk( tri )
%
%  returns 
% 
%  lnk  = [1 2; 2 3; 3 1; 2 4; 3 4];
% 

N = size(tri,1);
lnk = zeros(3*N,2);
for k = 1:N; 
   lnk(3*(k-1)+1,[1:2]) = tri(k,[1,2]);
   lnk(3*(k-1)+2,[1:2]) = tri(k,[1,3]);
   lnk(3*(k-1)+3,[1:2]) = tri(k,[2,3]);
end
lnk = sortrows(sort(lnk')');
lnk = unique(lnk,'rows');
end


