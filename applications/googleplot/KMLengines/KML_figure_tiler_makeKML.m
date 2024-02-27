function KML_figure_tiler_makeKML(OPT)
%KML_figure_tiler_makeKML subsidiary of KMLfigure_tiler
%
%See also:KMLfigure_tiler

OPT.timeSpan = '';

for level = OPT.highestLevel:OPT.lowestLevel
    tiles     = dir(fullfile(OPT.Path,OPT.Name,[OPT.Name '_*.png']));
    tileCodes = nan(length(tiles),level);
    for ii = 1:length(tiles)
        begin =  findstr(tiles(ii).name,OPT.Name) + length(OPT.Name); % mind colormap png being in same directory
       %begin =  findstr(tiles(ii).name,'_');
        if length(tiles(ii).name)-4-begin(end) == level
            tileCodes(ii,:) = tiles(ii).name(begin(end)+1:end-4);
        end
    end
    tileCodes(any(isnan(tileCodes),2),:) = [];
    tileCodes = char(tileCodes);
    tiles     = unique(tileCodes(:,1:end),'rows');
    addCode   = ['01';'23'];
    
    if level == OPT.highestLevel
        minLod = OPT.minLod0;
    else
        minLod = OPT.minLod;
    end
    
    if level == OPT.lowestLevel
        maxLod = OPT.maxLod0;
    else
        maxLod = OPT.maxLod;
    end
    
    for nn = 1:size(tiles,1)
        output = '';
        if level ~= OPT.lowestLevel
            %look for children PNG files
            for ii = 1:2
                for jj = 1:2
                    code = [tiles(nn,:) addCode(ii,jj)];
                    B = KML_figure_tiler_code2boundary(code);
                    PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' code '.png']);
                    if exist(PNGfileName,'file') & ~isempty(B)
                        output = [output sprintf([...
                            '<NetworkLink>\n'...
                            '<name>%s</name>\n'...% name
                            '%s'...% time
                            '<Region>\n'...
                            '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...% minLod,maxLod
                            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...% N,S,W,E
                            '</Region>\n'...
                            '<Link><href>%s_%s.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...% kmlname
                            '</NetworkLink>\n'],...
                            code,...
                            OPT.timeSpan,...
                            minLod,-1,...
                            B.N,B.S,B.W,B.E,...
                            OPT.Name,code)];
                    end
                end
            end
        end
        
        %% add png to kml
		% add twice (!) to avoid rendering issues at interface where GE DEM meets MSL
        B = KML_figure_tiler_code2boundary(tiles(nn,:));
        output = [output sprintf([...
            '<Region>\n'...
            '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'... % minLod,maxLod
            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ... % N,S,W,E
            '</Region>\n'...
            '<GroundOverlay>\n'... % clamptoGround
            '<name>%s</name>\n'... % kml_id
            '<drawOrder>%0.0f</drawOrder>\n'... % drawOrder
            '%s'... % timeSpan
            '<Icon><href>%s_%s.png</href></Icon>\n'... % file_link
            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ... % N,S,W,E
            '</GroundOverlay>\n'...
            '<GroundOverlay>\n'... % absolute
            '<name>%s</name>\n'... % kml_id
            '<drawOrder>%0.0f</drawOrder>\n'... % drawOrder
            '<altitude>.1</altitude><altitudeMode>absolute</altitudeMode>'...
            '%s'... % timeSpan
            '<Icon><href>%s_%s.png</href></Icon>\n'... % file_link
            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ... % N,S,W,E
            '</GroundOverlay>\n'],...
            minLod,maxLod,B.N,B.S,B.W,B.E,...
            tiles(nn,:),...
            OPT.drawOrder+level,OPT.timeSpan,...
            OPT.Name,tiles(nn,:),...
            B.N,B.S,B.W,B.E,...
            tiles(nn,:),...
            OPT.drawOrder+level,OPT.timeSpan,...
            OPT.Name,tiles(nn,:),...
            B.N,B.S,B.W,B.E)];
        
        fid=fopen(fullfile(OPT.Path,OPT.Name,[OPT.Name '_' tiles(nn,:) '.kml']),'w');
        OPT_header = struct(...
               'name',tiles(nn,:),...
               'open',OPT.open,...
            'visible',OPT.visible,...
        'description',OPT.description);

        output = [KML_header(OPT_header) output];
        
        % FOOTER
        output = [output KML_footer];
        fprintf(fid,'%s',output);
        
        % close KML
        fclose(fid);
    end
end
