      function icom = nesthd_det_icom (X,default,varargin)

      % det_icom: determines which point is active(1) or inactive (0) based only on comp grid or on grid enclosure
      %
      %
      %
      % See also: nesthd nesthd1


      %
      % Determine the icom array which states whether a point is active(1), inactive(0) oran open boundary (2)
      %

      mmax = size(X,1) + 1;
      nmax = size(X,2) + 1;
      X(X==default) = NaN;

      icom (1:size(X,1) + 1, 1:size(X,2) + 1) = 0;

      if isempty(varargin) || isempty (varargin{1})

         %
         % Don't use the enclosure
         %

         for m = 2: mmax - 1
            for n = 2: nmax - 1
               if ~isnan (X(m  ,n  )) && ~isnan(X(m-1,n  )) && ...
                  ~isnan (X(m-1,n-1)) && ~isnan(X(m  ,n-1))
                  icom(m,n) = 1;
               end
            end
         end
      else

         %
         % Use the enclosure
         %

         for n = 1: nmax
            X(1:mmax,n) = (1:1:mmax);
         end
         for m = 1: mmax
            Y(m,1:nmax) = (1:1:nmax);
         end

         MN = enclosure('read',varargin{1});

         i_start = 1;

         while i_start < size(MN,1)

            j=find(MN(:,1)==MN(i_start,1) & MN(:,2)==MN(i_start,2));
            i_stop=j(j>i_start);

            [icom_h,Bnd] =  inpolygon(X,Y,MN(i_start:i_stop,1),MN(i_start:i_stop,2));

            %
            % Exclude the boundary points
            %

            icom_h = icom_h - Bnd;

            for m = 1: mmax
               for n = 1: nmax

                  %
                  % If inside, change from acive to non-ative or vice versa
                  %

                  if icom_h(m,n)
                     icom(m,n) = ~ icom(m,n);
                  end

                  %
                  % Inner enclosure: INCLUDE the boundary points
                  %

                  if icom(m,n) == 1 && Bnd(m,n) == 1
                     icom  (m,n) = false;
                  end
               end
            end

            i_start = i_stop + 1;

         end
      end
