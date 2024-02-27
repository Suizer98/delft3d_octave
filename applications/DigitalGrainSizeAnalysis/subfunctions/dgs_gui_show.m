function dgs_gui_show(sample)

if ~exist('sample','var')
    objSelectBox = findobj('tag','PickImage');
    objImage     = findobj('tag','current_image');

    ix = get(objSelectBox,'value');
    sample = get(objImage,'userdata');
    sample = sample(ix);
end

if ~isempty(sample.name)
    
    if isempty(sample.data)
        sample.data=fileload(sample);
    end

    set(findobj('tag','current_image'),'cdata',sample.data); colormap(gray);

    % set resolution bar to whatever the resolution actually is
    set(findobj('tag','res'),'String',num2str(sample.resolution));

    % remove plotted roi lines from previous image
    ax = findobj('Tag','im_axes1');
    ax2 = findobj('Tag','plot_axes');
    ax3 = findobj('Tag','auto_axes');
    chx = get(ax,'Children');
    if length(chx)>=2
        chx(end)=[];
        delete(chx)
    end

    % update title
    % a=get(findobj('tag','im_axes1'),'title');
    % set(get(findobj('tag','im_axes1'),'title'),'string',char(sample.name));

    h=findobj('tag','current_image');
    set(h,'cdata',sample.data); % make first image appear

    [Nv,Nu,blank] = size(sample.data);
    set(h,'xdata',1:Nu); % scales and labels
    set(h,'ydata',1:Nv);

    set(ax,'ylim',[1,size(sample.data,1)])
    set(ax,'xlim',[1,size(sample.data,2)])

    % if navigating back, draw roi lines back on
    if sample.num_roi>0
        for k=1:sample.num_roi
            sample.roi_line{k} = line(sample.roi_x{k},sample.roi_y{k},'color','red','linewidth',2);
        end
    end

    % first set axes ticks to be increments of 500
    set(ax,'ytick',linspace(1,size(sample.data,1),2))
    set(ax,'xtick',linspace(1,size(sample.data,2),2))
    % scale current x and y labels
    set(ax,'xticklabels',num2str(get(ax,'xtick')'.*sample.resolution))
    set(ax,'yticklabels',num2str(get(ax,'ytick')'.*sample.resolution))
    % axis tight

    if isfield(sample,'roi_line')
        if iscell(sample.roi_line)
        sample.roi_line{1} = line(sample.roi_x{1},...
            sample.roi_y{1},'color','red','linewidth',5);
        end
    end

   if ~isfield(sample,'auto') || isempty(sample.auto)

        chx = get(ax3,'Children');
        if length(chx)>=2
            chx(end)=[];
            delete(chx)
        end
        axes(ax3)
        title('')

        [Nv,Nu,blank] = size(sample.data);

        % calculate 2D autocorrel
        im=sample.data(1:min(Nu,Nv),1:min(Nu,Nv));
        % 2D-FFT transform on de-meaned image
        % power spectrum
        mag=abs(fft2(fftshift(im-mean(im(:))))).^2;
        %Shift zero-frequency component to centre of spectrum
        auto=fftshift(real(ifft2(mag)));
        auto = auto./max(auto(:));

        [centx,centy] = find(auto==1);
        % spectify number of lags to compute
        l = length(auto);
        nlags=round(l/8);
        % centre 2d autocorrelogram
        auto = auto(centx-nlags:centx+nlags,centy-nlags:centy+nlags);

        sample.auto = auto;
        [Nv,blank,blank] = size(sample.auto);

        h=findobj('tag','auto_image');

        set(h,'userdata',sample);
        set(h,'cdata',sample.auto); % make fi

        set(findobj('tag','auto_axes'),'xlim',[-2 2+Nv],...
            'ylim',[-2 2+Nv])
        grid off
        title('2D autocorrelation')
        axes(ax)

    end
    %         cla(ax3)
    if ~isempty(sample.dist)

        %     cla(ax3)
        chx = get(ax3,'Children');
        if length(chx)>=2
            chx(end)=[];
            delete(chx)
        end

        h=findobj('tag','auto_image');

        tmpimage=sample.roi{1};
        [Nv,Nu,blank] = size(tmpimage);
        tmpimage=tmpimage(round((Nv/2)-sample.percentiles(8)*1/sample.resolution):...
            round((Nv/2)+sample.percentiles(8)*1/sample.resolution),...
            round((Nu/2)-sample.percentiles(8)*1/sample.resolution):...
            round((Nu/2)+sample.percentiles(8)*1/sample.resolution));
        [Nv,Nu,blank] = size(tmpimage);
        set(h,'cdata',tmpimage); % make fi
        axes(ax3)
        set(findobj('tag','auto_axes'),'xlim',[-2 2+Nv],...
            'ylim',[-2 2+Nv])
        set(ax3,'xticklabels',num2str(get(ax3,'xtick')'.*sample.resolution))
        set(ax3,'yticklabels',num2str(get(ax3,'ytick')'.*sample.resolution))

        grid off
        title('Sample Of Image')
        hold on
        plot([Nv/2 Nv/2],...
            [Nu/2 (Nu/2)+sample.percentiles(5)*1/sample.resolution],'r-','linewidth',2)
        text(Nv/2,Nu/2,'D_{50}','color','g','fontsize',12)

    else
        chx = get(ax3,'Children');
        if length(chx)>=2
            chx(end)=[];
            delete(chx)
        end
        [Nv,blank,blank] = size(sample.auto);

        h=findobj('tag','auto_image');

        set(h,'userdata',sample);
        set(h,'cdata',sample.auto); % make fi

        set(findobj('tag','auto_axes'),'xlim',[-2 2+Nv],...
            'ylim',[-2 2+Nv])
        grid off
        axes(ax3)
        title('2D autocorrelation')
    end
    axes(ax)


    if ~isempty(sample.dist)

        cla(ax2)

        h=findobj('Tag','plot_axes');
        axes(h)
        bar(sample.dist(:,1),sample.dist(:,2))
        if sample.resolution==1
            xlabel('Size (Pixels)')
        else
            xlabel('Size (mm)')
        end
        ylabel('Density')
        axis tight
        set(gca,'ydir','normal')
        text(.7,.92,['Mean = ',num2str(sample.arith_moments(1),3)],'units','normalized','fontsize',7)
        text(.7,.85,['Sorting = ',num2str(sample.arith_moments(2),3)],'units','normalized','fontsize',7)
        text(.7,.78,['Skewness = ',num2str(sample.arith_moments(3),3)],'units','normalized','fontsize',7)
        text(.7,.70,['D_{10} = ',num2str(sample.percentiles(2),3)],'units','normalized','fontsize',7)
        text(.7,.62,['D_{50} = ',num2str(sample.percentiles(5),3)],'units','normalized','fontsize',7)
        text(.7,.54,['D_{90} = ',num2str(sample.percentiles(8),3)],'units','normalized','fontsize',7)
        grid off
        axes(ax2)
        title('Size Distribution')
        axes(ax)

    else
        cla(ax2)
        title('')
    end
    
end