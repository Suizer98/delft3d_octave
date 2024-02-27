function phi = pea_simpson_et_al_1990_sigma(dsigma, eta, depth, rho, varargin)
%pea_simpson_et_al_1990_sigma  Potential energy anomaly phi by Simpson ea. '90
%
%   phi = pea_simpson_et_al_1990_sigma(dsigma, eta, depth, rho, <keyword,value>)
%
% Calculates the potential energy anomaly phi 
%
%                    z=surface
%                   /
%    phi = (g/H) * | (rho_depth_mean - rho) * z * dz    [J/m3]
%                 /
%               z=bottom
%
% using last dimension for rho as z, and calculating
% z and dz per location using sigma layer thicknesses dsigma,
% waterlevel eta (positive up) and depth (positive up).
% The last dimenion of rho should be positove up (use
% flipdium for delft3d, where k=1 is surface, hence positive down).
%
% as defined in:
%
% * Simpson, Brown, Matthews and Allen, 1990. Tidal straining,
%   density currents and stirring in the control of estuarine 
%   stratification, Estuaries, 13(2), 125-132. <a href="dx.doi.org/10.2307/1351581">DOI:10.2307/1351581</a>
% * F.C. Groenendijk, 1992. Distribution in time and space of fresh water
%   and suspended matter in the Dutch coastal zone. Directoraat-Generaal 
%   Rijkswaterstaat, Dienst Getijdewateren, 1992. <a href="http://books.google.com/books?id=SGAhGwAACAAJ">Google books</a>.
%
% z can be negative, this is dealt with in integral.
% Use optional <dim> when suppling matrices instead 
% of meshes. Use keyword 'weights' to supply the relative
% layer thicknesses in this case, which must be indentical 
% for all columns.
%
% See also: pea_simpson_et_al_1990, plume_depth_hetland_etal_2005, MEANWEIGHTED, D3D_SIGMA

   OPT.g       = 9.81;
   OPT.weights = [];
   
OPT = setproperty(OPT,varargin);

sz0 = size(rho);sz0 = sz0(1:end-1);
if  isvector(rho)
    rho = reshape(rho,[1 1 length(rho)]);
elseif  ndims(rho)==2
    rho = reshape(rho,[1 size(rho)]);
elseif ndims(rho)>3
    error('ndims(rho)>3 not implemented')
end
sz = size(rho);

if isscalar(eta)
    eta = repmat(eta,sz(1:2));
end

if isscalar(depth)
    depth = repmat(depth,sz(1:2));
end

phi = repmat(0,[sz(1:2) 1]);

for m=1:sz(1)
   for n=1:sz(2)
   
      h        = (eta(m,n) - depth(m,n));
      dz       = dsigma(:).*h;
      zcor     = [0;cumsum(dsigma(:))]*h + depth(m,n);
      zcen     = (zcor(1:end-1)+zcor(2:end))./2;
      rho1     = permute(rho(m,n,:),[2 3 1]);
      rhomean  = sum(rho1.*dsigma);
      rhoshear = rhomean - rho1;
      phi(m,n) = OPT.g.*sum(rhoshear(:).*zcen(:).*dz(:))./h;
         
   end
end

phi = reshape(phi,[sz0(:)' 1]);
