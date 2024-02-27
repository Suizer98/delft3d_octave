% loads the 30min total elevation & hourly Hm0/Tm02 calculates the intergrated wave
% energy and power when the water level exceeds a given threshold.
%The threshold is chosen to be a level that the dune toe becomes soaked by
%high tides and is under the influence of any wave activity.

clear

year = 1997; %yyyy or yyyymm this is the date of an extreme morphological event along the sefton coast

% The two water level threshold levels from literature that define dune
% impact under extreme events.
level=9.4; %Pye & Blott (2008) level for critical level for dune toe under cutting CD
%level=9.0; %Pye & Blott (2008) >8.83m CD level for which dune toe can be erroded 


level = level-4.93-0.22; % convert the threshold level from chart datumn to mean tidal level




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Load the time series data for water level and wave heights %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(['load ' ['elev' int2str(year) '.txt'] ';']); %this load the total water elevation (m) with reference level set to mean tidal level
eval(['load ' [int2str(year) '_wavenet.txt'] ';']); % this loads the wave parameters Significant wave height (m) and mwan wave period (s)
elev= eval(['elev' int2str(year)]);
wave1= eval(['X' int2str(year) '_wavenet']);

time=[0:length(elev)-1]./2*3600;% the time (s) of eah point in the loaded time series data.

%creat an empty array to put the data in 
wave=zeros(length(elev),3);
%fill the array with the 30minute water levels
wave(:,1)=elev(:,1);
%fill the array with hourly wave data interpolated to 30minute intervals.
wave(:,2:3)= interp1(wave1(:,1),wave1(:,2:3),elev(:,1));

%%%%%%%%% END OF DATA READ %%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%% IN THE DATA FIND THE PERIODS WHEN THE WATER EXCEEDS THE CHOSEN THRESHOLD%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Find periods when the total water level exceeds the threshold
II=find(elev(:,2)>=level);

% integrate the wave energy and wave power over time when the total water level exceeds
% the threshold for storm impact.  Intergrated SII Units Wave Energy, Js/m^2, Wave Power,Kws/m.
% This looks at the impact of all the tides during a study period of morphological impact.

% Offshore wave energy at the study location
E=zeros(length(elev),2); 
E(:,1)=elev(:,1);
E(II,2)=1027./16.*9.81.*wave(II,2).^2;
Etot=trapz(time,E(:,2))

% Offshore wave power at WaveNet
P=zeros(length(elev),2); 
P(:,1)=elev(:,1);
P(II,2)=1027./64./pi.*wave(II,3).*(9.81^2).*(wave(II,2).^2);
Ptot=trapz(time,P(:,2))

%Time intertrated energy (Eall) & power (Pall) for each tide exceeding threshold & duration threshold exceeded
% peak elevation, Hm0 & Tm02 values 
Eall=[];
Pall=[];
durall=[];
elevPall=[];
Hm0Pall=[];
Tm02Pall=[];
kk=II(1)-1;
if kk==0
    kk=1
    disp('Starts with incomplete tide');
end
for JJ=2:length(II)
    if II(JJ)~=II(JJ-1)+1
        kk2=II(JJ-1)+1;
        Esep=trapz(time(kk:kk2),E(kk:kk2,2));
        Psep=trapz(time(kk:kk2),P(kk:kk2,2));
        dur=time(kk2)-time(kk);
        elevP=max(elev(kk:kk2,2));
        Hm0P=max(wave(kk:kk2,2));
        Tm02P=max(wave(kk:kk2,3));
        kk=II(JJ)-1;
        Eall=[Eall;Esep];
        durall=[durall;dur];
        Pall=[Pall;Psep];
        elevPall=[elevPall; elevP];
        Hm0Pall=[Hm0Pall; Hm0P];
        Tm02Pall=[Tm02Pall; Tm02P];
    end
    if JJ==length(II)
        kk2=II(JJ)+1;
        if kk2>length(time)
            kk2=II(JJ)
            disp('Ends with incomplete tide')
        end
        Esep=trapz(time(kk:kk2),E(kk:kk2,2));
        Psep=trapz(time(kk:kk2),P(kk:kk2,2));
        dur=time(kk2)-time(kk);
        elevP=max(elev(kk:kk2,2));
        Hm0P=max(wave(kk:kk2,2));
        Tm02P=max(wave(kk:kk2,3));
        Eall=[Eall;Esep];
        durall=[durall;dur];
        Pall=[Pall;Psep];
        elevPall=[elevPall; elevP];
        Hm0Pall=[Hm0Pall; Hm0P];
        Tm02Pall=[Tm02Pall; Tm02P];
    end    
end

if length(II)==1
    kk2=II(1)+1;
    Esep=trapz(time(kk:kk2),E(kk:kk2,2));
    Psep=trapz(time(kk:kk2),P(kk:kk2,2));
    dur=time(kk2)-time(kk);
    elevP=max(elev(kk:kk2,2));
    Hm0P=max(wave(kk:kk2,2));
    Tm02P=max(wave(kk:kk2,3));
    Eall=Esep;
    durall=dur;
    Pall=Psep;
    elevPall=elevP;
    Hm0Pall=Hm0P;
    Tm02Pall=Tm02P;
end
%figure
%plot(Eall, '.')
%sum(Eall)
%figure
%plot(Pall, '.')
%sum(Pall)

%Find time of peak HW exceeding threshold for plotting
t=zeros(length(elevPall),1);
for ll=1:length(elevPall)
    aa=find(elev(:,2)==elevPall(ll));
    t(ll)=elev(aa,1);
end
tvec=datevec(t);


%Change duration above thershold of each tide from seconds to hrs
 durall=durall./3600;
 
 %Change elevations from Mean tidal level to Chart Datumn for end user
 elevPall= elevPall+4.93+0.22;
 
 
figure % For the chosen morphological even plot the storm impact indicator
subplot(3,1,1),plot(elev(:,1),elev(:,2),'k-',[elev(1,1) elev(length(elev),1)], [level level], 'r-', wave(:,1), wave(:,2),'b-',t,elevPall-4.93-0.22,'r.'),datetick('x','dd/mm')
ylabel('Water level CD (m) / Wave Height (m)'), xlabel('Date: DD/MM'), legend('Totoal Water elevation (tide & surge)', 'Water level threshold for storm impact', 'Wave Height', 'High water levels')
subplot(3,1,2),plot(E(:,1),E(:,2),'k-'),datetick('x','dd/mm')
ylabel('The intergrated wave energy over time, when water levels exceed the threshod (Js/m^2)'), xlabel('Date: DD/MM')
subplot(3,1,3),plot(P(:,1),P(:,2),'k-'),datetick('x','dd/mm')
ylabel('The intergrated wave power over time, when water levels exceed the threshod (Kws/m)'), xlabel('Date: DD/MM')

% Saves the plotted data as an ascii file if the user requires.
dataout=[tvec, durall, Eall, Pall, elevPall, Hm0Pall, Tm02Pall];
%eval(['save ' ['threshold' int2str(year) '_' num2str(th(zz)) 'm.txt'] ' dataout' ' -ascii']);

