function KML_figure_tiler_printTile(baseCode,D,OPT)
%KML_figure_tiler_printTile subsidiary of KMLfigure_tiler
%
%See also:KMLfigure_tiler
OPT.debug = 0;
if ~isfield(OPT,'WBtodo') %then it is the first call to this function
    OPT.WBtodo = sum(sum(~isnan(D.z)));
    multiWaitbar('fig2png_print_tile',0,'label',sprintf('Printing tiles of %d datapoints',OPT.WBtodo))
end
for addCode = ['0','1','2','3']
    code = [baseCode addCode];
    B    = KML_figure_tiler_code2boundary(code);
    
    % stop if tile is out of bounds
    if ~((D.E>B.W&&D.W<B.E)&&(D.N>B.S&&D.S<B.N))
        returnmessage(OPT.debug,'%-20s %-20s Reason: %s\n',code,'ABORTED','tile out of bounds');
        continue
    end
    
    R   = D.lon>=(B.W - OPT.dWE) & D.lon<=B.E + OPT.dWE &...
        D.lat>=(B.S - OPT.dNS) & D.lat<=B.N + OPT.dNS;
    R2  = D.lon>=(B.W          ) & D.lon<=B.E           &...
        D.lat>=(B.S          ) & D.lat<=B.N          ;
    
    if length(code) == OPT.lowestLevel
        % update waitbar
        multiWaitbar('fig2png_print_tile','increment',sum(sum(~isnan(D.z(R2(1:end-1,1:end-1)))))/OPT.WBtodo,'label',sprintf('Printing tile %s',code));  % D.z(R2(1:end-1,1:end-1) should be D.z(corner2center(R2))
    end
    
    % stop if no data is present in tile
    if ~any(R2(:))
        returnmessage(OPT.debug,'%-20s %-20s Reason: %s\n',code,'ABORTED','no data in tile');
        continue
    end
    
    % attempt to handle shading flat cases,
    % still does not work correctly though.
    % For curvi-linear grids with nan holes corner2center requires
    % a continuous piece of matrix, we we need to get
    % rid of all intermediate exclusions that works fine with shading interp.
    % In this sketch attempt of a U-shaped curvi-linear grid think of the upper left part:
    %
    %    __
    %   /  \
    %  |  +--\-----+ GE tile
    %   \ |    \   |
    %     \      \ |
    %     | \      \
    %     |   \    | \ a U-shaped curvi-linear grid line
    %     +-----\--+
    %             \
    
    mask1 = any(R'); % can be 0 0 0 1 1 1 0 0 0 1 1 1 in curvi-linear grids, so set all intermediate 0 to 1.
    mask2 = any(R) ;
    ind   = find(mask1==1);if ~isempty(ind);mask1(ind(1):ind(end)) = 1;end
    ind   = find(mask2==1);if ~isempty(ind);mask2(ind(1):ind(end)) = 1;end
    
    if isequal(size(R) - size(D.z),[0 0])
        D2.z  = D.z  (mask1,mask2);
        if isfield(D,'alpha'), D2.alpha = D.alpha(mask1,mask2);end
        
        
    elseif isequal(size(R) - size(D.z),[1 1])
        %                 Rc     =  ceil(corner2center(R));
        mask1c = floor(corner2center1(mask1))==1;
        mask2c = floor(corner2center1(mask2))==1;
        indc   = find(mask1c==1);if ~isempty(indc);mask1c(indc(1):indc(end)) = 1;end
        indc   = find(mask2c==1);if ~isempty(indc);mask2c(indc(1):indc(end)) = 1;end
        D2.z   =  D.z(mask1c,mask2c); % keep one smaller, do not add until plot
        if isfield(D,'alpha'), D2.alpha = D.alpha(mask1c,mask2c);end
    else
        error('we did not imagine this could happen')
    end
    
    if all(isnan(D2.z(:)))
        % stop if no data is present in tile
        returnmessage(OPT.debug,'%-20s %-20s Reason: %s\n',code,'ABORTED','only NAN''s in tile');
        continue
    end
    
    %  assign a subset of data structure D to a new data structure D2
    D2.lat = D.lat(mask1,mask2);
    D2.lon = D.lon(mask1,mask2);
    D2.N   = max(D.lat(:));
    D2.S   = min(D.lat(:));
    D2.W   = min(D.lon(:));
    D2.E   = max(D.lon(:));
    
    if length(code) < OPT.lowestLevel
        returnmessage(OPT.debug,'%-20s %-20s\n',code,'CONTINUING');
        KML_figure_tiler_printTile(code,D2,OPT)
    else
        returnmessage(OPT.debug,'%-20s %-20s',code,'PRINTING TILE');
        printTile(OPT,code,D,D2,R,B)
    end
end
% multiWaitbar('fig2png_print_tile',1);


function printTile(OPT,code,D,D2,R,B)
dNS = OPT.dimExt/OPT.dim*(B.N - B.S);
dWE = OPT.dimExt/OPT.dim*(B.E - B.W);
if isequal(size(R) - size(D.z),[0 0]) % shading interp case
    set(OPT.h ,'CDATA',          D2.z          ,'ZDATA',          D2.z          ,'YDATA',D2.lat,'XDATA',D2.lon); % also CDATA for pcolor objects
else % shading flat case
    set(OPT.h ,'CDATA',addrowcol(D2.z,1,1,-Inf),'ZDATA',addrowcol(D2.z,1,1,-Inf),'YDATA',D2.lat,'XDATA',D2.lon); % also CDATA for pcolor objects
end
if OPT.fixZlim
    % set(OPT.ha,'zlim',[B.W - dWE B.E + dWE] + nanmean(D2.z(:)));
    set(OPT.ha,'zlim',get(OPT.ha,'clim'))
    set(OPT.ha,'DataAspectRatio',[1 1 1]);
end
set(OPT.ha,'YLim',[B.S - dNS B.N + dNS]);
set(OPT.ha,'XLim',[B.W - dWE B.E + dWE]);

if ishandle(OPT.alphaChannel)
    set(OPT.ha_alpha,'YLim',[B.S - dNS B.N + dNS]);
    set(OPT.ha_alpha,'XLim',[B.W - dWE B.E + dWE]);
end



PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' code '.png']);

mergeExistingTiles = false;
% read a previous image if necessary
if OPT.mergeExistingTiles
    if exist(PNGfileName,'file')
        [oldIm ignore oldImAlpha] = imread(PNGfileName); %#ok<*ASGLU>
        % check if oldImAlpha exists, if not, create an
        % alpha image
        if sum(size(oldImAlpha)) == 0
            oldImAlpha = ones(size(oldIm,1),size(oldIm,2));
        end
        mergeExistingTiles = true;
    end
end
% TO DO error when gca has no data at moment of plotting
print(OPT.hf,'-dpng','-r1',PNGfileName);
% if an alpha channel figure is delivered, write this to a
% dummy file!
if ishandle(OPT.alphaChannel)
    print(OPT.hf_alpha,'-dpng','-r1','alphaChannel.png')
end

im   = imread(PNGfileName);
im   = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
mask = bsxfun(@eq,im,reshape(OPT.bgcolor,1,1,3));
mask = repmat(all(mask,3),[1 1 3]);
im(mask) = 0;
% Read the dummy alpha channel file
if ishandle(OPT.alphaChannel)
    im_alpha = imread('alphaChannel.png');
    im_alpha = im_alpha(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
    im_alpha(mask) = 0;
end
% merge data from different tiles
if mergeExistingTiles
    oldIm(~mask) = im(~mask);
    if ishandle(OPT.alphaChannel)
        % Adapt the alpha channel
        ImAlpha = im_alpha(:,:,1);
        oldImAlpha(~mask(:,:,1)) = ImAlpha(~mask(:,:,1));
        ImAlpha = oldImAlpha; % NOT YET TESTED!!!
    end
    im = oldIm;
    mask(repmat(oldImAlpha>0,[1 1 3])) = false;
else
    % If this tile was newly generated, simply use the
    % alphachannel directly from alphaChannel.png
    % alphaChannel while writing tile
    if ishandle(OPT.alphaChannel)
        ImAlpha = im_alpha(:,:,1);
    end
end

% return if no data is present in tile
if all(mask(:))
    delete(PNGfileName)
    returnmessage(OPT.debug,'...TILE DELETED, no data in tile\n');
else
    returnmessage(OPT.debug,'\n');
    % now move image around to color transparent pixels with the value of the
    % nearest neighbour.
    im2       = im;
    im2(mask) = 0;
    im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
        bsxfun(@max,            im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
    im(mask) = im2(mask);
    % Also move alpha channel around to color
    % transparent pixels
    if ishandle(OPT.alphaChannel)
        ImAlpha2  = ImAlpha;
        ImAlpha2(mask(:,:,1)) = 0;
        ImAlpha2 = bsxfun(@max,bsxfun(@max,ImAlpha2([1 1:end-1],[1 1:end-1]),ImAlpha2([2:end end],[1 1:end-1])),...
            bsxfun(@max,            ImAlpha2([2:end end],[2:end end]),ImAlpha2([1 1:end-1],[2:end end])));
        ImAlpha(mask(:,:,1)) = ImAlpha2(mask(:,:,1));
    end
    if ~ishandle(OPT.alphaChannel)
        imwrite(im,PNGfileName,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))),...
            'Author','$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_figure_tiler_printTile.m $'); % NOT 'Transparency' as non-existent pixels have alpha = 0
    else
        % Deliver the alpha channel to the file
        imwrite(im,PNGfileName,'Alpha',ImAlpha,...
            'Author','$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLengines/KML_figure_tiler_printTile.m $'); % NOT 'Transparency' as non-existent pixels have alpha = 0
    end
end

