function varargout=nesthd2_new(varargin)
% NESTHD2
%
% e.g. nesthd2('runid','tst','inputdir','d:\temp\','admfile','d:\temp\nesting.adm','hisfile','d:\run01\trih-ovr.dat','opt','hydro')
%

stride=1;
opt='both';
admfile='';
hisfile='';
openBoundaries=[];
inputdir='';
runid=[];
t0=[];
t1=[];
isave=1;
cs='projected';
zcor=0;
overallmodeltype='delft3dflow';

if length(varargin)==1
    % Read input from xml file
    xmlfile=varargin{1};
    xml=xml2struct(xmlfile,'structuretype','short');
    runid=xml.runid;
    inputdir=xml.inputdir;
    admfile=xml.admfile;
    opt=xml.opt;
    hisfile=xml.hisfile;
    if isfield(xml,'zcor')
        zcor=str2double(xml.zcor);
    end
    if isfield(xml,'starttime')
        t0=datestr(xml.starttime,'yyyymmdd HHMMSS');
    end
    if isfield(xml,'stoptime')
        t1=datestr(xml.stoptime,'yyyymmdd HHMMSS');
    end
else
    for i=1:length(varargin)
        if ischar(varargin{i})
            switch lower(varargin{i})
                case{'openboundaries'}
                    openBoundaries=varargin{i+1};
                case{'vertgrid'}
                    vertGrid=varargin{i+1};
                case{'hisfile'}
                    hisfile=varargin{i+1};
                case{'mdffile'}
                    mdffile=varargin{i+1};
                    [inputdir,runid,ext]=fileparts(mdffile);
                case{'inputdir'}
                    inputdir=varargin{i+1};
                    if ~isempty(inputdir)
                        if ~strcmpi(inputdir,filesep)
                            inputdir=[inputdir filesep];
                        end
                    end
                case{'runid'}
                    runid=varargin{i+1};
                case{'admfile'}
                    admfile=varargin{i+1};
                case{'zcor'}
                    zcor=varargin{i+1};
                case{'stride'}
                    stride=varargin{i+1};
                case{'opt'}
                    opt=varargin{i+1};
                case{'save'}
                    if ischar(varargin{i+1})
                        switch lower(varargin{i+1}(1))
                            case{'y'}
                                isave=1;
                            case{'n'}
                                isave=0;
                        end
                    else
                        isave=varargin{i+1};
                    end
                case{'starttime'}
                    t0=varargin{i+1};
                case{'stoptime'}
                    t1=varargin{i+1};
                case{'coordinatesystem'}
                    cs=varargin{i+1};
                case{'input'}
                    Flow=varargin{i+1};
                case{'overallmodeltype'}
                    overallmodeltype=varargin{i+1};
            end
        end
    end
end

if ~isempty(runid)
    % First read data from mdf file
    [Flow,openBoundaries]=delft3dflow_readInput(inputdir,runid);
    cs=Flow.cs;
    vertGrid.KMax=Flow.KMax;
    vertGrid.layerType=Flow.vertCoord;
    vertGrid.thick=Flow.thick;
    if strcmpi(vertGrid.layerType,'z')
        vertGrid.zTop=Flow.zTop;
        vertGrid.zBot=Flow.zBot;
    end
end

% Create nesting administration structure
switch overallmodeltype
    case{'delft3dflow'}
        % Read nesting administration file
        disp('Reading nesting administration file ...');
        nestadmin=readNestAdmin(admfile);
    case{'dflowfm'}
        flds={'wl','vel'};
        % Loop over boundary sections
        n=0;
        for ibnd=1:length(openBoundaries)
            % Loop over points
            for ip=1:length(openBoundaries(ibnd).x)
                n=n+1;
                for ifld=1:length(flds)
                    fld=flds{ifld};
                    nestadmin(n).(fld).w=1;
%                    nestadmin(n).(fld).name=[openBoundaries(ibnd).name '_' num2str(ip,'%0.4i')];
                    nestadmin(n).(fld).name=[openBoundaries(ibnd).name '_' num2str(ip,'%0.4i')];
                end
            end
            
            % Loop over points
            for ip=1:length(openBoundaries(ibnd).x)
                n=n+1;
                for ifld=1:length(flds)
                    fld=flds{ifld};
                    nestadmin(n).(fld).w=1;
%                    nestadmin(n).(fld).name=[openBoundaries(ibnd).name '_' num2str(ip,'%0.4i')];
                    nestadmin(n).(fld).name=[openBoundaries(ibnd).name '_' num2str(ip,'%0.4i')];
                end
            end
            
            
            
        end
end

% Read data for each boundary point that was found in readNestAdmin.m
disp('Reading data overall model ...');
[times,stations,overalldata]=getNestSeries(nestadmin,'hisfile',hisfile,'tstart',t0,'tstop',t1,'stride',stride,'overallmodeltype',overallmodeltype,opt);

% % Now interpolate data over vertical of boundary support points ()
% disp('Interpolating data onto nested model ...');
% nesteddata=interpolateNestData(times,overalldata,'nestedmodeltype','delft3dflow',opt);
nesteddata=overalldata;

for ip=1:length(nestadmin)
    nesteddatanames{ip}=nestadmin(ip).wl.name;
%    nesteddatanames{ip}=nestadmin(ip).name;
end

nbnd=length(openBoundaries);
for ib=1:nbnd
    for ip=1:length(openBoundaries(ib).x)
        % Find point in nested data
        bndname=[openBoundaries(ib).name '_' num2str(ip,'%0.4i')];
%        bndname=[openBoundaries(ib).name num2str(ip,'%0.4i')];
        ii=strmatch(bndname,nesteddatanames,'exact');
%        bndname=[openBoundaries(ib).name '_' num2str(ip,'%0.4i')];
        openBoundaries(ib).nodes(ip).timeseriesfile=[bndname '.tim'];
        openBoundaries(ib).nodes(ip).time=times;
        openBoundaries(ib).nodes(ip).value=nesteddata(ii).waterlevel;
        % Save file
        d=zeros(length(times),2);
        d(:,1)=(openBoundaries(ib).nodes(ip).time-Flow.refdate)*1440;
        d(:,2)=openBoundaries(ib).nodes(ip).value;
        save(openBoundaries(ib).nodes(ip).timeseriesfile,'d','-ascii');
    end
end

% Copy nesteddata structure to boundary data structure




% Save boundary condition files


% switch lower(opt)
%     case{'hydro','both'}
%         disp('Generating hydrodynamic boundary conditions ...');
%         openBoundaries=nesthd2_hydro(openBoundaries,vertGrid,s,nest,zcor,cs);
%         if isave
%             disp('Saving bct file');
%             fname=[inputdir Flow.bctFile];
%             delft3dflow_saveBctFile(Flow,openBoundaries,fname);
%         end
% end
% 
% switch lower(opt)
%     case{'transport','both'}
%         disp('Generating transport boundary conditions ...');
%         openBoundaries=nesthd2_transport(openBoundaries,vertGrid,s,nest);
%         if isave
%             disp('Saving bcc file');
%             fname=[inputdir Flow.bccFile];
%             delft3dflow_saveBccFile(Flow,openBoundaries,fname);
%         end
% end

if nargout>0
    varargout{1}=openBoundaries;
end

%%
function nest=readNestAdmin(fname)

strwl ='Nest administration for water level support point';
strvel='Nest administration for velocity    support point';

lwl=length(strwl);

fid=fopen(fname,'r');
k=0;
while 1
    f=fgetl(fid);
    if ~strcmpi(f(1),'*')
        break
    end
    k=k+1;
end
fclose(fid);

fid=fopen(fname,'r');
for i=1:k
    f=fgetl(fid);
end

supportpoints={''};
np=0;

while 1
    
    f=fgetl(fid);
    
    if ~ischar(f), break, end
    
    iwl=strfind(f,strwl);
    if isempty(iwl)
        iwl=0;
    end
    ivel=strfind(f,strvel);
    if isempty(ivel)
        ivel=0;
    end
    
    if iwl || ivel
        
        str=deblank2(f(lwl+1:end));
        str=strread(str,'%s','delimiter',' ');
        
        name=deblank2(str{1});
        
        % Check if this boundary point has already been found
        ii=strmatch(name,supportpoints,'exact');
        if isempty(ii)
            % New boundary point
            np=np+1;
            supportpoints{np}=name;
            ip=np;
        else
            ip=ii;
        end
        
        nest(ip).name=deblank2(str{1});
        
        if iwl
            % Support points for water level boundary
            fld='wl';
        else
            fld='vel';
%             anglestr=strread(str{end},'%s','delimiter','=');
%             nest(ip).angle=str2double(anglestr{2});
        end
        
        % Read m,n indices of surrounding support points
        for ii=1:4
            f=fgetl(fid);
            v=strread(f,'%f');
            m=v(1);
            n=v(2);
            nest(ip).(fld)(ii).m=m;
            nest(ip).(fld)(ii).n=n;
            nest(ip).(fld)(ii).w=v(3);
            m=[repmat(' ',1,5-length(num2str(m))) num2str(m)];
            n=[repmat(' ',1,5-length(num2str(n))) num2str(n)];
            nest(ip).(fld)(ii).name=['(M,N)=(' m ',' n ')'];            
        end
        
    end
    
end
fclose(fid);


%%
function [times,stationnames,nestdata]=getNestSeries(nestadmin,varargin)

% Defaults
stride=1;
opt='hydro';
t0=[];
t1=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'overallmodeltype'}
                overallmodeltype=varargin{ii+1};
            case{'overallmodelfile','hisfile'}
                hisfile=varargin{ii+1};
            case{'stride'}
                stride=varargin{ii+1};
            case{'tstart'}
                t0=varargin{ii+1};
            case{'tstop'}
                t1=varargin{ii+1};
            case{'hydro'}
                opt='hydro';
            case{'transport'}
                opt='transport';
            case{'both'}
                opt='both';
        end
    end
end

% Read stations, times, kmax from overall model
[allstations,times,kmax,fid]=readOverallModelData(hisfile,overallmodeltype);

% Determine indices of start and stop time
if ~isempty(t0)
    it1=find(times<=t0-1/86400,1,'last');
    it2=find(times>=t1+1/86400,1,'first');
    if isempty(it1)
        it1=1;
    end
    if isempty(it2)
        it2=length(times);
    end
else
    it1=1;
    it2=length(times);
end
times = times(it1:stride:it2);
times=datenum(round(datevec(times)));
isteps=it1:stride:it2;

% Check which stations need to be loaded (stored in vector istation)
stationnames=[];
istation=[];
for k=1:length(nestadmin)
    for it=1:2
        if it==1
            fld='wl';
        else
            fld='vel';
        end
        if ~isempty(nestadmin(k).(fld))
            for ip=1:length(nestadmin(k).(fld))
                name=nestadmin(k).(fld)(ip).name;
                if isempty(strmatch(name,stationnames,'exact'))
                    istat=strmatch(name,allstations,'exact');
                    if isempty(istat)
                        error(['Station ' name ' not found on history file!']);
                    end
                    istation(end+1)=istat;
                    stationnames{end+1}=name;
                end
            end
        end
    end
end

%% Hydrodynamics

switch lower(opt)
    case{'hydro','both'}
        
%         % Read bed levels
%         [z,dps]=readData(fid,'bedlevel',1,istation,overallmodeltype,kmax,layertype,zbot,ztop);
%         for k=1:length(nestadmin)
%             bedlevel(k)=computeMean(nestadmin(k),'wl',z,dps,stationnames,kmax);
%         end
        
layertype='sigma';
zbot=0;
ztop=0;

% Read water levels
        [z,wl]=readData(fid,'waterlevel',isteps,istation,overallmodeltype,kmax);
        for k=1:length(nestadmin)
            nestdata(k).waterlevel=computeMean(nestadmin(k),'wl',stationnames,1,wl);
        end
        
        % Read velocities
        [z,u,v]=readData(fid,'velocity',isteps,istation,overallmodeltype,kmax);
        for k=1:length(nestadmin)
            nestdata(k).z  = computeMean(nestadmin(k),'vel',stationnames,kmax,z);
            nestdata(k).u  = computeMean(nestadmin(k),'vel',stationnames,kmax,u);
            nestdata(k).v  = computeMean(nestadmin(k),'vel',stationnames,kmax,v);
        end
        
end

% %% Constituents
% 
% namc=vs_get('his-const','NAMCON');
% icn=0;
% for ic=1:size(namc,1)
%     switch lower(deblank(namc(ic,:)))
%         case{'turbulent energy','energy dissipation'}
%         otherwise
%             icn=icn+1;
%             nest.namcon{icn}=deblank(namc(ic,:));
%     end
% end
% 
% switch lower(opt)
%     case{'transport','both'}
%         
%         for ic=1:length(nest.namcon)
%             
%             par=nest.namcon{ic};
%             
%             % Salinity
%             %    if Flow.salinity.include
%             
%             
%             if ic==1
%                 sal00=qpread(fid,1,par,'griddata',isteps,istation);
%             else
%                 sal00=qpread(fid,1,par,'data',isteps,istation);
%             end
%             
%             sal0=zeros(nt,kmax,4);
%             sal0(sal0==0)=NaN;
%             
%             % Loop past every support point
%             for k=1:length(s.wl.name)
%                 
%                 sal{k}=zeros(nt,kmax);
%                 sal{k}(sal{k}==0)=NaN;
%                 if ic==1
%                     z{k}=sal{k};
%                 end
%                 
%                 % Loop past surrounding points
%                 for i=1:4
%                     m=s.wl.mm(k,i);
%                     n=s.wl.nn(k,i);
%                     if m>0
%                         ii= find(mused==m&nused==n,1);
%                         sal0(:,:,i)=squeeze(sal00.Val(:,ii,:));
%                         if ic==1
%                             z0(:,:,i)=squeeze(sal00.Z(:,ii,:));
%                         end
%                     else
%                         sal0(:,:,i)=zeros(nt,kmax,1);
%                         if ic==1
%                             z0(:,:,i)=zeros(nt,kmax,1);
%                         end
%                     end
%                 end
%                 
%                 % Apply weighting factors
%                 w=zeros(size(sal0));
%                 w0=squeeze(s.wl.w(k,:)');
%                 for i=1:4
%                     w(:,:,i)=w0(i);
%                 end
%                 w(isnan(sal0))=NaN;
%                 wmult=1./nansum(w,3);
%                 for i=1:4
%                     w(:,:,i)=w(:,:,i).*wmult;
%                 end
%                 sal{k}=nansum(w.*sal0,3);
%                 if ic==1
%                     z{k}=nansum(w.*z0,3);
%                 end
%                 
%             end
%             
%             nest.constituent(ic).data=sal;
%             
%             clear sal0 sal00 z0 salw zw w w0 wsum wmult sal
%             
%         end
% end
% 
% nest.t=times;
% nest.dps=dps;
% nest.wl=wl;
% nest.u=u;
% nest.v=v;
% nest.z=z;


%%
function openBoundaries=nesthd2_hydro(openBoundaries,vertGrid,s,nest,zcor,cs)

for i=1:length(openBoundaries)
    
    disp(['   Boundary ' openBoundaries(i).name ' - ' num2str(i) ' of ' num2str(length(openBoundaries))]);
    
    bnd=openBoundaries(i);
    
    switch lower(bnd.type)
        case{'z','r','x'}
            
            % Water levels
            % A
            m=bnd.M1;
            n=bnd.N1;
            j= find(s.wl.m==m & s.wl.n==n,1);
            wl(:,1)=nest.wl{j};
            dps(1)=nest.dps(j);
            
            % B
            m=bnd.M2;
            n=bnd.N2;
            j= find(s.wl.m==m & s.wl.n==n,1);
            wl(:,2)=nest.wl{j};
            dps(2)=nest.dps(j);
            
            wl=wl+zcor;
            
    end
    
    switch lower(bnd.type)
        case{'c','r','p','x'}
            % Currents
            
            % A
            m=bnd.M1;
            n=bnd.N1;
            j=find(s.wl.m==m & s.wl.n==n,1);
            u(:,:,1)=nest.u{j};
            v(:,:,1)=nest.v{j};
            z(:,:,1)=nest.z{j};
            
            % B
            m=bnd.M2;
            n=bnd.N2;
            j=find(s.wl.m==m & s.wl.n==n,1);
            u(:,:,2)=nest.u{j};
            v(:,:,2)=nest.v{j};
            z(:,:,2)=nest.z{j};
            
            u(isnan(u))=0;
            v(isnan(v))=0;
            
            for it=1:length(nest.t)
                tua=squeeze(u(it,:,1))';
                tub=squeeze(u(it,:,2))';
                tva=squeeze(v(it,:,1))';
                tvb=squeeze(v(it,:,2))';
                ua = tua.*cos(bnd.alphau(1)) + tva.*sin(bnd.alphau(1));
                ub = tub.*cos(bnd.alphau(2)) + tvb.*sin(bnd.alphau(2));
                va = tua.*cos(bnd.alphav(1)) + tva.*sin(bnd.alphav(1));
                vb = tub.*cos(bnd.alphav(2)) + tvb.*sin(bnd.alphav(2));
                u(it,:,1)=ua;
                u(it,:,2)=ub;
                v(it,:,1)=va;
                v(it,:,2)=vb;
            end
            
            dp(1)=-openBoundaries(i).depth(1);
            dp(2)=-openBoundaries(i).depth(2);
            
            if vertGrid.KMax>1
                
                % Now interpolate over water column
                
                if strcmpi(vertGrid.layerType,'z')
                    dplayer=squeeze(getLayerDepths(dp,vertGrid.thick,vertGrid.zBot,vertGrid.zTop));
                    dplayer=fliplr(dplayer);
                else
                    dplayer=squeeze(getLayerDepths(dp,vertGrid.thick));
                end
                
                for it=1:length(nest.t)
                    
                    % Loop through time
                    
                    z0=squeeze(z(it,:,1));
                    u0=squeeze(u(it,:,1));
                    v0=squeeze(v(it,:,1));
                    
                    imin=find(z0>-1e9, 1 );
                    imax=find(z0>-1e9, 1, 'last' );
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    if z0(end)>z0(1)
                        imin=find(z0>z0(1),   1, 'first')-1;
                        imax=find(z0<z0(end), 1, 'last' )+1;
                        %                         imin=find(z0>z0(1), 1 );
                        %                         imax=find(z0<z0(end), 1, 'last' );
                    else
                        imin=find(z0<=z0(1), 1 );
                        imax=find(z0>=z0(end), 1, 'last' );
                    end
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    
                    if z0(end)>z0(1)
                        z0=[-12000 z0 12000];
                    else
                        z0=[12000 z0 -12000];
                    end
                    u0=[u0(1) u0 u0(end)];
                    v0=[v0(1) v0 v0(end)];
                    u1(it,:,1)=interp1(z0,u0,squeeze(-dplayer(1,:)))';
                    v1(it,:,1)=interp1(z0,v0,squeeze(-dplayer(1,:)))';
                    
                    z0=squeeze(z(it,:,2));
                    u0=squeeze(u(it,:,2));
                    v0=squeeze(v(it,:,2));
                    
                    imin=find(z0>-1e9, 1 );
                    imax=find(z0>-1e9, 1, 'last' );
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    if z0(end)>z0(1)
                        imin=find(z0>z0(1),   1, 'first')-1;
                        imax=find(z0<z0(end), 1, 'last' )+1;
                        %                         imin=find(z0>z0(1), 1 );
                        %                         imax=find(z0<z0(end), 1, 'last' );
                    else
                        imin=find(z0<=z0(1), 1 );
                        imax=find(z0>=z0(end), 1, 'last' );
                    end
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    
                    if z0(end)>z0(1)
                        z0=[-12000 z0 12000];
                    else
                        z0=[12000 z0 -12000];
                    end
                    u0=[u0(1) u0 u0(end)];
                    v0=[v0(1) v0 v0(end)];
                    u1(it,:,2)=interp1(z0,u0,squeeze(-dplayer(2,:)));
                    v1(it,:,2)=interp1(z0,v0,squeeze(-dplayer(2,:)));
                end
            else
                u1=u;
                v1=v;
            end
            
    end
    
    openBoundaries(i).timeSeriesT=[];
    openBoundaries(i).timeSeriesA=[];
    openBoundaries(i).timeSeriesB=[];
    openBoundaries(i).timeSeriesAV=[];
    openBoundaries(i).timeSeriesBV=[];
    
    switch lower(bnd.type)
        case{'z'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(wl(:,1));
            openBoundaries(i).timeSeriesB=squeeze(wl(:,2));
        case{'c'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(u1(:,:,1));
            openBoundaries(i).timeSeriesB=squeeze(u1(:,:,2));
        case{'n'}
            openBoundaries(i).timeSeriesT=[nest.t(1);nest.t(end)];
            openBoundaries(i).timeSeriesA=[0;0];
            openBoundaries(i).timeSeriesB=[0;0];
        case{'r'}
            openBoundaries(i).timeSeriesT=nest.t;
            calfac=1.0;
            acor1=-dps(1)/dp(1);
            acor1=max(min(acor1,2.0),0.5);
            acor2=-dps(2)/dp(2);
            acor2=max(min(acor2,2.0),0.5);
            acor1=acor1*calfac;
            acor2=acor2*calfac;
            %             cr1=cr1+acor1;
            %             cr2=cr2+acor2;
            for k=1:vertGrid.KMax
                switch lower(openBoundaries(i).side)
                    case{'left','bottom'}
                        r1(:,k)=acor1*squeeze(u1(:,k,1)) + calfac*squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=acor2*squeeze(u1(:,k,2)) + calfac*squeeze(wl(:,2))*sqrt(9.81/dp(2));
                    case{'top','right'}
                        r1(:,k)=acor1*squeeze(u1(:,k,1)) - calfac*squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=acor2*squeeze(u1(:,k,2)) - calfac*squeeze(wl(:,2))*sqrt(9.81/dp(2));
                end
            end
            openBoundaries(i).timeSeriesA=r1;
            openBoundaries(i).timeSeriesB=r2;
        case{'x'}
            openBoundaries(i).timeSeriesT=nest.t;
            for k=1:vertGrid.KMax
                switch lower(openBoundaries(i).side)
                    case{'left','bottom'}
                        r1(:,k)=squeeze(u1(:,k,1)) + squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=squeeze(u1(:,k,2)) + squeeze(wl(:,2))*sqrt(9.81/dp(2));
                    case{'top','right'}
                        r1(:,k)=squeeze(u1(:,k,1)) - squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=squeeze(u1(:,k,2)) - squeeze(wl(:,2))*sqrt(9.81/dp(2));
                end
            end
            openBoundaries(i).timeSeriesA=r1;
            openBoundaries(i).timeSeriesB=r2;
            openBoundaries(i).timeSeriesAV=squeeze(v1(:,:,1));
            openBoundaries(i).timeSeriesBV=squeeze(v1(:,:,2));
        case{'p'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(u1(:,:,1));
            openBoundaries(i).timeSeriesB=squeeze(u1(:,:,2));
            openBoundaries(i).timeSeriesAV=squeeze(v1(:,:,1));
            openBoundaries(i).timeSeriesBV=squeeze(v1(:,:,2));
    end
    
    openBoundaries(i).profile='uniform';
    if vertGrid.KMax>1
        switch lower(bnd.type)
            case{'c','r','x','p'}
                openBoundaries(i).profile='3d-profile';
        end
    end
    
end

%% And now do the Neumann boundaries (this only works correctly in case of ONE water
%% level boundary!).
% First check if there are N boundaries
ibndneu=[];
nbndneu=0;
ibndwl=[];
nbndwl=0;
for i=1:length(openBoundaries)
    switch lower(openBoundaries(i).type)
        case{'n'}
            nbndneu=nbndneu+1;
            ibndneu(nbndneu)=i;
        case{'z'}
            nbndwl=nbndwl+1;
            ibndwl(nbndwl)=i;
    end
end
if nbndneu>0 && nbndwl==1
    % Compute length of water level boundary (take the first boundary)
    bndwl=openBoundaries(ibndwl(1));
    switch lower(cs)
        case{'projected','cartesian','xy'}
            lngth=sqrt((bndwl.x(end)-bndwl.x(1)).^2 + (bndwl.y(end)-bndwl.y(1)).^2);
        otherwise
            lngth=sqrt((111135.0*cos(0.5*(bndwl.y(1)+bndwl.y(end))*pi/180)*(bndwl.x(end)-bndwl.x(1))).^2 + (111323.7*(bndwl.y(end)-bndwl.y(1))).^2);
    end
    % Determine grid direction
    if strcmpi(bndwl.orientation,'positive')
        idir=1;
    else
        idir=-1;
    end
    wlgrad=idir*(squeeze(bndwl.timeSeriesB)-squeeze(bndwl.timeSeriesA))/lngth;
    for i=1:nbndneu
        openBoundaries(ibndneu(i)).timeSeriesT=openBoundaries(ibndwl(1)).timeSeriesT;
        openBoundaries(ibndneu(i)).timeSeriesA=wlgrad;
        openBoundaries(ibndneu(i)).timeSeriesB=wlgrad;
    end
end

%%
function openBoundaries=nesthd2_transport(openBoundaries,vertGrid,s,nest)

for i=1:length(openBoundaries)
    
    disp(['   Boundary ' openBoundaries(i).name ' - ' num2str(i) ' of ' num2str(length(openBoundaries))]);
    
    namcon=nest.namcon;
    
    nsed=0;
    ntrac=0;
    
    bnd=openBoundaries(i);
    
    for j=1:length(namcon)
        nm=lower(namcon{j});
        nm=nm(1:min(8,length(nm)));
        switch nm
            case{'salinity'}
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).salinity.nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).salinity.timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).salinity.timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).salinity.timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).salinity.profile=bnd.data.profile;
            case{'temperat'}
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).temperature.nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).temperature.timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).temperature.timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).temperature.timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).temperature.profile=bnd.data.profile;
            case{'sediment'}
                nsed=nsed+1;
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).sediment(nsed).nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).sediment(nsed).timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).sediment(nsed).timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).sediment(nsed).timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).sediment(nsed).profile=bnd.data.profile;
            otherwise
                ntrac=ntrac+1;
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).tracer(ntrac).nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).tracer(ntrac).timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).tracer(ntrac).timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).tracer(ntrac).timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).tracer(ntrac).profile=bnd.data.profile;
        end
        
    end
    
end

%%
function bnd=fillbnd(bnd,vertGrid,s,nest,ipar)

par=nest.constituent(ipar).data;

% A
m=bnd.M1;
n=bnd.N1;
j=find(s.wl.m==m & s.wl.n==n,1);
val(:,:,1)=par{j};
z(:,:,1)=nest.z{j};

% B
m=bnd.M2;
n=bnd.N2;
j=find(s.wl.m==m & s.wl.n==n,1);
val(:,:,2)=par{j};
z(:,:,2)=nest.z{j};

% Now interpolate over water column

dp(1)=-bnd.depth(1);
dp(2)=-bnd.depth(2);
if strcmpi(vertGrid.layerType,'z')
    dplayer=squeeze(getLayerDepths(dp,vertGrid.thick,vertGrid.zBot,vertGrid.zTop));
    dplayer=fliplr(dplayer);
else
    dplayer=squeeze(getLayerDepths(dp,vertGrid.thick));
end

if length(vertGrid.thick)==1
    dplayer=dplayer';
end

val1=zeros(length(nest.t),length(vertGrid.thick),2);

for it=1:length(nest.t)
    
    if strcmpi(vertGrid.layerType,'z')
        % A
        z0=squeeze(z(it,:,1));
        val0=squeeze(val(it,:,1));
        
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        % Sometimes required in case of z layers
        imax=find(isnan(z0), 1, 'first' );
        if ~isempty(imax)
            z0=z0(1:imax-1);
            val0=val0(1:imax-1);
        end
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end A contains only NaNs']);
        end
        
        dpa=squeeze(-dplayer(1,:));
        vala=interp1(z0,val0,dpa);
        
        % B
        z0=squeeze(z(it,:,2));
        val0=squeeze(val(it,:,2));
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        % Sometimes required in case of z layers
        imax=find(isnan(z0), 1, 'first' );
        if ~isempty(imax)
            z0=z0(1:imax-1);
            val0=val0(1:imax-1);
        end
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end B contains only NaNs']);
        end
        
        dpb=squeeze(-dplayer(2,:));
        valb=interp1(z0,val0,dpb);
        
        anotb=find(~isnan(vala) & isnan(valb));
        valb(anotb)=vala(anotb);
        
        bnota=find(~isnan(valb) & isnan(vala));
        vala(bnota)=valb(bnota);
        
        imin=find(~isnan(vala), 1 );
        imax=find(~isnan(vala), 1, 'last' );
        if imin>1
            vala(1:imin-1)=vala(imin);
        end
        if imax<length(vala)
            vala(imax+1:end)=vala(imax);
        end
        
        imin=find(~isnan(valb), 1 );
        imax=find(~isnan(valb), 1, 'last' );
        if imin>1
            valb(1:imin-1)=valb(imin);
        end
        if imax<length(valb)
            valb(imax+1:end)=valb(imax);
        end
        
        val1(it,:,1)=vala;
        val1(it,:,2)=valb;
        
    else
        % A
        z0=squeeze(z(it,:,1));
        val0=squeeze(val(it,:,1));
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end A contains only NaNs']);
        end
        
        if z0(end)>z0(1)
            z0=[-12000 z0 12000];
        else
            z0=[12000 z0 -12000];
        end
        val0=[val0(1) val0 val0(end)];
        
        val1(it,:,1)=interp1(z0,val0,squeeze(-dplayer(1,:)));
        
        % B
        z0=squeeze(z(it,:,2));
        val0=squeeze(val(it,:,2));
        
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end B contains only NaNs']);
        end
        
        if z0(end)>z0(1)
            z0=[-12000 z0 12000];
        else
            z0=[12000 z0 -12000];
        end
        val0=[val0(1) val0 val0(end)];
        val1(it,:,2)=interp1(z0,val0,squeeze(-dplayer(2,:)));
        
    end
end

bnd.data.nrTimeSeries=length(nest.t);
bnd.data.timeSeriesT = nest.t;
bnd.data.timeSeriesA = squeeze(val1(:,:,1));
bnd.data.timeSeriesB = squeeze(val1(:,:,2));
if vertGrid.KMax>1
    bnd.data.profile='3d-profile';
else
    bnd.data.profile='uniform';
end

%%
function varargout=readData(fid,par,isteps,istation,overallmodel,kmax)

switch lower(overallmodel)

    case{'delft3dflow'}
        
        switch par

            case{'bedlevel'}
                % Read water levels
                v=qpread(fid,1,'bed level','data',isteps,istation);
                varargout{1}=0;
                varargout{2}=squeeze(v.Val);

            case{'waterlevel'}
                % Read water levels
                v=qpread(fid,1,'water level','data',isteps,istation);
                dpt=qpread(fid,1,'water depth','data',isteps,istation);
                v.Val(dpt.Val<0.01)=0.0;
                varargout{1}=0;
                varargout{2}=squeeze(v.Val);
                
            case{'velocity'}
                % Read velocities
                if kmax==1
                    v=qpread(fid,1,'depth averaged velocity','griddata',isteps,istation);
                    v.Z=zeros(size(v.XComp));
                else
                    v=qpread(fid,1,'horizontal velocity','griddata',isteps,istation);
                end
                varargout{1}=squeeze(v.Z);
                varargout{2}=squeeze(v.XComp);
                varargout{3}=squeeze(v.YComp);
                varargout{4}=squeeze(v.XComp);
                varargout{5}=squeeze(v.YComp);
                
        end

    case{'dflowfm'}
        
        switch par

            case{'bedlevel'}
                % Read water levels
                v=qpread(fid,1,'bed level','data',isteps,istation);
                varargout{1}=0;
                varargout{2}=squeeze(v.Val);

            case{'waterlevel'}
                % Read water levels
                v=qpread(fid,1,'Water level (points)','data',isteps,istation);
%                 dpt=qpread(fid,1,'water depth','data',isteps,istation);
%                 v.Val(dpt.Val<0.01)=0.0;
                varargout{1}=0;
                varargout{2}=squeeze(v.Val);
                
            case{'velocity'}
                % Read velocities
                if kmax==1
                    v=qpread(fid,1,'velocity (points)','griddata',isteps,istation);
                    v.Z=zeros(size(v.XComp));
                else
                    v=qpread(fid,1,'velocity (points)','griddata',isteps,istation);
                end
                varargout{1}=squeeze(v.Z);
                varargout{2}=squeeze(v.XComp);
                varargout{3}=squeeze(v.YComp);
                varargout{4}=squeeze(v.XComp);
                varargout{5}=squeeze(v.YComp);
                
        end
        
end

%%
function vout=computeMean(nst,fld,stationnames,kmax,v)

w4=[0 0 0 0];
v4=zeros(size(v,1),4);

for ip=1:length(nst.(fld))
    istat=strmatch(nst.(fld)(ip).name,stationnames,'exact');
    if ~isempty(istat)
        if kmax==1
            v4(:,ip)=squeeze(v(:,istat));
            w4(ip)=nst.(fld)(ip).w;
        else
            v4(:,ip,:)=squeeze(v(:,istat,:));
            w4(ip)=nst.(fld)(ip).w;
        end
    else
        error(['Error! Station ' nst.(fld)(ip).name ' not found on history file!']);
    end
end

if kmax==1
    vout=v4*w4';
else
    for k=1:kmax
        vout(:,k)=v4(:,:,kmax)*w4';
    end
end
            
clear u0 v0 z0 w vel00

%%
function [allstations,times,kmax,fid]=readOverallModelData(hisfile,overallmodeltype)
% Reads stations, times, kmax from overall model

switch lower(overallmodeltype)
    case{'delft3dflow'}
        fid=qpfopen(hisfile);
        allstations = qpread(fid,1,'water level','stations');
        times       = qpread(fid,1,'water level','times');
        vs_use(hisfile,'quiet');
        kmax=vs_get('his-const','KMAX','quiet');
    case{'dflowfm'}
        fid=qpfopen(hisfile);
        allstations = qpread(fid,1,'Water level (points)','stations');
        times       = qpread(fid,1,'Water level (points)','times');
        kmax=1;
%         vs_use(hisfile,'quiet');
%         kmax=vs_get('his-const','KMAX','quiet');
end
