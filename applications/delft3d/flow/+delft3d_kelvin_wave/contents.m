%DELFT3D_KELVIN_WAVE - generating frictional kelvin wave boundaries for idealized rectangular models
%
% Elementary Toolbox for generating frictional kelvin wave 
% open boundaries by iterating an analytical solution, and sampling
% it on the specified open boundary segments. This approach
% works for the upstream boundary of rectangular grids. Due to
% linear friction in the analytical model, it does not work 
% for downstream boundaries fcor numerical models with quadratic
% friction (among which Delft3D).
%
% An example Delft3D input where this toolbox was used:
% https://svn.oss.deltares.nl/repos/openearthmodels/trunk/tudelft/delft3d_kelvinwave_rhine_rofi
%
% For documentation of the method please refer to:
%
% * Jacobs, Walter, 2004. Modelling the Rhine River Plume 
%   MSc. thesis, TU Delft, Civil Engineering.
%   http://resolver.tudelft.nl/uuid:cf8e752d-7ba7-4394-9a94-2b73e14f9949
% * De Boer, 2007. A note on Open Boundary Conditions (including Neumann) for
%   nested idealized coastal tidal models in Delft3D. 
%   Report 2007-1, TU Delft Environmental Fluid mechanics Section.
% * de Boer, G.J. 2009. On the interaction between tides and
%   stratification in the Rhine Region of Freshwater Influence
%   PhD thesis TU Delft, Civil Engineering (chapter 3).
%   http://resolver.tudelft.nl/uuid:c5c07865-be69-4db2-91e6-f675411a4136
%
% This rectangular Kelvin-wave model set-up was used in the following papers:
%
% * de Boer, G.J., Pietrzak, J.D., & Winterwerp, J.C. 2006. On the 
%   vertical structure of the Rhine region of freshwater influence
%   Ocean Dynamics, Vol. 56, 3-4, 198-216, special issue PECS 2004 
%   http://dx.doi.org/10.1007/s10236-005-0042-1
% * de Boer, G.J., Pietrzak, J.D., & Winterwerp, J.C. 2007. SST 
%   observations of upwelling induced by tidal straining in the Rhine ROFI, 
%   Continental Shelf Research, Vol. 29, 1, 263-277 
%   http://dx.doi.org/10.1016/j.ocemod.2007.12.003
% * de Boer, G.J., Pietrzak, J.D., & Winterwerp, J.C. 2008. Using the 
%   potential energy anomaly equation to investigate tidal straining 
%   and advection of stratification in a region of freshwater
%   influence, Ocean Modelling, Vol. 22, 1-2, 1-11 
%   http://dx.doi.org/10.1016/j.csr.2007.06.011
% * Elisabeth Fischer, Hans Burchard and Robert D. Hetland, 2009.
%   Numerical investigations of the turbulent kinetic energy 
%   dissipation rate in the Rhine region of freshwater influence,
%   Ocean Dynamics, 59, 629-641, 2009, special issue PECS 2008.
%   http://dx.doi.org/10.1007/s10236-009-0187-4
%
% main         - main function to generate harmonic kelvin wave OBC 
%
% input        - input: specification of kelvin wave properties
% boundaries   - input: specification of open boundary segments
% grids        - input: collection of orthogonal kelvin wave grids
% bch          - input: write delft3d boundary conditions for kelvin wave
%
% calculation  - actual analytical solution (iterative friction) of Kelvin wave
%
% ampphase     - quick-n-dirty visual assessment of results
% plot         - quick-n-dirty visual assessment of results
% tidalcycle   - quick-n-dirty visual assessment of results
%
%See also: delft3d
