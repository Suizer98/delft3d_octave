function nc_analyzeresults(url,name,nebed,tide)

xb = nc_getdimensions(url);

for t = 1:xb.nt-1
    nc_nicepictures(url,t,nebed,tide);
    print(gcf, '-dpng', sprintf(name,t));
end