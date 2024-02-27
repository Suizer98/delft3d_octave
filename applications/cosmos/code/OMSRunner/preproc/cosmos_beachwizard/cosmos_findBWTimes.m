function t=cosmos_findBWTimes(bwmodel)

s=urlread(['http://opendap.deltares.nl/thredds/catalog/opendap/deltares/beachwizard/output/' bwmodel '/catalog.html']); 
imatch=regexp(s,'<tt>.{1,100}\.nc</tt>','match');
for j=1:length(imatch)
    fname=imatch{j}(5:end-5);
    idot=find(fname=='.');
    tstr=fname(idot(1)+1:idot(end)-1);
    t(j)=datenum(tstr,'yyyymmdd.HHMMSS');
end
