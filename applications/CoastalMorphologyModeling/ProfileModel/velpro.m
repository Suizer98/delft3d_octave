clear all;close all
% Input
%
h=5         	% water depth
Hrms=1          % wave height
Tp=5            % wave period
dir=30      	% wave direction w.r.t. normal
ks=.05      	% bed roughness
rho=1025    	% density
kappa=0.4   	% von Karman constant
gamma=0.75      % breaker parameter
g=9.81
glm=1
semilogscale=0
color={'r','b'}
for h=2:9
    k=disper(h,Tp)  % wave number
    Dw=Baldock(gamma,k,h,Hrms,Tp,1);
    omega=2*pi/Tp;
    tauw=Dw*k/omega
    L=2*pi/k;C=omega/k;
    z0=ks/33                               		% z0 roughness height
    Chezy=18*log10(12*h/ks)                    	% Chezy coefficient
    Cf=9.81/Chezy^2                             % Friction coefficient
    %
    % Computation
    %
    tauwx=tauw*cos(dir*pi/180);
    tauwy=tauw*sin(dir*pi/180);
    z0=ks/33                               		% z0 roughness height
    Chezy=18*log10(12*h/ks)                    	% Chezy coefficient
    Cf=9.81/Chezy^2                             % Friction coefficient
    V=sqrt(tauwy/rho/Cf)             		    % Estmated depth-averaged velocity 2DH
    vst=sqrt(tauw/rho)                     		% Shear velocity
    z=-h+z0:0.001:-0.001;                   	% Z-array
    for glm=0:1
        if glm
            ust=1/2*(pi*Hrms/L)^2*C*cosh(2*k*(z+h))/(sinh(k*h))^2*cos(dir*pi/180);
            taubx=1/(1-log(h/z0))*(tauwx+rho*kappa*vst*ust(1));            	% Cross-shore bed shear stress
            u=-1/rho/vst/kappa*(tauwx*log(z/(z0-h)) ...
                -taubx*log((h+z)/z0))+ust(1)
            ; 		% cross-shore velocity as function of z
            ue=u-ust;
        else
            ust=1/8*g*Hrms^2/C/h*ones(size(z));
            taubx=1/(1-log(h/z0))*(tauwx+rho*kappa*vst*(mean(ust)));            	% Cross-shore bed shear stress
            u=-1/rho/vst/kappa*(tauwx*log(z/(z0-h)) ...
                -taubx*log((h+z)/z0)); 		% cross-shore velocity as function of z
            ue=u;
        end
        v=tauwy/rho/vst/kappa*log((h+z)./z*(z0-h)/z0);  	% longshore velocity as function of z
        %
        % Plotting
        %
        figure(1)
        subplot(121)
        if semilogscale
            semilogy(ue,z+h,color{glm+1},ust,z+h,[color{glm+1},'--'],'linewidth',2);xlabel('u (m/s)'),ylabel('z (m)');
        else
            plot(ue,z+h,color{glm+1},ust,z+h,[color{glm+1},'--'],'linewidth',2);xlabel('u (m/s)'),ylabel('z (m)');
        end
        title(' Cross-shore velocity');
        hold on
        subplot(122)
        if semilogscale
            semilogy(v,z+h,color{glm+1},V,z+h,[color{glm+1},'--'],'linewidth',2);xlabel('v (m/s)'),ylabel('z (m)')
        else
            plot(v,z+h,color{glm+1},V,z+h,[color{glm+1},'--'],'linewidth',2);xlabel('v (m/s)'),ylabel('z (m)')
        end
        title(' Longshore velocity')
    end
    subplot(121)
    legend('u_E, no GLM','u_s_t, no GLM','u_E, GLM','u_s_t, GLM')
    print('-depsc',['velpro' num2str(h),'.eps'])
    close all
end