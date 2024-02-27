function coastline=sfincs_read_coastline(filename)

s=load(filename);
coastline.x=s(:,1);
coastline.y=s(:,2);
coastline.slope=s(:,3);
coastline.orientation=s(:,4);
coastline.length=length(coastline.x);
