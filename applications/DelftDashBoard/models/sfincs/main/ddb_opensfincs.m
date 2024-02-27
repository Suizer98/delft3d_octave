function ddb_opensfincs(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}

        [filename, pathname, filterindex] = uigetfile('sfincs.inp','Select sfincs.inp file');

        if pathname~=0

            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end

            % Delete all domains
            ddb_plotsfincs('delete','domain',1);
            
            handles.model.sfincs.domain = [];

            handles = ddb_initialize_sfincs_domain(handles, '', ad, 'tst');
            handles.model.sfincs.domain(ad).input=sfincs_read_input(filename,handles.model.sfincs.domain(ad).input);
            inp=handles.model.sfincs.domain(ad).input;

            % Grid
            [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);
            
            % Cell centres!
            handles.model.sfincs.domain(ad).xg=xg;
            handles.model.sfincs.domain(ad).yg=yg;
%            handles.model.sfincs.domain(ad).gridx=xz(2:end,2:end);
%            handles.model.sfincs.domain(ad).gridy=yz(2:end,2:end);
            handles.model.sfincs.domain(ad).gridx=xz;
            handles.model.sfincs.domain(ad).gridy=yz;
            
            % Attribute files
            msk=zeros(inp.nmax,inp.mmax);
            z=msk;
            if ~isempty(inp.indexfile) || ~isempty(inp.depfile) || ~isempty(inp.mskfile)
                [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
                handles.model.sfincs.domain(ad).mask=msk;
                handles.model.sfincs.domain(ad).gridz=z;
            end
                        
            % Coastline file
            if ~isempty(inp.cstfile)
                handles.model.sfincs.domain(ad).coastline=sfincs_read_coastline(inp.cstfile);
                handles.model.sfincs.domain(ad).coastline.active_point=1;
            end
            
            % Bnd file
            if ~isempty(inp.bndfile)
                handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
                % Bzs file
                if exist(inp.bzsfile,'file')
                [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
                handles.model.sfincs.domain(ad).flowboundaryconditions.time=inp.tref+t/86400;
                handles.model.sfincs.domain(ad).flowboundaryconditions.zs=val;
                end
            end

            % Bwv file
            if ~isempty(inp.bwvfile)
                handles.model.sfincs.domain(ad).waveboundarypoints=sfincs_read_boundary_points(inp.bwvfile);
                % Bhs file
                if ~isempty(inp.bhsfile)
                    [t,val]=sfincs_read_boundary_conditions(inp.bhsfile);
                    handles.model.sfincs.domain(ad).waveboundarypoints.time=inp.tref+t/86400;
                    handles.model.sfincs.domain(ad).waveboundarypoints.hs=val;
                    [t,val]=sfincs_read_boundary_conditions(inp.btpfile);
                    handles.model.sfincs.domain(ad).waveboundarypoints.tp=val;
                    [t,val]=sfincs_read_boundary_conditions(inp.bwdfile);
                    handles.model.sfincs.domain(ad).waveboundarypoints.wd=val;
                end
            end

            % Obs file
            if ~isempty(inp.obsfile)
                handles.model.sfincs.domain(ad).obspoints=sfincs_read_observation_points(inp.obsfile);
            end

            % Obs file
            if ~isempty(inp.srcfile)
                handles.model.sfincs.domain(ad).sourcepoints=sfincs_read_boundary_points(inp.srcfile);
                [t,val]=sfincs_read_boundary_conditions(inp.disfile);
                handles.model.sfincs.domain(ad).sourcepoints.time=inp.tref+t/86400;
                handles.model.sfincs.domain(ad).sourcepoints.q=val;                
            end
            
            if ~isempty(inp.manningfile)
                handles.model.sfincs.domain(ad).roughness_type='file';
            else
                handles.model.sfincs.domain(ad).roughness_type='landsea';
            end

            if ~isempty(inp.amufile) && ~isempty(inp.amvfile)
                handles.model.sfincs.domain(ad).wind_type='rectangular';
            elseif ~isempty(inp.spwfile)
                handles.model.sfincs.domain(ad).wind_type='spiderweb';
            else
                handles.model.sfincs.domain(ad).wind_type='uniform';
            end
            
            if ~isempty(inp.amprfile)
                handles.model.sfincs.domain(ad).rain_type='rectangular';
            elseif ~isempty(inp.spwfile)
                handles.model.sfincs.domain(ad).rain_type='spiderweb';
            else
                handles.model.sfincs.domain(ad).rain_type='uniform';
            end
            
            setHandles(handles);
            ddb_plotsfincs('plot','active',0,'visible',1);
            gui_updateActiveTab;
        end        
    otherwise
end
