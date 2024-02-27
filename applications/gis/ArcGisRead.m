function varargout = ArcGisRead(fname,varargin)
%ARCGISREAD  Read gridded data set in Arc ASCII Grid Format [(1,1) at Upper Left as in GIS]
%
%   S      = arcgisread(filename,<keyword,value>)
%  [X,Y,D] = arcgisread(filename,<keyword,value>)
%
% reads contents of <a href="http://en.wikipedia.org/wiki/ESRI_grid">ESRI arcGIS file</a> into 
% variables X,Y and D, or into a struct S that
% directly can be plotted with pcolor(D.x,D.y.D.val)
%
% The following keywords are recommended when using struct S:
%
%  OPT.varname       - name of data block (default 'val')
%  OPT.long_name     - netCDF-CF convention
%  OPT.standard_name - netCDF-CF convention
%  OPT.units         - netCDF-CF convention
%
%See web: <a href="http://en.wikipedia.org/wiki/ESRI_grid">http://en.wikipedia.org/wiki/ESRI_grid</a>
%         <a href="http://webhelp.esri.com/arcgisdesktop/9.2/index.cfm?id=1309&pid=1308&topicname=ASCII_to_Raster_%28Conversion%29">@ESRI</a>
%
%See also: arcgrid, ARCGRIDREAD (in $ mapping toolbox)


%% User defined keywords

   OPT.plot          = 0;  % plot (default off, to prevent grinding of PC with big matrices)
   OPT.clim          = [-5 45]; % in OPT.units
   OPT.upwardy       = 0;  % ersie files have y going down, set this to 1 if you want y going up
   OPT.export        = 1;  % export plot
   OPT.mat           = 1;  % save as mat
   OPT.nc            = 0;  % save as netCDF
   OPT.type          = 'single';% 'double','int'
   OPT.epsg          = [];
   
   OPT.varname       = 'val'; % name of data block 
   OPT.long_name     = ''; % netCDF-CF convention
   OPT.standard_name = ''; % netCDF-CF convention
   OPT.units         = ''; % netCDF-CF convention
   
   if nargin==0;D = OPT;return;end; % make function act as object
   
   OPT      = setproperty(OPT,varargin{:});

   D.varname         = OPT.varname;      
   D.long_name       = OPT.long_name; 
   if isempty(D.long_name)
       [PATHSTR,NAME,EXT] = fileparts(fname); 
       D.long_name=[NAME EXT];
   end
   D.standard_name   = OPT.standard_name;
   D.units           = OPT.units;        

%% Open file (TO DO: perform checks on file)

   D.filename = fname;
   fid        = fopen(fname);
   basename   = fullfile(fileparts(fname),filename(fname));
   
  if OPT.plot
      TMP = figure;
  end


%% Read header

   s=fgetl(fid);[tmp rest]=strtok(s);D.ncols        = str2num(rest);
   s=fgetl(fid);[tmp rest]=strtok(s);D.nrows        = str2num(rest);
   s=fgetl(fid);[tmp rest]=strtok(s);D.xllcorner    = str2num(rest);
   s=fgetl(fid);[tmp rest]=strtok(s);D.yllcorner    = str2num(rest);
   s=fgetl(fid);[tmp rest]=strtok(s);D.cellsize     = str2num(rest);
   s=fgetl(fid);[tmp rest]=strtok(s);D.nodata_value = str2num(rest);

%% Read data

   D.(D.varname) = repmat(nan(OPT.type),[D.ncols,D.nrows]);
   D.(D.varname) = fscanf(     fid,'%f',[D.ncols,D.nrows])';
   D.(D.varname)(D.(D.varname)==D.nodata_value)=nan;

   fclose(fid);
   
%% Create rectangular grid

   for irow=1:D.ncols
      D.x(irow)=D.xllcorner+D.cellsize*(  irow-0.5           );
   end
   for jcol=1:D.nrows
      D.y(jcol)=D.yllcorner+D.cellsize*(-(jcol-0.5)+(D.nrows)); % fixed bug in OET revision 2120
      % lowest row lies 0.5* cellsize above yllcorner
      % substitution of lowest row index jcol = nrows, gives
      % (-(jcol  -0.5)+(D.nrows)) = ...
      % (-(nrows -0.5)+(  nrows)) = ...
      %   -nrows +0.5+    nrows   = +0.5
   end
   
%% 

if OPT.upwardy
   D.y           = D.y(end:-1:1);
   D.(D.varname) = flipud(D.(D.varname));
end

%% Write to *.mat file

   if OPT.mat
      save([basename,'.mat'],'-struct','D');
   end

%% Write to netCDF (*.nc) file

   if OPT.nc

      nc_cf_grid_write([basename,'.nc'],'long_name',OPT.long_name,...
                                          'varname',OPT.varname,...
                                            'units',OPT.units,...
                                                'x',D.x,...
                                                'y',D.y,...
                                              'val',D.(OPT.varname),...
                                            'units',OPT.units,...
                                             'epsg',OPT.epsg);
   end

%% Plot data (do this last, as it can be really sloooow)

   if OPT.plot
      pcolor(D.x,D.y,D.(D.varname));
      shading interp;
      axis    equal;
      caxis  (OPT.clim)
      tickmap('xy')
      %diff = abs(D.xllcorner-D.xllcorner+D.cellsize*D.ncols)*0.05;
      %xlim([D.xllcorner-diff D.xllcorner+D.cellsize*D.ncols]+diff)
      %diff = abs(D.yllcorner-D.yllcorner+D.cellsize*D.nrows)*0.05;
      %ylim([D.yllcorner-diff D.yllcorner+D.cellsize*D.nrows+diff])
      title(fname);
      colorbarwithtitle(['',' [',OPT.units,']']);
      hold on
      X=[D.x(1),D.x(end),D.x(end),D.x(1),D.x(1)];
      Y=[D.y(1),D.y(1),D.y(end),D.y(end),D.y(1)];
      plot(X,Y,'--r')
      grid on
      if OPT.export
         print2screensize([basename,'.png'])
      end
      pausedisp
      try;close(TMP);end
   end
   
%% output

   if nargout==1
      varargout = {D};
   elseif nargout==3
      varargout = {D.x,D.y,D.(D.varname)};
   end

%% EOF