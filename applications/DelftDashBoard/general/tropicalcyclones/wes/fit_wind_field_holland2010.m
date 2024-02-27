function [xn,vt,phia]=fit_wind_field_holland2010(vmax,rmax,pc,vtreal,phit,pn,phi_spiral,lat,dpdt,obs,wrad)

size_factor=1;

phi=90:-10:-270; % radial angles (cartesian, degrees)

rmax=rmax*1000; % convert from km to m

%wrad=[35 50 65 100];
%wrad=wrad*0.9/1.944; % Convert 10-minute averaged m/s

r=4000:4000:1000000;

% First estimates
xn=0.5;
vt=0.6*vtreal;

if lat>0
    phia=45; % angle with respect to track angle (cartesian degrees i.e. counter-clockwise)
else
    phia=-45;
end

dxn=0.01;
dvt=0.5;
dphia=5;

nrad=2;

%vvv=[35 50 65 100];

nobs=0;
for iq=1:length(obs.quadrant)
%    for irad=1:length(obs.quadrant(iq).radius)
    for irad=1:nrad
        if ~isnan(obs.quadrant(iq).radius(irad))
            obs.quadrant(iq).radius(irad)=obs.quadrant(iq).radius(irad)*size_factor;
            nobs=nobs+1;
%             obs.quadrant(iq).relative_speed(irad)=vvv(irad)*0.93/1.944;
        end
    end
end

% Just for plotting
xx=zeros(length(phi),length(r));
yy=xx;
for j=1:length(phi)
    xx(j,:)=0.001*r.*cos(phi(j)*pi/180);
    yy(j,:)=0.001*r.*sin(phi(j)*pi/180);
end

if nobs>0 && vmax>21
    
    % We first try to estimate the asymmetry angle phia using simple spline
    % function
    % Use R50 if all available, otherwise use any R35 available
%     r50 = [obs.quadrant(2).radius(2) obs.quadrant(1).radius(2) obs.quadrant(4).radius(2) obs.quadrant(3).radius(2) obs.quadrant(2).radius(2) obs.quadrant(1).radius(2)];
%     r50(isnan(r50))=0;
%     if all(r50)
%         % Use R50
%         drs=[-45 45 135 225 315 405];
%         ddd=0:1:360;
%         rmx=spline(drs,r50,ddd);
%         imx=find(rmx==max(rmx),1,'first');
%         phia=ddd(imx)-phit+90;
%     else
        % Try with R35
        r35 = [obs.quadrant(3).radius(1) obs.quadrant(2).radius(1) obs.quadrant(1).radius(1) obs.quadrant(4).radius(1) obs.quadrant(3).radius(1) obs.quadrant(2).radius(1) obs.quadrant(1).radius(1) obs.quadrant(4).radius(1)];
        r35(isnan(r35))=0;
        if any(r35)
            % Set R35 where not available to 0.75 of minimum available R35
            rmin=nanmin(r35);
            r35(r35==0)=rmin*0.75;
            drs=[-135 -45 45 135 225 315 405 495];
            ddd=0:1:360;
            rmx=spline(drs,r35,ddd);
            imx=find(rmx==max(rmx),1,'first');
            if lat>0
                phia=ddd(imx)+90-phit;
            else
                phia=ddd(imx)-90-phit;
            end
            if phia<-180
                phia=phia+360;
            end
            if phia>180
                phia=phia-360;
            end
        end
%         
%     end
    
    for irep=1:3
        
        w=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt,phia);
        [mean_error, rms_error, err]=compute_mean_error(r,w,obs,wrad);
        
        nit=0;
        
        % Now first adjust size of storm with xn
        while 1
            
            nit=nit+1;
            
            wu=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn+dxn,vt,phia);
            [mean_error_u, rms_error_u, err_u]=compute_mean_error(r,wu,obs,wrad);
            wd=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn-dxn,vt,phia);
            [mean_error_d, rms_error_d, err_d]=compute_mean_error(r,wd,obs,wrad);
            
            if rms_error_u<rms_error
                % Better with larger value of xn
                xn=xn+dxn;
                rms_error=rms_error_u;
            elseif rms_error_d<rms_error
                % Better with smaller value of xn
                xn=xn-dxn;
                rms_error=rms_error_d;
            else
                % Optimum reached
                break
            end
            
            if xn<0.3 || xn>1.0
                break
            end
            
            if nit>100
                break
            end
            
        end
        
        nit=0;
        % Now the asymmetry magnitude
        while 1
            
            nit=nit+1;
            
            w=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt+dvt,phia);
            [mean_error_u, rms_error_u, err_u]=compute_mean_error(r,w,obs,wrad);
            w=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt-dvt,phia);
            [mean_error_d, rms_error_d, err_d]=compute_mean_error(r,w,obs,wrad);
            
            if rms_error_u<rms_error
                % Better with larger value of vt
                vt=vt+dvt;
                rms_error=rms_error_u;
            elseif rms_error_d<rms_error
                % Better with smaller value of vt
                vt=vt-dvt;
                rms_error=rms_error_d;
            else
                break
            end
            
            if vt<0.0 || vt>1.5*vtreal
                break
            end
            
            if nit>100
                break
            end
            
        end
        
        nit=0;
        % Now the asymmetry direction
        while 1
            
            nit=nit+1;
            
            w=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt,phia+dphia);
            [mean_error_u, rms_error_u, err_u]=compute_mean_error(r,w,obs,wrad);
            w=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt,phia-dphia);
            [mean_error_d, rms_error_d, err_d]=compute_mean_error(r,w,obs,wrad);
            
            if rms_error_u<rms_error
                % Better with larger value of vt
                phia=phia+dphia;
                rms_error=rms_error_u;
            elseif rms_error_d<rms_error
                % Better with smaller value of vt
                phia=phia-dphia;
                rms_error=rms_error_d;
            else
                break
            end
            if phia<-180
                phia=phia+360;
            end
            if phia>180
                phia=phia-360;
            end
                
            
            if nit>100
                break
            end
            
        end
        
    end
    
end

function [mean_error, rms_error, err]=compute_mean_error(r,w,obs,wrad)

nq=4;
nrad=1;

iq1=[1 10 19 28];
iq2=[10 19 28 37];


err=zeros(nq,nrad);

for iq=1:nq
    for irad=1:nrad
        vrad=0;
        for j=iq1(iq):iq2(iq)
            ww=w(j,:);            
            if ~isnan(obs.quadrant(iq).radius(irad))
                % Compute wind speed vrad at required radius
                w0=interp1(r,ww,obs.quadrant(iq).radius(irad)*1000);
                vrad=max(vrad, w0);                
            else
                % Maximum wind speed must be lower than wrad
                w0=max(ww);
                vrad=max(vrad, w0);
            end
        end
        if ~isnan(obs.quadrant(iq).radius(irad))
            err(iq,irad)    = vrad - wrad(irad);
        else
            err(iq,irad) = NaN;
        end
    end
end
mean_error=nanmean(nanmean(err));
rms_error=sqrt(nanmean(nanmean(err.^2)));

function wind_speed=compute_wind_field(r,phi,vmax,pc,rmax,pn,vtreal,phit,lat,dpdt,phi_spiral,xn,vt,phia)

vms = vmax - vt;

[vr,pr]=holland2010_v02(r,vms,pc,pn,rmax,dpdt,lat,vtreal,xn);

wind_speed=zeros(length(phi),length(r));
wind_to_direction_cart=zeros(length(phi),length(r));

for iphi=1:length(phi)
    
    wind_speed(iphi,:) = vr;
    
    if lat>=0.0
        % Northern hemisphere
        dr=90+phi(iphi)+phi_spiral;
    else
        % Southern hemisphere
        dr=-90+phi(iphi)-phi_spiral;
    end
    wind_to_direction_cart(iphi,:)=dr;
end

ux=vt*cos((phit+phia)*pi/180);
uy=vt*sin((phit+phia)*pi/180);

vx=wind_speed.*cos(wind_to_direction_cart*pi/180)+ux;
vy=wind_speed.*sin(wind_to_direction_cart*pi/180)+uy;
wind_speed=sqrt(vx.^2 + vy.^2);
       
