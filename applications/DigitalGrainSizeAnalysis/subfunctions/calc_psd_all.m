
% calc_psd_all
% calculates PSD for each ROI for each image
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================

dofilt=0;
density=50;
start_size=3;

MotherWav='Morlet';
Args=struct('Pad',1,...      % pad the time series with zeroes (recommended)
    'Dj',1/8,... %8, ...    % this will do dj sub-octaves per octave
    'S0',start_size,...    % this says start at a scale of X pixels
    'J1',[],...
    'Mother',MotherWav);

if length(sample)==1
    
    calc_psd
    
else
    
    wh = waitbar(0,'Please wait, processing all images ...');
    
    for ii=1:length(sample)
        
        if sample(ii).num_roi>0
            
            P=cell(1,sample(ii).num_roi); scale=cell(1,sample(ii).num_roi);
            
            for k=1:sample(ii).num_roi
                
                 [P{k},scale{k}]=get_psd(sample(ii).roi{k},density,Args);
%                [P{k},scale{k}]=get_psd_quick(sample(ii).roi{k},density);

            end
            
            %scalei=min(cellfun(@min,scale)):10:max(cellfun(@max,scale));
            scalei=linspace(min(cellfun(@min,scale)),max(cellfun(@max,scale)),20);
            
            D=zeros(sample(ii).num_roi,length(scalei));
            for k=1:sample(ii).num_roi
                tmp=interp1(scale{k},P{k},scalei);
                tmp(isnan(tmp))=0;
                D(k,:)=tmp./sum(tmp);
            end
            
            clear k tmp P scale h x y
            
            if sample(ii).num_roi>1
                d=(mean(D)./sum(mean(D)))'; d(isnan(d))=0;
                sample(ii).dist=[scalei(:).*sample(ii).resolution,d./sum(d)];
            else
                d=D(:); d(isnan(d))=0;
                sample(ii).dist=[scalei(:).*sample(ii).resolution,d./sum(d)];
            end
            
%             index_keep=1:...
%                 round(interp1(cumsum(sample(ii).dist(:,2)),1:length(cumsum(sample(ii).dist(:,2))),.99));
%             
            index_keep=[1:length(sample(ii).dist)];
            
            sample(ii).dist=sample(ii).dist(index_keep,:);
            sample(ii).dist(:,2)=sample(ii).dist(:,2)./sum(sample(ii).dist(:,2));
            
            [sample(ii).percentiles,sample(ii).geom_moments,...
                sample(ii).arith_moments]=gsdparams(sample(ii).dist(:,2),sample(ii).dist(:,1));
            
            sample(ii).geom_moments(2) = 1000*2^-sample(ii).geom_moments(2);
            
            clear D scalei index_keep
            
            % need to save outputs
            
        else
            
            uiwait(msgbox('Create ROI first!','Warning','modal'));
            
        end
        waitbar(ii/length(sample),wh)
        
    end
    close(wh)
    
end

set(findobj('tag','current_image'),'userdata',sample);


if ~isempty(sample(ix).dist)
    
    h=findobj('Tag','plot_axes');
    axes(h)
    cla(ax2)
    
    bar(sample(ix).dist(1:end,1),sample(ix).dist(1:end,2));
    xlabs=get(ax2,'XTickLabel'); xlabs=str2num(xlabs);
    if xlabs(1)==0
        xlabs(1)=sample(ix).dist(1,1);  
        xlabs=num2str(xlabs); set(ax2,'XTickLabel',xlabs)
    end
    
    if sample(ix).resolution==1
        xlabel('Size (Pixels)')
    else
        xlabel('Size (mm)')
    end
    ylabel('Density')
    axis tight
    set(gca,'ydir','normal')
    text(.7,.92,['Mean = ',num2str(sample(ix).arith_moments(1),3)],'units','normalized','fontsize',7)
    text(.7,.85,['Sorting = ',num2str(sample(ix).arith_moments(2),3)],'units','normalized','fontsize',7)
    text(.7,.78,['Skewness = ',num2str(sample(ix).arith_moments(3),3)],'units','normalized','fontsize',7)
    text(.7,.70,['D_{10} = ',num2str(sample(ix).percentiles(2),3)],'units','normalized','fontsize',7)
    text(.7,.62,['D_{50} = ',num2str(sample(ix).percentiles(5),3)],'units','normalized','fontsize',7)
    text(.7,.54,['D_{90} = ',num2str(sample(ix).percentiles(8),3)],'units','normalized','fontsize',7)
    
    chx = get(ax3,'Children');
    if length(chx)>=2
        chx(end)=[];
        delete(chx)
    end
    
    h=findobj('tag','auto_image');
    
    tmpimage=sample(ix).roi{1};
    [Nv,Nu,blank] = size(tmpimage);
    tmpimage=tmpimage(round((Nv/2)-sample(ix).percentiles(8)*1/sample(ix).resolution):...
        round((Nv/2)+sample(ix).percentiles(8)*1/sample(ix).resolution),...
        round((Nu/2)-sample(ix).percentiles(8)*1/sample(ix).resolution):...
        round((Nu/2)+sample(ix).percentiles(8)*1/sample(ix).resolution));
    [Nv,Nu,blank] = size(tmpimage);
    set(h,'cdata',tmpimage); % make fi
    axes(ax3)
    set(findobj('tag','auto_axes'),'xlim',[0.5 0.5+Nv],...
        'ylim',[0.5 0.5+Nv])
    set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample(ix).resolution))
    set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample(ix).resolution))
    
    grid off
    title('Sample Of Image')
    hold on
    plot([Nv/2 Nv/2],...
        [Nu/2 (Nu/2)+sample(ix).percentiles(5)*1/sample(ix).resolution],'r-','linewidth',2)
    text(Nv/2,Nu/2,'D_{50}','color','g','fontsize',12)
    
    axes(ax)
    
end


clear tmpimage Nv Nu h

set(findobj('tag','current_image'),'userdata',sample);




