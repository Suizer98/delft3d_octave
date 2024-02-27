function points=sfincs_read_boundary_points(filename)

s=load(filename);
points.x=s(:,1)';
points.y=s(:,2)';
points.length=length(points.x);
points.handle=[];

