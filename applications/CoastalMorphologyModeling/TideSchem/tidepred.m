clear all; close all;
% Dimensions Grays Harbor
A=237000000;
Bh=24000;
umean=.1;
fac = [1  1  1  1    1    1.0836; ...
       0  1  1  0    1    0; ...
       0  1  1  0    1    0; ...
       0  0  1  0    1    0; ...
       0  0  1  0    1    0; ...
       0  0  0  1    0    1; ...
       0  0  0  0 -.13 -.13]
% name    frequency  (1/hr)
fM2  =   .0805114006  ;
fS2  =   .0833333333  ;
fN2  =   .0789992487  ;
fK1  =   .0417807462  ;
fO1  =   .0387306544  ;
fC1  =   .0402557003  ;
fM4  = 2*fM2  ;
TM2S2=1/(fS2-fM2)/24
TM2N2=1/(fM2-fN2)/24
TS2N2=1/(fS2-fN2)/24
% amplitude
for j=1:6;
    M2  =     0.954000 *fac(1,j);
    S2  =     0.216000 *fac(2,j);
    N2  =     0.174000 *fac(3,j);
    K1  =     0.501000 *fac(4,j);
    O1  =     0.274000 *fac(5,j);
    C1  =     0.524000 *fac(6,j);
    umean=              fac(7,j);
    M4  = 0;
    % phase
    gM2  =    229.810;
    gS2  = 	  248.900;
    gN2  = 	  210.590;
    gK1  = 	  230.850;
    gO1  = 	  221.560;
    gC1  =    .5*(gO1+gK1);
    gM4  =    2*gM2-360;
    %
    starttime = datenum(2003,1,1);
    endtime   = datenum(2004,1,1);
    refdate   = datenum(1900,1,1);
    %
    t=[starttime:1/24/6:endtime];
    trel=(t-refdate)*24;
    eta=M2*cos(2*pi*fM2*trel-gM2/360) + ...
        S2*cos(2*pi*fS2*trel-gS2/360) + ...
        N2*cos(2*pi*fN2*trel-gN2/360) + ...
        K1*cos(2*pi*fK1*trel-gK1/360) + ...
        O1*cos(2*pi*fO1*trel-gO1/360) + ...
        C1*cos(2*pi*fC1*trel-gC1/360) + ...
        M4*cos(2*pi*fM4*trel-gM4/360);
    detadt=-2*pi*fM2/3600*M2*sin(2*pi*fM2*trel-gM2/360) + ...
        -2*pi*fS2/3600*S2*sin(2*pi*fS2*trel-gS2/360) + ...
        -2*pi*fN2/3600*N2*sin(2*pi*fN2*trel-gN2/360) + ...
        -2*pi*fK1/3600*K1*sin(2*pi*fK1*trel-gK1/360) + ...
        -2*pi*fO1/3600*O1*sin(2*pi*fO1*trel-gO1/360) + ...
        -2*pi*fC1/3600*C1*sin(2*pi*fC1*trel-gC1/360) + ...
        -2*pi*fM4/3600*M4*sin(2*pi*fM4*trel-gM4/360);
    u = detadt*A/Bh+umean;
    s = u.^3;
    tfilt=2*round(1/(fS2-fM2)*6);tshift=round(tfilt/2);
    bfilt=ones(tfilt,1)/tfilt;
    s_lo=filter(bfilt,1,s);
    s_lo(1:end-tshift)=s_lo(1+tshift:end);
    cs=cumsum(s);
    spos=s;
    spos(spos<0)=0;
    smin=s;
    smin(smin>0)=0;
    cspos=cumsum(spos);
    csmin=cumsum(smin);
    faclo=50;
    faccs=1/365/24/6*faclo;
    %
    %
    figure(3)
    subplot(6,3,3*j-2);
    plot(t,u);
    axis([starttime endtime -3 3]);
    datetick('x','mm/yy');
    if j==1;title('U (m/s)');end
    if j<6;set(gca,'xticklabel',[]);end
    subplot(6,3,3*j-1);
    plot(t,s,t,faclo*s_lo);
    axis([starttime endtime -25 25]);
    if     j==1;text(starttime+10,15,'M2               ');
    elseif j==2;text(starttime+10,15,'M2+S2+N2         ');
    elseif j==3;text(starttime+10,15,'M2+S2+N2+O1+K1   ');
    elseif j==4;text(starttime+10,15,'M2+       C1     ');
    elseif j==5;text(starttime+10,15,'M2+S2+N2+O1+K1+Mean');
    elseif j==6;text(starttime+10,15,'M2*1.0836+C1+Mean  ');
    end
    datetick('x','mm/yy');
    if j==1;title('U³ (m³/s³)');end
    if j<6;set(gca,'xticklabel',[]);end
    subplot(6,3,3*j);
    plot(t,cs*faccs,t,cspos*faccs,t,csmin*faccs);
    axis([starttime endtime -50 50]);
    datetick('x','mm/yy');
	
    if j==1;title('Cum. U³ (m³/s³)');end
    if j<6;set(gca,'xticklabel',[]);end
    drawnow
    figure(1);
    if j>4
        if j==5;ch='b';else; ch='r';end
        plot(t,cs*faccs,ch,t,cspos*faccs,ch,t,csmin*faccs,ch,'linewidth',2);
        legend('M2+S2+N2+O1+K1+Mean','1.08M2+C1+Mean')
        hold on
        axis([starttime endtime -50 50]);
        datetick('x','mm/yy');
        title('Cum. U³ (m³/s³)')
        
		
    end
end

figure(1)
set(gcf,'color','w')
print('-depsc','tiderep.eps')
print('-dpng','tiderep.png')
figure(3)
set(gcf,'color','w')
print('-depsc','tidepred.eps')
print('-dpng','tidepred.png')