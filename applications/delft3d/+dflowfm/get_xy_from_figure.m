% get (x,y) values from a figure "ifig" by a mouse click
function pol=get_xy_from_figure(ifig)
    global pol_
    global user_done_
    user_done_ = false;
    fprintf('Click two or more points for slice and confirm with right mouse click...');
    figure(ifig);
    pol_.x = [];
    pol_.y = [];
    
    set_props(ifig,ifig)
    while (~user_done_)
        pause(1)
    end
    pol = pol_;
end

function set_props(h, ifig)
    if ( strcmp(get(h,'type'), 'axes') )
        set(h,'ButtonDownFcn',{@get_xy,ifig})
    else
        set(h,'hittest','off')
    end
    hChildren=get(h,'Children');
    for i=1:length(hChildren)
        set_props(hChildren(i), ifig)
    end

end


function get_xy(src,eventdata,parentfig)
    global pol_
    global user_done_
    if ( strcmp(get(parentfig, 'SelectionType'), 'alt') )
        user_done_ = true;
        return
    end
    % Else: user is still clicking points:
    val=get(src,'CurrentPoint');
    pol_.x = [pol_.x; val(1,1,1)];
    pol_.y = [pol_.y; val(1,2,1)];
    
    if ( length(pol_.x)>1 )
        line(pol_.x,pol_.y)
    end
end