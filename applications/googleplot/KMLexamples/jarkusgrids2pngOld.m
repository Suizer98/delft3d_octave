%JARKUSGRIDS2PNG   make kml file wiht Jarkus as georeferenced pngs
%
%See also: vaklodingen2png, jarkus_grids2kml, jarkus_grids_overview

outputDir      = 'P:\mcdata\opendap\rijkswaterstaat\jarkus\grids\KMLpreview';
url            = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/grids';
contents       = opendap_folder_contents(url);
EPSG           = load('EPSGnew');

OPT.colormap   = 'colormap2Dbathymetry';
OPT.cLim       = [-20 20];
OPT.colorSteps = [25,1000];
OPT.hillFactor = 10;

for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x    = nc_varget(contents{ii},   'x');
    y    = nc_varget(contents{ii},   'y');
    time = nc_varget(contents{ii},'time');
    
    % coordinates:
    [coords.NS,coords.WE] = convertCoordinatesNew([min(x)-10,min(x)-10;max(x)+10,max(x)+10],[min(y)-10,max(y)+10;min(y)-10,max(y)+10],...
        EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');

    coords.S = mean(min(coords.NS,[],2));
    coords.W = mean(min(coords.WE,[],1));
    coords.N = mean(max(coords.NS,[],2));
    coords.E = mean(max(coords.WE,[],1));
    dLon = mean(coords.WE(:,1)-coords.WE(:,2));
    dLat = mean(coords.NS(:,2)-coords.NS(:,1));
    coords.R =  atand(cosd(mean(mean(coords.NS)))*dLon/dLat);
    %angle = atan(cos(lat));

    % convert time to years
    time = datestr(time+datenum(1970,1,1),'yyyy-mm-dd');

    %create output directory
    outputDir2 = [outputDir '\' fname];

    %Check dir, make if needed
    if ~isdir(outputDir2)
        mkdir(outputDir2);
    end

    output = [];
    %loop through all the years
    for jj = 1:1:size(time,1)

        % display progress
        disp([num2str(ii) '/' num2str(length(contents)) ' ' fname ' ' time(jj,:)]);

        % load z data
        z = nc_varget(contents{ii},'z',[jj-1,0,0],[1,-1,-1]);
        z(z>500) = nan;

        if ~all(isnan(z(:)))

            % build colormap
            c = z;
            c(isnan(c)) = -.1;
            eval(sprintf('colorRGB = %s([%d,%d]);',OPT.colormap,OPT.colorSteps(1),OPT.colorSteps(2)));

            %clip c to min and max
            c(c<OPT.cLim(1)) = OPT.cLim(1);
            c(c>OPT.cLim(2)) = OPT.cLim(2);

            %convert color and hillshade values into colorRGB index values
            c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps(2)-1))+1);

            h = hillshade(-z,x,y,'zfactor',OPT.hillFactor)/255;
            h(isnan(h))=0.5;
            h = round(h*(OPT.colorSteps(1)-1)+1);

            fileName = [num2str(time(jj,:)) '.png'];
            % make image A



            ind = sub2ind(size(colorRGB),h(:),c(:));

            A = colorRGB([ind ind+(OPT.colorSteps(1)*OPT.colorSteps(2))...
                ind+2*(OPT.colorSteps(1)*OPT.colorSteps(2))]);

            A = reshape(A,[size(z),3]);

            imwrite(A,[outputDir2 '\' fileName],'png','Alpha',+~isnan(z));

            output = [output sprintf([...
                '<GroundOverlay>\n'...
                '<TimeStamp>\n'...
                '<when>%s</when>\n'...timeIn
                '</TimeStamp>\n'...
                '<name>%s</name>\n'...name
                '<Icon><href>%s</href></Icon>\n'...
                '<LatLonBox>\n'...
                '<south>%3.8f</south>\n'...S
                '<west>%3.8f</west>\n'...W
                '<north>%3.8f</north>\n'...N
                '<east>%3.8f</east>\n'...E
                '<rotation>%3.3f</rotation>\n'...
                '</LatLonBox>\n'...
                '</GroundOverlay>\n'],...
                time(jj,:),time(jj,:),...
                ['http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/grids/KMLpreview/' fname '/' fileName],....
                coords.S,coords.W,coords.N,coords.E,coords.R)];
        end
    end
    if length(output)>100
        OPT.fid=fopen([outputDir2 '\png.kml'],'w');
        OPT_header = struct(...
            'name',fname,...
            'open',0);
        output = [KML_header(OPT_header) output];
        % FOOTER
        output = [output KML_footer];
        fprintf(OPT.fid,output);
        % close KML
        fclose(OPT.fid);
    end
end









