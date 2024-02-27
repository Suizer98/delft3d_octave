%function getICESdata_all
%getICESdata_all loop for getICESdata
%
%See also: getICESdata

[codes, names, compounds, units] = getICESparameters;
kmlallfiles = {};

kml.pp = {};
for icode=1 % :length(codes)
    code = codes{icode};
    
    % todo only one colorbar per variable
  
    kml.yyyy = {};
    for yyyy=2010:2012 % year(now)
        
       kml.mm = {};
       for mm=1:12
       disp(['code: ',code,' yyyy:',num2str(yyyy),' mm:',num2str(mm)])
       kml.mm{end+1} = [code,'_',num2str(yyyy),'_',num2str(mm),'.kml'];
       [D,A] = getICESdata('ParameterCode',codes{icode},...
                    't0',datenum(yyyy  ,1,1),...
                    't1',datenum(yyyy  ,1,1),...
                   'lon',[-180 180],... % bounding box longitude 
                   'lat',[ -90  90],... % bounding box latitude
                     'p',[   0 1e6],... % bounding box depth (pressure)
               'kmlName',[code,'_',num2str(yyyy),'-',num2str(mm)],... %  month
              'fileName',kml.mm{end});
              % save to netCDF
       end
       kml.yyyy{end+1} = [code,'_',num2str(yyyy),'.kml'];
       KMLmerge_files('sourceFiles',kml.mm,'fileName',kml.yyyy{end},...
          'open',1,...
       'kmlName',[code,'_',num2str(yyyy)])
    end
    
    kml.pp{end+1} = [code,'_all.kml'];
    KMLmerge_files('sourceFiles',kml.yyyy,'fileName',kml.pp{end},...
     'open',1,...
     'kmlName',code,...
     ... % 'snippet',,...
     'description',[names{icode},' ',compounds{icode}])

end

   KMLmerge_files('sourceFiles',kml.pp,'fileName',['ICES_all.kml']);
   
   %kml2kmz()
