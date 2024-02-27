function [errorcode,varargout] = comnsize(varargin)
% COMNSIZE Check if all input arguments are either scalar or of common size.
%
% CALL:  [errorcode,y1,y2,...,yN] = comnsize(x1,x2,...,xN);
%
%  errorcode = 0 , if all xi are either scalar or of common size.
%              1 , if the non-scalar xi do not match in size.
%  y1,...,yN = Same as x1,...,xN, except that scalars are transformed to
%              a constant matrix with same size as the other inputs.
%  x1,...,xN = Input arguments.
%
%  COMNSIZE makes sure that the output arguments are of common size.
%  This is useful for implementing functions where arguments can either
%  be scalars or of common size. 
%
%  NOTE:  If the errorcode is 1, then yi = xi.
%
% Examples: 
%   A = rand(4,5);B = 2;C = rand(4,5);
%   [ec,A1,B1,C1] = comnsize(A,B,C);
%   ec2 = comnsize(A,1:2);

% Tested on: matlab 5.3
% History:
% revised pab 23.10.2000
%  - New name comnsize
%  - the input arguments can have a any dimension.
%  - Updated documentation
%  - Vectorized the calculations a bit more.
% Based on common_size.m by
%  KH <Kurt.Hornik@ci.tuwien.ac.at> Created: 15 October 1994


Np   = nargin;
Nout = max(nargout-1,0);
if Nout>Np, 
  error('The number of output arguments is too large.')
end

Ns =2;
sz = zeros(Np,Ns);
for ix = 1:Np,
  tmp = size (varargin{ix});
  Nt=length(tmp);
  if Nt>Ns,sz=[sz,ones(Np,Nt-Ns)];Ns=Nt; end % Add singleton dimensions
  sz(ix,1:Nt)=tmp;
end

csiz     = max(sz,[],1);        % find common size

% Check that non-scalar arguments match in size
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
errorcode = (any (any ((sz ~= 1)') & any ((sz ~= csiz(ones(Np, 1),:))')));

if Nout==0,return;end

isscalar = (prod(sz,2)==1)'; % find  mask to scalars
isscalar2 = isscalar(1:Nout); % Mask to those in output 
ind  = find(isscalar2);  % indices to scalar arguments
if (errorcode|all(isscalar)|isempty(ind)),
  varargout(1:Nout) = varargin(1:Nout);
else  
  ind0 = find(~isscalar2); % indices to non-scalar arguments
  if any(ind0),
    varargout(ind0) = varargin(ind0);
  end
  % Make sure the scalar arguments are of size csiz
  for ix = ind,
    varargout{ix} = varargin{ix}(ones(csiz));
  end
end
return














