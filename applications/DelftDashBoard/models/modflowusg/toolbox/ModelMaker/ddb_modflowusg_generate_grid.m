function handles=ddb_modflowusg_generate_grid(handles,id)

wb =   waitbox('Grid is being created ...');

try
    
    % This is where the magic happens!
    
    x0=handles.toolbox.modelmaker.xOri;
    y0=handles.toolbox.modelmaker.yOri;
    rot=handles.toolbox.modelmaker.rotation;
    nx=handles.toolbox.modelmaker.nX;
    ny=handles.toolbox.modelmaker.nY;
    dx=handles.toolbox.modelmaker.lengthX/nx;
    dy=handles.toolbox.modelmaker.lengthY/ny;
    
    lines=handles.toolbox.modelmaker.gridgen.lines;
    
    %% create the grid
    
    for ipol=1:length(lines)
        lines(ipol).ref_level=lines(ipol).refinement_level;
        lines(ipol).xy=[lines(ipol).x' lines(ipol).y'];
    end
    
    prepare_gridgen_input(rot, x0, y0, ny, nx, dx, dy, lines);
    
    exedir=handles.toolbox.modelmaker.dataDir;

    % construct grid
    system([exedir 'gridgen_x64.exe qtgbuild qtg1.dfn']);

    % write grid shapefile
    system([exedir 'gridgen_x64.exe qtg-to-shapefile qtg2.dfn']);

    % write grid nod-file
    system([exedir 'gridgen_x64.exe qtg-to-crs qtg2.dfn']);
    
    %% Load in grid
    fname='qtg.shp';
    fi = shape('open',fname);
    data = shape('read',fi,0,'polyline');
    handles.model.modflowusg.domain.grid.x=data(:,1);
    handles.model.modflowusg.domain.grid.y=data(:,2);

    try
        close(wb);
    end
    
    % Plot new domain
    handles=ddb_modflowusg_plot_grid(handles,'plot');
    
catch
    try
        close(wb);
    end
end
