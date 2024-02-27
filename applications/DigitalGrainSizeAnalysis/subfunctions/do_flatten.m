
% do_flatten
% flattens current image
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

if length(sample)>1
    
    ButtonName = questdlg('Flatten all images?','Flatten all?', ...
        'Yes','No, just this one', 'Yes');
    
    if strcmp(ButtonName,'Yes')
        wh = waitbar(0,'Please wait, flattening images ...');
        
        for ii=1:length(sample)
            
            if ~sample(ii).flattened
                
                disp('Flattening image ...')
                
                % read data in if not already done so
                if isempty(sample(ii).data)
                    sample(ii).data=fileload(fullfile(image_path,char(sample(ii).name)));
                end
                
                im=sample(ii).data;
                [n,m,p] = size(im);
                % cosine taper
                w = .25; % width of cosine in percent of width of X
                window = repmat(tukeywin(n,w),1,m).*rot90(repmat(tukeywin(m,w),1,n));
                
                for i = 1:p
                    im(:,:,i) = im(:,:,i).*window;
                end
                sample(ii).data=im;
                
                try
                    img=imageresize(sample(ii).data, .5, .5);
                    
                    [rows,cols] = size(img); %sample(ix).data);
                    [x,y] = meshgrid(1:rows,1:cols);
                    P = polyfitn([x(:),y(:)],img(:),2); %sample(ix).data(:),2);
                    zhat = polyvaln(P,[x(:),y(:)]);
                    zhat = reshape(zhat,rows,cols);
                    sample(ii).data=rescale(imageresize(img-zhat,2,2),0,255); %sample(ix).data-zhat,0,255);
                    clear x y P zhat rows cols
                catch
                    disp('Error in flattening image: ran out of memory. Continuing with a slower method')
                    
                    tmp=sample(ii).data; tmp(:,1:2:end)=[]; tmp(1:2:end,:)=[];
                    [rows,cols] = size(tmp);
                    [x,y] = meshgrid(1:rows,1:cols);
                    P = polyfitn([x(:),y(:)],tmp(:),2);
                    zhat = polyvaln(P,[x(:),y(:)]);
                    zhat = reshape(zhat,rows,cols);
                    b = ones(size(zhat)).*NaN;
                    c = reshape([zhat(:) b(:)]',2*size(zhat,1), []);
                    d = ones(size(c)).*NaN; c=c'; d=d';
                    e = reshape([c(:) d(:)]',2*size(c,1), [])';
                    zhat=inpaintn(e,1);
                    sample(ii).data=rescale(sample(ii).data-zhat,0,255);
                    clear x y P zhat rows cols b c d e tmp
                    
                end
                
                sample(ii).flattened = 1;
                
                disp('... done!')
                
                clear h k Nu Nv mag im auto nlags l centx centy
                
                
            end
            waitbar(ii/length(sample),wh)
            
        end
        close(wh)
        
        for ii=1:length(sample)
            sample(ii).dist=[];
            sample(ii).percentiles=[];
            sample(ii).arith_moments=[];
            sample(ii).geom_moments=[];
        end
        %     set(findobj('tag','current_image'),'userdata',sample);
        
        
    else % no just this image
        
        if ~sample(ix).flattened
            
            h = waitbar(0,'Please wait...');
            
            disp('Flattening image ...')
            
            sample(ix).orig_data=sample(ix).data;
            
            try
                
                img=imageresize(sample(ix).data, .5, .5);
                
                [rows,cols] = size(img); %sample(ix).data);
                [x,y] = meshgrid(1:rows,1:cols);
                waitbar(.3,h)
                P = polyfitn([x(:),y(:)],img(:),2); %sample(ix).data(:),2);
                waitbar(.6,h)
                zhat = polyvaln(P,[x(:),y(:)]);
                waitbar(.8,h)
                zhat = reshape(zhat,rows,cols);
                waitbar(.9,h)
                sample(ix).data=rescale(imageresize(img-zhat,2,2),0,255); %sample(ix).data-zhat,0,255);
                clear x y P zhat rows cols
            catch
                disp('Error in flattening image: ran out of memory. Continuing with a slower method')
                
                tmp=sample(ix).data; tmp(:,1:2:end)=[]; tmp(1:2:end,:)=[];
                [rows,cols] = size(tmp);
                [x,y] = meshgrid(1:rows,1:cols);
                waitbar(.3,h)
                P = polyfitn([x(:),y(:)],tmp(:),2);
                zhat = polyvaln(P,[x(:),y(:)]);
                zhat = reshape(zhat,rows,cols);
                waitbar(.5,h)
                b = ones(size(zhat)).*NaN;
                c = reshape([zhat(:) b(:)]',2*size(zhat,1), []);
                d = ones(size(c)).*NaN; c=c'; d=d';
                e = reshape([c(:) d(:)]',2*size(c,1), [])';
                zhat=inpaintn(e,1);
                waitbar(.9,h)
                sample(ix).data=rescale(sample(ix).data-zhat,0,255);
                clear x y P zhat rows cols b c d e tmp
                
            end
            close(h)
            
            sample(ix).flattened = 1;
            
            for k=1:sample(ix).num_roi
                sample(ix).roi{k}=sample(ix).data(min(sample(ix).roi_y{k}):...
                    max(sample(ix).roi_y{k}),...
                    min(sample(ix).roi_x{k}):...
                    max(sample(ix).roi_x{k}));
            end
            
            if ~isempty(sample(ix).dist)
                sample(ix).dist=[];
                sample(ix).percentiles=[];
                sample(ix).arith_moments=[];
                sample(ix).geom_moments=[];
            end
            
        end
        
    end
    
    % set(findobj('tag','current_image'),'userdata',sample);
    
else
    
    if ~sample(ix).flattened
        
        h = waitbar(0,'Please wait...');
        
        disp('Flattening image ...')
        
        sample(ix).orig_data=sample(ix).data;
        
        try
            
            img=imageresize(sample(ix).data, .5, .5);
            
            [rows,cols] = size(img); %sample(ix).data);
            [x,y] = meshgrid(1:rows,1:cols);
            waitbar(.3,h)
            P = polyfitn([x(:),y(:)],img(:),2); %sample(ix).data(:),2);
            waitbar(.6,h)
            zhat = polyvaln(P,[x(:),y(:)]);
            waitbar(.8,h)
            zhat = reshape(zhat,rows,cols);
            waitbar(.9,h)
            sample(ix).data=rescale(imageresize(img-zhat,2,2),0,255); %sample(ix).data-zhat,0,255);
            clear x y P zhat rows cols
        catch
            disp('Error in flattening image: ran out of memory. Continuing with a slower method')
            
            tmp=sample(ix).data; tmp(:,1:2:end)=[]; tmp(1:2:end,:)=[];
            [rows,cols] = size(tmp);
            [x,y] = meshgrid(1:rows,1:cols);
            waitbar(.3,h)
            P = polyfitn([x(:),y(:)],tmp(:),2);
            zhat = polyvaln(P,[x(:),y(:)]);
            zhat = reshape(zhat,rows,cols);
            waitbar(.5,h)
            b = ones(size(zhat)).*NaN;
            c = reshape([zhat(:) b(:)]',2*size(zhat,1), []);
            d = ones(size(c)).*NaN; c=c'; d=d';
            e = reshape([c(:) d(:)]',2*size(c,1), [])';
            zhat=inpaintn(e,1);
            waitbar(.9,h)
            sample(ix).data=rescale(sample(ix).data-zhat,0,255);
            clear x y P zhat rows cols b c d e tmp
            
        end
        close(h)
        
        sample(ix).flattened = 1;
        
        for k=1:sample(ix).num_roi
            sample(ix).roi{k}=sample(ix).data(min(sample(ix).roi_y{k}):...
                max(sample(ix).roi_y{k}),...
                min(sample(ix).roi_x{k}):...
                max(sample(ix).roi_x{k}));
        end
        
        if ~isempty(sample(ix).dist)
            sample(ix).dist=[];
            sample(ix).percentiles=[];
            sample(ix).arith_moments=[];
            sample(ix).geom_moments=[];
        end
        
    end
    
    
end


[Nv,Nu,blank] = size(sample(ix).data);
% calculate 2D autocorrel
im=sample(ix).data(1:min(Nu,Nv),1:min(Nu,Nv));
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

sample(ix).auto = auto;
[Nv,blank,blank] = size(sample(ix).auto);

h=findobj('tag','auto_image');

chx = get(ax3,'Children');
if length(chx)>=2
    chx(end)=[];
    delete(chx)
end
axes(ax3)
title('')

set(h,'userdata',sample);
set(h,'cdata',sample(ix).auto); % make fi

set(findobj('tag','auto_axes'),'xlim',[-2 2+Nv],...
    'ylim',[-2 2+Nv])
% on axes and labels
% set(findobj('tag','image'),'xlim',[0.5 Nu+0.5],'ylim',[0.5 Nv+.5])
grid off
title('2D autocorrelation')


set(findobj('tag','current_image'),'userdata',sample);
set(findobj('tag','current_image'),'cdata',sample(ix).data);
disp('... done!')

clear h k Nu Nv mag im auto nlags l centx centy




