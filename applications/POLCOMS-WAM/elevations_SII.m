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

% integrated exceedance water levels over time so time and elevation
% concidered in impact Units ms
% This looks at the impact of all the tides during a study period of
% morphological impact.
E=zeros(length(elev),2); 
E(:,1)=elev(:,1);
E(II,2)=elev(II,2)-level;
Etot=trapz(time,E(:,2))



%Time intertrated exceedance level for each tide exceeding threshold 
% This intergrates the water level exceeding a threshold for each
% individula tide during the study period to see if teh impact was due to a
% single extreme event.

% Eall = the intergrated water level of each tide over time
%elevPPall = HW level each tide

Eall=[];
elevPall=[];
kk=II(1)-1;
if kk==0
    kk=1
    disp('Starts with incomplete tide');
end
for JJ=2:length(II)
    if II(JJ)~=II(JJ-1)+1
        kk2=II(JJ-1)+1;
        Esep=trapz(time(kk:kk2),E(kk:kk2,2));
        elevP=max(elev(kk:kk2,2));
        kk=II(JJ)-1;
        Eall=[Eall;Esep];
        elevPall=[elevPall; elevP];
       
    end
    if JJ==length(II)
        kk2=II(JJ)+1;
        if kk2>length(time)
            kk2=II(JJ)
            disp('Ends with incomplete tide')
        end
        Esep=trapz(time(kk:kk2),E(kk:kk2,2));
        elevP=max(elev(kk:kk2,2));
        Eall=[Eall;Esep]; 
        elevPall=[elevPall; elevP];
    end    
end

if length(II)==1
    kk2=II(1)+1;
    Esep=trapz(time(kk:kk2),E(kk:kk2,2));  
    elevP=max(elev(kk:kk2,2));
    Eall=Esep; 
    elevPall=[elevPall; elevP];
end
%figure
%plot(Eall, '.')
%sum(Eall)


%Find time of peak HW exceeding threshold for plotting
t=zeros(length(elevPall),1);
for ll=1:length(elevPall)
    aa=find(elev(:,2)==elevPall(ll));
    t(ll)=elev(aa,1);
end
tvec=datevec(t);

 
 %Change elevations from mean tidal level back to Chart Datum for end user
 elevPall= elevPall+4.93+0.22;
 
 
figure % For the chosen morphological even plot the storm impact indicator

subplot(2,1,1),plot(elev(:,1),elev(:,2),'k-',[elev(1,1) elev(length(elev),1)], [level level], 'r-', wave(:,1), wave(:,2),'b-',t,elevPall-4.93-0.22,'r.'),datetick('x','dd/mm')
ylabel('Water level CD (m) / Wave Height (m)'), xlabel('Date: DD/MM'), legend('Totoal Water elevation (tide & surge)', 'Water level threshold for storm impact', 'Wave Height', 'High water levels')
subplot(2,1,2),plot(E(:,1),E(:,2),'k-'),datetick('x','dd/mm')
ylabel('The intergrated water level over time exceeding the threshod (ms)'), xlabel('Date: DD/MM')


% Saves the plotted data as an ascii file if the user requires.
dataout=[tvec, Eall];
%eval(['save ' ['threshold' int2str(year) '_' num2str(th(zz)) 'm.txt'] ' dataout' ' -ascii']);



