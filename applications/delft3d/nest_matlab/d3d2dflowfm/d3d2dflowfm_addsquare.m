function xyz = d3d2dflowfm_addsquare(xyz)

xmax = max(xyz(:,1));
xmin = min(xyz(:,1));
ymax = max(xyz(:,2));
ymin = min(xyz(:,2));

dx = (xmax-xmin)/10.;

xyz(end+1,1) = xmin - dx;
xyz(end  ,2) = ymin - dx;
xyz(end  ,3) = mean(xyz(:,3));
xyz(end+1,1) = xmax + dx;
xyz(end  ,2) = ymin - dx;
xyz(end  ,3) = mean(xyz(:,3));
xyz(end+1,1) = xmax + dx;
xyz(end  ,2) = ymax + dx;
xyz(end  ,3) = mean(xyz(:,3));
xyz(end+1,1) = xmin - dx;
xyz(end  ,2) = ymax + dx;
xyz(end  ,3) = mean(xyz(:,3));
