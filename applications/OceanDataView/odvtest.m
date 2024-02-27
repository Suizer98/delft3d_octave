%ODVTEST   script to test ODVRREAD, ODVDISP, ODVPLOT_CAST, ODVPLOT_OVERVIEW
%
%   plots all odv files files in a directory one by one in Matlab 
%   and all together in Google Earth.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

close all
clear all

% $Id: odvtest.m 10522 2014-04-10 21:00:37Z boer_g $
% $Date: 2014-04-11 05:00:37 +0800 (Fri, 11 Apr 2014) $
% $Author: boer_g $
% $Revision: 10522 $
% $HeadURL
% $Keywords:

OPT.pause        = 0;
OPT.plot         = 0;
OPT.kml          = 1; % 1=overall, 2=also per CDi
OPT.basedir      = 'd:\checkouts\OpenEarthRawData\SeaDataNet\';

%% cast: CTD NIOZ
SET(1).vc                = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(1).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre630-270409_result\'];
SET(1).sdn_standard_name = 'P011::PSALPR02';
SET(1).clim              = [5 25];
SET(1).z                 = [];
SET(1).zScaleFun         = @(z)10*z;
SET(1).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',w,'">NODC</a>'];
SET(1).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=1018420=',w,'">NODC</a>'];

%% samples: KNMI VOS: surface samples only
SET(2).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(2).directory         = [OPT.basedir,filesep,'userkc30e50-data_centre632-090210_result\'];
SET(2).sdn_standard_name = 'SDN:P011::PSSTTS01'; % Temperature of the water body by in-situ thermometer
SET(2).clim              = [5 25];
SET(2).z                 = [];
SET(2).zScaleFun         = @(z)10*z;
SET(2).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',w,'">NODC</a>'];
SET(2).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=1018420=',w,'">NODC</a>'];

%% cast: CTD NIOZ
% D          1x100            74915376  struct   
% usergd30d98-data_centre630-2011-02-23_result_cylinders.kml 440 Mb
SET(3).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(3).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre630-2011-02-23_result\'];
SET(3).sdn_standard_name = 'SDN:P011::PSALPR02'; % Temperature of the water body by in-situ thermometer
SET(3).clim              = [30 34];
SET(3).z                 = 'SDN:P011::PRESPS01';
SET(3).zScaleFun         = @(z)10*z;
SET(3).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',w,'">NODC</a>'];
SET(3).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=1018420=',w,'">NODC</a>'];

%% samples: imares: surface samples only
SET(4).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(4).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre633-230211_result\'];
SET(4).sdn_standard_name = 'SDN:P011::ODSDM021';% Salinity of the water body
SET(4).clim              = [5 25];
SET(4).z                 = [];
SET(4).zScaleFun         = @(z)10*z;
SET(4).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',w,'">NODC</a>'];
SET(4).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=1018420=',w,'">NODC</a>'];

%% cast + samples (cast with 1 datapoint): TNO lithogaphy
SET(5).vc                = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(5).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre635-210311_result\'];
SET(5).sdn_standard_name = 'SDN:P011::XXXXXXXX';
SET(5).sdn_standard_name = 'SDN:P011::SEGMLENG';
SET(5).clim              = [0 2];
SET(5).z                 = 'SDN:P011::COREDIST';
SET(5).zScaleFun         = @(z)100*z; % deepest cores go down to O(100m)
SET(5).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.dinoloket.nl/dinoLks/minisite/Entry?datatype=bor&id=',x,'&queryProperty=NitgNumber">DINO</a>'];

%% cast + samples (cast with 1 datapoint): TNO lithogaphy
SET(6).vc                = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(6).directory         = [OPT.basedir,filesep,'userHBM-data_centre635-220711_result\'];
SET(6).sdn_standard_name = 'SDN:P011::XXXXXXXX';
SET(6).sdn_standard_name = 'SDN:P011::SEGMLENG';
SET(6).clim              = [0 2];
SET(6).z                 = 'SDN:P011::COREDIST';
SET(6).zScaleFun         = @(z)100*z; % deepest cores go down to O(100m)
SET(6).urlFcn            = @(x,y,z,w,v)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.dinoloket.nl/dinoLks/minisite/Entry?datatype=bor&id=',x,'&queryProperty=NitgNumber">DINO</a> <br> strata = ',v];
%% samples: EMODnet chemistry
SET(7).vc                = 'd:\opendap.deltares.nl\thredds\dodsC\opendap\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(7).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre120-2014-03-20_result\'];
SET(7).sdn_standard_name = 'SDN:P011::PHOSAADC';
SET(7).clim              = [5 25];
SET(7).z                 = 'SDN:P011::COREDIST';
SET(7).zScaleFun         = @(z)10*z;
SET(7).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://www.nodc.nl/v_cdi_v2/print_xml.aspx?n_code=',w,'">NODC</a>'];
SET(7).urlFcn            = @(x,y,z,w)['station = ',y,' <br> LOCAL_CDI_ID = ',x,' <br> date = ',z,' <br> link = <a href="http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=1018420=',w,'">NODC</a>'];

% samples: RWS
% http://live.waterbase.nl/index.cfm?loc=DELFZL&page=start.locaties.databeschikbaarheid&taal=nl&loc=&wbwns=1|Waterhoogte+in+cm+t.o.v.+normaal+amsterdams+peil+in+oppervlaktewater&whichform=2

for i=7%1:length(SET)

   L = odv_metadata(SET(i).directory); % add extraction of # params and # 
   
% Coastline of world
   
   C.lon = nc_varget(SET(i).vc,'lon');
   C.lat = nc_varget(SET(i).vc,'lat');
   
   clear D
   
% Cycle CDi

   for ifile=1:length(L.name);
       
      disp([num2str(ifile),'/',num2str(length(L.name))])
   
      fname = L.name{ifile};
       
      set(gcf,'name',[num2str(ifile),': ',fname])
       
      jfile    = ifile;% = 1;
      D(jfile) = odvread([SET(i).directory,filesep,fname],...
                'resolve',1,...
          'CDI_record_id',L.CDI_record_id(ifile));
       
      %odvdisp(D)
      
      %%
      clf
      if OPT.plot
       if D(jfile).cast==1
        odvplot_cast    (D(jfile),'lon',C.lon,'lat',C.lat,'sdn_standard_name',SET(i).sdn_standard_name,'z',SET(i).z);
       else
        odvplot_overview(D(jfile),'lon',C.lon,'lat',C.lat,'sdn_standard_name',SET(i).sdn_standard_name);
       end
      end
      
      if OPT.kml > 1
        fnames{ifile} = [D(jfile).LOCAL_CDI_ID,'.kml'];
        if ~(D(jfile).cast==1)
         odvplot_overview_kml(D(jfile),...
                  'fileName',fnames{ifile},...
                  'colorbar',0,...
         'sdn_standard_name',SET(i).sdn_standard_name,...
                      'clim',SET(i).clim,...
                 'colorMap',jet(24));
        else
            KMLcylinder({D(ifile).metadata.latitude   },...
                        {D(ifile).metadata.longitude  },...
                        {1.*[0;cumsum(D(1).data{12})]},...
                        {D(ifile).data{12}            },10e3,'fileName',fnames{ifile},'colorMap',@(x)jet(x),'cLim',[0 2],'colorSteps',32);
         end
      end
      
      if OPT.pause
         disp(['processed # ',num2str([ifile,length(L.name);],'%0.3d/%0.3d'),', press key to continue'])
         pausedisp
      end

   end % ifile 
   
%% merge kml files

   if OPT.kml > 1
    if ~(D(jfile).cast==1)   
     fnames{end+1} = [last_subdir(SET(i).directory),'_colorbar.kml'];
     [~,pngname]=KMLcolorbar('CBcolorTitle',['water temperature [°C] (',SET(i).sdn_standard_name,')'],...
                               'CBfileName',fnames{end},...
                                   'CBclim',SET(i).clim,...
                               'CBcolorMap',jet(24));
     overallkml = [last_subdir(SET(i).directory),'.kml'];
     KMLmerge_files('sourceFiles',fnames,'fileName',overallkml);
     KML2kmz(overallkml,pngname)
     deletefile(fnames)
    end
   end
   
%% merge
   
   if OPT.kml > 0 & D(jfile).cast
   
     M2D     = odv_merge(D,'sdn_standard_name',SET(i).sdn_standard_name,'z',SET(i).z,'metadataFcn',@(z) z(1),'dataFcn',@(z) sum(z));
     M3D     = odv_merge(D,'sdn_standard_name',SET(i).sdn_standard_name,'z',SET(i).z,'metadataFcn',@(z) z(1),'dataFcn',@(z) z(:));
     M3Dtype = odv_merge(D,'sdn_standard_name',SET(i).sdn_standard_name,'z',SET(i).z,'metadataFcn',@(z) z(1),'dataFcn',@(z) z(:));
   
   %% make one kml with all data from downloaded set, encompassing multiple odv files
      text = cellfun(SET(i).urlFcn,...
                  cells2cell(M2D.LOCAL_CDI_ID),...
                  cells2cell(M2D.station),...
                  cellstr(datestr(cell2mat(M2D.datenum),'yyyy-mmm-dd'))',...
                  ... cells2cell(M2D.CDI_record_id),...
                  cellfun(@(x) str2line(num2str(x),'s','|'),M3Dtype.data,'uni',0)',...
                  'uniformoutput',0);
   %%                  
      KMLmarker(cell2mat(M2D.latitude),cell2mat(M2D.longitude),cell2mat(M2D.data),...
           'description',['EDMO_code',num2str(M2D.EDMO_code{1})],... 
                  'name',cells2cell(M2D.LOCAL_CDI_ID),... 
                  'html',text,...
              'fileName',[last_subdir(SET(i).directory),'.kml'],...
                'timeIn',datestr(cell2mat(M2D.datenum)-1,'yyyy-mm-dd'),... % datestr is Muuch faster
               'timeOut',datestr(cell2mat(M2D.datenum)+1,'yyyy-mm-dd'),...
               'kmlName',[last_subdir(SET(i).directory),'.kml'],...
       'iconnormalState','http://maps.google.com/mapfiles/kml/pal5/icon5.png',...
    'iconhighlightState','http://maps.google.com/mapfiles/kml/pal5/icon5.png',...
      'scalenormalState',1,'scalehighlightState',1)
       
      % TO DO think about what should be up
      % and whether to add a dummy offset (no, because a few cores are realy deep)
      % dataclasses = unique(cellstr(char(cellfun(@(x) char(unique(x)),M2.data,'uni',0)))); % see colormap_dino
      

     [CB.map,CB.label]= colormap_dino;
      M3Dtype.classes  = M3Dtype.data; %cellfun(@(x) colormap_dino(x),M3Dtype.data,'uni',0);
      M3D.z            = cellfun(@(z) (1.*[0;cumsum(z)]),M3D.data,'uniformoutput',0);
      
      KMLcolumn  (M2D.latitude   ,...
                  M2D.longitude  ,...
                  M3D.z,...
                  M3Dtype.classes,'nTH',6,'R',250,'dR',1,...
                  'fileName',[last_subdir(SET(i).directory),'_cylinders.kml'],...
                  'colorMap',@(x)colormap_dino,...
                  'colorSteps',size(colormap_dino,1),'cLim',[0.5 length(CB.label)+.5],...
                  'fillAlpha',.9,'zScaleFun',SET(i).zScaleFun,...
                  'colorbar',1,...
                  'CBcolorTitle','TNO DINO sediment classification',...
                  'CBcolorTickLabel',CB.label,'CBcolorTick',1:length(CB.label));

   end  

end % set

