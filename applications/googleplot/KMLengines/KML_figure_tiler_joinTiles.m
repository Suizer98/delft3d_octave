function KML_figure_tiler_joinTiles(OPT)
%KML_figure_tiler_joinTiles subsidiary of KMLfigure_tiler
%
%See also:KMLfigure_tiler

multiWaitbar('fig2png_merge_tiles' ,0,'label',['Merging tiles in ' OPT.Name])
for level = OPT.lowestLevel:-1:OPT.highestLevel+1
    tiles = dir(fullfile(OPT.Path,OPT.Name,[OPT.Name '_*.png']));
    tileCodes = nan(length(tiles),level);
    for ii = 1:length(tiles)
        begin =  findstr(tiles(ii).name,'_');
        if length(tiles(ii).name)-4-begin(end) == level
            tileCodes(ii,:) = tiles(ii).name(begin(end)+1:end-4);
        end
    end
    tileCodes(any(isnan(tileCodes),2),:) = [];
    tileCodes =   char(tileCodes);
    newTiles  = unique(tileCodes(:,1:end-1),'rows');
   
    WB.a = 1-0.25.^(OPT.lowestLevel - level);
    WB.b = (1-WB.a)*0.75;
    
    for nn = 1:size(newTiles,1);
        
        imL = zeros(OPT.dim*2,OPT.dim*2,3);         % image Large (composed of up to 4 smaller images
        aaL = uint8(zeros(OPT.dim*2,OPT.dim*2));    % alpha data of large image
        code = ['01';'23'];
        for ii = 1:2
            for jj = 1:2
                PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' newTiles(nn,:) code(ii,jj) '.png']);
                if exist(PNGfileName,'file')
                    % add data to 
                    [imL((ii-1)*OPT.dim+1:ii*OPT.dim,...
                         (jj-1)*OPT.dim+1:jj*OPT.dim,1:3),...
                        ignore,...
                        aaL((ii-1)*OPT.dim+1:ii*OPT.dim,...
                            (jj-1)*OPT.dim+1:jj*OPT.dim)] = imread(PNGfileName);
                end
            end
        end
        
        tmpL = +(aaL>0);
        tmpS =...
            tmpL(1:2:OPT.dim*2,1:2:OPT.dim*2)+...
            tmpL(2:2:OPT.dim*2,2:2:OPT.dim*2)+...
            tmpL(1:2:OPT.dim*2,2:2:OPT.dim*2)+...
            tmpL(2:2:OPT.dim*2,1:2:OPT.dim*2);    
        tmpS(tmpS==0) = 1;     
        
        mask = reshape(repmat(aaL==0,1,3),size(imL));
        imL(mask) = 0;
        
        imS = ...
            imL(1:2:OPT.dim*2,1:2:OPT.dim*2,1:3)+...
            imL(2:2:OPT.dim*2,2:2:OPT.dim*2,1:3)+...
            imL(1:2:OPT.dim*2,2:2:OPT.dim*2,1:3)+...
            imL(2:2:OPT.dim*2,1:2:OPT.dim*2,1:3);
        
        imS(:,:,1) = imS(:,:,1)./tmpS;
        imS(:,:,2) = imS(:,:,2)./tmpS;
        imS(:,:,3) = imS(:,:,3)./tmpS;
        
        imS = uint8(imS);
        
         aaS = ...
            aaL(1:2:OPT.dim*2,1:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(1:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,1:2:OPT.dim*2)/4;
        
        mask = reshape(repmat(aaS==0,1,3),size(imS));
        
        % now move image around to color transparent pixels with the value of the
                        % nearest neighbour.
        
        im2       = imS;
        im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
              bsxfun(@max,im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
        imS(mask) = im2(mask);
       
        PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' newTiles(nn,:) '.png']);
        imwrite(imS,PNGfileName,'Alpha',aaS ,...
            'Author','$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_figure_tiler_joinTiles.m $');
        
        if mod(nn,5)==1;
            multiWaitbar('fig2png_merge_tiles' ,WB.a + WB.b*nn/size(newTiles,1),'label',['Merging tiles in ' OPT.Name])
        end
    end
end
multiWaitbar('fig2png_merge_tiles' ,1,'label',['Merging tiles in ' OPT.Name])