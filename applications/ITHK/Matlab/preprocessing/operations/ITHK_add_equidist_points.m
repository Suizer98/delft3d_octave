function outLDB=ITHK_addEquidistantPointsBetweenSupportingLDBPoints(dx,ldb)

% ITHK_addEquidistantPointsBetweenSupportingLDBPoints - does what it says
%
% out=ITHK_addEquidistantPointsBetweenSupportingLDBPoints(in,dx)

outLDB=[];

if nargin==0
    if isempty(which('ITHK_landboundary.m'))
        wlsettings;
    end
    ldb=ITHK_landboundary('read');
end

if isempty(ldb)
    return
end

if ~isstruct(ldb)
    [ldbCell, ldbBegin, ldbEnd, ldbIn]=ITHK_disassembleLdb(ldb);
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
end


for cc=1:length(ldbCell)
    in=ldbCell{cc};
    out=[];
    for ii=1:size(in,1)-1
        %Determine distance between two points 
        dist=sqrt((in(ii+1,1)-in(ii,1)).^2 + (in(ii+1,2)-in(ii,2)).^2);
        
        ox=interp1([0 dist],in(ii:ii+1,1),0:dx:dist)';
        oy=interp1([0 dist],in(ii:ii+1,2),0:dx:dist)';

        out=[out ; [ox oy]];
    end
    outCell{cc}=out;
end

out=ITHK_rebuildLdb(outCell);

if ~isstruct(ldb)
    outLDB=ITHK_rebuildLdb(outCell);
else
    outLDB.ldbCell=outCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end