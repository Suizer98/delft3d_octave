%NC_NANTEST  This shows how NaNs behave in snctools
%
% Values indentical to _Fillvalue are returned as NaN.
% NaNs in the data are returned as NaN, so there is no nead to specify 
% NaN as _Fillvalue
%
%See also: nan, scntools

% TO DO: check also for C interface in addition to java interface
% TO DO: check also for native 2009a matlab interface in addition to java interface
% TO DO: move to scntools

OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');

for USE_JAVA=[0 1]

      setpref ('SNCTOOLS', 'USE_JAVA', USE_JAVA);
   
   %% Initialize
   %------------------
   
      OPT.dump          = 1;
   
   %% 0 Read raw data
   %------------------
   
      D.datenum = now + [0 1 2 3];
      D.data    = [nan 0 1 2];
      
   %% 1a Create file
   %------------------
   
      outputfile    = [pwd,filesep,'nc_nantest.nc'];
      
      nc_create_empty (outputfile)
   
   %% 2 Create dimensions
   %------------------
   
      nc_add_dimension(outputfile, 'time'     , length(D.datenum))
   
   %% 3 Create variables
   %------------------
      clear nc
   
         ifld = 1;
      nc(ifld).Name         = 'var0';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time'};
      nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', -1);
   
         ifld = ifld + 1;
      nc(ifld).Name         = 'var1';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time'};
      nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', nan);
   
         ifld = ifld + 1;
      nc(ifld).Name         = 'var2';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time'};
      nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 0);
   
         ifld = ifld + 1;
      nc(ifld).Name         = 'var3';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time'};
      nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 1);
   
         ifld = ifld + 1;
      nc(ifld).Name         = 'var4';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'time'};
      nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 2);
   
   %% 4 Create attibutes
   %------------------
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
   
   %% 5 Fill variables
   %------------------
   
      nc_varput(outputfile, 'var0', D.data); % NaN is returned as NaN: behaves same as var1
      nc_varput(outputfile, 'var1', D.data); % NaN is returned as NaN: behaves same as var0
      nc_varput(outputfile, 'var2', D.data); % NaN an 0 are returned as NaN 
      nc_varput(outputfile, 'var3', D.data); % NaN an 1 are returned as NaN
      nc_varput(outputfile, 'var4', D.data); % NaN an 2 are returned as NaN
   
   %% 6 Check
   %------------------
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
      DMP = nc_getall(outputfile);
      
      disp('------------------------------------------')
      disp([' with USE_JAVA: ',num2str(USE_JAVA)])
      disp([' data [ ', num2str(D.data),' ] as initially specified'])
      disp('------------------------------------------')
      disp([' data [ ', num2str(DMP.var0.data'),' ] written with FillValue:  ',num2str(DMP.var0.FillValue)])
      disp([' data [ ', num2str(DMP.var1.data'),' ] written with FillValue:  ',num2str(DMP.var1.FillValue)])
      disp([' data [ ', num2str(DMP.var2.data'),' ] written with FillValue:  ',num2str(DMP.var2.FillValue)])
      disp([' data [ ', num2str(DMP.var3.data'),' ] written with FillValue:  ',num2str(DMP.var3.FillValue)])
      disp([' data [ ', num2str(DMP.var4.data'),' ] written with FillValue:  ',num2str(DMP.var4.FillValue)])
   

end  % USE_JAVA

setpref ('SNCTOOLS', 'USE_JAVA',OPT.USE_JAVA);

%% EOF

