function handles = set_add_inf(handles)

    % set_add_inf : initializes additional information (nesthd_gui)


    %
    % Initialise additional information (set the defaults)
    %

    handles.bnd        = nesthd_get_bnd_data(handles.files_hd2{1});
    if isempty(handles.bnd)
        return
    end

    handles.no_bnd     = length(handles.bnd.DATA);
    handles.wlev       = false;
    handles.vel        = false;
    handles.conc       = false;

    for ibnd = 1: handles.no_bnd
       type = lower(handles.bnd.DATA(ibnd).bndtype);
       if type == 'z'
           handles.wlev = true;
           handles.add_inf.a0 = 0.0;
       end
       if type == 'c' || type == 'p' || type == 'r' || type == 'x' || handles.nfs_inf.lstci > 0
           handles.vel = true;
           handles.add_inf.profile='uniform';
           if handles.nfs_inf.kmax > 1
               handles.add_inf.profile = '3d-profile';
           end
       end
    end

    if handles.nfs_inf.lstci > 0
        handles.conc = true;
        handles.l_act = 1;
        for l = 1: handles.nfs_inf.lstci
            handles.add_inf.genconc(l) = true;
            handles.add_inf.add(l)     = 0.;
            handles.add_inf.max(l)     = 100.;
            handles.add_inf.min(l)     = 0.;
        end
    end

