function [c,dps,sedthick,srcsnk]=difu4(c,wl,dps,sedthick,he,u,v,grd,par,updbed)

% Water depths
% at cell centres
h=wl-dps;
%h(h<0.1)=NaN;
dryflc=0.1;
% Determine kfu, kfv and kfs
kfs=zeros(size(dps));
kfs(h>dryflc)=1;
kfu=zeros(size(dps));
kfv=kfu;
kfu(kfs==1 & kfs(grd.nmu)==1)=1;
kfv(kfs==1 & kfs(grd.num)==1)=1;

h=max(h,0.01);

% at cell faces
hu=0.5*(h(grd.nm)+h(grd.nmu));
hv=0.5*(h(grd.nm)+h(grd.num));

% Equilibrium concentration ce
ce=par.cE.*(he./h).^par.nfac;

% fixfac=sedthick/0.1;
% fixfac=max(0,min(fixfac,1));
% fixfac=zeros(size(dps))+1;

% Discharges
qu=kfu.*u.*hu;
qv=kfv.*v.*hv;

% Boundary conditions
%     cc(1,:)=0;
%     cc(end,:)=0;
%     cc(:,1)=0;
%     cc(:,end)=0;

%     cc(1,:)=max(cc(2,:),0);
%     cc(end,:)=max(cc(end-1,:),0);
%     cc(:,1)=max(cc(:,2),0);
%     cc(:,end)=max(cc(:,end-1),0);

%% Advection

% qup=max(qu,0);
% qum=min(qu(grd.nmd),0);
% qvp=max(qv,0);
% qvm=min(qv(grd.ndm),0);
% 
% qup=max(qu(grd.nmd),0);
% qum=min(qu(grd.nm),0);
% qvp=max(qv(grd.ndm),0);
% qvm=min(qv(grd.nm),0);
% 
% qup=0.5*(max(qu(grd.nmd),0)+max(qu(grd.nm),0));
% qum=0.5*(min(qu(grd.nmd),0)+min(qu(grd.nm),0));
% qvp=0.5*(max(qv(grd.ndm),0)+max(qv(grd.nm),0));
% qvm=0.5*(min(qv(grd.ndm),0)+min(qv(grd.nm),0));


qup=max(qu,0);
qum=min(qu,0);
qvp=max(qv,0);
qvm=min(qv,0);

% qup=qup.*fixfac;
% qum=qum.*fixfac(grd.nmu);
% qvp=qvp.*fixfac;
% qvm=qvm.*fixfac(grd.num);


cnm=c;

cnmuuu=c(grd.nmuuu);
cnmuu=c(grd.nmuu);
cnmu=c(grd.nmu);
cnmd=c(grd.nmd);
cnmdd=c(grd.nmdd);

cnuuum=c(grd.nuuum);
cnuum=c(grd.nuum);
cnum=c(grd.num);
cndm=c(grd.ndm);
cnddm=c(grd.nddm);

cnmuu(isnan(cnmuu))=cnm(isnan(cnmuu));
cnmu(isnan(cnmu))=cnm(isnan(cnmu));
cnmd(isnan(cnmd))=cnm(isnan(cnmd));
cnmdd(isnan(cnmdd))=cnm(isnan(cnmdd));

cnuum(isnan(cnuum))=cnm(isnan(cnuum));
cnum(isnan(cnum))=cnm(isnan(cnum));
cndm(isnan(cnum))=cnm(isnan(cnum));
cnddm(isnan(cnum))=cnm(isnan(cnum));

% Fluxes in x direction
cxp=(10*cnm-5*cnmd+1*cnmdd)/6;
cxm=(10*cnmu-5*cnmuu+1*cnmuuu)/6;
% cxp=max(cxp,0);
% cxm=max(cxm,0);
qxp=qup.*(cxp-par.cE);
qxm=qum.*(cxm-par.cE);
qx=(qxp+qxm).*grd.dx; % kg/s

% Fluxes in y direction
cyp=(10*cnm-5*cndm+1*cnddm)/6;
cym=(10*cnum-5*cnuum+1*cnuuum)/6;
% cyp=max(cyp,0);
% cym=max(cym,0);
qyp=qvp.*(cyp-par.cE);
qym=qvm.*(cym-par.cE);
qy=(qyp+qym).*grd.dy; % kg/s

qx(isnan(qx))=0;
qy(isnan(qy))=0;

%Total mass in each cell
m=c.*h.*grd.a;

%cvol0=nansum(m)*10000/par.cdryb;

m = m - par.dt*qx;
m = m + par.dt*qx(grd.nmd);
m = m - par.dt*qy;
m = m + par.dt*qy(grd.ndm);

%cvol1=nansum(m)*10000/par.cdryb;

c = m./h./grd.a;

%dvol=par.morfac*(cvol1-cvol0);
%disp(100*dvol/cvol1)


% uxm = ( 2*c(grd.nmu) + 3*c(grd.nm) - 6*c(grd.nmd) + 1*c(grd.nmdd))./(6*grd.dx);
% uym = ( 2*c(grd.num) + 3*c(grd.nm) - 6*c(grd.ndm) + 1*c(grd.nddm))./(6*grd.dy);
% uxp = (-2*c(grd.nmd) - 3*c(grd.nm) + 6*c(grd.nmu) - 1*c(grd.nmuu))./(6*grd.dx);
% uyp = (-2*c(grd.ndm) - 3*c(grd.nm) + 6*c(grd.num) - 1*c(grd.nuum))./(6*grd.dy);
% 
% cvol0=nansum(c.*-dps)*10000/par.cdryb;
% %    c = c - dt*(up.*uxm + um.*uxp + vp.*uym + vm.*uyp);
% c = c - par.dt*(qup.*uxm + qum.*uxp + qvp.*uym + qvm.*uyp)./max(h,0.01);
% cvol1=nansum(c.*-dps)*10000/par.cdryb;
% dvol=par.morfac*(cvol1-cvol0);
% disp(100*dvol/cvol1)

%% Diffusion

% Sediment fluxes
qx=kfu.*par.d.*grd.dy.*hu.*(c-c(grd.nmu))./grd.dx; % kg/s
qy=kfv.*par.d.*grd.dx.*hv.*(c-c(grd.num))./grd.dy; % kg/s
qx(isnan(qx))=0;
qy(isnan(qy))=0;

% Total suspended mass in each cell
m=c.*h.*grd.a;

% Update sediment mass
m = m - par.dt*qx;
m = m + par.dt*qx(grd.nmd);
m = m - par.dt*qy;
m = m + par.dt*qy(grd.ndm);

% Compute new concentrations
c = m./h./grd.a;
%c(c<0)=0;

% %% Forester filter (check for negative concentrations)
% maxfil=20;
% cthr=-0.001;
% cthr=-10000;
% if min(c)<cthr
%     for itfil=1:maxfil
%         c0=c;
%         idifu=zeros([1 length(c)]);
%         idifu(c<cthr)=1;
%         volnmu = min(1.0, volum1(grd.nmu)./volum1(grd.nm));
%         cofnmu = 0.125*(idifu(grd.nmu) + idifu(grd.nm)).*kfu(grd.nm).*volnmu;
%         volnmd = min(1.0, volum1(grd.nmd)./volum1(grd.nm));
%         cofnmd = 0.125*(idifu(grd.nmd) + idifu(grd.nm)).*kfu(grd.nmd).*volnmd;
%         volnum = min(1.0, volum1(grd.num)./volum1(grd.nm));
%         cofnum = 0.125*(idifu(grd.num) + idifu(grd.nm)).*kfv(grd.nm).*volnum;
%         volndm = min(1.0, volum1(grd.ndm)./volum1(grd.nm));
%         cofndm = 0.125*(idifu(grd.ndm) + idifu(grd.nm)).*kfv(grd.ndm).*volndm;
%         cofnmu(isnan(cofnmu))=0;
%         cofnmd(isnan(cofnmd))=0;
%         cofnum(isnan(cofnum))=0;
%         cofndm(isnan(cofndm))=0;
%         c = c0 .* (1 - cofnmu - cofnmd - cofndm - cofnum) + ...
%             c0(nmu).*cofnmu + ...
%             c0(nmd).*cofnmd + ...
%             c0(num).*cofnum + ...
%             c0(ndm).*cofndm;
%         % Check againg for negative concentrations
%         if min(c)>=cthr
%             %                 disp(itfil)
%             break
%         end
%     end
% end

%% Erosion and deposition
ffac=kfs.*par.dt.*par.ws./h; % (-)
% ffac=par.dt*par.ws./h; % (-)
%ffac=min(ffac,1); % Limit ffac to 1
srcsnk=kfs.*ffac.*(ce-c); % (kg/m3)
%srcsnk(kfs==0)=0;
%srcsnk(srcsnk>0 & sedthick<0.05) = 0;
%srcsnk(srcsnk>0) = srcsnk(srcsnk>0).*fixfac(srcsnk>0);
% Update concentrations
c = c + srcsnk;

% c(isnan(c))=0;

if updbed
    h0 = h;
    dps = dps - par.morfac*srcsnk.*h/par.cdryb;
    sedthick = sedthick - par.morfac*srcsnk.*h/par.cdryb;
    h1=max(wl-dps,0.01);
    c=c.*(h0./h1);
end
