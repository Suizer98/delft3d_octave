function sfincs_hmax2geotiff(tiffile,geomskfile,hmaxfile)

[x,y,z]=sfincs_read_hmaxgeo_bin(geomskfile,hmaxfile);

z=flipud(z);

z=round(z*100); % Convert to cm

x0=min(x);
x1=max(x);
y0=min(y);
y1=max(y);

bbox=[x0 y0;x1 y1];
bit_depth=8;

geotiffwrite(tiffile, bbox, z, bit_depth);

