function varargout = nc_multibeam_from_asc(varargin)
%NC_MULTIBEAM_FROM_ASC  One line description goes here.
%
%   nc_multibeam_from_asc(<keyword,value>)
%
% Creates a set of time-dependent netCDF grid tiles (z = f(x,y,t))
% from a set of ESRI ASCII files. The netCDF files and the ESRI 
% grids should have the same cellsize (=dx=dy) and offset modulo from 
% (0,0) (=dx/2=dy.2), so no interpolation of ANY kind is performed 
% (not even nearest neightbour): the data points from the ESRI data grids 
% are simply redistributed (inserted) into the grids tiles defined 
% in nc_multibeam_from_asc. 
% However, the extent of the grids can be totally different though.
% The bounding boxes of the ESRI grids can either be finer or
% coarser then the nc_multibeam_from_asc tiles, and can also overlap.
% 
%   <ncfiles> = nc_multibeam_from_asc(<keyword,value>)
%
% returns the names of the ncfiles that have been created, or 
% to which data have been added. To obtain a list of the 
% availabel proerties call:
%
%   OPT = nc_multibeam_from_asc()
%
%See also: nc_multibeam, arcgis, nc_cf_gridset

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
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
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Jun 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: nc_multibeam_from_asc.m 5347 2011-10-18 14:01:59Z tda@vanoord.com $
% $Date: 2011-10-18 22:01:59 +0800 (Tue, 18 Oct 2011) $
% $Author: tda@vanoord.com $
% $Revision: 5347 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nc_processing/nc_multibeam/nc_multibeam_from_asc.m $
% $Keywords: $

%% options

   OPT.netcdfversion       = 3;
   OPT.block_size          = 1e7;
   OPT.make                = true;
   OPT.copy2server         = false;
   
   OPT.basepath_local      = '';
   OPT.basepath_network    = '';
   OPT.basepath_opendap    = '';
   OPT.raw_path            = '';
   OPT.raw_extension       = '*.asc';
   OPT.netcdf_path         = [];
   OPT.cache_path          = fullfile(tempdir,'nc_asc');
   OPT.zip                 = true;          % are the files zipped?
   OPT.zip_extension       = '*.zip';       % zip file extension
   
   OPT.datatype            = 'multibeam';
   OPT.EPSGcode            = [];
   OPT.dateFcn             = @(s) datenum(monthstr_mmm_dutch2eng(s(1:8)),'yyyy mmm'); % how to extract the date from the filename
   
   OPT.mapsizex            = 5000;            % size of fixed map in x-direction in m (between outer corners!))
   OPT.mapsizey            = 5000;            % size of fixed map in y-direction in m (between outer corners!))
   OPT.gridsizex           = 5;               % x grid resolution
   OPT.gridsizey           = 5;               % y grid resolution
%  OPT.cellsize % we can't have unequal dx and dy because the asc source doesn't allow it
   OPT.xoffset             = OPT.gridsizex/2; % zero point of x centres grid (i.e. x of data points, not x of pixels corners)
   OPT.yoffset             = OPT.gridsizey/2; % zero point of y centres grid (i.e. y of data points, not y of pixels corners)
   OPT.zfactor             = 1;               % scale z by this factor
   
   OPT.Conventions         = 'CF-1.5';
   OPT.CF_featureType      = 'grid';
   OPT.title               = 'Multibeam';
   OPT.institution         = ' ';
   OPT.source              = 'Topography measured with multibeam on project survey vessel';
   OPT.history             = 'Created with: $Id: nc_multibeam_from_asc.m 5347 2011-10-18 14:01:59Z tda@vanoord.com $ $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nc_processing/nc_multibeam/nc_multibeam_from_asc.m $';
   OPT.references          = 'No reference material available';
   OPT.comment             = 'Data surveyed by survey department for ...';
   OPT.email               = 'e@mail.com';
   OPT.version             = 'Trial';
   OPT.terms_for_use       = 'These data is for internal use by ... staff only!';
   OPT.disclaimer          = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   OPT.eps                 = 1e12.*eps; % needed for doubles and nodatavalues like 999.999999
   
   if nargin==0
       varargout = {OPT};
       return
   end
   OPT = setproperty(OPT, varargin{:});

   if ~(OPT.gridsizex==OPT.gridsizey)
      error('gridsizex should match gridsizey: requested grid should align with grid in asc file that has same cellsize in x and y.')
   end
   
   if isempty(OPT.EPSGcode)
       error('DATA WITHOUT COORDINATE INFO IS USELESS, PLEASE PROVIDE the EPSGcode, see epsg-registry.org')
   end

   ncfiles = {};
   
if OPT.make
   multiWaitbar( 'CloseAll' );
   multiWaitbar( 'Raw data to NetCDF',0,'Color',[0.2 0.6 0.2])
   disp('generating nc files... ')
   %% limited input check
   if isempty(OPT.raw_path)
       error %#ok<LTARG>
   end
   
   %%
   EPSG             = load('EPSG');

   if isempty(fullfile(OPT.basepath_local,OPT.netcdf_path))
       warning(['fullfile(OPT.basepath_local,OPT.netcdf_path) isempty',])%#ok<LTARG>
   end
   
   mkpath(fullfile(OPT.basepath_local,OPT.netcdf_path));
   delete(fullfile(OPT.basepath_local,OPT.netcdf_path,'*.nc')); % TO DO: relocate existing files

   if OPT.zip
       mkpath(OPT.cache_path);
       fns = dir(fullfile(OPT.raw_path,OPT.zip_extension));
   else
       fns = dir(fullfile(OPT.raw_path,OPT.raw_extension));
   end
   
   %% check if files are found

   if isempty(fns)
       error(['no raw files in: ',OPT.raw_path])
   end
    
%% sort so that the time vector ends up continuously increasing in the netCDF file  

   dates = cellfun(OPT.dateFcn,{fns.name});
   [dates,ind]= sort(dates);
   fns = fns(ind);
   
%% initialize waitbar

   WB.done       = 0;
   WB.bytesToDo  = 0;
   if OPT.zip
       multiWaitbar('raw_unzipping'  ,0,'Color',[0.2 0.7 0.9])
   end
   multiWaitbar('nc_reading'         ,0,'Color',[0.1 0.5 0.8],'label','Reading')
   multiWaitbar('nc_writing'         ,0,'Color',[0.1 0.3 0.6],'label','Writing')
   for ii = 1:length(fns)
       WB.bytesToDo = WB.bytesToDo + fns(ii).bytes;
   end
   WB.bytesToDo            =  WB.bytesToDo*2;
   WB.bytesDoneClosedFiles = 0;
   WB.zipratio             = 1;
   
   for jj = 1:length(fns)
    
   %% unzip

        if OPT.zip
            multiWaitbar('raw_unzipping', 0,'label',sprintf('Unzipping %s',fns(jj).name));
            %delete files in cache
            delete(fullfile(OPT.cache_path, '*'));
            
            % uncompress files with a gui for progres indication
            uncompress(fullfile(OPT.raw_path,fns(jj).name),...
                'outpath',fullfile(OPT.cache_path),'gui',true,'quiet',true);
            
            % read the output of unpacked files
            fns_unzipped = dir(fullfile(OPT.cache_path,OPT.raw_extension));
            
            % get the size of the unpacked files that will be processed
            unpacked_size = 0;
            for kk = 1:length(fns_unzipped)
                unpacked_size = unpacked_size + fns_unzipped(kk).bytes;
            end
            WB.bytesToDo = WB.bytesToDo/WB.zipratio;
            
            % calculate a zip ratio to estimate the compression level (used
            % to estimate the total work for the progress bar)
            WB.zipratio = (WB.zipratio*(jj-1)+unpacked_size/fns(jj).bytes)/jj;
            WB.bytesToDo = WB.bytesToDo*WB.zipratio;
            multiWaitbar('raw_unzipping', 1);
        else
            fns_unzipped = fns(jj);
        end
        
   %% read asc
   %  TO DO: merge this codecell that read asc file with arcgisread, arc_asc_read

        for ii = 1:length(fns_unzipped)
            disp(fns_unzipped(ii).name);
            %% set waitbars to 0 and update label
            multiWaitbar('nc_writing',0,'label','Writing: *.nc')
            multiWaitbar('nc_reading',0,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name)))
            %% read data
            
            % process time
            time    = OPT.dateFcn(fns_unzipped(ii).name) - datenum(1970,1,1);
            
            if OPT.zip
                fid      = fopen(fullfile(OPT.cache_path,fns_unzipped(ii).name));
            else
                fid      = fopen(fullfile(OPT.raw_path  ,fns_unzipped(ii).name));
            end
            
         %% read header
         
            s = textscan(fid,'%s %f',6);
            
            ncols        = s{2}(strcmpi(s{1},'ncols'        ));
            nrows        = s{2}(strcmpi(s{1},'nrows'        ));
            xllcorner    = s{2}(strcmpi(s{1},'xllcorner'    ));
            yllcorner    = s{2}(strcmpi(s{1},'yllcorner'    ));
            cellsize     = s{2}(strcmpi(s{1},'cellsize'     ));
            nodata_value = s{2}(strcmpi(s{1},'nodata_value' ));               
            if isempty(ncols)||isempty(nrows)||isempty(xllcorner)||isempty(yllcorner)||isempty(cellsize)||isempty(nodata_value)
                error('reading asc file')
            end
            
         %% read file chunkwise

            kk = 0;
            while ~feof(fid)
                % read the file
                multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
                multiWaitbar('nc_reading',ftell(fid)/fns_unzipped(ii).bytes,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name))) ;
                kk       = kk+1;
                D{kk}    = textscan(fid,'%f64',floor(OPT.block_size/ncols)*ncols,'CollectOutput',true); %#ok<AGROW>
                D{kk}{1} = reshape(D{kk}{1},ncols,[])'; %#ok<AGROW>
                if all(abs(D{kk}{1}(:) - nodata_value) < OPT.eps)
                    D{kk}{1} = nan; %#ok<AGROW>
                else
                    D{kk}{1}(abs(D{kk}{1}-nodata_value) < OPT.eps) = nan; %#ok<AGROW>
                end
            end
            multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ftell(fid))/WB.bytesToDo)
            multiWaitbar('nc_reading'        ,ftell(fid)/fns_unzipped(ii).bytes,...
                'label',sprintf('Reading: %s', (fns_unzipped(ii).name))) ;
            fclose(fid);

         if ~(cellsize == OPT.gridsizex & ...
              cellsize == OPT.gridsizey ) % gridsizey==gridsizey already checked above
              error('cellsizex~=cellsizey')
         end
         
         if ~(mod(xllcorner,cellsize)==0)
              error(['xllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
         end

         if ~(mod(yllcorner,cellsize)==0)
              error(['yllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
         end
         
         %% calculate x,y of cell CENTRES, by adding half a grid cell
         %  to the cell CORNERS. From now on we only use x and y where data reside
         %  i.e. the centers [xllcenter +/- cellsize,yllcorner +/- cellsize]
            
            xllcenter = xllcorner+cellsize/2;
            yllcorner = yllcorner+cellsize/2;

         %% write data to nc files
            
            multiWaitbar('nc_writing',0,'label',sprintf('Writing: %s...', (fns_unzipped(ii).name)))
            % set the extent of the fixed maps (decide according to desired nc filesize)
            
            minx    = xllcenter;
            miny    = yllcorner;
            maxx    = xllcenter + cellsize.*(ncols-1);
            maxy    = yllcorner + cellsize.*(nrows-1);
            minx    = floor(minx/OPT.mapsizex)*OPT.mapsizex + OPT.xoffset;
            miny    = floor(miny/OPT.mapsizey)*OPT.mapsizey + OPT.yoffset;

            x      =         xllcenter:cellsize:xllcenter + cellsize*(ncols-1);
            y      = flipud((yllcorner:cellsize:yllcorner + cellsize*(nrows-1))');
            y(:,2) = ceil((1:size(y,1))'./ floor(OPT.block_size/ncols));
            y(:,3) = mod ((0:size(y,1)-1)',floor(OPT.block_size/ncols))+1;
            
            % loop through data
            for x0      = minx : OPT.mapsizex : maxx
                for y0  = miny : OPT.mapsizey : maxy
                    ix = find(x     >=x0            ,1,'first'):find(x     <x0+OPT.mapsizex,1,'last');
                    iy = find(y(:,1)<y0+OPT.mapsizey,1,'first'):find(y(:,1)>=y0            ,1,'last');
                    
                    z = nan(length(iy),length(ix));
                    for iD = unique(y(iy,2))'
                        if ~(numel(D{iD}{1})==1&&isnan(D{iD}{1}(1)))
                            z(y(iy,2)==iD,:) = D{iD}{1}(y(iy(y(iy,2)==iD),3),ix)*OPT.zfactor;
                        end
                    end
                    
                    % generate X,Y,Z
                    x_vector = x0 + (0:(OPT.mapsizex/OPT.gridsizex)-1) * OPT.gridsizex;
                    y_vector = y0 + (0:(OPT.mapsizey/OPT.gridsizey)-1) * OPT.gridsizey;
                    
                    [X,Y]    = meshgrid(x_vector,y_vector);
                    Z = nan(size(X));
                    Z(...
                        find(y_vector  <=y(iy(1),1),1,'last' ):-1:find(y_vector  >=y(iy(end),1),1,'first'),...
                        find(x_vector  >=x(ix(1)  ),1,'first'):+1:find(x_vector  <=x(ix(end)  ),1,'last' )) = z;
                    
                    % set the name for the nc file
                    ncfile = fullfile(OPT.basepath_local,OPT.netcdf_path,...
                        sprintf('%.2f_%.2f_%s_data.nc',x0-.5*OPT.gridsizex,y0-.5*OPT.gridsizey,OPT.datatype));
                    
                    if any(~isnan(Z(:)))
                        Z = flipud(Z);
                        Y = flipud(Y);
                        % if a non trivial Z matrix is returned write the data
                        % to a nc file
                        
% TO DO implemented for free choice of file name (e.g. www.kadaster.nl names)

                        ncfile = fullfile(OPT.basepath_local,OPT.netcdf_path,...
                            sprintf('%.2f_%.2f_%s_data.nc',x0-.5*OPT.gridsizex,y0-.5*OPT.gridsizey,OPT.datatype));
                        
                        ncfiles{end+1} = ncfile;
                        
                        if ~exist(ncfile, 'file')
                            nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
                        end
                        nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z')
                    end
                    
                    % crop ncfile name for waitbars
                    if length(ncfile)>70
                        ncfiletxt = ['...' ncfile(end-68:end)];
                    end
                    
                    WB.writtenDone =  (find(x0==minx : OPT.mapsizex : maxx,1,'first')-1)/...
                        length(minx : OPT.mapsizex : maxx)+ find(y0==miny : OPT.mapsizey : maxy,1,'first')/...
                        length(miny : OPT.mapsizey : maxy)/...
                        length(minx : OPT.mapsizex : maxx);
                    multiWaitbar('nc_writing',WB.writtenDone,'label',ncfiletxt)
                    multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+(1+WB.writtenDone)*fns_unzipped(ii).bytes)/WB.bytesToDo)
                end
                
            end
            WB.writtenDone = 1;
            multiWaitbar('nc_writing',WB.writtenDone,'label',ncfile)
            WB.bytesDoneClosedFiles = WB.bytesDoneClosedFiles+fns_unzipped(ii).bytes;
        end
    end
    
    if OPT.zip
        try %#ok<TRYNC>
            rmdir(OPT.cache_path,'s')
        end
        multiWaitbar('raw_unzipping','close')
    end
    
    multiWaitbar('Raw data to NetCDF',1,'label','Generating NC files')
    multiWaitbar('nc_reading','close')
    multiWaitbar('nc_writing','close')
else
    disp('generation of nc files skipped')
end

OPT = nc_multibeam_copync2server(OPT);

varargout = {unique(ncfiles)};