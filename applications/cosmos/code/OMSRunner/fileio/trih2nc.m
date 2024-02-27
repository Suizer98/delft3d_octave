function trih2nc(loc,trifile,ncfile)
% to do : merge with VS_TRIH2NC
%See also: VS_TRIH2NC


    trifile = [loc filesep trifile];
    ncfile  = [loc filesep ncfile];
    
    % create netcdf file
    nc_create_empty(ncfile,nc_clobber_mode);

    % set global attributes
    nc_attput(ncfile,nc_global,'title','Delft3D history output');
    nc_attput(ncfile,nc_global,'institution','Deltares');
    nc_attput(ncfile,nc_global,'source','Converted from TRIH file by TRIH2NC');
    nc_attput(ncfile,nc_global,'history',[datestr(now) ' Converted from TRIH file by TRIH2NC']);
    nc_attput(ncfile,nc_global,'references','http://www.deltares.nl');
    nc_attput(ncfile,nc_global,'comment','Converted from TRIH file by TRIH2NC');
    
    if exist(trifile,'file')
        
        % open trih file
        fid = qpfopen(trifile);
        
        % read data fields
        fields = qpread(fid,1);

        % loop through data fields
        for i = 1:length(fields)
            name = fields(i).name;
            nname = normalize_name(name);
            
            % skip empties
            if name(1) == '-'; continue; end;
            
            % set dimensions, if not already done
            if i == 1
                
                % set time dimension
                times = qpread(fid,1,name,'times');
                nc_add_dimension(ncfile,'time',length(times));
                nc_addvar(ncfile,nc_varset('time',nc_double,{'time'},'time','days since 1970-01-01 00:00:00','time','','T'));
                nc_varput(ncfile,'time',times-datenum('1970-01-01 00:00:00'));
                
                % set station dimension
                stations = qpread(fid,1,name,'stations');
                nc_add_dimension(ncfile,'station',length(stations));
                
                % read coordinate data from stations
                m = nan(size(stations)); n = nan(size(stations));
                for j = 1:length(stations)
                    re = regexp(stations{j},'\(M,N\)=\(\s*(?<m>\d+),\s*(?<n>\d+)\)','names');
                    m(j) = str2double(re.m); n(j) = str2double(re.n);
                end
                
                nc_addvar(ncfile,nc_varset('m',nc_double,{'station'},'x-coordinate in Cartesian system','m','projection_x_coordinate'));
                nc_addvar(ncfile,nc_varset('n',nc_double,{'station'},'y-coordinate in Cartesian system','m','projection_y_coordinate'));
                
                nc_varput(ncfile,'m',m);
                nc_varput(ncfile,'n',n);
            end
            
            % add field data
            data = qpread(fid,name,'data',0,0);
            
            if isfield(data,'Val')
                if ndims(data.Val) == 2 && all(size(data.Val)==[length(times) length(stations)])
                    nc_addvar(ncfile,nc_varset(nname,nc_float,{'time','station'},name,fields(i).Units,nname,'','','','station'));
                    nc_varput(ncfile,nname,data.Val);
                end
            end
        end
    end
    
    nc_dump(ncfile);
end

% FUNCTION: return variable struct for nc_addvar function
function s = nc_varset(name,nctype,dims,long_name,units,varargin)
    s = struct( ...
        'Name',name, ...
        'Nctype',nctype, ...
        'Dimension',{dims}, ...
        'Attribute',struct( ...
            'Name',{'long_name','units'}, ...
            'Value',{long_name,units} ...
        ) ...
    );

    n = 3;
    
    atts = {'standard_name','type','axis','_FillValue','coordinates'};
    for i = 1:length(varargin)
        if ~isempty(varargin{i})
            s.Attribute(n).name = atts{i};
            s.Attribute(n).Value = varargin{i};
            n = n + 1;
        end
    end
end

% FUNCTION: normalizes name for use in structs etc.
function name = normalize_name(name)
    parts = regexp(name,'\W','split');
    name = sprintf(['%s' repmat('_%s',1,length(parts)-1)],parts{:});
end