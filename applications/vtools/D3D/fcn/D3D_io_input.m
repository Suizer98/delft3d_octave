%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18415 $
%$Date: 2022-10-10 19:07:38 +0800 (Mon, 10 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_io_input.m 18415 2022-10-10 11:07:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
%write:
%   pli:
%       -pli.name: name of the polyline (char) or number of the polyline (double)
%       -pli.xy: coordinates
%e.g.
% dep=D3D_io_input('read',fdep,fgrd,'location','cor');
% D3D_io_input('write','c:\Users\chavarri\Downloads\trial.dep',dep,'location','cor','dummy',false,'format','%15.13e');
%
%e.g. Interpolating bed level to D3D4 grid:
%
% dep=D3D_io_input('read',fpath_dep);
% grd=D3D_io_input('read',fpath_grd_d3d4,'location','cor');
% 
% F=scatteredInterpolant(dep(:,1),dep(:,2),dep(:,3));
% dep_int=F(grd.cend.x,grd.cend.y);
% 
% grd.cor.dep=-dep_int(1:end-1,1:end-1);
% 
% D3D_io_input('write',fpath_dep_out,grd,'location','cor');

function varargout=D3D_io_input(what_do,fname,varargin)

%% cell 

if iscell(fname)
    F=@(X)fileparts_ext(X);
    ext_c=cellfun(F,fname,'UniformOutput',false);
    idx_ext=find_str_in_cell(ext_c,ext_c(1));
    nf=numel(fname);
    if numel(idx_ext)~=nf
        error('Not all files in the cell array have the same extension')
    end
    
    kf=1;
    stru_out_all=D3D_io_input(what_do,fname{kf},varargin{:});
    for kf=2:nf
        stru_out_loc=D3D_io_input(what_do,fname{kf},varargin{:});
        if isstruct(stru_out_loc)
%             if numel(stru_out_loc)==1
%                 error('do concatenation of variables')
%             else %concatenation of structures
                stru_out_all=[stru_out_all;stru_out_loc];
%             end
            
        end
        
    end
    varargout{1,1}=stru_out_all;
    return
end

%% char
if ~ischar(fname)
    error('fname should be char')
end
[~,~,ext]=fileparts(fname);

switch what_do
    case 'read'
        if exist(fname,'file')~=2
            error('File does not exist: %s',fname)
        end
        switch ext
            case '.mdf'
                stru_out=delft3d_io_mdf('read',fname);
            case '.mdu'
                stru_out=dflowfm_io_mdu('read',fname);
            case {'.sed','.mor'}
                stru_out=delft3d_io_sed(fname);
            case {'.pli','.pliz','.pol','.ldb'}
                stru_out=D3D_read_polys(fname,varargin{:});
            case '.ini'
                stru_out=delft3d_io_sed(fname);
                cstype=parse_ini(stru_out);
                if ~isnan(cstype)
                    [~,stru_out]=S3_read_crosssectiondefinitions(fname,'file_type',cstype);
                end
            case '.grd'
                OPT.nodatavalue=NaN;
                stru_out=delft3d_io_grd('read',fname,OPT);
            case '.dep'
                G=delft3d_io_grd('read',varargin{1});
                stru_out=delft3d_io_dep('read',fname,G,varargin(2:3));
%                 G=wlgrid('read',varargin{1});
%                 stru_out=wldep('read',fname,G);
            case {'.bct','.bc'}
                stru_out=bct_io('read',fname);
                for kT=1:stru_out.NTables
                    idx_tim=find_str_in_cell({stru_out.Table(kT).Parameter.Name},{'time'});
                    if isnan(idx_tim)
                        warning('Time not found')
                        continue
                    end
                    str_time=stru_out.Table(kT).Parameter(idx_tim).Unit;
                    [tim_ref_dtim,units,~,~]=read_str_time(str_time);
%                     tim_ref=num2str(stru_out.Table(kT).ReferenceTime(1));
%                     tim_ref_dtim=datetime(str2double(tim_ref(1:4)),str2double(tim_ref(5:6)),str2double(tim_ref(7:8)));
%                     units=stru_out.Table(kT).TimeUnit;
                    tim_data=stru_out.Table(kT).Data(:,idx_tim);
                    switch units
                        case 'seconds'
                            tim_un=seconds(tim_data);
                        case 'minutes'
                            tim_un=minutes(tim_data);
                        otherwise
                            error('add')
                    end
                    tim_dtim=tim_ref_dtim+tim_un;
                    stru_out.Table(kT).Time=tim_dtim;
                end
            case '.xyz'
%                 stru_out=dflowfm_io_xydata('read',fname); %extremely slow
                stru_out=readmatrix(fname,'FileType','text');
                if size(stru_out,2)>3
                    messageOut(NaN,'The file seems to have a weir delimiter and cannot read it properly. Trying in a different way.')
                    [xyz_all,err]=read_xyz(fname);
                    if err~=1
                        stru_out=xyz_all;
                    end
                end

            case '.xyn'
                stru_out=D3D_read_xyn(fname,varargin{:});
            case '.ext'
                stru_out=delft3d_io_sed(fname); %there are repeated blocks, so we cannot use dflowfm_io_mdu
            case '.sob'
                a=readcell(fname,'FileType','text');
                aux2=cellfun(@(X)datetime(X,'InputFormat','yyyy/MM/dd;HH:mm:ss'),a(:,1));
                val=cell2mat(a(:,2));
                stru_out.tim=aux2;
                stru_out.val=val;
%                 figure; hold on; plot(aux2,val)
            case '.shp'
                stru_out=shp2struct(fname,varargin{:});
            case '.tim'
                if nargin~=3
                    error('You need to specify the reference date as input')
                end
                tim=readmatrix(fname,'filetype','text');
                stru_out.tim=varargin{1}+minutes(tim(:,1));
                stru_out.val=tim(:,2:end);
            case '.sub'
                %%
                ksub=0;
                kpar=0;
                fid=fopen(fname);
                while ~feof(fid)
                    lin=fgetl(fid);
                    if strcmp(lin(1:3),'sub')
                        ksub=ksub+1;
                        tok=regexp(lin,'''','split');
                        stru_out.substance(ksub).name=tok{1,2};
                    end
                    if strcmp(lin(1:3),'par')
                        kpar=kpar+1;
                        tok=regexp(lin,'''','split');
                        stru_out.parameter(kpar).name=tok{1,2};
                        lin=fgetl(fid);
                        while ~strcmp(lin(1:13),'end-parameter')
                            lin=deblankstart(lin);
                            tok=regexp(lin,'''','split');
                            if numel(tok)>1 %char
                                stru_out.parameter(kpar).(deblank(tok{1,1}))=tok{1,2};
                            else
                                tok=regexp(lin,' ','split');
                                stru_out.parameter(kpar).(deblank(tok{1,1}))=str2double(tok{1,end});
                            end
                            lin=fgetl(fid);
                        end
                    end
                end
                fclose(fid);
            otherwise
                error('Extension %s in file %s not available for reading',ext,fname)
        end %ext
        varargout{1}=stru_out;
    case 'write'
        stru_in=varargin{1};
        switch ext
            case {'.mdu','.mor','.sed','.ext','.ini'}
                if strcmp(ext,'.ini')
                    cstype=NaN;
                    if isfield(stru_in,'id') %cross-sectional type of structure. It may not be strong enough.
                        if isfield(stru_in,'chainage')
                            cstype=3;
                        else
                            cstype=2;
                        end
                    end
                    if ~isnan(cstype)
                        [fdir,fname]=fileparts(fname);
                        simdef.D3D.dire_sim=fdir;
                        switch cstype
                            case 2 %definition
                                simdef.csd=stru_in;
                                D3D_crosssectiondefinitions(simdef,'fname',sprintf('%s.ini',fname));
                            case 3 %location
                                simdef.csl=stru_in;
                                D3D_crosssectionlocation(simdef,'fname',sprintf('%s.ini',fname));
                        end
                    end
                else
                    dflowfm_io_mdu('write',fname,stru_in);
                end
            case {'.mdf'}
                delft3d_io_mdf('write',fname,stru_in.keywords);
            case {'.pli','.ldb','.pol','.pliz'}
%                 stru_in(kpol).name: double or string
%                 stru_in(kpol).xy: [np,2] array with x-coordinate (:,1) and y-coordinate (:,2)
                D3D_write_polys(fname,stru_in);
            case '.dep'
                delft3d_io_dep('write',fname,stru_in,varargin(2:end));
            case '.bct'
                stru_in.file.bct=fname;
                D3D_bct(stru_in);
            case '.bc'
% stru_in.name
% stru_in.function
% stru_in.time_interpolation
% stru_in.quantity
% stru_in.unit
% stru_in.val
                if isfield(stru_in,'Check') %read from 
                    stru_in=D3D_table_d3d4_to_FM(stru_in);
                end
                D3D_write_bc(fname,stru_in)
            case '.xyz'
%                 D3D_io_input('write',xyz)
%                 xyz(:,1) = x-coordinate
%                 xyz(:,2) = y-coordinate
%                 xyz(:,3) = z-coordinate
                fid=fopen(fname,'w');
                ndep=size(stru_in,1);
                for kl=1:ndep
                    fprintf(fid,' %14.7f %14.7f %14.13f \n',stru_in(kl,1),stru_in(kl,2),stru_in(kl,3));
                end
                fclose(fid);
                
            case '.xyn'
                fid=fopen(fname,'w');
                ndep=numel(stru_in);
                for kl=1:ndep
                    fprintf(fid,' %14.7f %14.7f %s \n',stru_in(kl).x,stru_in(kl).y,stru_in(kl).name);
                end
                fclose(fid);
%                 messageOut(NaN,sprintf('File written: %s',fname));
            case '.shp'
                shapewrite(fname,'polyline',{stru_in.xy},{})  
%                 messageOut(NaN,sprintf('File written: %s',fname));
            case '' %writing a series of tim files
%                 D3D_io_input('write',dire_out,stru_in,reftime);
%                 dire_out = folder to write  
%                 stru_in = same structure as for bc
%                 reftime = datetime of the mdu file
                ref_date=varargin{2}; %all time series must have the reference date of the mdu
                ns=numel(stru_in);
                for ks=1:ns
                    idx_all=1:1:numel(stru_in(ks).quantity);
                    [idx_tim,bol_tim]=find_str_in_cell(stru_in(ks).quantity,{'time'});
                    idx_val=idx_all(~bol_tim);
                    str_tim=stru_in(ks).unit{idx_tim};
                    [t0,unit]=read_str_time(str_tim);
                    tim_val=stru_in(ks).val(:,idx_tim);
                    switch unit
                        case 'seconds'
                            data_loc(ks).tim=t0+seconds(tim_val);
                        case 'minutes'
                            data_loc(ks).tim=t0+minutes(tim_val);
                        otherwise
                            error('add')
                    end
                    data_loc(ks).val=stru_in(ks).val(:,idx_val);
                    data_loc(ks).quantity=stru_in(ks).quantity;
                end
                fname_tim_v={stru_in.name};
                %not sure if needed
%                 if nargin<6
%                     D3D_write_tim_2(data_loc,fname,fname_tim_v,ref_date)
%                 else
                    D3D_write_tim_2(data_loc,fname,fname_tim_v,ref_date,varargin{3:end})
%                 end
            otherwise
                error('Extension %s in file %s not available for writing',ext,fname)
        end
        messageOut(NaN,sprintf('File written: %s',fname));
end

end %function

%%
%%
%%

function ext=fileparts_ext(fname)

[~,~,ext]=fileparts(fname);

end %function

%%

function cstype=parse_ini(stru_out)

cstype=NaN;
if isfield(stru_out,'General') 
    cstype=1;
    str_gen='General';
elseif isfield(stru_out,'general') 
    cstype=1;
    str_gen='general';                    
end
if ~isnan(cstype)
    if isfield(stru_out.(str_gen),'fileType') %maybe also non-capital? we need a general way of dealing with it
        switch stru_out.(str_gen).fileType
            case 'crossDef'
                cstype=2;
            case 'crossLoc'
                cstype=3;
        end
    else
        cstype=NaN;
        messageOut(NaN,'It is an ini-file with [general] block, but I cannot find the <fileType>')
    end
end
                
end %function