function [] = donar_donarMat2nc(donarMat,filename)
%donar_donarMat2nc Generate the NetCDF files from the compends.
%
%  [] = donar_donarMat2nc(donarMat,ncfilename)
%
%See also:
        
        thefields = fields(donarMat);
        
        for ifield = 1:length(thefields)

         %% Create the netCDF file
            
            ncfile   = [filename,'_',thefields{ifield},'.nc'];
            ncfile   = strrep(ncfile,'\raw\','\nc\')
            ncfile   = strrep(ncfile,'\mat\','\')

            nc_create_empty(ncfile);

         %% GLOBAL ATTRIBUTES

            % Store header as global attributes
            
            theHDRfields = fields(donarMat.(thefields{ifield}).hdr);
            theHDRfields = donar_rawcode2NCcode(theHDRfields);
            for ihdrfield = 1:1:size(theHDRfields,1)
                for iNCfield = 1:1:size(theHDRfields{ihdrfield,2},1)
                    attcode = theHDRfields{ihdrfield,2}{iNCfield,1}; % 1 or 2
                    varname = theHDRfields{ihdrfield,2}{iNCfield,2};
                    attname = theHDRfields{ihdrfield,2}{iNCfield,3};
                    attval  = donarMat.(thefields{ifield}).hdr.(theHDRfields{ihdrfield,1}){attcode};
                    nc_attput(ncfile, varname, attname, attval);
                end
            end

         %% DEFINE DIMENSIONS

            % Define dimensions in this order: [time,z,y,x]
            
            numrec = length(donarMat.(thefields{ifield}).data);
            nc_adddim(ncfile, 'time' , numrec)


         %% CREATE AND PUT DIMENSIONS

            for idim = 1:size(donarMat.(thefields{ifield}).dimensions,1)

                disp( ['Adding ',donarMat.(thefields{ifield}).dimensions{idim},'(Column: ',num2str(idim),') to the netCDF file'])
                nc(idim).Name             = donarMat.(thefields{ifield}).dimensions{idim};
                nc(idim).Nctype           = 'double'; % float not sufficient as datenums are big: double
                nc(idim).Dimension        = {'time'}; % QuickPlot error: plots dimensions instead of datestr
                nc(idim).Attribute(    1) = struct('Name', 'long_name'      ,'Value', donarMat.(thefields{ifield}).dimensions{idim,1});
                nc(idim).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', donarMat.(thefields{ifield}).dimensions{idim,1});
                nc(idim).Attribute(end+1) = struct('Name', 'units'          ,'Value', donarMat.(thefields{ifield}).dimensions{idim,2});

                nc_addvar(ncfile, nc(idim));
                nc_varput(ncfile, donarMat.(thefields{ifield}).dimensions{idim}, donarMat.(thefields{ifield}).data(:,idim));
                
            end


         %% CREATE AND PUT VARIABLES
         %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
         
                idim = idim+1;
                variableCol = donarMat.(thefields{ifield}).variableCol;
                nc(idim).Name             = donarMat.(thefields{ifield}).standard_name;
                nc(idim).Nctype           = 'double'; % no double needed
                nc(idim).Dimension        = {'time'};
                nc(idim).Attribute(    1) = struct('Name', 'long_name'      ,'Value',              donarMat.(thefields{ifield}).name);
                nc(idim).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value',              donarMat.(thefields{ifield}).standard_name);
                udunits = ehd2udunits (donarMat.(thefields{ifield}).hdr.EHD{2});
                
                % mS/m   donarMat.conductivity.hdr.EHD{2}
                % U      donarMat.fluorescence.hdr.EHD{2}
                % mg/l   donarMat.oxygen.hdr.EHD{2}
                % DIMSLS donarMat.ph.hdr.EHD{2}
                % uE     donarMat.air_radiance.hdr.EHD{2}
                % DIMSLS donarMat.sea_water_salinity.hdr.EHD{2}
                %                 temperature
                % NTU    donarMat.turbidity.hdr.EHD{2}
                % uE     donarMat.water_radiance.hdr.EHD{2}

                nc(idim).Attribute(end+1) = struct('Name', 'units'          ,'Value', udunits);
                nc(idim).Attribute(end+1) = struct('Name', 'units_long_name','Value', ehd2unitname(donarMat.(thefields{ifield}).hdr.EHD{2}));
                
                if ~isempty(donarMat.(thefields{ifield}).deltares_name)
                   nc(idim).Attribute(end+1) = struct('Name', 'deltares_name'  ,'Value', donarMat.(thefields{ifield}).deltares_name);  
                end
                nc(idim).Attribute(end+1)    = struct('Name', 'FillValue'    ,'Value', single(nan));
                nc(idim).Attribute(end+1)    = struct('Name', 'cell_methods' ,'Value', 'time: point area: point');% needs to be same type as data itself (i.e. single)
                nc(idim).Attribute(end+1)    = struct('Name', 'actual_range' ,'Value', [min(donarMat.(thefields{ifield}).data(:,variableCol)) max(donarMat.(thefields{ifield}).data(:,variableCol))]);
                nc_addvar(ncfile, nc(idim));

                nc_varput(ncfile, donarMat.(thefields{ifield}).standard_name, donarMat.(thefields{ifield}).data(:,variableCol));
        end