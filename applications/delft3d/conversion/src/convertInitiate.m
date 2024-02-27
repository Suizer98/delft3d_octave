% Read the input path
inputdir              = get(handles.edit1,'String');

% Read the mdf filename
mdffile               = get(handles.edit3,'String');
mdffile               = deblank2(mdffile);
if isempty(mdffile);
    if exist('wb'); close(wb); end;
    errordlg('No mdf-file specified.','Error');
%     break;
else
    if length(mdffile) > 3;
        if ~strcmp(mdffile(end-3:end),'.mdf');
            mdffile    = [mdffile,'.mdf'];
            set(handles.edit3,'String',mdffile);
        end
    end
    mdfexist          = [inputdir,'\',mdffile];
    if exist(mdfexist,'file')==0;
        errordlg('The specified mdf file does not exist.','Error');
%         break;
    end
end

% Read the mdu filename
mdufile               = get(handles.edit4,'String');
if isempty(mdufile);
    mdufile           = mdffile(1:end-4);
    mdufile           = [mdufile,'.mdu'];
    set(handles.edit4,'String',mdufile);
else
    if length(mdufile) > 3;
        if ~strcmp(mdufile(end-3:end),'.mdu');
            mdufile    = [mdufile,'.mdu'];
            set(handles.edit4,'String',mdufile);
        end
    end
end
mducore               = mdufile(1:end-4);

% Read the mdf-file
mdfcontents           = delft3d_io_mdf('read',[inputdir,'\',mdffile]);
mdfkeywds             = mdfcontents.keywords;




%%%%%% FIRST: THE MDF-FILE

%%% Panel GEOMETRY

% Check if grd file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filcco') | isfield(mdfkeywds,'filcco');
    set(handles.edit5,'String',mdfkeywds.filcco);
end

% Check if enc file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filgrd') | isfield(mdfkeywds,'filgrd');
    set(handles.edit6,'String',mdfkeywds.filgrd);
end

% Check if dep file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Fildep') | isfield(mdfkeywds,'fildep');
    set(handles.edit7,'String',mdfkeywds.fildep);
end



%%% Panel BOUNDARIES

% Check if bnd file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filbnd') | isfield(mdfkeywds,'filbnd');
    set(handles.edit9,'String',mdfkeywds.filbnd);
end



%%% Panel BOUNDARY DATA

% Check if bct file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilbcT') | isfield(mdfkeywds,'filbct');
    set(handles.edit11,'String',mdfkeywds.filbct);
end

% Check if bca file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilAna') | isfield(mdfkeywds,'filana');
    set(handles.edit12,'String',mdfkeywds.filana);
end

% Check if bch file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilbcH') | isfield(mdfkeywds,'filbch');
    set(handles.edit13,'String',mdfkeywds.filbch);
end

% Read the mdf file (only to check if salinity is included)
if isfield(mdfkeywds,'sub1') == 1;
    finds            = find(mdfkeywds.sub1 == 'S');
    if isempty(finds);
        salinity     = false;
    else
        salinity     = true;
    end
else
    salinity         = false;
end

% Check if bcc file is specified in mdf file; if yes, then put name in edit box
if (isfield(mdfkeywds,'FilbcC') | isfield(mdfkeywds,'filbcc')) & salinity == true;
    set(handles.edit14,'String',mdfkeywds.filbcc);
end



%%% Panel WIND

% Check if wnd file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filwnd') | isfield(mdfkeywds,'filwnd');
    set(handles.edit32,'String',mdfkeywds.filwnd);
end

% Check if spw file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filweb') | isfield(mdfkeywds,'filweb');
    set(handles.edit34,'String',mdfkeywds.filweb);
end



%%% Panel ADDITIONAL FILES

% Check if obs file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilSta') | isfield(mdfkeywds,'filsta');
    set(handles.edit15,'String',mdfkeywds.filsta);
end

% Check if crs file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilCrs') | isfield(mdfkeywds,'filcrs');
    set(handles.edit16,'String',mdfkeywds.filcrs);
end

% Check if rgh file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilRgh') | isfield(mdfkeywds,'filrgh');
    set(handles.edit17,'String',mdfkeywds.filrgh);
end

% Check if edy file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilEdy') | isfield(mdfkeywds,'filedy');
    set(handles.edit18,'String',mdfkeywds.filedy);
end

% Check if dry file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilDry') | isfield(mdfkeywds,'fildry');
    set(handles.edit19,'String',mdfkeywds.fildry);
end

% Check if thd file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilTd' ) | isfield(mdfkeywds,'filtd' );
    set(handles.edit20,'String',mdfkeywds.filtd );
end

% Check if ini file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'FilIc' ) | isfield(mdfkeywds,'filic' );
    set(handles.edit21,'String',mdfkeywds.filic );
end

% Check if 2dw file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Fil2dw') | isfield(mdfkeywds,'fil2dw');
    set(handles.edit36,'String',mdfkeywds.fil2dw);
end




%%%%%% SECOND: THE MDU-FILE

%%% Panel GEOMETRY

% Check if grd file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'Filcco') | isfield(mdfkeywds,'filcco');
    set(handles.edit8,'String',[mducore,'_net.nc']);
end

% Check if grd file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'Filcco') | isfield(mdfkeywds,'filcco');
    set(handles.edit30,'String',[mducore,'_bed.xyz']);
end



%%% Panel BOUNDARIES

% Check if bnd file is specified in mdf file; if yes, apply mdu core name
set(handles.edit10,'String',[mducore,'.ext']);



%%% Panel WIND

% Check if wnd file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filwnd') | isfield(mdfkeywds,'filwnd');
    if ~isempty(get(handles.edit32,'String'));
        set(handles.edit33,'String',[mdfkeywds.filwnd]);
    end
end

% Check if spw file is specified in mdf file; if yes, then put name in edit box
if isfield(mdfkeywds,'Filweb') | isfield(mdfkeywds,'filweb');
    if ~isempty(get(handles.edit34,'String'));
        set(handles.edit35,'String',[mdfkeywds.filweb]);
    end
end



%%% Panel ADDITIONAL FILES

% Check if obs file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilSta') | isfield(mdfkeywds,'filsta');
    if ~isempty(deblank2(get(handles.edit15,'String')));
        set(handles.edit22,'String',[mducore,'_obs.xyn']);
    end
end

% Check if crs file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilCrs') | isfield(mdfkeywds,'filcrs');
    if ~isempty(deblank2(get(handles.edit16,'String')));
        set(handles.edit31,'String',[mducore,'_crs.pli']);
    end
end

% Check if rgh file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilRgh') | isfield(mdfkeywds,'filrgh');
    if ~isempty(deblank2(get(handles.edit17,'String')));
        set(handles.edit24,'String',[mducore,'_rgh.xyz']);
    end
end

% Check if edy file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilEdy') | isfield(mdfkeywds,'filedy');
    if ~isempty(deblank2(get(handles.edit18,'String')));
        set(handles.edit25,'String',[mducore,'_edy.xyz']);
    end
end

% Check if thd file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilTd' ) | isfield(mdfkeywds,'filtd' );
    if ~isempty(deblank2(get(handles.edit20,'String')));
        set(handles.edit27,'String',[mducore,'_thd.pli']);
    end
end

% Check if dry file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilDry') | isfield(mdfkeywds,'fildry');
    if ~isempty(deblank2(get(handles.edit19,'String')));              
        set(handles.edit27,'String',[mducore,'_thd.pli']);
    end
end

% Check if ini file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'FilIc' ) | isfield(mdfkeywds,'filic' );
    if ~isempty(deblank2(get(handles.edit21,'String')));
        set(handles.edit28,'String',[mducore,'_ini.xyz']);
    end
end

% Check if 2dw file is specified in mdf file; if yes, apply mdu core name
if isfield(mdfkeywds,'Fil2dw') | isfield(mdfkeywds,'fil2dw');
    if ~isempty(deblank2(get(handles.edit36,'String')));
        set(handles.edit37,'String',[mducore,'_tdk.pli']);
    end
end


%%%%%% THIRD: EMPTY THE LISTBOXESS

% Enable the listboxes
set(handles.listbox1 ,'Enable','on');
set(handles.listbox2 ,'Enable','on');
set(handles.listbox3 ,'Enable','on');
set(handles.listbox4 ,'Enable','on');
set(handles.listbox5 ,'Enable','on');

% Empty the listboxes
set(handles.listbox1 ,'String',' ');
set(handles.listbox2 ,'String',' ');
set(handles.listbox3 ,'String',' ');
set(handles.listbox4 ,'String',' ');
set(handles.listbox5 ,'String',' ');

% Select first entry
set(handles.listbox1 ,'Value',1);
set(handles.listbox2 ,'Value',1);
set(handles.listbox3 ,'Value',1);
set(handles.listbox4 ,'Value',1);
set(handles.listbox5 ,'Value',1);