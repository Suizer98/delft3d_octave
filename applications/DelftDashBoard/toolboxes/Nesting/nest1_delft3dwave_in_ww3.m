function point_output=nest1_delft3dwave_in_ww3(point_output,grdfile,depfile,nr_cells_per_section)

% Read grid and depth file
[xg,yg,enc,cs,nodatavalue] = wlgrid('read',grdfile);
% TODO coordinate conversion

depth = wldep('read',depfile,[size(xg,1)+1 size(xg,2)+1]);
depth=depth(1:end-1,1:end-1);
[bnd,circ,sections]=find_boundary_sections_on_regular_grid(xg,yg,depth,0);

% Determine points
ithin=nr_cells_per_section;
ithin=2;
nrp=point_output.nrpoints;
inest=0;
for isec=1:length(sections)
    np=length(sections(isec).x);
    ipoints=1:ithin:np;
    if ipoints(end~=np)
        ipoints=[ipoints np];
        for ip=1:length(ipoints)
            nrp=nrp+1;
            inest=inest+1;
            point_output.points(nrp).name=['d3d_nest' num2str(inest,'%0.3i')];
            point_output.points(nrp).x=sections(isec).x(ipoints(ip));
            point_output.points(nrp).y=sections(isec).y(ipoints(ip));
        end
    end
end
point_output.nrpoints=nrp;
for ip=1:nrp
    point_output.point_names{ip}=point_output.points(ip).name;
end


