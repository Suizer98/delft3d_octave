function superoverlay(overallfilename,s,xmin,ymin,dx,dy,varargin)

% Default settings
tilesize=256;
clmap=jet(64);
clim=[0 10];
transparency=0.5;
itiles=[];
description='unknown';
name='tile';
filefolder='';
linkfolder='';
colorbarlabel='';
kmz=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'activetiles'}
                itiles=varargin{ii+1};
                if ~iscell(itiles)
                    itiles=mat2cell(itiles);
                end
            case{'tilesize'}
                tilesize=varargin{ii+1};
            case{'colormap'}
                clmap=varargin{ii+1};
            case{'colorlimits','clim'}
                clim=varargin{ii+1};
            case{'transparency','alpha'}
                transparency=varargin{ii+1};
            case{'description'}
                description=varargin{ii+1};
            case{'name'}
                name=varargin{ii+1};
            case{'directory'}
                filefolder=varargin{ii+1};
                if filefolder(end)~=filesep
                    filefolder=[filefolder filesep];
                end
                if ~exist(filefolder,'dir')
                    mkdir(filefolder);
                    mkdir([filefolder filesep 'tiles']);
                end
            case{'colorbarlabel'}
                colorbarlabel=varargin{ii+1};
            case{'kmz'}
                kmz=1;
        end
    end
end

npmax=max(size(s));
ntx=ceil(npmax/tilesize);
nty=ceil(npmax/tilesize);

if isempty(itiles)
    itiles{1}=zeros(ntx,nty)+1;
end

% And now make make high level tiles (just the pngs)
for it=1:ntx
    for jt=1:nty
        if itiles{1}(it,jt)
            i1=(it-1)*tilesize+1;
            i2=i1+tilesize-1;
            j1=(jt-1)*tilesize+1;
            j2=j1+tilesize-1;
            d=full(s(j1:j2,i1:i2));
            d(d==0)=NaN;
            ii=find(~isnan(d), 1);
            if ~isempty(ii)
                d=flipud(d);
                d(d==0)=NaN;
                cdata=z2rgb(d,clmap,clim);
                alfa=zeros(tilesize,tilesize);
                alfa(d>0)=transparency;
                tilename=[name '.zl1.' num2str(it,'%0.5i') '.' num2str(jt,'%0.5i')];
                filename=[filefolder 'tiles' filesep tilename '.png'];
                imwrite(cdata,filename,'png','alpha',alfa);
            else
                itiles{1}(it,jt)=0;
            end
        end
    end
end

ilev=1;

% Now make kml files
while 1

    disp(['Processing level ' num2str(ilev)]);
    
    if ntx==0
        % Have reached lowest resolution tile in previous step, so stop
        % processing
        break
    end
    
    itiles{ilev+1}=zeros(floor(ntx/2),floor(nty/2));

    if ilev==1
        for it=1:ntx
            for jt=1:nty
                if itiles{ilev}(it,jt)
                    
                    west=xmin+(it-1)*tilesize*dx(ilev);
                    east=west+tilesize*dx(ilev);
                    south=ymin+(jt-1)*tilesize*dy(ilev);
                    north=south+tilesize*dy(ilev);
                    
                    tilename=[name '.zl1.' num2str(it,'%0.5i') '.' num2str(jt,'%0.5i')];
                    filename=[filefolder 'tiles' filesep tilename '.kml'];
                    
                    fid=fopen(filename,'wt');
                    fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');
                    fprintf(fid,'%s\n','<Folder>');
                    fprintf(fid,'%s\n',['  <name>' tilename '</name>']);
                    fprintf(fid,'%s\n',['  <description>' description '</description>']);
                    fprintf(fid,'%s\n','  <GroundOverlay>');
                    fprintf(fid,'%s\n',['    <name>' tilename '</name>']);
                    fprintf(fid,'%s\n','    <Icon>        ');
                    fprintf(fid,'%s\n',['      <href>' tilename '.png' '</href>']);
                    fprintf(fid,'%s\n','    </Icon>      ');
                    fprintf(fid,'%s\n','    <LatLonBox>        ');
                    fprintf(fid,'%s\n',['      <north>' num2str(north,'%10.6f') '</north>']);
                    fprintf(fid,'%s\n',['      <south>' num2str(south,'%10.6f') '</south>']);
                    fprintf(fid,'%s\n',['      <east>' num2str(east,'%10.6f') '</east>']);
                    fprintf(fid,'%s\n',['      <west>' num2str(west,'%10.6f') '</west>']);
                    fprintf(fid,'%s\n','    </LatLonBox>');
                    fprintf(fid,'%s\n','    <altitude>100.0</altitude>');
                    fprintf(fid,'%s\n','    <altitudeMode>absolute</altitudeMode>');  
                    fprintf(fid,'%s\n','  </GroundOverlay>  ');
                    fprintf(fid,'%s\n','</Folder>');
                    fprintf(fid,'%s\n','</kml>');
                    fclose(fid);
                    
                    itnext=ceil(it/2);
                    jtnext=ceil(jt/2);
                    
                    itiles{ilev+1}(itnext,jtnext)=1;
                    
                end
            end
        end
        ilev=ilev+1;
        ntx=round(ntx/2);
        nty=round(nty/2);
        dx(ilev)=dx*2;
        dy(ilev)=dy*2;
    else
        for it=1:ntx
            for jt=1:nty
                if itiles{ilev}(it,jt)

                    tilename=[name '.zl' num2str(ilev) '.' num2str(it,'%0.5i') '.' num2str(jt,'%0.5i')];
                    filename=[filefolder 'tiles' filesep tilename '.kml'];
                    
                    west=xmin+(it-1)*tilesize*dx(ilev);
                    east=west+tilesize*dx(ilev);
                    south=ymin+(jt-1)*tilesize*dy(ilev);
                    north=south+tilesize*dy(ilev);
                    
                    fid=fopen(filename,'wt');
                    
                    fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2">');
                    fprintf(fid,'%s\n','<Document>');
                    fprintf(fid,'%s\n','  <Region>');
                    fprintf(fid,'%s\n','    <Lod>');
                    fprintf(fid,'%s\n','      <minLodPixels>128</minLodPixels><maxLodPixels>1024</maxLodPixels>');
                    fprintf(fid,'%s\n','    </Lod>');
                    fprintf(fid,'%s\n','    <LatLonAltBox>');
                    fprintf(fid,'%s\n',['      <north>' num2str(north,'%10.6f') '</north>']);
                    fprintf(fid,'%s\n',['      <south>' num2str(south,'%10.6f') '</south>']);
                    fprintf(fid,'%s\n',['      <east>' num2str(east,'%10.6f') '</east>']);
                    fprintf(fid,'%s\n',['      <west>' num2str(west,'%10.6f') '</west>']);
                    fprintf(fid,'%s\n','    </LatLonAltBox>');
                    fprintf(fid,'%s\n','  </Region>');
                    
                    % The tile belonging to this region

                    % First make new tile by resampling
                    
                    iit(1)=it*2-1; % Lower left
                    iit(2)=it*2;   % Lower right
                    iit(3)=it*2-1; % Upper left
                    iit(4)=it*2;   % Upper right
                    
                    jjt(1)=jt*2-1;
                    jjt(2)=jt*2-1;
                    jjt(3)=jt*2;
                    jjt(4)=jt*2;

                    istart(1)=1;
                    istart(2)=129;
                    istart(3)=1;
                    istart(4)=129;
                    jstart(1)=129;
                    jstart(2)=129;
                    jstart(3)=1;
                    jstart(4)=1;
                    cdata=uint8(zeros(tilesize,tilesize,3));
                    alfa=uint8(zeros(tilesize,tilesize));
                    for inext=1:4
                        tilenamenext=[filefolder 'tiles' filesep name '.zl' num2str(ilev-1) '.' num2str(iit(inext),'%0.5i') '.' num2str(jjt(inext),'%0.5i')];
                        if itiles{ilev-1}(iit(inext),jjt(inext))
                            [cdata0,map,alfa0]=imread([tilenamenext '.png']);
                            cdata0=cdata0(1:2:end-1,1:2:end-1,:);
                            alfa0=alfa0(1:2:end-1,1:2:end-1,:);                            
                            cdata(jstart(inext):jstart(inext)+127,istart(inext):istart(inext)+127,:)=cdata0;
                            alfa(jstart(inext):jstart(inext)+127,istart(inext):istart(inext)+127)=alfa0;
                        end
                    end
                    imwrite(cdata,[filefolder 'tiles' filesep tilename '.png'],'png','alpha',alfa);
                                        
                    % Now write ground overlay for this tile to kml file
                    fprintf(fid,'%s\n','  <GroundOverlay>');
                    fprintf(fid,'%s\n','    <drawOrder>5</drawOrder>');
                    fprintf(fid,'%s\n','    <Icon>');
                    fprintf(fid,'%s\n',['      <href>' tilename '.png' '</href>']);
                    fprintf(fid,'%s\n','    </Icon>      ');
                    fprintf(fid,'%s\n','    <LatLonBox>        ');
                    fprintf(fid,'%s\n',['      <north>' num2str(north,'%10.6f') '</north>']);
                    fprintf(fid,'%s\n',['      <south>' num2str(south,'%10.6f') '</south>']);
                    fprintf(fid,'%s\n',['      <east>' num2str(east,'%10.6f') '</east>']);
                    fprintf(fid,'%s\n',['      <west>' num2str(west,'%10.6f') '</west>']);
                    fprintf(fid,'%s\n','    </LatLonBox>');                    
                    fprintf(fid,'%s\n','    <altitude>100.0</altitude>');
                    fprintf(fid,'%s\n','    <altitudeMode>absolute</altitudeMode>');  
                    fprintf(fid,'%s\n','  </GroundOverlay>  ');
                    
                    % And now for the 4 higher level regions                    
                    
                    for inext=1:4

                        if itiles{ilev-1}(iit(inext),jjt(inext))
                            
                            west=xmin+(iit(inext)-1)*tilesize*dx(ilev-1);
                            east=west+tilesize*dx(ilev-1);
                            south=ymin+(jjt(inext)-1)*tilesize*dy(ilev-1);
                            north=south+tilesize*dy(ilev-1);

                            tilename=[name '.zl' num2str(ilev-1) '.' num2str(iit(inext),'%0.5i') '.' num2str(jjt(inext),'%0.5i')];

                            fprintf(fid,'%s\n','  <NetworkLink>');
                            fprintf(fid,'%s\n',['    <name>' tilename '</name>']);
                            fprintf(fid,'%s\n','    <Region>');
                            fprintf(fid,'%s\n','      <Lod>');
                            fprintf(fid,'%s\n','        <minLodPixels>128</minLodPixels><maxLodPixels>-1</maxLodPixels>');
                            fprintf(fid,'%s\n','      </Lod>');
                            fprintf(fid,'%s\n','      <LatLonAltBox>');
                            fprintf(fid,'%s\n',['        <north>' num2str(north,'%10.6f') '</north>']);
                            fprintf(fid,'%s\n',['        <south>' num2str(south,'%10.6f') '</south>']);
                            fprintf(fid,'%s\n',['        <east>' num2str(east,'%10.6f') '</east>']);
                            fprintf(fid,'%s\n',['        <west>' num2str(west,'%10.6f') '</west>']);
                            fprintf(fid,'%s\n','      </LatLonAltBox>');
                            fprintf(fid,'%s\n','    </Region>');
                            fprintf(fid,'%s\n','    <Link>');
                            fprintf(fid,'%s\n',['      <href>' tilename '.kml</href>']);
                            fprintf(fid,'%s\n','      <viewRefreshMode>onRegion</viewRefreshMode>');
                            fprintf(fid,'%s\n','    </Link>');
                            fprintf(fid,'%s\n','  </NetworkLink>');
                            
                        end                            
                            
                    end

                    itnext=ceil(it/2);
                    jtnext=ceil(jt/2);
                    
                    itiles{ilev+1}(itnext,jtnext)=1;
                    
                    fprintf(fid,'%s\n','</Document>');
                    fprintf(fid,'%s\n','</kml>');

                    fclose(fid);
                    
                end
            end
        end
        ilev=ilev+1;
        if ntx>1
            ntx=round(ntx/2);
            nty=round(nty/2);
        else
            ntx=0;
            nty=0;
        end
        dx(ilev)=dx(ilev-1)*2;
        dy(ilev)=dy(ilev-1)*2;
    end
    
end

% Write final kml

ilev=ilev-1;

west=xmin;
east=west+tilesize*dx(ilev);
south=ymin;
north=south+tilesize*dy(ilev);

tilename=[name '.zl' num2str(ilev) '.' num2str(1,'%0.5i') '.' num2str(1,'%0.5i')];

fid=fopen([filefolder overallfilename],'wt');
                    
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','  <Folder>');
fprintf(fid,'%s\n','    <ScreenOverlay id="colorbar">');
fprintf(fid,'%s\n','      <Icon>');
fprintf(fid,'%s\n','        <href>colorbar.png</href>');
fprintf(fid,'%s\n','      </Icon>');
fprintf(fid,'%s\n','      <overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','      <screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','      <rotation>0</rotation>');
fprintf(fid,'%s\n','      <size x="0" y="0" xunits="pixels" yunits="pixels"/>');
fprintf(fid,'%s\n','    </ScreenOverlay>');
fprintf(fid,'%s\n','    <NetworkLink>');
fprintf(fid,'%s\n',['      <name>' name '</name>']);
fprintf(fid,'%s\n','      <Region>');
fprintf(fid,'%s\n','        <Lod>');
fprintf(fid,'%s\n','          <minLodPixels>128</minLodPixels><maxLodPixels>-1</maxLodPixels>');
fprintf(fid,'%s\n','        </Lod>');
fprintf(fid,'%s\n','        <LatLonAltBox>');
fprintf(fid,'%s\n',['          <north>' num2str(north) '</north>']);
fprintf(fid,'%s\n',['          <south>' num2str(south) '</south>']);
fprintf(fid,'%s\n',['          <east>' num2str(east) '</east>']);
fprintf(fid,'%s\n',['          <west>' num2str(west) '</west>']);
fprintf(fid,'%s\n','        </LatLonAltBox>');
fprintf(fid,'%s\n','      </Region>');
fprintf(fid,'%s\n','      <Link>');
fprintf(fid,'%s\n',['        <href>tiles\' tilename '.kml</href>']);
fprintf(fid,'%s\n','        <viewRefreshMode>onRegion</viewRefreshMode>');
fprintf(fid,'%s\n','      </Link>');
fprintf(fid,'%s\n','    </NetworkLink>');
fprintf(fid,'%s\n','  </Folder>');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

cdec=1;
cosmos_makeColorBar([filefolder 'colorbar.png'],'contours',clim(1):clim(2),'colormap','jet','label',colorbarlabel,'decimals',cdec);

if kmz
    n=0;
    curdir=pwd;
    kmzfile=[overallfilename(1:end-4) '.kmz'];
    flist=dir(filefolder);
    for ii=1:length(flist)
        switch flist(ii).name
            case{'.','..'}
            otherwise
                n=n+1;
                files{n}=fullfile(curdir, filefolder, flist(ii).name);
        end
    end
    zip(kmzfile, files);
    movefile([kmzfile '.zip'],kmzfile);
end
