function Icon=kngr_makeIcon(file,sz,iconfile)

[a amap]=imread(file);
[r,c] = size(a);
r_skip = ceil(r/sz);
c_skip = ceil(c/sz);
% Create the thinxthin icon (RGB data)
Icon = a(1:r_skip:end,1:c_skip:end,:);
Icon(Icon==255) = 255;

if nargin>2
    Im2Ico({Icon},{amap},{},iconfile);
end