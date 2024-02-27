
%% 

clear
clc

%% INPUT

x=0:10:1000;
etab=[11:-0.01:10.51,0.5:-0.01:0];  

%% PLOT

figure
hold on
plot(x,etab);

%% CALC

np=numel(etab);
for kp=1:np
    csd(kp).id=sprintf('cs_%04d',kp);
    csd(kp).type='zwRiver';
    csd(kp).thalweg=0;               
    csd(kp).numLevels=2;                   
    csd(kp).levels=[etab(kp),100];
    csd(kp).flowWidths=[10000,10001];
    csd(kp).totalWidths=[10000,10001];
    csd(kp).leveeCrestLevel       = 0.000;
    csd(kp).leveeFlowArea         = 0.000;               
    csd(kp).leveeTotalArea        = 0.000 ;              
    csd(kp).leveeBaseLevel        = 0.000  ;             
    csd(kp).mainWidth             = 10001.000           ;
    csd(kp).fp1Width              = 0.000               ;
    csd(kp).fp2Width              = 0.000 ;
    
    csl(kp).id                    =sprintf('cs_loc_%04d',kp);
    csl(kp).branchId              ='Channel1';
    csl(kp).chainage              = x(kp)  ;          
    csl(kp).shift                 = 0.000      ;         
    csl(kp).definitionId          =sprintf('cs_%04d',kp);
end

%% WRITE

simdef.D3D.dire_sim=pwd;
simdef.csd=csd;
simdef.csl=csl;

D3D_crosssectiondefinitions(simdef)
D3D_crosssectionlocation(simdef)