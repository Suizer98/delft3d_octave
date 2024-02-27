function writeMapKMZ(varargin)

dr='.\';
delfiles=0;
colbar='';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'filename'}
                fname=varargin{i+1};
            case{'dir'}
                dr=varargin{i+1};
            case{'filelist'}
                flist=varargin{i+1};
            case{'colorbar'}
                colbar=varargin{i+1};
            case{'xlim'}
                xlim=varargin{i+1};
            case{'ylim'}
                ylim=varargin{i+1};
            case{'deletefiles'}
                delfiles=varargin{i+1};
        end
    end
end

fid=fopen([dr filesep fname '.kml'],'wt');

fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','<Document>');
if ~isempty(colbar)
    fprintf(fid,'%s\n','  <ScreenOverlay id="colorbar">');
    fprintf(fid,'%s\n','    <Icon>');
    fprintf(fid,'%s\n',['      <href>' colbar '</href>']);
    fprintf(fid,'%s\n','    </Icon>');
    fprintf(fid,'%s\n','    <overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <rotation>0</rotation>');
    fprintf(fid,'%s\n','    <size x="0" y="0" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','  </ScreenOverlay>');
end
for it=1:length(flist)
    fprintf(fid,'%s\n','  <Folder>');
    fprintf(fid,'%s\n','    <GroundOverlay>');
    fprintf(fid,'%s\n',['      <name>' flist{it} '</name>']);
    fprintf(fid,'%s\n','      <Icon>');
    fprintf(fid,'%s\n',['        <href>' flist{it} '</href>']);
    fprintf(fid,'%s\n','      </Icon>');
    fprintf(fid,'%s\n','      <LatLonBox>');
    fprintf(fid,'%s\n',['        <north>' num2str(ylim(2),'%10.4f') '</north>']);
    fprintf(fid,'%s\n',['        <south>' num2str(ylim(1),'%10.4f') '</south>']);
    fprintf(fid,'%s\n',['        <east>' num2str(xlim(2),'%10.4f') '</east>']);
    fprintf(fid,'%s\n',['        <west>' num2str(xlim(1),'%10.4f') '</west>']);
    fprintf(fid,'%s\n','      </LatLonBox>');
    fprintf(fid,'%s\n','    </GroundOverlay>');
    fprintf(fid,'%s\n','  </Folder>');
end

fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');

fclose(fid);

fnames{1}=[dr filesep fname '.kml'];
nf=1;
if ~isempty(colbar)
    nf=nf+1;
    fnames{nf}=[dr filesep colbar];
end
for it=1:length(flist)
    nf=nf+1;
    fnames{nf}=[dr filesep flist{it}];
end

%delete([dr filesep fname '.kmz']);
zip([dr filesep fname '.zip'],fnames);
movefile([dr filesep fname '.zip'],[dr filesep fname '.kmz']);

if delfiles
    delete([dr filesep fname '.kml']);
    delete([dr filesep colbar]);
    for it=1:length(flist)
        delete([dr filesep flist{it}]);
    end
end

