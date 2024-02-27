function nc_animate(url,vars,ti)


if ~iscell(vars); vars = {vars}; end;

n = length(vars);
nx = ceil(sqrt(n));
ny = ceil(n/nx);

time = nc_varget(url,'globaltime');
x = nc_varget(url,'globalx');
y = nc_varget(url,'y');

data0 = struct();

figure;

ttitle = annotation('textbox',[0 .95 1 .05],'String','', ...
        'HorizontalAlignment','center','LineStyle','none');
    
clim = struct();

if ~exist('ti','var')
    ti = 0:length(time)-1;
end

for t = ti
    if time(t+1)>1e10; continue; end;
    
    for i = 1:length(vars)
        var = vars{i};
        
        show_diff = false;
        ext = '';
        if var(1) == '~'
            show_diff = true;
            ext = '\Delta';
            var = var(2:end);
        end
        
        if nc_isvar(url,var)
            varinfo = nc_getvarinfo(url,var);

            if strcmpi([varinfo.Dimension{:}],'globaltimeyx')
                data = nc_varget(url,var,[t 0 0],[1 -1 -1]);
                
                if show_diff
                    if t == ti(1)
                        data0.(var) = data;
                        data = nan(size(data));
                    else
                        data = data - data0.(var);
                    end
                end
                
                if ~isfield(clim,var) || ~any(clim.(var))
                    clim.(var) = [floor(min(min(data))) ceil(max(max(data)))];
                    if any(isnan(clim.(var))); clim.(var) = [0 0]; end;
                end
                
                subplot(ny,nx,i); pcolor(x,y,data);
                shading flat; title([ext var]);
                caxis(clim.(var)); colorbar;
            end
        end
    end
    
    if ishandle(ttitle)
        set(ttitle,'String',['t = ' num2str(time(t+1)) ...
            ' (' num2str(round(100*t/(length(time)-1))) '%)']);
    end
    
    drawnow;
end