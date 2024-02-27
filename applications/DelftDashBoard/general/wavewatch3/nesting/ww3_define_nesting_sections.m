function [x0out,y0out,dxout,dyout,npout,ixdout,iydout]=ww3_define_nesting_sections(ww3_grid_file)
% Creates nesting sections for ww3 in ww3 nesting

% Read detailed model data
grd=ww3_read_grid_inp(ww3_grid_file);
dr=fileparts(ww3_grid_file);
bot=ww3_read_bottom_depth_file([dr filesep grd.bottom_depth_filename],grd.nx,grd.ny,grd.bottom_depth_scaling_factor);
[xg,yg]=meshgrid(grd.x0:grd.dx:grd.x0+(grd.nx-1)*grd.dx,grd.y0:grd.dy:grd.y0+(grd.ny-1)*grd.dy);            

thresh=-10;

% Bottom row
ix=0;
iy=1;
nsec=0;
newsection=1;
while 1
    ix=ix+1;
    if ix>grd.nx
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)<thresh
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=grd.dx;
            dy(nsec)=0;
            % Also define detailed model boundary points
            ixd(nsec,1)=ix;
            iyd(nsec,1)=iy;
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    else
        if bot(iy,ix)>thresh
            % End of section found
            newsection=1;
        else
            % Continue along this section
            np(nsec)=np(nsec)+1;            
            % Also define detailed model boundary points
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    end
end

% Top row
ix=0;
iy=grd.ny;
newsection=1;
while 1
    ix=ix+1;
    if ix>grd.nx
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)<thresh
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=grd.dx;
            dy(nsec)=0;
            % Also define detailed model boundary points
            ixd(nsec,1)=ix;
            iyd(nsec,1)=iy;
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    else
        if bot(iy,ix)>thresh
            % End of section found
            newsection=1;
        else
            % Continue along this section
            np(nsec)=np(nsec)+1;            
            % Also define detailed model boundary points
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    end
end

% Left row
ix=1;
iy=1;
newsection=1;
while 1
    iy=iy+1;
    if iy==grd.ny
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)<thresh
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=0;
            dy(nsec)=grd.dx;
            % Also define detailed model boundary points
            ixd(nsec,1)=ix;
            iyd(nsec,1)=iy;
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    else
        if bot(iy,ix)>thresh
            % End of section found
            newsection=1;
        else
            % Continue along this section
            np(nsec)=np(nsec)+1;            
            % Also define detailed model boundary points
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    end
end

% Right row
ix=grd.nx;
iy=1;
newsection=1;
while 1
    iy=iy+1;
    if iy==grd.ny
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)<thresh
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=0;
            dy(nsec)=grd.dx;
            % Also define detailed model boundary points
            ixd(nsec,1)=ix;
            iyd(nsec,1)=iy;
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    else
        if bot(iy,ix)>thresh
            % End of section found
            newsection=1;
        else
            % Continue along this section
            np(nsec)=np(nsec)+1;            
            % Also define detailed model boundary points
            ixd(nsec,2)=ix;
            iyd(nsec,2)=iy;
        end
    end
end

% Get rid of boundary sections that cover just one point
nsec=0;
for j=1:length(np)
    if ixd(j,1)==ixd(j,2) && iyd(j,1)==iyd(j,2)
        % Skip this section
    else
        nsec=nsec+1;
        npout(nsec)=np(j);
        x0out(nsec)=x0(j);
        y0out(nsec)=y0(j);
        dxout(nsec)=dx(j);
        dyout(nsec)=dy(j);
        ixdout(nsec,1)=ixd(j,1);
        ixdout(nsec,2)=ixd(j,2);
        iydout(nsec,1)=iyd(j,1);
        iydout(nsec,2)=iyd(j,2);
    end
end
