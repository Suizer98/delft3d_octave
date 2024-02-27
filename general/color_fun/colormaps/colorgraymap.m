function C = colorgraymap(catalog,varargin)
%COLORGRAYMAP   set of colormaps that appears as linear grayscale on black/white printer
%
%    C = colorgraymap(catalog)
%    C = colorgraymap(catalog,n)
%
% returns a colormap with colors that appears as a linear grayscale 
% colormap on a black-and-white printer with n values (default 64)
%
% 'wbrk' 
% 'wgrk' 
% 'wpgk' 
% 'wpbgk'
% 'wypbk'
% 'wygbk'
% 'wyrk' 
% 'wmrk' 
% 'wcbk' 
% 'wmbk' 
% 'wcgk' 
% 'wygk' 
%
% C = colorgraymap(catalog,n,1) plots a sample image to test a colormap
% C = colorgraymap('all',n,1)   plots sample images for all available colormap
%
%See also: COLORMAPEDITOR, COLORMAP, COLORMAPGRAY, CMRMAP

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------- 

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id: colorgraymap.m 685 2009-07-15 08:12:55Z boer_g $
% $Date: 2009-07-15 16:12:55 +0800 (Wed, 15 Jul 2009) $
% $Author: boer_g $
% $Revision: 685 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/colorgraymap.m $
% $Keywords: $

%% code   

if nargin >2
   OPT.plot = 1;
else
   OPT.plot = 0;
end

if nargin >1
   n = varargin{1};
else
   n = 64;
end

%% Catalogue selection

if strcmp(catalog,'all') & OPT.plot==1

   catalogs = {'wbrk' ,...
               'wgrk' ,...
               'wpgk' ,...
               'wpbgk',...
               'wypbk',...
               'wygbk',...
               'wyrk' ,...
               'wmrk' ,...
               'wcbk' ,...
               'wmbk' ,...
               'wcgk' ,...
               'wygk' }
   
else
 
   catalogs = {catalog};

end

%% Catalogue data
for i=1:length(catalogs)

   catalog = char(catalogs{i});

   switch lower(catalog)
   
   case 'wbrk'
   
        C0 = [0.0  0.0 0.0  ;
              0.5  0.0 0.0  ;
              1.0  0.0 0.0  ;
              0.75 0.0 0.75 ;
              0.5  0.5 1    ;
              0.5  1   1    ; 
              1    1   1    ];
        
   case 'wgrk'
   
        C0 = [0.0  0.0   0.0 ;
              0.5  0.0   0.0 ;
              1.0  0.0   0.0 ;
              0.75 0.75  0.0 ;
              0.5  1     0.5 ;
              0.5  1     1   ; 
              1    1     1   ];  
              
              
   case 'wpgk'
   
        C0 = [0.0  0.0  0.0 ;
              0.0  0.5  0.0 ;
              0.0  1.0  0.0 ;
              0.75 0.75 0.0 ;
              1    0.5  0.5 ;
              1    0.5  1   ; 
              1    1    1   ];
   
   case 'wpbgk'
   
        C0 = [0.0 0.0  0.0  ;
              0.0 0.5  0.0  ;
              0.0 1.0  0.0  ;
              0.0 0.75 0.75 ;
              0.5 0.5  1    ;
              1   0.5  1    ; 
              1   1    1    ];
              
   case 'wypbk'
   
        C0 = [0.0  0.0  0.0 ;
              0.0  0.0  0.5 ;
              0.0  0.0  1.0 ;
              0.75 0.0  0.75;
              1    0.5  0.5 ;
              1    1    0.5 ; 
              1    1    1   ];
   
   case 'wygbk'
   
        C0 = [0.0  0.0  0.0 ;
              0.0  0.0  0.5 ;
              0.0  0.0  1.0 ;
              0.0  0.75 0.75;
              0.5  1    0.5 ;
              1    1    0.5 ; 
              1    1    1   ];
            
   % as white requires full r,g,and b values,
   % it's hard to have r,g or b alone close to white
   % therefore c,y,m always appear close to white
   
   case 'wyrk'
   
        C0 = [0.0  0.0  0.0 ;
              1.0  0.0  0.0
              1.0  1.0  0.0
              1    1    1   ];            
        
   case 'wmrk'
   
        C0 = [0.0  0.0 0.0  ;
              1.0  0.0 0.0  
              1.0  0.0 1.0  
              1    1   1    ];            

   case 'wcbk'
   
        C0 = [0.0 0.0 0.0   ;
              0.0 0.0 1.0   
              0.0 1.0 1.0   
              1   1   1     ];            

   case 'wmbk'
   
        C0 = [0.0 0.0 0.0   ;
              0.0 0.0 1.0   
              1.0 0.0 1.0   
              1   1   1     ];            

   case 'wcgk'
   
        C0 = [0.0 0.0  0.0   ;
              0.0 1.0  0.0   
              0.0 1.0  1.0   
              1   1    1     ];            

   case 'wygk'
   
        C0 = [0.0 0.0 0.0    ;
              0.0 1.0 0.0    
              1.0 1.0 0.0    
              1   1   1      ];
              
   otherwise
   
   
      error([catalog,' not in catalog'])
   
   
   end
   
        C  = flipud(clrmap(C0,n));
   
%% Catalogue plot (for testing)
   if OPT.plot
   
      TMP = figure;

      [x,y]=meshgrid(0:100,0:100);
     
      subplot(1,3,1)
     
         pcolorcorcen(y)
         colormap(C);
         colorbar;
      
      subplot(1,3,2)
      
         order = n:-1:1;
         order = 1:n;
         
         plot(C(:,1)  ,order,'r')
         hold on	 
         plot(C(:,2)  ,order,'g')
         plot(C(:,3)  ,order,'b')
         
         plot(sum(C,2),order,'k')
         
         axis tight     
         
      subplot(1,3,3)
      
         surf(peaks)
         colormap(C),colorbar;
      
      print(gcf,['colorgraymap_',catalog],'-dpng')
      %print(gcf,['colorgraymap_',catalog],'-deps')
      
      close(TMP)
        
   end     
   
end   

%% EOF