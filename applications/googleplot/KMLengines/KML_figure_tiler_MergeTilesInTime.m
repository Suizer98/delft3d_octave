function KML_figure_tiler_MergeTilesInTime(pathname)
%KML_figure_tiler_MergeTilesInTime subsidiary of KMLfigure_tiler
%
%See also:KMLfigure_tiler

multiWaitbar('Merging',0,'color',[.2 .6 .4],'label','Inquiring number of files...');
allfiles        = findAllFiles(pathname,'pattern_incl','*.png');
allfilescropped = char(allfiles);
token           = strfind(allfilescropped(1,:),'_');
token           = token(end);
allfilescropped = allfilescropped(:,token+1:end-4);
allfilescropped = cellstr(allfilescropped);
multiWaitbar('Merging',0,'label','Merging png files...');
% figure
lastpct = 0;
for i1=2:size(allfiles,1)
    i2 = find(strcmp(allfilescropped(i1),allfilescropped(1:i1-1)),1,'last');
    if any(i2)
        [previous.X, ~, previous.alpha] = imread(allfiles{i2},'png');
        [current.X, ~, current.alpha] = imread(allfiles{i1},'png');
        nn = (current.alpha<255 & previous.alpha>0);
        if any(nn(:))
            weightprevious =  repmat(double(previous.alpha(nn)) ./ (double(current.alpha(nn))+double(previous.alpha(nn))),1,3);
            weightcurrent  =  1-weightprevious;
            
            current.alpha = max(previous.alpha,current.alpha);
            nn             = find(nn);
            ind = repmat(nn,1,3)+repmat([0 1 2] * numel(previous.alpha),length(nn),1);
            %                 h(1) =subplot(1,3,1);
            %                 image(current.X);
            %                 h(2) =subplot(1,3,2);
            %                 image(previous.X);
            current.X(ind) = uint8(double(current.X(ind)) .* weightcurrent + double(previous.X(ind)) .* weightprevious);
            
            nn = find(all(current.X==0,3) & ~all(previous.X==0,3));
            ind = repmat(nn,1,3)+repmat([0 1 2] * numel(previous.alpha),length(nn),1);
            current.X(ind) = previous.X(ind);
            
            
            imwrite(current.X,allfiles{i1},'png','Alpha',current.alpha);
            %                 h(3) = subplot(1,3,3);
            %                 image(current.X);
            %                 linkaxes(h)
            %                 a=1;
        end
    end
    if i1 / size(allfiles,1) * 100 > lastpct
        lastpct = ceil(i1 / size(allfiles,1) * 100 );
        multiWaitbar('Merging',i1 / size(allfiles,1));
    end
end
multiWaitbar('Merging',1);

