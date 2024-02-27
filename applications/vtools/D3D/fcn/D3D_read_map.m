%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17514 $
%$Date: 2021-10-04 15:15:38 +0800 (Mon, 04 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_read_map.m 17514 2021-10-04 07:15:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_map.m $
%
%get data from 1 time step in D3D, output name as in D3D

function out=D3D_read_map(simdef,in)


%% RENAME in

file=simdef.file;
flg=simdef.flg;

kt=in.kt;    
ky=in.ky;
kx=in.kx;
kf=in.kf;
kl=in.kl;
nl=in.nl;

%% DEFAULT

if isfield(flg,'zerosarenan')==0
    flg.zerosarenan=0;
end

if isfield(flg,'mean_type')==0
    flg.mean_type=1;
end

if isfield(flg,'get_EHY')==0
    flg.get_EHY=0;
end
if file.partitions>1
    flg.get_EHY=1;
end
if flg.get_EHY
    flg.which_s=0;
end
if isfield(flg,'lan')==0
    flg.lan='en';
end

%% results structure

NFStruct=vs_use(file.map,'quiet');

ismor=D3D_is(file.map);

%HELP
% vs_let(NFStruct,'-cmdhelp') %map file
% vs_disp(NFStruct)
% [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1)

%% domain size and input
    %time
[time_r,time_mor_r,time_dnum]=D3D_results_time(file.map,ismor,kt);

% ITMAPC=vs_let(NFStruct,'map-info-series','ITMAPC','quiet'); %results time vector
% out.nTt=numel(ITMAPC);
%     %x
% MMAX=vs_let(NFStruct,'map-const','MMAX','quiet'); 
% out.MMAX=MMAX; 
%     %y
% NMAX=vs_let(NFStruct,'map-const','NMAX','quiet');
% out.NMAX=NMAX; 
%     %k
% KMAX=vs_let(NFStruct,'map-const','KMAX','quiet');
% out.KMAX=KMAX; 
    %sediment
if isfield(file,'sed')
dchar=D3D_read_sed(file.sed); %characteristic grain size per fraction (ATTENTION! bug in 'delft3d_io_sed.m' function)
% dchar=sqrt(dlimits(1,:).*dlimits(2,:));
nf=numel(dchar); %number of sediment fractions
% out.nf=nf;
end
%     %number of substrate layers
% if isempty(vs_find(NFStruct,'LYRFRAC')) %if it does not exists, there is one layer
%     nl=1;
% else 
%     LYRFRAC=vs_let(NFStruct,'map-sed-series',{1},'LYRFRAC','quiet'); %fractions at layers [-] (t,y,x,l,f)
%     nl=size(LYRFRAC,4); 
% end
% out.nl=nl;
    %secondary flow
% mdf=delft3d_io_mdf('read',file.mdf); %gives error?
% if isempty(strfind(mdf.keywords.sub1,'I'))
%     secflow=0;
% else
%     secflow=1;
% end
secflow=0;


% morpho=1;
% % if isfield(file,'mor')==0
% if isnan(find_str_in_cell({NFStruct.GrpDat.Name},{'map-infsed-serie'}))
%     morpho=0;
% end

%done after
% if isfield(flg,'zerosarenan')==0
%     flg.zerosarenan=0;
% end
  
%% plot input

mean_type=flg.mean_type;
% mean_type=1; %dg
% if flg.which_v==3
%     mean_type=2; 
% end

if isfield(flg,'elliptic')==0
    flg.elliptic=0; 
else
    
end

% if kt==0 %only give domain size as output
%     warning('do we reach this point?')
%     flg.which_v=-1;
%     flg.which_p=-1;
% else
    nT=numel(kt);
%     out.nT=nT;
    ny=numel(ky);
%     out.ny=ny;
    nx=numel(kx);
%     out.nx=nx;
    nF=numel(kf);
%     out.nF=nF;
% end


    %% time and space
if flg.which_p~=-1 
% TUNIT=vs_let(NFStruct,'map-const','TUNIT','quiet'); %dt unit
% DT=vs_let(NFStruct,'map-const','DT','quiet'); %dt
% time_r=ITMAPC*DT*TUNIT; %results time vector [s]
% if morpho==1
%     MORFT=vs_let(NFStruct,'map-infsed-serie','MORFT','quiet'); %morphological time (days since start)
%     time_r_morpho=MORFT*24*3600; %seconds
% end



if flg.get_EHY
    gridInfo=EHY_getGridInfo(file.map,{'face_nodes_xy','XYcen','face_nodes','XYcor'});
    Xcen=gridInfo.Xcen;
    Ycen=gridInfo.Ycen;
    Xcor=gridInfo.Xcor;
    Ycor=gridInfo.Ycor;
else
    XZ=vs_let(NFStruct,'map-const','XZ',{ky,kx},'quiet'); %x coordinate at z point [m]
    YZ=vs_let(NFStruct,'map-const','YZ',{ky,kx},'quiet'); %y coordinate at z point [m]

    % KCS=vs_let(NFStruct,'map-const','KCS',{ky,kx},'quiet'); 

    XCOR=vs_let(NFStruct,'map-const','XCOR','quiet'); %x coordinate at cell borders [m]
    % XCOR=reshape(XCOR,in.NMAX,in.MMAX)';
    XCOR=squeeze(XCOR);
    YCOR=vs_let(NFStruct,'map-const','YCOR','quiet'); %y coordinate at cell borders [m]
    YCOR=squeeze(YCOR);
    % YCOR=reshape(YCOR,in.NMAX,in.MMAX)';

    out.XCOR=XCOR;
    out.YCOR=YCOR;

    %coordinates of velocity points
%     XU=XCOR(:,1:end-1)+(XCOR(:,2:end)-XCOR(:,1:end-1))/2;
%     YU=YCOR(:,1:end-1)+(YCOR(:,2:end)-YCOR(:,1:end-1))/2;
%     XV=XCOR(1:end-1,:)+(XCOR(2:end,:)-XCOR(1:end-1,:))/2;
%     YV=YCOR(1:end-1,:)+(YCOR(2:end,:)-YCOR(1:end-1,:))/2;
% 
%     THICK=vs_let(NFStruct,'map-const','THICK','quiet'); %Fraction part of layer thickness of total water-height [ .01*% ]

    if flg.zerosarenan
        XZ(XZ==0)=NaN;
        YZ(YZ==0)=NaN;
        XCOR(XCOR==0)=NaN;
        YCOR(YCOR==0)=NaN;
    end
end


end


    %% vars

switch flg.which_p
    case -1 %nothing
        
    case 1 %3D bed elevation and gsd
        %%
        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
        LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
        
        %bed level at z point
        bl=-DPS; %(because positive is downward for D3D depth)
        
        %mean grain size
        dm=mean_grain_size(LYRFRAC,dchar,mean_type);
        
        %output
        out.XZ=reshape(XZ,ny,nx);
        out.YZ=reshape(YZ,ny,nx);
        out.bl=reshape(bl,ny,nx);
            out.bl(1,:)=NaN;
            out.bl(end,:)=NaN;
        out.cvar=reshape(dm(1,:,:,1),ny,nx);   
        out.time_r=time_r(kt); 
        
    case {2,3,5,6,8,9,19} %2DH & 1D
        %%
        switch flg.which_v
            case 0 
            case 1 %etab
                %%
                if flg.get_EHY
                    z=get_EHY(file.map,'dps',time_dnum);
                    out=v2struct(z,Xcor,Ycor,time_r,Xcen,Ycen,nT,nx,ny,flg,kt);
                else
                    DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                    z=-DPS;
                    out=out_var_2DH(z,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                end
                out.zlabel='bed elevation [m]';
            case 2 %h (flow depth at z point)
                %%
                switch ismor
                    case 0
                        DPS=vs_let(NFStruct,'map-const','DP0',{ky,kx},'quiet');
                    case 1
                        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                end
                
                S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
                
                dp=S1+DPS;
                dp(dp==0)=NaN;
                out=out_var_2DH(dp,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                out.zlabel='flow depth [m]';    
            case {3,26} %dm,dg
                %%
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,kl,1:nf},'quiet'); %fractions at top layer [-] (t,y,x,l,f)
                
                dm=mean_grain_size(LYRFRAC,dchar,mean_type);
                dm(dm==1)=NaN;
                
                %output                
                out=out_var_2DH(dm,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                switch flg.which_v
                    case 3
                        out.zlabel=labels4all('dm',1,flg.lan);    
                    case 26
                        out.zlabel=labels4all('dg',1,flg.lan);    
                end
                
            case 4 %dm fIk
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
                DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
                
                fIk=find_substrate(LYRFRAC,DP_BEDLYR);
                dm=mean_grain_size(fIk,dchar,mean_type);
                                
                %output
                switch flg.which_p
                    case 2
                       %output                
                        out.z=reshape(dm,ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        out.time_r=time_r(kt);
                    case 5
                        out.z=reshape(fIk(:,:,1:end-2,kf),nT,nx-2);
                        out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
                        out.YZ=time_r;
                end                
            case 5 %fIk
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
                DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
                
                fIk=find_substrate(LYRFRAC,DP_BEDLYR);
                                
                %output
                switch flg.which_p
                    case 5
                        out.z=reshape(fIk(:,:,1:end-2,kf),nT,nx-2);
                        out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
                        out.YZ=time_r;
                end
            case 6 %I
                I=vs_let(NFStruct,'map-series',{kt},'R1',{ky,kx,1,1},'quiet');
                
                %output                
                out.z=reshape(I,ny,nx);
                out.XZ=reshape(XZ,ny,nx);
                out.YZ=reshape(YZ,ny,nx);
                out.time_r=time_r(kt);
                switch flg.which_p
                    case 2
                        out.z (1,:)=NaN;
                        out.z (end,:)=NaN;                     
                end
            case 7 %elliptic
                HIRCHK=vs_let(NFStruct,'map-sed-series',{kt},'HIRCHK',{ky,kx},'quiet'); %Hyperbolic/Elliptic Hirano model [-]
                HIRCHK(HIRCHK==-999)=NaN;
                
                if flg.which_p==8
                    HIRCHK=cumulative_elliptic(HIRCHK); %make it cumulative
                end
                
                %output
                out.z=reshape(HIRCHK,ny,nx);
                out.XZ=reshape(XZ,ny,nx);
                out.YZ=reshape(YZ,ny,nx);
                out.time_r=time_r(kt);
                switch flg.which_p
                    case {2,8}
                        out.z (1,:)=NaN;
                        out.z (end,:)=NaN;                     
                end
            case 8 %Fak
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1,kf},'quiet'); %fractions at top layer [-] (t,y,x,l,f)
                
                %output                
                out=out_var_2DH(LYRFRAC,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                
%                 out.z=reshape(LYRFRAC,ny,nx,nF);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case 2
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
                out.zlabel=sprintf('volume fraction content in the active layer of fraction %d [-]',kf);
            case 9 %detrended etab based on etab_0
                DPS_0=vs_let(NFStruct,'map-sed-series',{1} ,'DPS',{ky,kx},'quiet'); %depth at z point [m]
                DPS  =vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                
                %output
                switch flg.which_p
                    case 2
                        out.z=reshape(-DPS-(-DPS_0),ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        out.time_r=time_r(kt);
                        out.z (1,:)=NaN;
                        out.z (end,:)=NaN;                     
                    case 3
                        out.z=reshape(-DPS-(-DPS_0),ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        out.time_r=time_r(kt);
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
                    case 6
                        ndim=max(nx,ny);
                        out.z=reshape(-DPS-(-DPS_0),nT,ndim);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        out.time_r=time_r(kt);                   
                end
                out.zlabel='relative bed elevation [m]';
            case 10
%                 U1=vs_get(NFStruct,'map-series',{kt},'U1',{ky,kx,KMAX},'quiet'); %velocity in x direction at u point [m/s]
%                 V1=vs_get(NFStruct,'map-series',{kt},'V1',{ky,kx,KMAX},'quiet'); %velocity in y direction at v point [m/s]
                
                  data = qpread(NFStruct,1,'depth averaged velocity','data',kt,kx,ky);
                  u=sqrt(data.XComp.^2+data.YComp.^2);

                switch ismor
                    case 0
                        DPS=vs_let(NFStruct,'map-const','DP0',{ky,kx},'quiet');
                    case 1
                        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                end
                
                S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
                
                %flow depth at z point
                dp=S1+DPS;
                
                dp_r=reshape(dp,ny,nx)';
                u(dp_r==0)=NaN; 
                
%                 aa=qpfopen(file.map);
%                 DATA = qpread(NFStruct,'Val1')
%                 DATA = qpread(aa,'domains')+
%                  [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1) 
%                  [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1,'depth averaged velocity','data') 
%                  data = qpread(NFStruct,1,'depth averaged velocity','data') 
%                  
%                  data = qpread(NFStruct,1,'depth averaged velocity','data','griddata') 
%                 DATA = qpread(file.map,aa,'depth averaged velocity','griddata')
%                 DATA = qpread(file.map,aa,'depth averaged velocity','griddata',,T,S,M,N,K)
%                 d3d_qp('selectfile',file.map)
%                 d3d_qp('selectfield','depth averaged velocity')
%                 d3d_qp('editt',kt)
%                 d3d_qp('editm',kx)
%                 d3d_qp('editn',ky)
%                 d3d_qp('exportdata','C:\Users\chavarri\Downloads\temp.mat')
%                 
                out.z=u';
%                 out.z=u;
%                 switch flg.which_p
%                     case 2
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
                out.zlabel='depth-averaged velocity [m/s]';
                out.XZ=reshape(XZ,ny,nx);
                out.YZ=reshape(YZ,ny,nx);
                out.time_r=time_r(kt);
            case 11
                switch simdef.flg.which_p
                    case 2 %2DH
                        %u
                        U1=vs_let(NFStruct,'map-series',{kt},'U1',{ky,kx,kl},'quiet');
                        V1=vs_let(NFStruct,'map-series',{kt},'V1',{ky,kx,kl},'quiet');
                        %xy
%                         data = qpread(NFStruct,1,'velocity','data',kt,kx,ky);
                        
                        %save
%                         out.ucx_s=data.XComp;
%                         out.ucy_s=data.YComp;
%                         out.ucz_s=data.ZComp;
% %                         out.uc_norm=uc_norm;
%                         out.x_face_s=in.pol.x;
%                         out.y_face_s=in.pol.y;
%                         out.z_face_s=z_face_s;
                        out.XZ=XZ;
                        out.YZ=YZ;
                        out.U1=squeeze(U1);
                        out.V1=squeeze(V1);
                        out.time_r=time_r(kt); 
                        out.zlabel='velocity [m/s]';

                    case 9 %2DV
                
                data = qpread(NFStruct,1,'velocity','data',kt,kx,ky);
                ucx=data.XComp;
                ucy=data.YComp;
                ucz=data.ZComp;
                data = qpread(NFStruct,1,'velocity','griddata',kt); %I do not know how to get the griddata and the kt I want at the same time
                xcordvel=data.X(:,:,1);
                ycordvel=data.Y(:,:,1);
                zcordvel=data.Z;

                %% get from coordinates directly
                if simdef.flg.interp_u==1
                ucx_s=squeeze(ucx)';
                ucy_s=squeeze(ucy)';
                ucz_s=squeeze(ucz)';
                uc_norm=sqrt(ucx_s.^2+ucy_s.^2+ucz_s.^2);
                in.pol.x=xcordvel(kx,ky);
                in.pol.y=ycordvel(kx,ky);
                z_face_s=squeeze(zcordvel(kx,ky,:))';
                error('we have to go to patch data for correctly plotting it...')
                end
                %% interplate 2D
%                 if 0
%                 uc_norm=NaN(KMAX,npcs);
%                 ucx_s=NaN(KMAX,npcs);
%                 ucy_s=NaN(KMAX,npcs);
%                 ucz_s=NaN(KMAX,npcs);
%                 z_face_s=NaN(KMAX,npcs);
%                 for kfl=1:KMAX
% %                     FU1=scatteredInterpolant(reshape(XU(1:end-1,1:end-1),[],1),reshape(YU(1:end-1,1:end-1),[],1),reshape(U1(:,2:end-1,1:end-1,kfl),[],1));
% %                     FV1=scatteredInterpolant(reshape(XV(1:end-1,1:end-1),[],1),reshape(YV(1:end-1,1:end-1),[],1),reshape(V1(:,1:end-1,2:end-1,kfl),[],1));
% %                     FW =scatteredInterpolant(reshape(XZ(:,2:end-1,1:end),[],1),reshape(YZ(:,2:end-1,1:end),[],1),reshape(WPHY(:,2:end-1,1:end,kfl),[],1));
%                     FU1=scatteredInterpolant(reshape(xcordvel(2:end-1,2:end-1),[],1),reshape(ycordvel(2:end-1,2:end-1),[],1),reshape(ucx(2:end-1,2:end-1,kfl),[],1));
%                     FV1=scatteredInterpolant(reshape(xcordvel(2:end-1,2:end-1),[],1),reshape(ycordvel(2:end-1,2:end-1),[],1),reshape(ucy(2:end-1,2:end-1,kfl),[],1));
%                     FW =scatteredInterpolant(reshape(xcordvel(2:end-1,2:end-1),[],1),reshape(ycordvel(2:end-1,2:end-1),[],1),reshape(ucz(2:end-1,2:end-1,kfl),[],1));
%                     
%                     FZ =scatteredInterpolant(reshape(xcordvel(2:end-1,2:end-1),[],1),reshape(ycordvel(2:end-1,2:end-1),[],1),reshape(zcordvel(2:end-1,2:end-1,kfl),[],1));
%                     
%                     ucx_s(kfl,:)=FU1(in.pol.x,in.pol.y);
%                     ucy_s(kfl,:)=FV1(in.pol.x,in.pol.y);
%                     ucz_s(kfl,:)= FW(in.pol.x,in.pol.y);
% 
%                     uc_norm(kfl,:)=sqrt(ucx_s(kfl,:).^2+ucy_s(kfl,:).^2+ucz_s(kfl,:).^2);
%                     
%                     z_face_s(kfl,:)=FZ(in.pol.x,in.pol.y);
% 
%                 end
%                 end
                %% interpolate 3D
                
                if simdef.flg.interp_u==3
                    npcs=numel(in.pol.y);
                npiz=3*KMAX; 
 
                uc_norm=NaN(npiz,npcs);
                ucx_s=NaN(npiz,npcs);
                ucy_s=NaN(npiz,npcs);
                ucz_s=NaN(npiz,npcs);
                z_face_s=NaN(npiz,npcs);
                
                xmin=min(in.pol.x);
                xmax=max(in.pol.x);
                ymin=min(in.pol.y);
                ymax=max(in.pol.y);
                
                epsilon=0.25; %we should use something like 2dx. Compute dx base on area of cells or similar
                
                idx_take=xcordvel(:)<xmax+epsilon & xcordvel(:)>xmin-epsilon & ycordvel(:)<ymax+epsilon & ycordvel(:)>ymin-epsilon;
%                 idx_pos=1:1:numel(idx_take);
%                 idx_pos=idx_pos(idx_take);
%                 [row,col]=ind2sub(size(xcordvel),idx_pos);

% ucx_lin=NaN(size(ucx(:,:,1)));
% ucy_lin=NaN(size(ucx(:,:,1)));
% ucz_lin=NaN(size(ucx(:,:,1)));
% zcordvel_lin=NaN(size(ucx(:,:,1)));
% 
npint=sum(idx_take);
ucx_mat=NaN(npint,KMAX);
ucy_mat=NaN(npint,KMAX);
ucz_mat=NaN(npint,KMAX);
zcordvel_mat=NaN(npint,KMAX);
                for kfl=1:KMAX
                    ucx_lin=ucx(:,:,kfl);
                    ucx_mat(:,kfl)=ucx_lin(idx_take);
                    
                    ucy_lin=ucy(:,:,kfl);
                    ucy_mat(:,kfl)=ucy_lin(idx_take);
                    
                    ucz_lin=ucz(:,:,kfl);
                    ucz_mat(:,kfl)=ucz_lin(idx_take);
                    
                    zcordvel_lin=zcordvel(:,:,kfl);
                    zcordvel_mat(:,kfl)=zcordvel_lin(idx_take);
                    
                end
                
                
                FU1=scatteredInterpolant(repmat(xcordvel(idx_take),KMAX,1),repmat(ycordvel(idx_take),KMAX,1),zcordvel_mat(:),ucx_mat(:),'linear','nearest');  
                FV1=scatteredInterpolant(repmat(xcordvel(idx_take),KMAX,1),repmat(ycordvel(idx_take),KMAX,1),zcordvel_mat(:),ucy_mat(:),'linear','nearest');  
                FW =scatteredInterpolant(repmat(xcordvel(idx_take),KMAX,1),repmat(ycordvel(idx_take),KMAX,1),zcordvel_mat(:),ucz_mat(:),'linear','nearest');  
                
                x_face_s=repmat(in.pol.x,npiz,1); 
                y_face_s=repmat(in.pol.y,npiz,1); 
                
                %this one if morphology!
%                 DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                DPS=vs_let(NFStruct,'map-const',{1},'DPS0',{ky,kx},'quiet'); %depth at z point [m]
                S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
 
                
                Fwl=scatteredInterpolant(XZ(idx_take),YZ(idx_take),S1(idx_take));
                Fbl=scatteredInterpolant(XZ(idx_take),YZ(idx_take),-DPS(idx_take));
                
                wl_cs=Fwl(in.pol.x,in.pol.y);
                bl_cs=Fbl(in.pol.x,in.pol.y);
                for kpcs=1:npcs
                    z_face_s(:,kpcs)=linspace(wl_cs(kpcs),bl_cs(kpcs),npiz);
                end
                
                ucx_i=FU1(x_face_s(:),y_face_s(:),z_face_s(:));
                ucy_i=FV1(x_face_s(:),y_face_s(:),z_face_s(:));
                ucz_i=FW (x_face_s(:),y_face_s(:),z_face_s(:));
                
                ucx_s=reshape(ucx_i,npiz,npcs);
                ucy_s=reshape(ucy_i,npiz,npcs);
                ucz_s=reshape(ucz_i,npiz,npcs);
                
                end
                %%
                out.ucx_s=ucx_s;
                out.ucy_s=ucy_s;
                out.ucz_s=ucz_s;
                out.uc_norm=uc_norm;
                out.x_face_s=in.pol.x;
                out.y_face_s=in.pol.y;
                out.z_face_s=z_face_s;
                
                out.time_r=time_r(kt); 
                out.zlabel='velocity [m/s]';
                end
                %%
%                 data = qpread(NFStruct,1,'velocity','griddata',kt)
%                 U1=vs_let(NFStruct,'map-series',{kt},'U1','quiet'); %U-velocity per layer in U-point [-] (fl,y,x) (m-component)
%                 V1=vs_let(NFStruct,'map-series',{kt},'V1','quiet'); %V-velocity per layer in V-point [-] (fl,y,x) (n-component)
%                 WPHY=vs_let(NFStruct,'map-series',{kt},'WPHY','quiet'); %W-velocity per layer in zeta point [-] (fl,y,x)
%                 DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%                 S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
                
                
                %flow depth at z point
%                 dp=S1+DPS;
% %                 dp(dp==0)=NaN;
                
                %output                


                %interpolate cell center (comparison with FM)
%                 FDP=scatteredInterpolant(reshape(XZ(:,2:end-1,1:end),[],1),reshape(YZ(:,2:end-1,1:end),[],1),reshape(dp(:,2:end-1,1:end),[],1));
%                 FS1=scatteredInterpolant(reshape(XZ(:,2:end-1,1:end),[],1),reshape(YZ(:,2:end-1,1:end),[],1),reshape(S1(:,2:end-1,1:end),[],1));
%                 DP_cs=FDP(in.pol.x,in.pol.y);
%                 S1_cs=FS1(in.pol.x,in.pol.y);
%                 
%                 aux_dp_rel1=[0,cumsum(THICK)];
%                 aux_dp_rel=aux_dp_rel1(1:end-1)+(aux_dp_rel1(2:end)-aux_dp_rel1(1:end-1))/2;
%                 dp_rel=DP_cs.*aux_dp_rel';
% 
%                 z_face_s=S1_cs-dp_rel;
%                         xz=squeeze(XZ);
%         yz=squeeze(YZ);
%         u=squeeze(U1(:,:,:,1));
%         xz=xz(2:end-1,1:end-1);
%         yz=yz(2:end-1,1:end-1);
%         u=u(2:end-1,1:end-1);
%         figure
%         surf(xz,yz,u,'edgecolor','none')
%         colorbar
%         view([0,90])
%         %%
%         figure
%         ucx_aux=ucx(:,:,1);
%         ucx_aux=-DPS;
%         scatter(xcordvel(idx_take),ycordvel(idx_take),10,ucx_aux(idx_take),'filled')
%         colorbar
% %         view([0,90])
%         colormap('jet')
%         %%
%         figure
% %         surf(xcordvel,ycordvel,ucx(:,:,1),'edgecolor','none')
%         surf(xcordvel,ycordvel,-squeeze(DPS)','edgecolor','none')
%         colorbar
%         view([0,90])
%         colormap('jet')
            case 12 %water level
                switch ismor
                    case 0
                        DPS=vs_let(NFStruct,'map-const','DP0',{ky,kx},'quiet');
                    case 1
                        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                end
                
                S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
                
                %flow depth at z point
                dp=S1+DPS;
                S1(dp==0)=NaN; 
                
                
                %output                
%                 switch flg.which_s
%                     case 1
                out.z=reshape(S1,ny,nx);
                out.XZ=reshape(XZ,ny,nx);
                out.YZ=reshape(YZ,ny,nx);
                out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case 2
% %                         out.z (1,:)=NaN;
% %                         out.z (end,:)=NaN;                     
%                 end
                out.zlabel='water level [m]';                
%                     case 4
%                 xcords=XCOR(1:end-1,1:end-1);
%                 ycords=YCOR(1:end-1,1:end-1);
%                     aux=reshape(dp,ny,nx);
%                 center_data=aux(2:end-1,2:end-1)';
%                 
%                 [faces,vertices,col]=patchFormat(xcords,ycords,center_data);
% 
%                 out.z=col;
%                 out.x_node=vertices(:,1);
%                 out.y_node=vertices(:,2);
% %                 out.x_face=x_face;
% %                 out.y_face=y_face;
%                 out.XZ=reshape(XZ,ny,nx); %this is useful for plot limits
%                 out.YZ=reshape(YZ,ny,nx); %this is useful for plot limits
%                 out.faces=faces;
%                 out.time_r=time_r(kt); 
%                 out.zlabel='flow depth [m]';
%                 end
            case 16
                
                  data = qpread(NFStruct,1,'depth averaged velocity','data',kt,kx,ky);
                  u=sqrt(data.XComp.^2+data.YComp.^2);

                switch ismor
                    case 0
                        DPS=vs_let(NFStruct,'map-const','DP0',{ky,kx},'quiet');
                    case 1
                        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                end
                
                S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
                
                %flow depth at z point
                dp=S1+DPS;
                
                dp_r=reshape(dp,ny,nx);
                u=u';
                u(dp_r==0)=NaN; 
                q=u.*dp_r;
             
                out.z=q;

                out.zlabel='specific water discharge [m^2/s]';
                out.XZ=reshape(XZ,ny,nx);
                out.YZ=reshape(YZ,ny,nx);
                out.time_r=time_r(kt);
            case 17
                DPS0=vs_let(NFStruct,'map-sed-series',{1},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                z=-DPS+DPS0;
                out=out_var_2DH(z,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                out.zlabel='bed elevation change [m]';
                out.zlabel_code='detab';
                out.time_r=time_r_morpho(kt);
            case 19 %bed load transport
                SBUU=vs_get(NFStruct,'map-sed-series',{kt},'SBUU',{ky,kx,kf},'quiet'); %bed load transport excluding pores per fraction in x direction at u point [m^2/s]
                SBVV=vs_get(NFStruct,'map-sed-series',{kt},'SBVV',{ky,kx,kf},'quiet'); %bed load transport excluding pores per fraction in y direction at v point [m^2/s]
                z=sqrt(SBUU.^2+SBVV.^2);
                out=out_var_2DH(z,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                out.zlabel='bedload transport magnitude [m^2/s]';
            case 33 %cell area
                z=vs_let(NFStruct,'map-const',{1},'GSQS',{ky,kx},'quiet'); 
                out=out_var_2DH(z,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt);
                out.zlabel='cell area [m^2]';
                
            otherwise
                error('You are asking for plotting an unexisting variable')
        end %flg.which_v
        out.kf=kf;
        
        %%

        
    case 4 %patch
        %%
        LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
        
        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
        
        %bed level at z point
        bl=-DPS; %(because positive is downward for D3D depth)        
        
        %substrate elevation
        isdpbedlyr=find_str_in_cell({NFStruct.ElmDef.Name},{'DP_BEDLYR'});
        if ~isnan(isdpbedlyr)
            DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
            sub=repmat(bl,1,1,1,nl+1)-DP_BEDLYR;
        else
            nt=1;
%             THLYR=vs_let(NFStruct,'map-sed-series',{kt},'THLYR',{ky,kx},'quiet'); %thickness of layers [m] THIS OUTPUT HAS DISAPPEARED! 
            THLYR=vs_let(NFStruct,'map-sed-series',{kt},'THLYR',{ky,kx,1:1:nl},'quiet'); %thickness of layers [m] THIS OUTPUT HAS DISAPPEARED! 
            lay_abspos=repmat(bl,1,1,1,nl)-cumsum(THLYR,4);
            sub=NaN(nt,ny,nx,nl);
            sub(:,:,:,1   )=bl; 
            sub(:,:,:,2:nl+1)=lay_abspos(:,:,:,1:end);
        end
        
        %mean grain size
        dm=mean_grain_size(LYRFRAC,dchar,mean_type);
                        
        %output
        xc_a=XCOR(ky,kx);
        yc_a=YCOR(ky,kx);
        s=sqrt((xc_a-xc_a(1)).^2+(yc_a-yc_a(1)).^2);
        s=s(1:end-1);
%         out.XZ=celledges(XZ);
        out.XZ=s;
        
        nmax=max(nx,ny);
        if nmax==nx
            out.sub=reshape(sub(:,:,2:end-1,:),nmax-2,nl+1)';
            switch flg.which_v
                case 8
                    out.cvar=reshape(LYRFRAC(:,:,2:end-1,:,kf),nmax-2,nl)';
                case {3,26}
                    out.cvar=reshape(dm(:,:,2:end-1,:),nmax-2,nl)';
                otherwise
                    error('2 or 3')
            end
        else
            out.sub=reshape(sub(:,2:end-1,:,:),nmax-2,nl+1)';
            switch flg.which_v
                case 8
                    out.cvar=reshape(LYRFRAC(:,2:end-1,:,:,kf),nmax-2,nl)';
                case {3,26}
                    out.cvar=reshape(dm(:,2:end-1,:),nmax-2,nl)';
                otherwise
                    error('2 or 3')
            end
        end


        out.kf=kf;
%         out.time_r=time_r(kt);
    case 7 % 0D
        LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
        DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
        S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
        U1=vs_let(NFStruct,'map-series',{kt},'U1',{ky,kx,1},'quiet'); %velocity in x direction at u point [m/s]
        V1=vs_let(NFStruct,'map-series',{kt},'V1',{ky,kx,1},'quiet'); %velocity in y direction at v point [m/s]
        SBUU=vs_get(NFStruct,'map-sed-series',{kt},'SBUU',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in x direction at u point [m3/s]
        SBVV=vs_get(NFStruct,'map-sed-series',{kt},'SBVV',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in y direction at v point [m3/s]
                
        dp=S1+DPS; %flow depth        
        fIk=find_substrate(LYRFRAC,DP_BEDLYR); %interface
        thklyr=layer_thickness(DP_BEDLYR);
        
        %output
        out.Fak=reshape(LYRFRAC(:,:,:,1,:),1,nf);
        out.La =reshape(thklyr (:,:,:,1,:),1, 1);
        out.fIk=reshape(fIk,1,nf);
        out.SBUU=reshape(SBUU,1,nf);
        out.SBVV=reshape(SBVV,1,nf);
        out.dp=reshape(dp,1,1);
        out.U1=reshape(U1,1,1);
        out.V1=reshape(V1,1,1);

    otherwise
        %%
        error('ups...')
end
 
%elliptic output
if flg.which_p~=-1 && flg.elliptic==2
    HIRCHK=vs_let(NFStruct,'map-sed-series',{kt},'HIRCHK',{ky,kx},'quiet'); %Hyperbolic/Elliptic Hirano model [-]
    switch flg.which_p
        case 1
            HIRCHK=reshape(HIRCHK,ny,nx);
            HIRCHK(1,:)=NaN;
            HIRCHK(end,:)=NaN;
        case 5
            HIRCHK=reshape(HIRCHK(:,:,1:end-2),nT,nx-2);
            HIRCHK(1,:)=NaN;
        case 7 %0D
            HIRJCU=vs_let(NFStruct,'map-sed-series',{kt},'HIRJCU',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in u-direction (no sec flow in the indeces!)
            HIRJCV=vs_let(NFStruct,'map-sed-series',{kt},'HIRJCV',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in v-direction (no sec flow in the indeces!)
            
            HIRCHK=reshape(HIRCHK,1,1);
            out.HIRJCU=reshape(HIRJCU,nf+3+secflow,nf+3+secflow);
            out.HIRJCV=reshape(HIRJCV,nf+3+secflow,nf+3+secflow);
    end
    out.HIRCHK=HIRCHK;
end

%% OUTPUT FOR ALL

if exist('time_dnum','var')
    out.time_dnum=time_dnum(kt);
end
if exist('time_mor_r','var')
    out.time_mor=time_mor_r(kt);
end
out.time_r=time_r(kt);
out.time_r_all=time_r;

end %main function

%%
function dm=mean_grain_size(LYRFRAC,dchar,mean_type)

lyr_s=size(LYRFRAC);
nT=lyr_s(1);
ny=lyr_s(2);
nx=lyr_s(3);
nl=lyr_s(4);
if numel(lyr_s)<5
    nf=1;
else 
    nf=lyr_s(5);
end
aux.m=NaN(nT,ny,nx,nl,nf);
for kf=1:nf
    aux.m(:,:,:,:,kf)=dchar(kf).*ones(nT,ny,nx,nl);
end

switch mean_type
    case 1
        dm=2.^(sum(LYRFRAC.*log2(aux.m),5));  
    case 2
        dm=sum(LYRFRAC.*aux.m,5); 
end

% make safe for ill defined lyrfrac
idx = find(abs(sum(LYRFRAC,5) - 1) > 1e-6); 
dm(idx) = NaN;  

end %function mean_grain_size

%%
function XZ_e=celledges(XZ)

nx=size(XZ,3);
XZ_a=reshape(XZ,1,nx); %XZ(:,:,1:end-1)
XZ_d=diff(XZ_a);
XZ_e=XZ_a(1:end-1)-XZ_d;

end
    
%%

function fIk=find_substrate(LYRFRAC,DP_BEDLYR)

lyr_s=size(LYRFRAC);
nT=lyr_s(1);
ny=lyr_s(2);
nx=lyr_s(3);
% nl=lyr_s(4);
nf=lyr_s(5);

thklyr=layer_thickness(DP_BEDLYR);
fIk=NaN(nT,ny,nx,1,nf);
for kkt=1:nT
    for kky=1:ny
        for kkx=1:nx
            kks=find(thklyr(kkt,kky,kkx,2:end),1,'first')+1;
            if isempty(kks)
                fIk(kkt,kky,kkx,1,:)=NaN;
            else
                fIk(kkt,kky,kkx,1,:)=LYRFRAC(kkt,kky,kkx,kks,:);
            end
        end
    end
end

end

%%

function thklyr=layer_thickness(DP_BEDLYR)

thklyr=diff(DP_BEDLYR,1,4);

end

%%

function HIRCHK_cumulative=cumulative_elliptic(HIRCHK)

HIRCHK_cumulative=squeeze(nansum(HIRCHK,1));
HIRCHK_cumulative(HIRCHK_cumulative>1)=1;

end
%%

function out=out_var_2DH(z,XZ,YZ,time_r,XCOR,YCOR,nT,nx,ny,flg,kt)


if isfield(flg,'nine3sarenan')==0
    flg.nine3sarenan=0;
end

if isfield(flg,'zerosinvarsarenan')==0
    flg.zerosinvarsarenan=0;
end

if flg.nine3sarenan
    z(z==999)=NaN;
end

if flg.zerosinvarsarenan
    z(z==0)=NaN;
end
 
%output
switch flg.which_p
    case 2
        switch flg.which_s
            case -1
        z=squeeze(z);
        XZ=squeeze(XZ);
        YZ=squeeze(YZ);
        out=v2struct(z,XZ,YZ,XCOR,YCOR);
        out.time_r=time_r(kt);        
            case 0
        z=squeeze(permute(z(1,1:end-1,1:end-1),[1,3,2]));
        out=v2struct(z,XZ,YZ,XCOR,YCOR);
        out.time_r=time_r(kt);
            case 1
        out.z=reshape(z,ny,nx,[]);
        out.XZ=reshape(XZ,ny,nx);
        out.YZ=reshape(YZ,ny,nx);
        out.time_r=time_r(kt);
        out.z (1,:)=NaN;
        out.z (end,:)=NaN; 
            case 4
        xcords=XCOR(1:end-1,1:end-1);
        ycords=YCOR(1:end-1,1:end-1);
        aux=reshape(z,ny,nx);
%         center_data=aux(2:end-1,2:end-1)';
        center_data=aux(2:end-1,2:end-1);

        [faces,vertices,col]=patchFormat(xcords,ycords,center_data);

        out.z=col;
        out.x_node=vertices(:,1);
        out.y_node=vertices(:,2);
%                 out.x_face=x_face;
%                 out.y_face=y_face;
        out.XZ=reshape(XZ,ny,nx); %this is useful for plot limits
        out.YZ=reshape(YZ,ny,nx); %this is useful for plot limits
        out.faces=faces;
        out.time_r=time_r(kt);   
            case 5
                z=squeeze(permute(z(1,1:end-1,1:end-1),[1,3,2]));
                z_size=size(z);
                z=reshape(z,[],1);
%                 valr=reshape(val1,vals);
                out=v2struct(z,XZ,YZ,XCOR,YCOR,z_size);
                out.time_r=time_r(kt);
        end
    case 6
        ndim=max(nx,ny);
        out.z=reshape(z,nT,ndim);
        out.XZ=reshape(XZ,ny,nx);
        out.YZ=reshape(YZ,ny,nx);
        out.time_r=time_r(kt);           

end


end

%%

function val=get_EHY(file_map,vartok,time_dnum)

OPT.varName=vartok;
OPT.t0=time_dnum(1);
OPT.tend=time_dnum(end);
OPT.disp=0;

map_data=EHY_getMapModelData(file_map,OPT);
% if numel(size(map_data.val))==2
%     val=map_data.val';
% else
    val=map_data.val;
% end

end
        % %bed level at z point
        % bl=-DPS; %(because positive is downward for D3D depth)
        % 
        % %flow depth at z point
        % dp=S1+DPS;
        % 
        % %substrate elevation
        % lay_abspos=repmat(bl,1,1,1,nl)-cumsum(THLYR,4);
        % sub=NaN(nt,ny,nx,nl);
        % sub(:,:,:,1   )=bl; 
        % sub(:,:,:,2:nl+1)=lay_abspos(:,:,:,1:end);
        % 
        % %mean grain size
        % aux.m=NaN(nt,ny,nx,nl,nf);
        % for kf=1:nf
        %     aux.m(:,:,:,:,kf)=dchar(kf).*ones(nt,ny,nx,nl);
        % end
        % dm=2.^(sum(LYRFRAC.*log2(aux.m),5));  
        
            
        %         SED=delft3d_io_sed(file.sed); %sediment information BUG!! my own function later
        %         MOR=delft3d_io_mor(file.mor); %morphology information
        % 
        %         XZ=vs_let(NFStruct,'map-const','XZ','quiet'); %x coordinate at z point [m]
        %         YZ=vs_let(NFStruct,'map-const','YZ','quiet'); %y coordinate at z point [m]
        % 
        %         XCOR=vs_let(NFStruct,'map-const','XCOR','quiet'); %x coordinate at cell borders [m]
        %         YCOR=vs_let(NFStruct,'map-const','YCOR','quiet'); %y coordinate at cell borders [m]
        % 
        %         DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS','quiet'); %depth at z point [m]
        %         S1=vs_let(NFStruct,'map-series',{kt},'S1','quiet'); %water level at z point [m]
        % 
        %         THLYR=vs_let(NFStruct,'map-sed-series',{kt},'THLYR','quiet'); %thickness of layers [m]
        %         LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC','quiet'); %fractions at layers [-] (t,y,x,l,f)
        % 
        %         U1=vs_get(NFStruct,'map-series','U1','quiet'); %velocity in x direction at u point [m/s]
        %         V1=vs_get(NFStruct,'map-series','V1','quiet'); %velocity in y direction at v point [m/s]
        %         
        %         SBUU=vs_get(NFStruct,'map-sed-series','SBUU','quiet'); %bed load transport excluding pores per fraction in x direction at u point [m3/s]
        %         SBVV=vs_get(NFStruct,'map-sed-series','SBVV','quiet'); %bed load transport excluding pores per fraction in y direction at v point [m3/s]
        %         
        %         KFU=vs_get(NFStruct,'map-series','KFU','quiet'); %active points in x direction
        %         KFV=vs_get(NFStruct,'map-series','KFV','quiet'); %active points in y direction
        %         
        %         TAUKSI=vs_get(NFStruct,'map-series','TAUKSI','quiet'); %bottom stress in u point
        %         TAUETA=vs_get(NFStruct,'map-series','TAUETA','quiet'); %bottom stress in v point
        %         TAUMAX=vs_get(NFStruct,'map-series','TAUMAX','quiet'); %max bottom stress in z point
        
        