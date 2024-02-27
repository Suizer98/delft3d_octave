%BIN2TEST   Test script.

 %% 1   

   [cxcor,cycor] = meshgrid(-1:1,-2:2);
   cx0 = 0;
   cy0 = 0;
   
   [cxcor,cycor] = rotatevector(cxcor-cx0,cycor-cy0,45);
   cxcor = cxcor+cx0;
   cycor = cycor+cy0;
   
   [cxcen,cycen] = corner2center(cxcor,cycor);
   
   grid_plot(cxcor,cycor)
   axis equal
   grid
   
   
   fx = -3+ 6.*rand(1,100);
   fy = -3+ 6.*rand(1,100);
   fz = fx;
   fweight = 2.*ones(size(fx));
   
   hold on
   
   plot(fx,fy,'r.');
   
   cstat = bin2(fx,fy,fz,fweight,cxcor,cycor);
   
   text(cxcen(:),cycen(:),num2str(cstat.n(:)));

 %% 2   make sure that all obsertvations are taken tinto account
 %%     once and only one, so take any doubles at the edges of 
 %%     neighbouring bins into account.
 
 figure
   
   [cxcor,cycor] = meshgrid(-1:1,-1:2);
   
   [cxcen,cycen] = corner2center(cxcor,cycor);
   
   grid_plot(cxcor,cycor)
   axis equal
   grid
   
   [fx   ,fy   ] = meshgrid(-1:.5:1,-1:.5:2);
   
   fz = fx;
   fweight = 1.*ones(size(fx));
   
   hold on
   
   plot(fx,fy,'r.');
   
   cstat = bin2(fx,fy,fz,fweight,cxcor,cycor,'dispprogress',0,'tictoc',0);
   
   text(cxcen(:),cycen(:),num2str(cstat.n(:)));
   
   title({['# raw    data: ',num2str(prod(size(fx)) )],...
          ['# binned data:' ,num2str(sum(cstat.n(:)))]});