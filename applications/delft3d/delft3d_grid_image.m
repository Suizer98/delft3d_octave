function DELFT3D_GRID_IMAGE   
%ASCII image of Delft3D grid matrix
%
%        `--+---@---+---@---+---@---+---@---+---@---+---@        
%   n=5   ::::::|:::::::|:::::::|:::::::|:::::::|:::::::|        
%         ::x:::+:::x:::+:::x:::+:::x:::+:::x:::+:::x:::|        
%  - - -  ::::::|:::::::|:::::::|:::::::|:::::::|:::::::|        
%        `--+---o---+---o---+---o---+---o---+---o---+---@        
%   n=4   ::::::|       |       |       |       |:::::::|        
%         ::x:::+   x   +   x   +   x   +   x   +:::x:::|        
%  - - -  ::::::|       |       |       |       |:::::::|        
%        `--+---o---+---o---+---o---+---o---+---o---+---@        
%   n=3   ::::::|       |       |       |       |:::::::|        
%         ::x:::+   x   +   x   +   x   +   x   +:::x:::|        
%  - - -  ::::::|       |       |       |       |:::::::|        
%        `--+---o---+---o---+---o---+---o---+---o---+---@        
%   n=2   ::::::|       |       |       |       |:::::::|        
%         ::x:::+   x   +   x   +   x   +   x   +:::x:::|        
%  - - -  ::::::|       |       |       |       |:::::::|        
%        `--+---o---+---o---+---o---+---o---+---o---+---@        
%   n=1   ::::::|:::::::|:::::::|:::::::|:::::::|:::::::|        
%         ::x:::+:::x:::+:::x:::+:::x:::+:::x:::+:::x:::|        
%  - - -  ::::::|:::::::|:::::::|:::::::|:::::::|:::::::|        
%        `      `       `       `       `       `       `      
%         .       .       .       .       .       .       .      
%         .  m=1  .  m=2  .  m=3  .  m=4  .  m=5  .  m=6  .      
%         .       .       .       .       .       .       .      
%                                                                
%   LEGEND:                                                      
%                                                                
%    o          corner point                                  
%                                                                
%    @          corner point that does not need a depth       
%                                                                
%    `          this corner point is not present              
%                                                                
%    x          center point                                     
%                                                                
%    |                                                            
%    +          u velocity point                            
%    |                                                            
%                                                                
%   -+-         v velocity point                            
%                                                                
%   ::::        inactive/dummy area of grid                      
%                                                                
%   o---+---o                                                    
%   |       |                                                    
%   +       +   control volume                                   
%   |       |                                                    
%   o---+---o                                                    
%                                                                
%       +---o   center /corner/ velocity                          
%           |   points with same matrix indices                  
%       x   +                                         
%
% Grid definition sizes:
%
%   4 x 3 grid of active volumes requires a 
%   5 x 4 grid of active corner points, and a 
%   6 x 5 active numerical grid which has
%   5 x 3 active u velocity points
%   4 x 4 active v velocity points
           
help delft3d_grid_image

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_grid_image.m 9944 2014-01-06 23:06:38Z boer_g $
% $Date: 2014-01-07 07:06:38 +0800 (Tue, 07 Jan 2014) $
% $Author: boer_g $
% $Revision: 9944 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_grid_image.m $

