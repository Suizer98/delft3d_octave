epsi=1e-06;

n=0;
yTemp=yl(1);
I=[];
curQTA=ddb_getQuadtreeAddress(xl(1),yl(1),zmlev);
curQTA2=ddb_getQuadtreeAddress(xl(1),yl(1),zmlev);

while ~strcmp(curQTA2,ddb_getQuadtreeAddress(xl(1),yl(2),zmlev))
    ret=ddb_getCoordinatesFromAddress(ddb_getQuadtreeAddress(xl(1),yTemp,zmlev));
    tempI=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(xl(1),yTemp,zmlev)]);
    while ~strcmp(curQTA,ddb_getQuadtreeAddress(xl(2),yTemp,zmlev))
        temp2I=imread(['http://kh.google.com/kh?v=3&t=' ddb_getQuadtreeAddress(ret.longmax+epsi,ret.lat,zmlev)]);
        tempI=[tempI temp2I];
        curQTA=ddb_getQuadtreeAddress(ret.longmax+epsi,ret.lat,zmlev)
        ret=ddb_getCoordinatesFromAddress(curQTA);
    end
    I=[tempI;I];
    yTemp=ret.latmin+epsi;
    curQTA=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
    curQTA2=ddb_getQuadtreeAddress(xl(1),yTemp,zmlev);
    ret=ddb_getCoordinatesFromAddress(curQTA2);
end
