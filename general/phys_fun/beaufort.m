function value_out = beaufort(value_in,unit)
%BEAUFORT   transform SI wind speeds and beaufort scale
%
%   wind_beaufort = beaufort(wind_mps)
%
% See also: http://en.wikipedia.org/wiki/Beaufort_scale

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl	
%
%       Deltares
%       Marine and coastal systems
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   -------------------------------------------------------------------

   value_out = value_in;
   value_out(                  value_in <= 0.3 ) =  0;
   value_out(value_in >  0.3 & value_in <= 1.5 ) =  1; 
   value_out(value_in >  1.5 & value_in <= 3.3 ) =  2; 
   value_out(value_in >  3.3 & value_in <= 5.5 ) =  3; 
   value_out(value_in >  5.5 & value_in <= 8.0 ) =  4; 
   value_out(value_in >  8.0 & value_in <= 10.8) =  5; 
   value_out(value_in > 10.8 & value_in <= 13.9) =  6; 
   value_out(value_in > 13.9 & value_in <= 17.2) =  7; 
   value_out(value_in > 17.2 & value_in <= 20.7) =  8; 
   value_out(value_in > 20.7 & value_in <= 24.5) =  9; 
   value_out(value_in > 24.5 & value_in <= 28.4) = 10;
   value_out(value_in > 28.4 & value_in <= 32.6) = 11;
   value_out(value_in > 32.6                   ) = 12;

%% EOF