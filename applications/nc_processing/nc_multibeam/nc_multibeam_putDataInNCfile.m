function nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z,varargin)
%NC_MULTIBEAM_PUTDATAINNCFILE
%
%   nc_multibeam_putdatainncfile(OPT,ncfile,time,Z,<keyword,value>)
%
% adds variable to a netcdf file (incl time) using matlabs native (2008b+) netcdf
%
%See also: nc_multibeam, snctools

   OPT.debug       = 1;
   OPT = setproperty(OPT,varargin{:});
   
   dimSizeX = (OPT.mapsizex/OPT.gridsizex);
   dimSizeY = (OPT.mapsizey/OPT.gridsizex);

%% Open NC file

   NCid = netcdf.open(ncfile, 'NC_WRITE');

%% get already available timesteps in nc file

   varid = netcdf.inqVarID(NCid,'time');
   [~,dimlen] = netcdf.inqDim(NCid,netcdf.inqDimID(NCid,'time'));
   if dimlen == 0 
       time0 = [];
   else
       time0 = netcdf.getVar(NCid,varid);
   end

%% add time if it is not already in nc file

   if any(time0 == time)
       jj = find(time0 == time,1)-1;
   else
       jj = length(time0);
       netcdf.putVar(NCid,varid,jj,1,time);
   end
   
   varid = netcdf.inqVarID(NCid,'z');

%% Merge Z data with existing data if it exists

if jj ~= length(time0) % then existing nc file already has data
    % read Z data
    Z0       = netcdf.getVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1]);
    Znotnan  = ~isnan(Z);
    Z0notnan = ~isnan(Z0);
    notnan   = Znotnan&Z0notnan;
    % check if data will be overwritten
    if any(notnan) % values are not nan in both existing and new data
        [~,filename] = fileparts(ncfile);
        date = nc_cf_time(ncfile,'time',jj,1);
        if OPT.debug
            TMP = figure;
            subplot(1,3,1)
            pcolorcorcen(double(Z0)); % TO DO: this appears to be empty for some reason
            colorbar('horiz')
            axis equal
            title('existing Z')
            
            subplot(1,3,2)
            pcolorcorcen(Z);
            colorbar('horiz')
            axis equal
            title('new Z')
            
            subplot(1,3,3)
            pcolorcorcen(Z-double(Z0));
            colorbar('horiz')
            title('difference')
            axis equal
            colormap(colormap_cpt('temperature'))
            colormap(jet)
            clim_diff = 2*percentile(abs(Z(notnan)-double(Z0(notnan))),95);
            clim([-1 1]*clim_diff)
            print2screensizeoverwrite([filepathstrname(ncfile),'_',datestr(date,'YYYYMMDD'),'.png'])
            clf;close(TMP)
        end
        if isequal(Z0(notnan),Z(notnan))
            % this is ok
            fprintf(1,'in %s, WARNING: %d values are overwritten by identical values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        else 
            % this is (most likely) not ok   
            fprintf(2,'in %s, ERROR: %d values are overwritten by different values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        end
    end
    Z0(Znotnan) = Z(Znotnan);
    Z = Z0;
end

%% Write z data

   netcdf.putVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1],Z); % matlab uses reverse order, so here [x y t] to get [t y x] in ncbrowse and snctools
   
%% Update actual_range

   actual_range = netcdf.getAtt(NCid,varid,'actual_range');
   actual_range(1) = min(actual_range(1),min(Z(:)));
   actual_range(2) = max(actual_range(2),max(Z(:)));
   netcdf.putAtt(NCid,varid,'actual_range',actual_range);

%% Close NC file

   netcdf.close(NCid)
   
end

