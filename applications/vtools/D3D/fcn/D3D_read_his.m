%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_read_his.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_his.m $
%
%get data from 1 time step in D3D, output name as in D3D

function out=D3D_read_his(simdef,in)


%% RENAME in

file=simdef.file;
flg=simdef.flg;

%% results structure

NFStruct=vs_use(file.his,'quiet');

%HELP
% vs_let(NFStruct,'-cmdhelp') %map file
% vs_disp(NFStruct)
% [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1)

%% domain size and input
    %time
ITHISC=vs_let(NFStruct,'his-info-series','ITHISC','quiet'); %results time vector
out.nTt=numel(ITHISC);
    %x
% MMAX=vs_let(NFStruct,'his-const','MMAX','quiet'); 
% out.MMAX=MMAX; 
    %y
% NMAX=vs_let(NFStruct,'his-const','NMAX','quiet');
% out.NMAX=NMAX; 
    %k
KMAX=vs_let(NFStruct,'his-const','KMAX','quiet');
out.kz=KMAX; 
    %stations
NOSTAT=vs_let(NFStruct,'his-const','NOSTAT','quiet');
out.ns=NOSTAT;    
    %orientation
ALFAS=vs_let(NFStruct,'his-const','ALFAS','quiet');
    %sediment
dlimits=D3D_read_sed(file.sed); %characteristic grain size per fraction (ATTENTION! bug in 'delft3d_io_sed.m' function)
dchar=sqrt(dlimits(1,:).*dlimits(2,:));
nf=numel(dchar); %number of sediment fractions
out.nf=nf;
    %number of substrate layers
% if isempty(vs_find(NFStruct,'LYRFRAC')) %if it does not exists, there is one layer
%     nl=1;
% else 
%     LYRFRAC=vs_let(NFStruct,'his-sed-series',{1},'LYRFRAC','quiet'); %fractions at layers [-] (t,y,x,l,f)
%     nl=size(LYRFRAC,4); 
% end
% out.nl=nl;
    %secondary flow
% mdf=delft3d_io_mdf('read',file.mdf);
% if isempty(strfind(mdf.keywords.sub1,'I'))
%     secflow=0;
% else
%     secflow=1;
% end

%% plot input

% if isfield(in,'ky')
%     ky=in.ky;
% else 
%     ky=1:1:NMAX;
% end
% if isfield(in,'kx')
%     kx=in.kx;
% else 
%     kx=1:1:MMAX;
% end
% if isfield(in,'kf')
%     kf=in.kf;
% else 
%     kf=1:1:nf;
% end
if isfield(in,'station')
    ks=in.station;
else
    ks=1:NOSTAT; 
end
% if isfield(flg,'mean_type')==0
%     mean_type=1; %log2
% else
%     mean_type=flg.mean_type; 
% end
% if isfield(flg,'elliptic')==0
%     flg.elliptic=0; 
% else
%     
% end



kt=in.kt;    
if kt==0 %only give domain size as output
%     flg.which_v=-1;
    flg.which_p=-1;
else
    nT=numel(kt);
    out.nT=nT;
%     ny=numel(ky);
%     out.ny=ny;
%     nx=numel(kx);
%     out.nx=nx;
%     nF=numel(kf);
%     out.nF=nF;
end




    %% time and space
if flg.which_p~=-1
TUNIT=vs_let(NFStruct,'his-const','TUNIT','quiet'); %dt unit
DT=vs_let(NFStruct,'his-const','DT','quiet'); %dt
time_r=ITHISC*DT*TUNIT; %results time vector [s]

% XZ=vs_let(NFStruct,'his-const','XZ',{ky,kx},'quiet'); %x coordinate at z point [m]
% YZ=vs_let(NFStruct,'his-const','YZ',{ky,kx},'quiet'); %y coordinate at z point [m]

% XCOR=vs_let(NFStruct,'his-const','XCOR','quiet'); %x coordinate at cell borders [m]
% XCOR=reshape(XCOR,NMAX,MMAX)';
% YCOR=vs_let(NFStruct,'his-const','YCOR','quiet'); %y coordinate at cell borders [m]
% YCOR=reshape(YCOR,NMAX,MMAX)';

% out.XCOR=XCOR;
% out.YCOR=YCOR;

%coordinates of velocity points
% XU=XCOR(:,1:end-1)+(XCOR(:,2:end)-XCOR(:,1:end-1))/2;
% YU=YCOR(:,1:end-1)+(YCOR(:,2:end)-YCOR(:,1:end-1))/2;
% XV=XCOR(1:end-1,:)+(XCOR(2:end,:)-XCOR(1:end-1,:))/2;
% YV=YCOR(1:end-1,:)+(YCOR(2:end,:)-YCOR(1:end-1,:))/2;
                
THICK=vs_let(NFStruct,'his-const','THICK','quiet'); %Fraction part of layer thickness of total water-height [ .01*% ]
     
end


    %% vars
switch flg.which_p
    case {'a'}
        switch flg.which_v
            case 11 %velocity
                v_s=vs_let(NFStruct,'his-series',{kt},'ZCURU',{ks,1:KMAX},'quiet');
                v_n=vs_let(NFStruct,'his-series',{kt},'ZCURV',{ks,1:KMAX},'quiet');
                vz=vs_let(NFStruct,'his-series',{kt},'ZCURW',{ks,1:KMAX},'quiet');
                
                wl=vs_let(NFStruct,'his-series',{kt},'ZWL',{ks},'quiet'); 
                dps=vs_let(NFStruct,'his-series',{kt},'DPS',{ks},'quiet');
                etab=-dps;
                h=wl-etab;
                aux_dp_rel1=[0,cumsum(THICK)];
                aux_dp_rel=aux_dp_rel1(1:end-1)+(aux_dp_rel1(2:end)-aux_dp_rel1(1:end-1))/2;
                dp_rel=h.*aux_dp_rel';
                zcoordinate_c=wl-dp_rel;
                
                v_s=squeeze(v_s);
                v_n=squeeze(v_n);
                vz=squeeze(vz);
                
                ALFAS=-ALFAS;
                vx= v_s*sin(ALFAS(ks)*2*pi/360)+v_n*cos(ALFAS(ks)*2*pi/360);
                vy=-v_s*cos(ALFAS(ks)*2*pi/360)+v_n*sin(ALFAS(ks)*2*pi/360);
                
%                 vx=-vx; %I don't fuly get theorientation of ALFAS
%                 vy=vy;
                
%                 out.z=[v_s,v_n,vz];
                out.z=[vx,vy,vz];
                
                out.zcoordinate_c=zcoordinate_c;
                out.time_r=time_r(kt); 
                out.zlabel='velocity [m/s]';                
            case 12 %water level
                wl=vs_let(NFStruct,'his-series',{kt},'ZWL',{ks},'quiet'); 
                
                %output
                out.z=wl;
%                 out.x_node=x_node;
%                 out.y_node=y_node;
%                 out.x_face=x_face;
%                 out.y_face=y_face;
%                 out.faces=faces;
                out.time_r=time_r(kt); 
                out.zlabel='water level [m]';
        end
        
end

%%
%%

%%
% switch flg.which_p
%     case -1 %nothing
%         
%     case 1 %3D bed elevation and gsd
%         %%
%         DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%         LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
%         
%         %bed level at z point
%         bl=-DPS; %(because positive is downward for D3D depth)
%         
%         %mean grain size
%         dm=mean_grain_size(LYRFRAC,dchar,mean_type);
%         
%         %output
%         out.XZ=reshape(XZ,ny,nx);
%         out.YZ=reshape(YZ,ny,nx);
%         out.bl=reshape(bl,ny,nx);
%             out.bl(1,:)=NaN;
%             out.bl(end,:)=NaN;
%         out.cvar=reshape(dm(1,:,:,1),ny,nx);   
%         out.time_r=time_r(kt); 
%         
%     case {2,3,5,6,8,9} %2DH & 1D
%         %%
%         switch flg.which_v
%             case 1 %etab
%                 DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%                 
%                 %output
%                 switch flg.which_p
%                     case 2
%                         out.z=reshape(-DPS,ny,nx);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                     case 6
%                         ndim=max(nx,ny);
%                         out.z=reshape(-DPS,nT,ndim);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);                   
%                 end
%                 out.zlabel='bed elevation [m]';
%             case 2 %h
%                 %%
%                 DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%                 S1=vs_let(NFStruct,'his-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
%                 
%                 %flow depth at z point
%                 dp=S1+DPS;
%                 dp(dp==0)=NaN;
%                 
%                 %output                
%                 switch flg.which_s
%                     case 1
%                 out.z=reshape(dp,ny,nx);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
% %                 switch flg.which_p
% %                     case 2
% % %                         out.z (1,:)=NaN;
% % %                         out.z (end,:)=NaN;                     
% %                 end
%                 out.zlabel='flow depth [m]';                
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
%                     
%                 %%
%             case 3 %dm
%                 LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1,1:nf},'quiet'); %fractions at top layer [-] (t,y,x,l,f)
%                 
%                 dm=mean_grain_size(LYRFRAC,dchar,mean_type);
%                 dm(dm==1)=NaN;
%                 %output                
%                 out.z=reshape(dm,ny,nx);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case 2
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
%             case 4 %dm fIk
%                 LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
%                 DP_BEDLYR=vs_let(NFStruct,'his-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
%                 
%                 fIk=find_substrate(LYRFRAC,DP_BEDLYR);
%                 dm=mean_grain_size(fIk,dchar,mean_type);
%                                 
%                 %output
%                 switch flg.which_p
%                     case 2
%                        %output                
%                         out.z=reshape(dm,ny,nx);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);
%                     case 5
%                         out.z=reshape(fIk(:,:,1:end-2,kf),nT,nx-2);
%                         out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
%                         out.YZ=time_r;
%                 end                
%             case 5 %fIk
%                 LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
%                 DP_BEDLYR=vs_let(NFStruct,'his-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
%                 
%                 fIk=find_substrate(LYRFRAC,DP_BEDLYR);
%                                 
%                 %output
%                 switch flg.which_p
%                     case 5
%                         out.z=reshape(fIk(:,:,1:end-2,kf),nT,nx-2);
%                         out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
%                         out.YZ=time_r;
%                 end
%             case 6 %I
%                 I=vs_let(NFStruct,'his-series',{kt},'R1',{ky,kx,1,1},'quiet');
%                 
%                 %output                
%                 out.z=reshape(I,ny,nx);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case 2
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
%             case 7 %elliptic
%                 HIRCHK=vs_let(NFStruct,'his-sed-series',{kt},'HIRCHK',{ky,kx},'quiet'); %Hyperbolic/Elliptic Hirano model [-]
%                 HIRCHK(HIRCHK==-999)=NaN;
%                 
%                 if flg.which_p==8
%                     HIRCHK=cumulative_elliptic(HIRCHK); %make it cumulative
%                 end
%                 
%                 %output
%                 out.z=reshape(HIRCHK,ny,nx);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case {2,8}
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
%             case 8 %Fak
%                 LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1,kf},'quiet'); %fractions at top layer [-] (t,y,x,l,f)
%                 
%                 %output                
%                 out.z=reshape(LYRFRAC,ny,nx,nF);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%                 switch flg.which_p
%                     case 2
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                 end
%                 out.zlabel=sprintf('volume fraction content at the active layer of fraction %d [-]',kf);
%             case 9 %detrended etab based on etab_0
%                 DPS_0=vs_let(NFStruct,'his-sed-series',{1} ,'DPS',{ky,kx},'quiet'); %depth at z point [m]
%                 DPS  =vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%                 
%                 %output
%                 switch flg.which_p
%                     case 2
%                         out.z=reshape(-DPS-(-DPS_0),ny,nx);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);
%                         out.z (1,:)=NaN;
%                         out.z (end,:)=NaN;                     
%                     case 3
%                         out.z=reshape(-DPS-(-DPS_0),ny,nx);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);
% %                         out.z (1,:)=NaN;
% %                         out.z (end,:)=NaN;                     
%                     case 6
%                         ndim=max(nx,ny);
%                         out.z=reshape(-DPS-(-DPS_0),nT,ndim);
%                         out.XZ=reshape(XZ,ny,nx);
%                         out.YZ=reshape(YZ,ny,nx);
%                         out.time_r=time_r(kt);                   
%                 end
%                 out.zlabel='relative bed elevation [m]';
%             case 10
% %                 U1=vs_get(NFStruct,'his-series',{kt},'U1',{ky,kx,KMAX},'quiet'); %velocity in x direction at u point [m/s]
% %                 V1=vs_get(NFStruct,'his-series',{kt},'V1',{ky,kx,KMAX},'quiet'); %velocity in y direction at v point [m/s]
%                 
%                   data = qpread(NFStruct,1,'depth averaged velocity','data',kt,kx,ky);
%                   u=sqrt(data.XComp.^2+data.YComp.^2);
% 
% %                 aa=qpfopen(file.his);
% %                 DATA = qpread(NFStruct,'Val1')
% %                 DATA = qpread(aa,'domains')+
% %                  [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1) 
% %                  [FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1,'depth averaged velocity','data') 
% %                  data = qpread(NFStruct,1,'depth averaged velocity','data') 
% %                  
% %                  data = qpread(NFStruct,1,'depth averaged velocity','data','griddata') 
% %                 DATA = qpread(file.his,aa,'depth averaged velocity','griddata')
% %                 DATA = qpread(file.his,aa,'depth averaged velocity','griddata',,T,S,M,N,K)
% %                 d3d_qp('selectfile',file.his)
% %                 d3d_qp('selectfield','depth averaged velocity')
% %                 d3d_qp('editt',kt)
% %                 d3d_qp('editm',kx)
% %                 d3d_qp('editn',ky)
% %                 d3d_qp('exportdata','C:\Users\chavarri\Downloads\temp.mat')
% %                 
%                 out.z=u';
% %                 out.z=u;
% %                 switch flg.which_p
% %                     case 2
% %                         out.z (1,:)=NaN;
% %                         out.z (end,:)=NaN;                     
% %                 end
%                 out.zlabel='depth averaged velocity [m/s]';
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
%             case 11
%                 npcs=numel(in.pol.y);
%                 data = qpread(NFStruct,1,'velocity','data',kt,kx,ky);
%                 ucx=data.XComp;
%                 ucy=data.YComp;
%                 ucz=data.ZComp;
%                 data = qpread(NFStruct,1,'velocity','griddata',kt); %I do not know how to get the griddata and the kt I want at the same time
%                 xcordvel=data.X(:,:,1);
%                 ycordvel=data.Y(:,:,1);
%                 zcordvel=data.Z;
% %                 data = qpread(NFStruct,1,'velocity','griddata',kt)
% %                 U1=vs_let(NFStruct,'his-series',{kt},'U1','quiet'); %U-velocity per layer in U-point [-] (fl,y,x) (m-component)
% %                 V1=vs_let(NFStruct,'his-series',{kt},'V1','quiet'); %V-velocity per layer in V-point [-] (fl,y,x) (n-component)
% %                 WPHY=vs_let(NFStruct,'his-series',{kt},'WPHY','quiet'); %W-velocity per layer in zeta point [-] (fl,y,x)
% %                 DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
% %                 S1=vs_let(NFStruct,'his-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
%                 
%                 
%                 %flow depth at z point
% %                 dp=S1+DPS;
% % %                 dp(dp==0)=NaN;
%                 
%                 %output                
% 
% 
%                 %interpolate cell center (comparison with FM)
% %                 FDP=scatteredInterpolant(reshape(XZ(:,2:end-1,1:end),[],1),reshape(YZ(:,2:end-1,1:end),[],1),reshape(dp(:,2:end-1,1:end),[],1));
% %                 FS1=scatteredInterpolant(reshape(XZ(:,2:end-1,1:end),[],1),reshape(YZ(:,2:end-1,1:end),[],1),reshape(S1(:,2:end-1,1:end),[],1));
% %                 DP_cs=FDP(in.pol.x,in.pol.y);
% %                 S1_cs=FS1(in.pol.x,in.pol.y);
% %                 
% %                 aux_dp_rel1=[0,cumsum(THICK)];
% %                 aux_dp_rel=aux_dp_rel1(1:end-1)+(aux_dp_rel1(2:end)-aux_dp_rel1(1:end-1))/2;
% %                 dp_rel=DP_cs.*aux_dp_rel';
% % 
% %                 z_face_s=S1_cs-dp_rel;
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
%                 
%                 out.ucx_s=ucx_s;
%                 out.ucy_s=ucy_s;
%                 out.ucz_s=ucz_s;
%                 out.uc_norm=uc_norm;
%                 out.x_face_s=in.pol.x;
%                 out.y_face_s=in.pol.y;
%                 out.z_face_s=z_face_s;
%                 
%                 out.time_r=time_r(kt); 
%                 out.zlabel='velocity [m/s]';
%                 %%
% %                         xz=squeeze(XZ);
% %         yz=squeeze(YZ);
% %         u=squeeze(U1(:,:,:,1));
% %         xz=xz(2:end-1,1:end-1);
% %         yz=yz(2:end-1,1:end-1);
% %         u=u(2:end-1,1:end-1);
% %         figure
% %         surf(xz,yz,u,'edgecolor','none')
% %         colorbar
% %         view([0,90])
% %         %%
% %         figure
% %         surf(xcordvel,ycordvel,ucx(:,:,1),'edgecolor','none')
% %         colorbar
% %         view([0,90])
% %         colormap('jet')
%             case 12 %water level
%                 S1=vs_let(NFStruct,'his-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
%                 
%                 %output                
% %                 switch flg.which_s
% %                     case 1
%                 out.z=reshape(S1,ny,nx);
%                 out.XZ=reshape(XZ,ny,nx);
%                 out.YZ=reshape(YZ,ny,nx);
%                 out.time_r=time_r(kt);
% %                 switch flg.which_p
% %                     case 2
% % %                         out.z (1,:)=NaN;
% % %                         out.z (end,:)=NaN;                     
% %                 end
%                 out.zlabel='water level [m]';                
% %                     case 4
% %                 xcords=XCOR(1:end-1,1:end-1);
% %                 ycords=YCOR(1:end-1,1:end-1);
% %                     aux=reshape(dp,ny,nx);
% %                 center_data=aux(2:end-1,2:end-1)';
% %                 
% %                 [faces,vertices,col]=patchFormat(xcords,ycords,center_data);
% % 
% %                 out.z=col;
% %                 out.x_node=vertices(:,1);
% %                 out.y_node=vertices(:,2);
% % %                 out.x_face=x_face;
% % %                 out.y_face=y_face;
% %                 out.XZ=reshape(XZ,ny,nx); %this is useful for plot limits
% %                 out.YZ=reshape(YZ,ny,nx); %this is useful for plot limits
% %                 out.faces=faces;
% %                 out.time_r=time_r(kt); 
% %                 out.zlabel='flow depth [m]';
% %                 end
%                 
%             otherwise
%                 error('You are asking for plotting an unexisting variable')
% 
% 
%         end %flg.which_v
%         out.kf=kf;
%         
%         %%
% 
%         
%     case 4 %patch
%         %%
%         LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
%         DP_BEDLYR=vs_let(NFStruct,'his-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
% 
%         DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%         
%         %bed level at z point
%         bl=-DPS; %(because positive is downward for D3D depth)
%                
%         %substrate elevation
%             %old
% %         THLYR=vs_let(NFStruct,'his-sed-series',{kt},'THLYR',{ky,kx},'quiet'); %thickness of layers [m] THIS OUTPUT HAS DISAPPEARED! 
% %         lay_abspos=repmat(bl,1,1,1,nl)-cumsum(THLYR,4);
% %         sub=NaN(nt,ny,nx,nl);
% %         sub(:,:,:,1   )=bl; 
% %         sub(:,:,:,2:nl+1)=lay_abspos(:,:,:,1:end);
%             %new
%         sub=repmat(bl,1,1,1,nl+1)-DP_BEDLYR;
%         
%         %mean grain size
%         dm=mean_grain_size(LYRFRAC,dchar,mean_type);
%                         
%         %output
%         out.XZ=celledges(XZ);
%         out.sub=reshape(sub(:,:,2:end-1,:),nx-2,nl+1)';
%         switch flg.which_v
%             case 2
%                 out.cvar=reshape(LYRFRAC(:,:,2:end-1,:,kf),nx-2,nl)';
%             case 3
%                 out.cvar=reshape(dm(:,:,2:end-1,:),nx-2,nl)';
%             otherwise
%                 error('2 or 3')
%         end
%         out.kf=kf;
%         out.time=time_r(kt);
%     case 7 % 0D
%         LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
%         DP_BEDLYR=vs_let(NFStruct,'his-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
%         DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
%         S1=vs_let(NFStruct,'his-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
%         U1=vs_let(NFStruct,'his-series',{kt},'U1',{ky,kx,1},'quiet'); %velocity in x direction at u point [m/s]
%         V1=vs_let(NFStruct,'his-series',{kt},'V1',{ky,kx,1},'quiet'); %velocity in y direction at v point [m/s]
%         SBUU=vs_get(NFStruct,'his-sed-series',{kt},'SBUU',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in x direction at u point [m3/s]
%         SBVV=vs_get(NFStruct,'his-sed-series',{kt},'SBVV',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in y direction at v point [m3/s]
%                 
%         dp=S1+DPS; %flow depth        
%         fIk=find_substrate(LYRFRAC,DP_BEDLYR); %interface
%         thklyr=layer_thickness(DP_BEDLYR);
%         
%         %output
%         out.Fak=reshape(LYRFRAC(:,:,:,1,:),1,nf);
%         out.La =reshape(thklyr (:,:,:,1,:),1, 1);
%         out.fIk=reshape(fIk,1,nf);
%         out.SBUU=reshape(SBUU,1,nf);
%         out.SBVV=reshape(SBVV,1,nf);
%         out.dp=reshape(dp,1,1);
%         out.U1=reshape(U1,1,1);
%         out.V1=reshape(V1,1,1);
% 
%     otherwise
%         %%
%         error('ups...')
% end
%  
% %elliptic output
% if flg.which_p~=-1 && flg.elliptic==2
%     HIRCHK=vs_let(NFStruct,'his-sed-series',{kt},'HIRCHK',{ky,kx},'quiet'); %Hyperbolic/Elliptic Hirano model [-]
%     switch flg.which_p
%         case 1
%             HIRCHK=reshape(HIRCHK,ny,nx);
%             HIRCHK(1,:)=NaN;
%             HIRCHK(end,:)=NaN;
%         case 5
%             HIRCHK=reshape(HIRCHK(:,:,1:end-2),nT,nx-2);
%             HIRCHK(1,:)=NaN;
%         case 7 %0D
%             HIRJCU=vs_let(NFStruct,'his-sed-series',{kt},'HIRJCU',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in u-direction (no sec flow in the indeces!)
%             HIRJCV=vs_let(NFStruct,'his-sed-series',{kt},'HIRJCV',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in v-direction (no sec flow in the indeces!)
%             
%             HIRCHK=reshape(HIRCHK,1,1);
%             out.HIRJCU=reshape(HIRJCU,nf+3+secflow,nf+3+secflow);
%             out.HIRJCV=reshape(HIRJCV,nf+3+secflow,nf+3+secflow);
%     end
%     out.HIRCHK=HIRCHK;
% end
% 
% 
% end %main function
% 
% %%
% function dm=mean_grain_size(LYRFRAC,dchar,mean_type)
% 
% lyr_s=size(LYRFRAC);
% nT=lyr_s(1);
% ny=lyr_s(2);
% nx=lyr_s(3);
% nl=lyr_s(4);
% nf=lyr_s(5);
% aux.m=NaN(nT,ny,nx,nl,nf);
% for kf=1:nf
%     aux.m(:,:,:,:,kf)=dchar(kf).*ones(nT,ny,nx,nl);
% end
% 
% switch mean_type
%     case 1
%         dm=2.^(sum(LYRFRAC.*log2(aux.m),5));  
%     case 2
%         dm=sum(LYRFRAC.*aux.m,5); 
% end
% 
% end %function mean_grain_size
% 
% %%
% function XZ_e=celledges(XZ)
% 
% nx=size(XZ,3);
% XZ_a=reshape(XZ,1,nx); %XZ(:,:,1:end-1)
% XZ_d=diff(XZ_a);
% XZ_e=XZ_a(1:end-1)-XZ_d;
% 
% end
%     
% %%
% 
% function fIk=find_substrate(LYRFRAC,DP_BEDLYR)
% 
% lyr_s=size(LYRFRAC);
% nT=lyr_s(1);
% ny=lyr_s(2);
% nx=lyr_s(3);
% % nl=lyr_s(4);
% nf=lyr_s(5);
% 
% thklyr=layer_thickness(DP_BEDLYR);
% fIk=NaN(nT,ny,nx,1,nf);
% for kkt=1:nT
%     for kky=1:ny
%         for kkx=1:nx
%             kks=find(thklyr(kkt,kky,kkx,2:end),1,'first')+1;
%             if isempty(kks)
%                 fIk(kkt,kky,kkx,1,:)=NaN;
%             else
%                 fIk(kkt,kky,kkx,1,:)=LYRFRAC(kkt,kky,kkx,kks,:);
%             end
%         end
%     end
% end
% 
% end
% 
% %%
% 
% function thklyr=layer_thickness(DP_BEDLYR)
% 
% thklyr=diff(DP_BEDLYR,1,4);
% 
% end
% 
% %%
% 
% function HIRCHK_cumulative=cumulative_elliptic(HIRCHK)
% 
% HIRCHK_cumulative=squeeze(nansum(HIRCHK,1));
% HIRCHK_cumulative(HIRCHK_cumulative>1)=1;
% 
% end
% %%
% 
%         % %bed level at z point
%         % bl=-DPS; %(because positive is downward for D3D depth)
%         % 
%         % %flow depth at z point
%         % dp=S1+DPS;
%         % 
%         % %substrate elevation
%         % lay_abspos=repmat(bl,1,1,1,nl)-cumsum(THLYR,4);
%         % sub=NaN(nt,ny,nx,nl);
%         % sub(:,:,:,1   )=bl; 
%         % sub(:,:,:,2:nl+1)=lay_abspos(:,:,:,1:end);
%         % 
%         % %mean grain size
%         % aux.m=NaN(nt,ny,nx,nl,nf);
%         % for kf=1:nf
%         %     aux.m(:,:,:,:,kf)=dchar(kf).*ones(nt,ny,nx,nl);
%         % end
%         % dm=2.^(sum(LYRFRAC.*log2(aux.m),5));  
%         
%             
%         %         SED=delft3d_io_sed(file.sed); %sediment information BUG!! my own function later
%         %         MOR=delft3d_io_mor(file.mor); %morphology information
%         % 
%         %         XZ=vs_let(NFStruct,'his-const','XZ','quiet'); %x coordinate at z point [m]
%         %         YZ=vs_let(NFStruct,'his-const','YZ','quiet'); %y coordinate at z point [m]
%         % 
%         %         XCOR=vs_let(NFStruct,'his-const','XCOR','quiet'); %x coordinate at cell borders [m]
%         %         YCOR=vs_let(NFStruct,'his-const','YCOR','quiet'); %y coordinate at cell borders [m]
%         % 
%         %         DPS=vs_let(NFStruct,'his-sed-series',{kt},'DPS','quiet'); %depth at z point [m]
%         %         S1=vs_let(NFStruct,'his-series',{kt},'S1','quiet'); %water level at z point [m]
%         % 
%         %         THLYR=vs_let(NFStruct,'his-sed-series',{kt},'THLYR','quiet'); %thickness of layers [m]
%         %         LYRFRAC=vs_let(NFStruct,'his-sed-series',{kt},'LYRFRAC','quiet'); %fractions at layers [-] (t,y,x,l,f)
%         % 
%         %         U1=vs_get(NFStruct,'his-series','U1','quiet'); %velocity in x direction at u point [m/s]
%         %         V1=vs_get(NFStruct,'his-series','V1','quiet'); %velocity in y direction at v point [m/s]
%         %         
%         %         SBUU=vs_get(NFStruct,'his-sed-series','SBUU','quiet'); %bed load transport excluding pores per fraction in x direction at u point [m3/s]
%         %         SBVV=vs_get(NFStruct,'his-sed-series','SBVV','quiet'); %bed load transport excluding pores per fraction in y direction at v point [m3/s]
%         %         
%         %         KFU=vs_get(NFStruct,'his-series','KFU','quiet'); %active points in x direction
%         %         KFV=vs_get(NFStruct,'his-series','KFV','quiet'); %active points in y direction
%         %         
%         %         TAUKSI=vs_get(NFStruct,'his-series','TAUKSI','quiet'); %bottom stress in u point
%         %         TAUETA=vs_get(NFStruct,'his-series','TAUETA','quiet'); %bottom stress in v point
%         %         TAUMAX=vs_get(NFStruct,'his-series','TAUMAX','quiet'); %max bottom stress in z point
%         
        