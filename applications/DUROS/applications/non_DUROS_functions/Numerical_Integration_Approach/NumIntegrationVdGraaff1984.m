%NUMINTEGRATIONVDGRAAFF1984     routine to reproduce the numerical
%integration as carried out by Van de Graaff, 1984 (Probabilistische
%methoden bij het duinontwerp, achtergronden van de taw-leidraad
%'duinafslag'
clear; close all; clc

startTime       = clock;
steps           = [25  5 20  5 20]; % WL_t Hsig_t D50 profile others
zRef            = 5; % most seaward intersection of this level with the profile will be used as x-reference to express the retreat
Tp_t            = 12;
variables       = [ 1  1  1  1  3];
Nvariables      = sum(variables(steps~=1));

results = zeros(prod(steps),8);

% waterlevel
alfa    = 727.86;
beta    = 3.01;
Pmin    = 1e-7;
Pmax    = 1e-2;
[WL_t, P] = getWaterlevel(alfa, beta, Pmin, Pmax, steps(1));

% wave height
sigmaHsig_t = .6;

% grain size
muD50       = 225e-6;
sigmaD50    = muD50/10;

% profile
xInitial        = [-200 -24.375 5.625 55.725 230.625 1950]';
zInitial        = [15 15 3 0 -3 -14.4625]';
muProfileFluct  = 0;
sigmaProfileFluct = 60;

% derive x-reference
id      = max(find(zInitial>zRef)); id = id:id+1;
xRef    = interp1(zInitial(id), xInitial(id), zRef);


id = 0;
for a = 1 : steps(1) % all waterlevels
    muHsig_t = getMu(WL_t(a));
    
    distributionHsig_t = getNormalDistribution(muHsig_t, sigmaHsig_t, steps(2));
    for b = 1 : steps(2) % all wave heights
        Hsig_t = distributionHsig_t(b);
        
        distributionD50 = getNormalDistribution(muD50, sigmaD50, steps(3));
        for c = 1 : steps(3) % all grain sizes
            D50 = distributionD50(c);
            
            distributionProfileFluct = getNormalDistribution(muProfileFluct, sigmaProfileFluct, steps(4));
            for d = 1 : steps(4) % all profile fluctuations
                ProfileFluct = distributionProfileFluct(d);
                DuneErosionSettings('set','ProfileFluct', ProfileFluct);

                [result, Volume, x00min, x0max, x0except] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t);
                
                AF = diff([result(1).xActive(1) xRef]);
                Erosion = -Volume;
                mudeltaErosion = .05*Erosion;
                sigmadeltaErosion = sqrt((.1*Erosion)^2+(.25*.05)^2+(20+.1*Erosion)^2);
                distributionErosion = getNormalDistribution(mudeltaErosion, sigmadeltaErosion, steps(5));
                for e = 1 : steps(5) % all others
                    deltaErosion = distributionErosion(e);
                    
                    TargetVolume = -deltaErosion;
                    x = [result(1).xLand; result(1).xActive; result(1).xSea];
                    z = [result(1).zLand; result(1).z2Active; result(1).zSea];
                    x2 = [WL_t(a)-max(zInitial) 0 x0max-x00min]'; 
                    z2 = [max(zInitial) WL_t(a) WL_t(a)]';
                    result(3) = getDuneErosion_additional(x, z, x2, z2, WL_t(a), x00min, result(1).info.x0, x0except, TargetVolume); %#ok<AGROW>
                    AF = diff([result(end).xActive(1) xRef]);
%                     deltaRetreat = deltaErosion/(max(zInitial)-WL_t(a));
                    probability  = P(a)*prod(1./steps(2:end));
                    
                    id = id+1;
                    results(id,1:7) = [WL_t(a) Hsig_t D50 ProfileFluct Erosion AF probability];
                end
            end
        end
    end
    if a == 1 || a == steps(1)
        endTime = estTime(startTime,a/steps(1));
    end
end
save('NumIntegrationVdGraaff1984.asc','results','-ascii')
results = sortrows(results, 6); % sort based on AF
results(:,end) = flipud(cumsum(flipud(results(:,7)))); % cumulative probability

k = max(find(results(:,end)>1e-5));
NormativeAF = interp1(results(k:k+1,end),results(k:k+1,6),1e-5); % interpolate 1e-5 probability

figure;
% subplot(2,1,1);
semilogx(results(:,end),results(:,end-2),[1e-5 1e-5 1],[0 NormativeAF NormativeAF],'--r')
set(gca,'XDir','reverse','XLim',[1e-6 1e-2],'YLim',[0 max([100 NormativeAF])]);
yticks=get(gca,'YTick');
set(gca,'YTick',sort([yticks NormativeAF]),'YTicklabel',sort([yticks round(NormativeAF)]));
grid on;
xlabel('Probability of exceedance per year');
ylabel('AF [m]','Rotation',270,'VerticalAlignment','top');
% subplot(2,1,2);
% results      = sortrows(results,6);
% results(:,9) = flipud(cumsum(flipud(results(:,8))));
% k                   = max(find(results(:,end)>1e-5));
% NormativeErosion   = interp1(results(k:k+1,end),results(k:k+1,6),1e-5);
% semilogx(results(:,end),results(:,end-3),[1e-5 1e-5 1],[0 NormativeErosion NormativeErosion],'--r')
% set(gca,'XDir','reverse','XLim',[1e-6 1e-2],'YLim',[0 NormativeErosion*1.05]);
% yticks=get(gca,'YTick');
% set(gca,'YTick',sort([yticks NormativeErosion]),'YTicklabel',sort([yticks roundoff(NormativeErosion,-1)]));
% grid on;
% xlabel('Probability of exceedance per year');
% ylabel('Erosion volume [m^3/m^1] above
% SSL','Rotation',270,'VerticalAlignment','top');
