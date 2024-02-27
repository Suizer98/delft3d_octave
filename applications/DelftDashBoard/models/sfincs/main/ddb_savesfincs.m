function ddb_savesfincs(opt)

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

% Do some checks here
if handles.model.sfincs.domain(ad).flowboundarypoints.length==0
    inp.bndfile='';
    inp.bzsfile='';
end

if handles.model.sfincs.domain(ad).waveboundarypoints.length==0
    inp.bwvfile='';
    inp.bhsfile='';
    inp.btpfile='';
    inp.bwdfile='';
end

if handles.model.sfincs.domain(ad).sourcepoints.length==0
    inp.srcfile='';
    inp.disfile='';
end

if length(handles.model.sfincs.domain(ad).obspoints.x)==0
    inp.obsfile='';
end

if handles.model.sfincs.domain(ad).coastline.length==0
    inp.cstfile='';
end

switch handles.model.sfincs.domain(ad).roughness_type
    case{'uniform'}
        inp.manning_sea=[];
        inp.manning_land=[];
        inp.rghfile='';
        inp.rgh_lev_land=[];
    case{'landsea'}
        inp.manning=[];
        inp.rghfile='';
    case{'file'}
        inp.manning=[];
        inp.manning_sea=[];
        inp.manning_land=[];
        inp.rgh_lev_land=[];
end

inp.bzifile='';

switch lower(opt)
    case{'save'}
                
        sfincs_write_input('sfincs.inp',inp);
        
        fid=fopen('run.bat','wt');
        fprintf(fid,'%s\n',[handles.model.sfincs.exedir filesep 'sfincs.exe']);
        fclose(fid);
        
    case{'saveall'}
        
        sfincs_write_input('sfincs.inp',inp);
        
        % Attribute files
        
        % Bnd file
        if handles.model.sfincs.domain(ad).flowboundarypoints.length>0
            sfincs_write_boundary_points(inp.bndfile,handles.model.sfincs.domain(ad).flowboundarypoints);
            t=handles.model.sfincs.domain(ad).flowboundarypoints.time;
            v=handles.model.sfincs.domain(ad).flowboundarypoints.zs;
            sfincs_save_boundary_conditions(inp.bzsfile,t,v,inp.tref);
        end
        %             % Bzs file
        %             [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
        %             handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
        
        % Bwv file
        if handles.model.sfincs.domain(ad).waveboundarypoints.length>0
            sfincs_write_boundary_points(inp.bwvfile,handles.model.sfincs.domain(ad).waveboundarypoints);
            t=handles.model.sfincs.domain(ad).waveboundarypoints.time;
            v=handles.model.sfincs.domain(ad).waveboundarypoints.hs;
            sfincs_save_boundary_conditions(inp.bhsfile,t,v,inp.tref);
            t=handles.model.sfincs.domain(ad).waveboundarypoints.time;
            v=handles.model.sfincs.domain(ad).waveboundarypoints.tp;
            sfincs_save_boundary_conditions(inp.btpfile,t,v,inp.tref);
            t=handles.model.sfincs.domain(ad).waveboundarypoints.time;
            v=handles.model.sfincs.domain(ad).waveboundarypoints.wd;
            sfincs_save_boundary_conditions(inp.bwdfile,t,v,inp.tref);
        end
        
        % Coastline file
        if handles.model.sfincs.domain(ad).coastline.length>0
            sfincs_write_coastline(inp.cstfile,handles.model.sfincs.domain(ad).coastline);
        end

        % Obs file
        if handles.model.sfincs.domain(ad).obspoints.length>0
            sfincs_write_obsfile(inp.obsfile,handles.model.sfincs.domain(ad).obspoints);
        end

        % Src file
        if handles.model.sfincs.domain(ad).sourcepoints.length>0
            sfincs_write_obsfile(inp.srcfile,handles.model.sfincs.domain(ad).sourcepoints);
            t=handles.model.sfincs.domain(ad).sourcepoints.time;
            v=handles.model.sfincs.domain(ad).sourcepoints.q;
            sfincs_save_boundary_conditions(inp.disfile,t,v,inp.tref);
        end
        
end

%setHandles(handles);
