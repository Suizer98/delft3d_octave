
% un_flatten
% reverses any previous flattening on this image
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

% get current image
% and current image data
sample=get(findobj('tag','current_image'),'userdata');

if sample(ix).flattened %|| ~sample(ix).filtered
    
    
    if isfield(sample(ix),'orig_data')
        sample(ix).data=sample(ix).orig_data;
        sample(ix).orig_data=[];
    end
    sample(ix).flattened = 0;
    
    set(findobj('tag','current_image'),'cdata',sample(ix).data);
    set(findobj('tag','current_image'),'userdata',sample);

    if isempty(sample(ix).data)
        dgs_gui_swopsimages
    end
    
    sample=get(findobj('tag','current_image'),'userdata');
    
    for k=1:sample(ix).num_roi
        sample(ix).roi{k}=sample(ix).data(min(sample(ix).roi_y{k}):...
            max(sample(ix).roi_y{k}),...
            min(sample(ix).roi_x{k}):...
            max(sample(ix).roi_x{k}));
    end
    
    [Nv,Nu,blank] = size(sample(ix).data);
    % calculate 2D autocorrel
    im=sample(ix).data(1:min(Nu,Nv),1:min(Nu,Nv));
    % 2D-FFT transform on de-meaned image
    % power spectrum
    mag=abs(fft2(im-mean(im(:)))).^2;
    %Shift zero-frequency component to centre of spectrum
    auto=fftshift(real(ifft2(mag)));
    auto = auto./max(auto(:));
    
    [centx,centy] = find(auto==1);
    % spectify number of lags to compute
    l = length(auto);
    nlags=round(l/8);
    % centre 2d autocorrelogram
    auto = auto(centx-nlags:centx+nlags,centy-nlags:centy+nlags);
    
    sample(ix).auto = auto;
    [Nv,Nu,blank] = size(sample(ix).auto);
    
    h=findobj('tag','auto_image');
    
    chx = get(ax3,'Children');
    if length(chx)>=2
        chx(end)=[];
        delete(chx)
    end
    axes(ax3)
    title('')
    
    sample=get(findobj('tag','current_image'),'userdata');
    set(h,'userdata',sample);
    set(h,'cdata',sample(ix).auto); % make fi
    
    set(findobj('tag','auto_axes'),'xlim',[-2 2+Nv],...
        'ylim',[-2 2+Nv])
    % on axes and labels
    % set(findobj('tag','image'),'xlim',[0.5 Nu+0.5],'ylim',[0.5 Nv+.5])
    grid off
    title('2D autocorrelation')
    
    
    set(findobj('tag','current_image'),'cdata',sample(ix).data);
    set(findobj('tag','current_image'),'userdata',sample);
    
    clear Nu Nv mag im auto nlags l centx centy
    
    uiwait(msgbox('filter removed',' '));
    
else
    uiwait(msgbox('image not been flattened',' '));
    
end
