%VAKLODINGEN_OVERVIEW   make kml file with links to all vaklodingen files in a folder on OPeNDAP server
%
%See also: vaklodingen_overview, jarkus_grids2kml, jarkusgrids2png

clear all
url           = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen';
url           = 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen';
KMLbaseString = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen/'; % where kml's are stored

contents      = opendap_folder_contents(url);

EPSG          = load('EPSG');

for ii = 1:length(contents);
    disp(sprintf('reading coordinates: % 2d / %d',ii,length(contents)));
    [path, fname]         = fileparts(contents{ii});
    x                     = nc_varget(contents{ii},   'x');
    y                     = nc_varget(contents{ii},   'y');
    x2                    = [x(1) x(end) x(end) x(1) x(1)];
    y2                    = [y(1) y(1) y(end) y(end) y(1)];
    [lon(:,ii),lat(:,ii)] = convertCoordinates(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    markerNames{ii}       = fname;
    markerLat(ii)         = mean(lat(:,ii));
    markerLon(ii)         = mean(lon(:,ii));
    markerX(ii,:)         = [min(x(:)) max(x(:))];
    markerY(ii,:)         = [min(y(:)) max(y(:))];
end


%% set options
OPT.fileName         = 'Vaklodingen_overview.kml';
OPT.kmlName          = 'Vaklodingen overview';
OPT.lineWidth        = 1;
OPT.lineColor        = [0 0 0];
OPT.lineAlpha        = 1;
OPT.openInGE         = false;
OPT.reversePoly      = false;
OPT.description      = '<a href="http://www.rijkswaterstaat.nl">Rijkswaterstaat</a> vaklodingen provided by <a href="http://www.openearth.nl"> OpenEarthTools</a>';
OPT.text             = '';
OPT.latText          = mean(lat,1);
OPT.lonText          = mean(lon,1);

OPT.link2prerendered = 1;
OPT.link2opendap     = 1; % not HYRAX

%% start KML
OPT.fid=fopen(OPT.fileName,'w');

%% HEADER
OPT_header = struct(...
    'name'       ,OPT.kmlName,...
    'open'       ,0,...
    'description',OPT.description);
output = KML_header(OPT_header);

%% STYLE
OPT_style = struct(...
    'name'     ,['style' num2str(1)],...
    'lineColor',OPT.lineColor(1,:) ,...
    'lineAlpha',OPT.lineAlpha(1),...
    'lineWidth',OPT.lineWidth(1));
output = [output KML_style(OPT_style)];

if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
    for ii = 2:length(lat(1,:))
        OPT_style.name = ['style' num2str(ii)];
        if length(OPT.lineColor(:,1))>1;OPT_style.lineColor = OPT.lineColor(ii,:);end
        if length(OPT.lineWidth(:,1))>1;OPT_style.lineWidth = OPT.lineWidth(ii,:);end
        if length(OPT.lineAlpha(:,1))>1;OPT_style.lineAlpha = OPT.lineAlpha(ii,:);end
        output = [output KML_style(OPT_style)];
    end
end
%% marker BallonStyle

output = [output ...
    '<Style id="normalState">\n'...
    '<IconStyle><scale>0.7</scale><Icon><href>\n'...
    'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png\n'...
    '</href></Icon></IconStyle>\n'...
    '<LabelStyle><scale>0</scale></LabelStyle>\n'...
    '</Style>\n'...
    '<Style id="highlightState">\n'...
    '<IconStyle><Icon><href>\n'...
    'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png\n'...
    '</href></Icon></IconStyle>\n'...
    '<BalloonStyle>\n'...
    '<text><![CDATA[<h3>$[name]</h3>\n'...
    '$[description]<hr /><br />Provided by:\n'...
    '<img src="https://public.deltares.nl/download/attachments/16876019/OET?version=1" align="right" width="100"/>]]></text>\n'...
    '</BalloonStyle></Style>\n'...
    '<StyleMap id="MarkerBalloonStyle">\n'...
    '<Pair><key>normal</key><styleUrl>#normalState</styleUrl></Pair> \n'...
    '<Pair><key>highlight</key><styleUrl>#highlightState</styleUrl></Pair> \n'...
    '</StyleMap>\n'];

%% print output
output = [output, '<Folder>'];
output = [output, '<name>bounding boxes</name>'];
output = [output, '<Name>Outlines</Name>'];
fprintf(OPT.fid,output);

%% LINE
OPT_line = struct(...
    'name'      ,'',...
    'styleName' ,['style' num2str(1)],...
    'timeIn'    ,[],...
    'timeOut'   ,[],...
    'visibility',1,...
    'extrude'   ,0);
% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;
for ii=1:length(lat(1,:))
    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
        OPT_line.styleName = ['style' num2str(ii)];
    end
    OPT_line.name = markerNames{ii};
    newOutput     =  KML_line(lat(:,ii),lon(:,ii),'clampToGround',OPT_line);
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    if kk>1e5
        %then print and reset
        fprintf(OPT.fid,output(1:kk-1));
        kk     = 1;
        output = repmat(char(1),1,1e5);
    end
end
fprintf(OPT.fid,output(1:kk-1)); % print output

%% labels
output = '</Folder>';
output = [output, '<Folder>'];
output = [output, '<name>Links</name>'];
output = [output, '<Name>Outlines</Name>'];

%% generate markers

%% tableContents

for ii=1:length(lat(1,:))
    disp(sprintf('writing coordinates: % 2d / %d',ii,length(contents)));
    
    if OPT.link2prerendered
    
    tableContents = [];
    tempString    = [KMLbaseString 'KMLpreview/' markerNames{ii} '/'];
    [html,status] = urlread([tempString 'contents.html']);
    if status
        checkTime = datestr(nc_cf_time(contents{ii},'time'),'YYYY-mm-dd');
        for ll = 1:length(checkTime(:,1))
            if isempty(strfind(html,[checkTime(ll,:) '_2D.kmz']))
                str2D  = '-';
            else
                str2D = [' <a href="' tempString checkTime(ll,:) '_2D.kmz">2D</a>'];
            end
            if isempty(strfind(html,[checkTime(ll,:) '_3D.kmz']))
                str3D  = '-';
            else
                str3D = [' <a href="' tempString checkTime(ll,:) '_3D.kmz">3D</a>'];
            end
             %if ~(strcmp(str2D,'-')&&strcmp(str3D,'-'))
                tableContents = [tableContents sprintf([...
                    '<tr><td>%s</td>'...      % year
                    '<td>%s</td>'....         % 2D
                    '<td>%s</td></tr>\n'],....% 3D
                    checkTime(ll,:),str2D,str3D)];
             %end
        end
    end

    % generate table with data links
    if isempty(tableContents)
        table = ['<h3>Available pre-rendered datafiles</h3>\n'...
            'No pre-rendered data available'];
    else
        table = [...
            '<h3>Available pre-rendered datafiles</h3>\n'...
            '<table border="0" padding="0" width="200">'...
            tableContents...
            '</table>'];
    end
    
    end % if OPT.link2prerendered
    
    if OPT.link2opendap
    
      table = [table ...
         '<h3>Meta information</h3>'...
         '<table border="0" padding="0" width="200">'...
            sprintf([...
           '<tr><td>THREDDS server</td><td><a href="%s">meta-info:    </a></td></tr>'...      % link to OPeNDAP
           '<tr><td>THREDDS server</td><td><a href="%s">netCDF via ftp</a></td></tr>\n'],...  % link to ftp
           [       contents{ii},'.html'],...
           [strrep(contents{ii},'dodsC/','fileServer/')]),...
         '</table>'];
         
    end

    % generate description
    output = [output, sprintf([...
        '<Placemark>\n'...
        '<name>%s</name>\n'...                                         % name
        '<snippet></snippet>\n'...
        '<description><![CDATA[RD coordinates:  <br>\n'...
        'x: % 7.0f -% 7.0f<br>\n'...                                   % [xmin xmax]
        'y: % 7.0f -% 7.0f<br>\n'...                                   % [ymin ymax]
        '<hr />\n'...
        '<a href="%s">Time animation</a>'...                           % link to timeseries
        '%s'...                                                        % table with links to pre-remj
        ']]></description>\n'...
        '<styleUrl>#MarkerBalloonStyle</styleUrl>\n'...
        '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>\n'... % lat lon
        '</Placemark>\n'],...
        markerNames{ii},markerX(ii,:),markerY(ii,:),...
        [tempString 'png.kml'],...
        table,markerLon(ii),markerLat(ii))];
end

%% FOOTER
output = [output '</Folder>' KML_footer];
fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);
%% compress to kmz?
if strcmpi  ( OPT.fileName(end),'z')
    movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete  ([OPT.fileName(1:end-3) 'kml'])
end

