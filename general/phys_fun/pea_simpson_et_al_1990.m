function phi = pea_simpson_et_al_1990(varargin)
%PEA_SIMPSON_ET_AL_1990  Potential energy anomaly phi by Simpson ea. '90
%
%   phi = pea_simpson_et_al_1990(z,rho,<dim>,<keyword,value>)
%
% Calculates the potential energy anomaly phi 
%
%                    z=surface
%                   /
%    phi = (g/H) * | (rho_depth_mean - rho) * z * dz    [J/m3]
%                 /
%               z=bottom
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
% See also: pea_simpson_et_al_1990_sigma, MEANWEIGHTED, D3D_SIGMA

   OPT.g       = 9.81;
   OPT.weights = [];
   
   rho  = varargin{2};
   
   if ~odd(nargin)
     dim = min(find(size(rho)~=1));
     if isempty(dim), dim = 1; end
     nextarg = 3;
   else
     dim = varargin{3};
     nextarg = 4;
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});
   
   if size(varargin{1},dim) == size(rho,dim);
     zcen = varargin{1};
     if isvector(zcen)
       zcor    = center2corner1(zcen);
     else
       zcor    = center2corner1(zcen,dim);
     end
   elseif size(varargin{1},dim) == size(rho,dim) +1;
     zcor = varargin{1};
     if isvector(zcor)
       zcen = corner2center1(zcor);
     else
       zcen = corner2center1(zcor,dim);
     end
   end
   dz     = (diff(zcor,[],dim));
   h      = abs(sum(dz,dim));
   
   if isvector(zcor)
      weights = dz;
   else
      weights = OPT.weights;
   end
   
  [rhomean,rhoshear] = meanweighted(rho,dim,weights);
   
   phi    = OPT.g.*sum        ((rhoshear).*zcen.*dz,dim)./h;
%  phi    = OPT.g.*trapz(zcen,( rhoshear).*zcen    ,dim)./h;

   