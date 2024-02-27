      function [mn_bsp,mn_nes,weight_n,varargout] = nesthd_frombnd2pnt(bnd,mcnes,ncnes,weight,varargin)

      % frombnd2pnt: go from a boundary segement administration to a point (name based) administration

      mn_bsp.names = nesthd_convertmn2string(reshape(bnd.m',size(bnd.m,1)*2,1)       ,reshape(bnd.n',size(bnd.n,1)*2,1)       );
      
      for i_nes = 1: 4
          mn_nes (i_nes).names   = nesthd_convertmn2string(reshape(mcnes(:,:,i_nes)',size(bnd.m,1)*2,1),reshape(ncnes(:,:,i_nes)',size(bnd.m,1)*2,1));
          weight_n(i_nes).values = reshape (weight(:,:,i_nes)',size(bnd.m,1)*2,1);
      end

      % angles
      if nargin >= 5
         varargout{1} = reshape([varargin{1};varargin{1}],length(varargin{1})*2,1);
      end
      % orientation
      if nargin >= 6
         varargout{2} = reshape([varargin{2};varargin{2}],length(varargin{2})*2,1);
      end
