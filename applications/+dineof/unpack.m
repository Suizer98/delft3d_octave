function Xm = unpack(X,mask);
%UNPACK   restore vector of active-only DINOEF points into full matrix
%
%   Xm = dineof.unpack(X,mask)
%
% where X    is stored in outputEof.lftvec
%       mask is defined in DINEOF.init by keyword mask
%
% !  This function is based on the dineof_unpack.m shipped with
% !  DINEOF from http://modb.oce.ulg.ac.be/mediawiki/index.php/DINEOF
%
%See also: dineof

n  = size(X,2);
Xm = zeros(size(mask,1),size(mask,2),n);

swap = 1;
try
  if getpref('SNCTOOLS','PRESERVE_FVD')==0;
     swap=0;
  end
end

if swap
   for k=1:n
     Xm(:,:,k) = unpackinsert(X(:,k),mask')';
   end
else
   for k=1:n
     Xm(:,:,k) = unpackinsert(X(:,k),mask')';
   end
end

function E = unpackinsert(U,mask);

E = double(mask);
E(find(mask==1)) = U;
E(find(mask==0)) = NaN;

