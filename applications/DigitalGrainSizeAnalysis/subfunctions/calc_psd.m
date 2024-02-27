
% calc_psd
% calculates PSD for each ROI
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

if sample(ix).num_roi>0
    
    P=cell(1,sample(ix).num_roi); scale=cell(1,sample(ix).num_roi);
    
    h = waitbar(0,'Please wait...');
    for k=1:sample(ix).num_roi
        
        [P{k},scale{k}]=get_psd(sample(ix).roi{k},density,Args);
%         [P{k},scale{k}]=get_psd_quick(sample(ix).roi{k},density);
        
        waitbar(k/sample(ix).num_roi,h)
        
    end
    close(h)
    
    scalei=linspace(min(cellfun(@min,scale)),max(cellfun(@max,scale)),20);
    
    D=zeros(sample(ix).num_roi,length(scalei));
    for k=1:sample(ix).num_roi
        tmp=interp1(scale{k},P{k},scalei);
        tmp(isnan(tmp))=0;
        D(k,:)=tmp./sum(tmp);
    end
    
    clear k tmp P scale h x y
    
    if sample(ix).num_roi>1
        sample(ix).dist=[scalei(:).*sample(ix).resolution,(mean(D)./sum(mean(D)))'];
    else
        sample(ix).dist=[scalei(:).*sample(ix).resolution,D(:)];
    end
%     
%     index_keep=1:...
%         round(interp1(cumsum(sample(ix).dist(:,2)),1:length(cumsum(sample(ix).dist(:,2))),.99));
%     
    index_keep=[1:length(sample(ix).dist)];
    
    sample(ix).dist=sample(ix).dist(index_keep,:);
    sample(ix).dist(:,2)=sample(ix).dist(:,2)./sum(sample(ix).dist(:,2));
    
    [sample(ix).percentiles,sample(ix).geom_moments,...
        sample(ix).arith_moments]=gsdparams(sample(ix).dist(:,2),sample(ix).dist(:,1));
    
    sample(ix).geom_moments(2) = 1000*2^-sample(ix).geom_moments(2);
    
    clear D scalei index_keep
    
    h=findobj('Tag','plot_axes');
    axes(h)
    cla(ax2)
    bar(sample(ix).dist(1:end,1),sample(ix).dist(1:end,2))
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
    set(findobj('tag','current_image'),'userdata',sample);
    
    clear tmpimage Nv Nu h
    
    % need to save outputs
    
else
    
    uiwait(msgbox('Create ROI first!','Warning','modal'));
    
end

