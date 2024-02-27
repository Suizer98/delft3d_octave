
%% PATCH

fig_input.pat.cvar=2; %plot in cvar: 1=volume fraction kf; 2=mean grain size; 3=Phi; 4=Phi (mm)
fig_input.pat.kf=1; %size fraction

fig_input.pat.time_input=1; 
    %0=all the time steps; 
    %1='time' is a single time or a vector with the time steps to plot. If NaN it plots the last time step; 
    %2='time' is the spacing between 1 and the last results;
fig_input.pat.time=NaN;

fig_input.pat.dispfig=2; %display 1=pause until click; 2=pause 'pausetime'; 3=print .png; 4=print .eps; 5=movie .avi
fig_input.pat.disppos=1; %1=full monitor 1; 2=full monitor 2; 3=full in two monitors
fig_input.pat.pausetime=0.001;
fig_input.pat.FrameRate=10; %frame rate if movie
fig_input.pat.Quality=50; %quality if movie

fig_input.pat.unitx=1; %conversion from m
fig_input.pat.unity=1; %conversion from m
fig_input.pat.unitt=1; %conversion from s
% fig_input.pat.unitt=1/3600/24/365; %conversion from s
% fig_input.pat.unitt=1/3600/24/366/1000; %conversion from s
% fig_input.pat.unitt=1/3600; %conversion from s

kr=1; kc=1;
fig_input.pat.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.pat.lims.y(kr,kc,1:2)=[-10,700];
fig_input.pat.lims.x(kr,kc,1:2)=[0,3e2];
fig_input.pat.lims.c(kr,kc,1:2)=log2([2.1,5.3]);
fig_input.pat.cbar_Ticks=log2([2.3,2.6,3.0,3.5,4.0,4.6,5.3]); %comment to avoid imposing

%% LEVEL
         
fig_input.lev.time_input=1; %0=all the time steps; 1='time' is a single time or a vector with the time steps to plot; 2='time' is the spacing between 1 and the last results;
fig_input.lev.time=NaN;
         
fig_input.lev.dispfig=1; %display 1=pause until click; 2=pause 'pausetime';  
fig_input.lev.disppos=3; %1=full monitor 1; 2=full monitor 2; 3=full in two monitors
fig_input.lev.pausetime=0.1;
     
fig_input.lev.unitx=1; %conversion from m
fig_input.lev.unity=1; %conversion from m
% fig_input.lev.unitt=1/3600/365/24; %conversion from s
fig_input.lev.unitt=1; %conversion from s
     
kr=1; kc=1;
fig_input.lev.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.lev.lims.y(kr,kc,1:2)=[0,10];
fig_input.lev.lims.x(kr,kc,1:2)=[-0.5,0.5];
fig_input.lev.lims.c(kr,kc,1:2)=[0,1];
  
%% X-CNT
         
fig_input.xcn.x=500; %x position to plot [m];
fig_input.xcn.varp=8; %variable to plot: 1=Fak; 2=qb; 3=qbk; 4=pmm; 5=etab; 6=dm (geometric (2^...)); 7=Gammak; 8=dm (arithmetic (Fak*dk))
fig_input.xcn.varp2=2; %subvariable to plot: if fig_input.xtv.varp=1 then nf; 
                                            %if fig_input.xtv.varp=4 then 1=alpha, 2=beta; 3=M_etab; 4=M_Mak
                                            %if fig_input.xtv.varp=7 then nf; 

fig_input.xcn.dispfig=0; %0=nothing; 1=print .png 2=print .eps; 
fig_input.xcn.disppos=1; %1=full monitor 1; 2=full monitor 2; 3=full in two monitors
     
fig_input.xcn.unitx=1; %conversion from m
fig_input.xcn.unity=1; %conversion from m
fig_input.xcn.unitt=1; %conversion from s
fig_input.xcn.unitqb=0.4*2650*1000*60; %conversion from m^2/s

kr=1; kc=1;
fig_input.xcn.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.xcn.lims.x(kr,kc,1:2)=[0,10];
fig_input.xcn.lims.y(kr,kc,1:2)=[0,1];
fig_input.xcn.lims.c(kr,kc,1:2)=[-3,1];

%% X-T-var

fig_input.xtv.varp=5; %variable to plot: 
    %1=Fak;
    %2=qb;
    %3=qbk;
    %4=pmm;
    %5=etab;
    %6=dm (geometric (2^...));
    %7=Gammak;
    %8=dm (arithmetic (Fak*dk))
    %9=Fak+fsk
    %10=h
    %11=approximate eigenvalues
    %12=sum(qbk) (selected fractions)
    %13=sum(Fak) (selected fractions)
    %14=sum(Mak+Gammak) (selected fractions)
    %15=sum(Gammak) (selected fractions)
    %16=sum(Mak+Gammak)/(La+sum(Gammak)) (selected fractions) 
    %17=Mak
    %18=(Mak+Gammak)/(La+sum(Gammak))
    %19=detrended etab (based on the slope of each profile)
fig_input.xtv.varp2=1; %subvariable to plot: if fig_input.xtv.varp=1 then nf; 
                                            %if fig_input.xtv.varp=4 then 1=alpha, 2=beta; 
                                            %if fig_input.xtv.varp=7 then nf; 
                                            
fig_input.xtv.dispfig=3; %0=nothing; 1=print .png; 2=print .eps; 3=pause until click; 4=pause pausetime
fig_input.xtv.pausetime=0.1;
fig_input.xtv.disppos=1; %1=full monitor 1; 2=full monitor 2; 3=full in two monitors

fig_input.xtv.time_input=1; %0=all the time steps; 1='time' is a single time or a vector with the time steps to plot; 2='time' is the spacing between 1 and the last results;
fig_input.xtv.time=12;

fig_input.xtv.XScale='linear';
fig_input.xtv.YScale='linear';

fig_input.xtv.unitx=1; %conversion from m
fig_input.xtv.unitt=1; %conversion from s
% fig_input.xtv.unitt=1/3600/24; %conversion from s
fig_input.xtv.unity=1; %conversion from m^2/s
% fig_input.xtv.unity=0.4*2650*1000*60; %conversion from m^2/s

kr=1; kc=1;
fig_input.xtv.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.xtv.lims.x(kr,kc,1:2)=[0,200];
fig_input.xtv.lims.y(kr,kc,1:2)=[0,2e4];
fig_input.xtv.lims.c(kr,kc,1:2)=[-0.5,0.5]*1e-2;

%% X-CNT (PMM)
         
fig_input.xcn_pmm.x=4.8; %x position to plot [m];

fig_input.xcn_pmm.dispfig=0; %0=nothing; 1=print .png 2=print .eps; 
fig_input.xcn_pmm.disppos=1; %1=full monitor 1; 2=full monitor 2; 3=full in two monitors
     
fig_input.xcn_pmm.unitx=1; %conversion from m
fig_input.xcn_pmm.unity=1; %conversion from m
fig_input.xcn_pmm.unitt=1; %conversion from s

kr=1; kc=1;
fig_input.xcn_pmm.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.xcn_pmm.lims.x(kr,kc,1:2)=[0,10];
fig_input.xcn_pmm.lims.y(kr,kc,1:2)=[0,0.4];
fig_input.xcn_pmm.lims.c(kr,kc,1:2)=[-3,1];

%% %% %% %% %% %% %%
%% ADVANCED INPUT %%
%% %% %% %% %% %% %%

%% TIME LOOP
     
fig_input.tlo.unitx=1; %conversion from m
fig_input.tlo.unity=1; %conversion from m
fig_input.tlo.unitt=1; %conversion from s
     
fig_input.tlo.prnt.filename='loop time';
fig_input.tlo.prnt.size=[0,0,14,9]; %slide=[0,0,25.4,19.05]
    
kr=1; kc=1;
fig_input.tlo.lims.auto=1; %0=imposed values; 1=automatic limits
fig_input.tlo.lims.y(kr,kc,1:2)=[-2e-3,2e-3];
fig_input.tlo.lims.x(kr,kc,1:2)=[0,100];
fig_input.tlo.lims.c(kr,kc,1:2)=[0,1];

fig_input.tlo.time_input=1; %0=all the time steps; 1='time' is a single time or a vector with the time steps to plot; 2='time' is the spacing between 1 and the last results;
fig_input.tlo.time=1;

fig_input.tlo.npr=1; %number of plot rows
fig_input.tlo.npc=1; %number of plot columns

fig_input.tlo.dispfig=1; %display 1=pause until click; 2=pause 'pausetime';  
fig_input.tlo.pausetime=0.01;

fig_input.tlo.marg.mt=1.0; %top margin [cm]
fig_input.tlo.marg.mb=1.5; %bottom margin [cm]
fig_input.tlo.marg.mr=2.5; %right margin [cm]
fig_input.tlo.marg.ml=1.5; %left margin [cm]
fig_input.tlo.marg.sh=1.0; %horizontal spacing [cm]
fig_input.tlo.marg.sv=0.0; %vertical spacing [cm]

fig_input.tlo.prop.lw1=1; %linewidth [pp]
fig_input.tlo.prop.ls1='-'; %linestyle [pp]
fig_input.tlo.prop.fs=12; %font size [pp]

fig_input.tlo.xlabels{kr,kc}='time step [-]';
fig_input.tlo.ylabels{kr,kc}='loop time [s]';
fig_input.tlo.titlestr{kr,kc}='';

%% PATCH (advanced input)

fig_input.pat.prnt.filename='patch';
fig_input.pat.prnt.size=[0,0,25.4,14.29]; %slide (4:3)=[0,0,25.4,19.05]; slide (16:9)=[0,0,25.4,14.29]

fig_input.pat.npr=1; %number of plot rows
fig_input.pat.npc=1; %number of plot columns

fig_input.pat.marg.mt=1.0; %top margin [cm]
fig_input.pat.marg.mb=2.5; %bottom margin [cm]
fig_input.pat.marg.mr=4.5; %right margin [cm]
fig_input.pat.marg.ml=3.0; %left margin [cm]
fig_input.pat.marg.sh=1.0; %horizontal spacing [cm]
fig_input.pat.marg.sv=0.0; %vertical spacing [cm]

% fig_input.pat.prop.edgecolor='k'; %'none' 'k'
fig_input.pat.prop.edgecolor='none'; %'none' 'k'
fig_input.pat.prop.fs=20; %font size [pp]
fig_input.pat.prop.lw_patch=1; %line width of the patched

fig_input.pat.last_layer=0; %remove last layer
if fig_input.pat.last_layer
    warning('last layer is not plotted')
end

fig_input.pat.cbar.sfig=[1,1];
fig_input.pat.cbar.displacement=[0.05,0,0.03,0]; %[delta_x,delta_y,delta_w,delta_h]
fig_input.pat.cbar.location='eastoutside';
% fig_input.pat.cmap=brewermap(100,'RdYlBu');
cmap=brewermap(1000,'YlOrBr');
fig_input.pat.cmap=cmap(200:end,:);

switch fig_input.pat.unitx
    case 1
        fig_input.pat.xlabels{kr,kc}='streamwise position [m]';
    case 1/1000
        fig_input.pat.xlabels{kr,kc}='streamwise position [km]';
end
fig_input.pat.ylabels{kr,kc}='elevation [m]';
%fig_input.pat.titlestr{kr,kc}='time [h]';
switch fig_input.pat.unitt
case 1
	fig_input.pat.titlestr{kr,kc}='s';
case 1/3600
	fig_input.pat.titlestr{kr,kc}='h';
case 1/3600/24
	fig_input.pat.titlestr{kr,kc}='days';
case 1/3600/24/365
	fig_input.pat.titlestr{kr,kc}='years';
case 1/3600/24/366/1000
	fig_input.pat.titlestr{kr,kc}='ka';
end

	
switch fig_input.pat.cvar
case 1
	fig_input.pat.cbar.label=sprintf('volume fraction %d',fig_input.pat.kf);
case {2,4}
	fig_input.pat.cbar.label='mean grain size [mm]';
case 3
	fig_input.pat.cbar.label='\Phi [-]';
end

fig_input.pat.cbar.num_str='%3.1f';

%% LEVEL (advanced input)

fig_input.lev.prnt.filename='level';
fig_input.lev.prnt.size=[0,0,14,9]; %slide=[0,0,25.4,19.05]
    
fig_input.lev.npr=1; %number of plot rows
fig_input.lev.npc=1; %number of plot columns
  
fig_input.lev.marg.mt=1.0; %top margin [cm]
fig_input.lev.marg.mb=1.5; %bottom margin [cm]
fig_input.lev.marg.mr=2.5; %right margin [cm]
fig_input.lev.marg.ml=1.5; %left margin [cm]
fig_input.lev.marg.sh=1.0; %horizontal spacing [cm]
fig_input.lev.marg.sv=0.0; %vertical spacing [cm]

fig_input.lev.prop.lw1=1; %linewidth [pp]
fig_input.lev.prop.ls1='-'; %linestyle [pp]
fig_input.lev.prop.fs=12; %font size [pp]

fig_input.lev.xlabels{kr,kc}='streamwise position [m]';
fig_input.lev.ylabels{kr,kc}='elevation [m]';

switch fig_input.lev.unitt
case 1
	fig_input.lev.titlestr{kr,kc}='time [s]';
case 1/3600
	fig_input.lev.titlestr{kr,kc}='time [h]';
case 1/3600/24
	fig_input.lev.titlestr{kr,kc}='time [days]';
case 1/3600/24/365
	fig_input.lev.titlestr{kr,kc}='time [years]';
end

%% X_CNT (advanced input)

fig_input.xcn.prnt.filename='xcnt';
fig_input.xcn.prnt.size=[0,0,12,10]; %slide=[0,0,25.4,19.05]

fig_input.xcn.npr=1; %number of plot rows
fig_input.xcn.npc=1; %number of plot columns

fig_input.xcn.marg.mt=1.0; %top margin [cm]
fig_input.xcn.marg.mb=1.5; %bottom margin [cm]
fig_input.xcn.marg.mr=0.5; %right margin [cm]
fig_input.xcn.marg.ml=2.0; %left margin [cm]
fig_input.xcn.marg.sh=1.0; %horizontal spacing [cm]
fig_input.xcn.marg.sv=0.0; %vertical spacing [cm]

fig_input.xcn.prop.fs=12; %font size [pp]
fig_input.xcn.prop.lw=1; %line width of the patched

fig_input.xcn.titlestr{kr,kc}=sprintf('x=%4.2f [m]',fig_input.xcn.x);

switch fig_input.xcn.varp
    case 1
        fig_input.xcn.ylabels{kr,kc}=sprintf('volume content of fraction %d at the bed surface [-]',fig_input.xcn.varp2);
    case 2
        switch fig_input.xcn.unitqb
            case 1
                fig_input.xcn.ylabels{kr,kc}='total sediment transport rate [m^2/s]';
            case 0.4*2650*1000*60 
                fig_input.xcn.ylabels{kr,kc}='total sediment transport rate [g/min]';
        end
    case 4
        switch fig_input.xcn.varp2
            case 1
                fig_input.xcn.ylabels{kr,kc}='\alpha [-]';
            case 2
                fig_input.xcn.ylabels{kr,kc}='\beta [-]';
            case 3
                fig_input.xcn.ylabels{kr,kc}='M_{\eta} [-]';
            case 4
                fig_input.xcn.ylabels{kr,kc}='M_{Mak} [-]';
        end
    case 5
        fig_input.xcn.ylabels{kr,kc}='bed elevation [m]';
    case 7
        fig_input.xcn.ylabels{kr,kc}=sprintf('Gamma_%d [m]',fig_input.xtv.varp2);
    case 8
        fig_input.xcn.ylabels{kr,kc}=sprintf('mean grain size [m]');
end

switch fig_input.xcn.unitt
case 1
	fig_input.xcn.xlabels{kr,kc}='time [s]';
case 1/3600
	fig_input.xcn.xlabels{kr,kc}='time [h]';
case 1/3600/24
	fig_input.xcn.xlabels{kr,kc}='time [days]';
case 1/3600/24/365
	fig_input.xcn.xlabels{kr,kc}='time [years]';
end
	
%% X-T-var (advanced input)

fig_input.xtv.prnt.filename='xtvt';
fig_input.xtv.prnt.size=[0,0,12,12]; %slide=[0,0,25.4,19.05]

fig_input.xtv.npr=1; %number of plot rows
fig_input.xtv.npc=1; %number of plot columns

fig_input.xtv.marg.mt=1.0; %top margin [cm]
fig_input.xtv.marg.mb=1.5; %bottom margin [cm]
fig_input.xtv.marg.mr=2.0; %right margin [cm]
fig_input.xtv.marg.ml=1.0; %left margin [cm]
fig_input.xtv.marg.sh=1.0; %horizontal spacing [cm]
fig_input.xtv.marg.sv=0.0; %vertical spacing [cm]

fig_input.xtv.prop.edgecolor='none'; %'none'
fig_input.xtv.prop.fs=12; %font size [pp]
fig_input.xtv.prop.lw=1; %line width of the patched

% fig_input.xtv.titlestr{kr,kc}=sprintf('x=%4.2f [m]',fig_input.xtv.x);

fig_input.xtv.cbar.sfig=[1,1];
fig_input.xtv.cbar.displacement=[0.05,0,0.03,0]; %[delta_x,delta_y,delta_w,delta_h]
fig_input.xtv.cbar.location='eastoutside';
fig_input.xtv.cmap=brewermap(100,'RdYlBu');

switch fig_input.xtv.varp
case 1
	fig_input.xtv.cbar.label=sprintf('volume fraction %d',fig_input.xtv.varp2);
case 2
    fig_input.xtv.cbar.label='q_{b} [m^2/s]';        
% 	fig_input.xtv.cbar.label='mean grain size [mm]';
case 3
    fig_input.xtv.cbar.label=sprintf('q_{b%d} [m^2/s]',fig_input.xtv.varp2);        
case 4
    switch fig_input.xtv.varp2
    case 1
        fig_input.xtv.cbar.label='alpha [-]';
    case 2
        fig_input.xtv.cbar.label='beta [-]';
    end
case 5
    fig_input.xtv.cbar.label='eta [m]';
case 7
    fig_input.xtv.cbar.label=sprintf('Gamma_%d [m]',fig_input.xtv.varp2);
case 10
    fig_input.xtv.cbar.label='flow depth [m]';
case 13
    fig_input.xtv.cbar.label='Fak [-]';
case 19
    fig_input.xtv.cbar.label='detrended bed elevation [m]';
otherwise 
    fig_input.xtv.cbar.label='You should know...';
end

switch fig_input.xtv.unitx
case 1
	fig_input.xtv.xlabels{kr,kc}='streamwise position [m]';
case 1/1000
	fig_input.xtv.xlabels{kr,kc}='streamwise position [km]';
end

switch fig_input.xtv.unitt
case 1
	fig_input.xtv.ylabels{kr,kc}='time [s]';
case 1/3600
	fig_input.xtv.ylabels{kr,kc}='time [h]';
case 1/3600/24
	fig_input.xtv.ylabels{kr,kc}='time [days]';
case 1/3600/24/365
	fig_input.xtv.ylabels{kr,kc}='time [years]';
end

switch fig_input.xtv.unitt
case 1
	fig_input.xtv.titlestr{kr,kc}='time [s]';
case 1/3600
	fig_input.xtv.titlestr{kr,kc}='time [h]';
case 1/3600/24
	fig_input.xtv.titlestr{kr,kc}='time [days]';
case 1/3600/24/365
	fig_input.xtv.titlestr{kr,kc}='time [years]';
end

%% X_CNT (PMM) (advanced input)

fig_input.xcn_pmm.prnt.filename='xcnt';
fig_input.xcn_pmm.prnt.size=[0,0,12,10]; %slide=[0,0,25.4,19.05]

fig_input.xcn_pmm.npr=4; %number of plot rows
fig_input.xcn_pmm.npc=1; %number of plot columns

fig_input.xcn_pmm.marg.mt=0.5; %top margin [cm]
fig_input.xcn_pmm.marg.mb=1.0; %bottom margin [cm]
fig_input.xcn_pmm.marg.mr=0.5; %right margin [cm]
fig_input.xcn_pmm.marg.ml=1.0; %left margin [cm]
fig_input.xcn_pmm.marg.sh=1.0; %horizontal spacing [cm]
fig_input.xcn_pmm.marg.sv=0.5; %vertical spacing [cm]

fig_input.xcn_pmm.prop.fs=12; %font size [pp]
fig_input.xcn_pmm.prop.lw=1; %line width 

fig_input.xcn_pmm.titlestr{1,1}=sprintf('x=%4.2f [m]',fig_input.xcn_pmm.x);

fig_input.xcn_pmm.ylabels{1,1}='\alpha [-]';
fig_input.xcn_pmm.ylabels{2,1}='\beta [-]';
fig_input.xcn_pmm.ylabels{3,1}='M_{\eta} [-]';
fig_input.xcn_pmm.ylabels{4,1}='M_{Mak} [-]';

switch fig_input.xcn_pmm.unitt
case 1
	fig_input.xcn_pmm.xlabels{4,1}='time [s]';
case 1/3600
	fig_input.xcn_pmm.xlabels{4,1}='time [h]';
case 1/3600/24
	fig_input.xcn_pmm.xlabels{4,1}='time [days]';
case 1/3600/24/365
	fig_input.xcn_pmm.xlabels{4,1}='time [years]';
end
