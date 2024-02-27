function S57toMat(fname,inpdir,outdir)

disp(['Converting ' fname ' ...']);

fwversion='2.4.7';

load ObjectClasses;

setenv('OGR_S57_OPTIONS','LNAM_REFS=ON');
setenv('GDAL_DATA',['C:\Program Files\FWTools' fwversion '\data']);

%%
disp('Generating GML ...');
ogrexe=['"C:\Program Files\FWTools' fwversion '\bin\ogr2ogr"'];
%sysstr=[ogrexe ' -skipfailures -append -f "GML" ' outdir '\' fname '.gml ' inpdir fname '.000'];
sysstr=[ogrexe ' -skipfailures -f "GML" ' outdir '\' fname '.gml ' inpdir fname '.000'];
system(sysstr);

%%
disp('Parsing ...');
a=xml2struct([outdir fname '.gml']);

%%
disp('Making structure ...');

n=0;
s=[];
b0=[];
s0=[];
s2=[];

nchild=length(a);

for i=1:nchild

    data=a(i).featureMember;
    fn=fieldnames(data);
    fn=fn{1};

    if isfield(data.(fn),'geometryProperty')

        geo=data.(fn).geometryProperty;

        tp=fieldnames(geo);
        tp=tp{1};

        switch(lower(tp))
            case{'point'}
                coorstr=geo.Point.coordinates;
                v0=strread(coorstr,'%f','delimiter',',');
                if length(v0)==2
                    x=v0(1:2:end-1);
                    y=v0(2:2:end);
                    a(i).featureMember.(fn).Coordinates=[x y];
                else
                    x=v0(1:3:end-2);
                    y=v0(2:3:end-1);
                    z=v0(3:3:end);
                    a(i).featureMember.(fn).Coordinates=[x y z];
                end
                a(i).featureMember.(fn).Type='Point';
            case{'multipoint'}
                np=length(geo.MultiPoint);
                for j=1:np
                    coorstr=geo.MultiPoint(j).pointMember.Point.coordinates;
                    v0=strread(coorstr,'%f','delimiter',',');
                    if length(v0)==2
                        x=v0(1:2:end-1);
                        y=v0(2:2:end);
                        s(n).Coordinates(k,:)=[x y];
                    else
                        x=v0(1:3:end-2);
                        y=v0(2:3:end-1);
                        z=v0(3:3:end);
                        a(i).featureMember.(fn).Coordinates(j,:)=[x y z];
                    end
                end
                a(i).featureMember.(fn).Type='MultiPoint';
            case{'linestring'}
                coorstr=geo.LineString.coordinates;
                v0=strread(coorstr,'%f','delimiter',',');
                x=v0(1:2:end-1);
                y=v0(2:2:end);
                a(i).featureMember.(fn).Coordinates=[x y];
                a(i).featureMember.(fn).Type='Polyline';
            case{'polygon'}
                np=length(geo.Polygon);
                no=0;
                ni=0;
                for j=1:np
                    if isfield(geo.Polygon(j),'outerBoundaryIs')
                        if ~isempty(geo.Polygon(j).outerBoundaryIs)
                            no=no+1;
                            coorstr=geo.Polygon(j).outerBoundaryIs.LinearRing.coordinates;
                            v0=strread(coorstr,'%f','delimiter',',');
                            x=v0(1:2:end-1);
                            y=v0(2:2:end);
                            a(i).featureMember.(fn).Outer(no).Coordinates=[x y];
                        end
                    end
                    if isfield(geo.Polygon(j),'innerBoundaryIs')
                        if ~isempty(geo.Polygon(j).innerBoundaryIs)
                            ni=ni+1;
                            coorstr=geo.Polygon(j).innerBoundaryIs.LinearRing.coordinates;
                            v0=strread(coorstr,'%f','delimiter',',');
                            x=v0(1:2:end-1);
                            y=v0(2:2:end);
                            a(i).featureMember.(fn).Inner(ni).Coordinates=[x y];
                        end
                    end
                end
                a(i).featureMember.(fn).Type='Polygon';
        end
    end
end

s=[];

xl(1)=str2double(a(1).boundedBy.Box(1).coord.X);
xl(2)=str2double(a(1).boundedBy.Box(2).coord.X);
yl(1)=str2double(a(1).boundedBy.Box(1).coord.Y);
yl(2)=str2double(a(1).boundedBy.Box(2).coord.Y);

s.Box.X=xl;
s.Box.Y=yl;

s.DSID=a(1).featureMember.DSID;

for i=1:length(ObjectClasses)
    acr=ObjectClasses(i).Acronym;
    acr=strrep(acr,'$','DOLLAR');
    s.Layers.(acr)=[];
end

for i=2:nchild
    fn=fieldnames(a(i).featureMember);
    fn=fn{1};
    if isfield(s.Layers,fn)
        nn=length(s.Layers.(fn));
        fnames=fieldnames(a(i).featureMember.(fn));
        for j=1:length(fnames)
            fnm2=fnames{j};
            if ~strcmpi(fnm2,'geometryProperty')
                s.Layers.(fn)(nn+1).(fnm2)=a(i).featureMember.(fn).(fnm2);
            end
        end
    end
end

save([outdir fname '.mat'],'-struct','s');

delete([outdir '\*.gml']);
delete([outdir '\*.xsd']);

disp('Done');
