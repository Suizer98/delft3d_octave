% clear all;close all;clc
%%  GET MULTIPLE FILES IN MAIN DIRECTORY
%% Get Options
OPT = setOptions();

%% get the directories where raw data can be found.
% Search for all raw files in main directory (incl. subdirectory)
rawfiledirs = getFileDir('dir',OPT.dir);
k = 1;
for i = 1:length(rawfiledirs)
    %% Get the raw data
    [raw_data{i}, xls_data{i}] = ShearStress('fdir',rawfiledirs{i});
    fields  = fieldnames(raw_data{i});
    homedir = fileparts(rawfiledirs{i});
    for j = 1:length(fields);
        [homedir2, testname{k}] = fileparts(homedir);
        oslimread{k} = raw_data{i}.(fields{j})(:,1);
        [error{k}, means{k}, means2{k}, error2{k}, timeline{k}] = rate_stress('oslimread',oslimread{k},'fdir',rawfiledirs{i});
        k = k+1;
    end
end

%plot oslim data
figure;
colorm = jet(size(oslimread,2));
for i = 1:size(oslimread,2)jet
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    plot(timeline{i},oslimread{i}/OPT.slope_calibration,'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:));
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('experiment time [seconds]')
ylabel('oslim [g/L]')


% plot errorbar
figure;
for i = 1:size(oslimread,2)
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    errorbar(OPT.shear,means{i},error{i},'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:))%'Linestyle',':','Color','m');
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('Shear stress [Pa]')
ylabel('Erosionrate [g/(m2*(dt*s))]')

% plot errorbar error rate per second
figure;
for i = 1:size(oslimread,2)
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    errorbar(OPT.shear,means2{i},error2{i},'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:))%'Linestyle',':','Color','m');
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('Shear stress [Pa]')
ylabel('Erosionrate [g/(m2*s)]')

%%  GET SINGLE FILES
clear all;clc
OPT = setOptions();

% get raw data from 24hrp, filename = 24hrp004.raw
i = 1;
rawfiledirs{i} = 'D:\Projects\ShortQuestions\Chatham\Tests\24 hour motor test\24hrp\24hrp';
[raw_data{i}, xls_data{i}] = ShearStress('fdir',rawfiledirs{i},'ffilter','24hrp004');

i = 2;
rawfiledirs{i} = 'd:\Projects\ShortQuestions\Chatham\Tests\Test 24 hours - second\09903\';
[raw_data{i}, xls_data{i}] = ShearStress('fdir',rawfiledirs{i},'ffilter','raw');

k = 1;
for i = 1:length(rawfiledirs)
    %% Get the raw data
    fields  = fieldnames(raw_data{i});
    homedir = fileparts(rawfiledirs{i});
    for j = 1:length(fields);
        [homedir2, testname{k}] = fileparts(homedir);
        oslimread{k} = raw_data{i}.(fields{j})(:,1);
        [error{k}, means{k}, means2{k}, error2{k}, timeline{k}] = rate_stress('oslimread',oslimread{k},'fdir',rawfiledirs{i});
        k = k+1;
    end
end

%% at this point the following information is in memory
% testname cell with all the test names
% oslimread cell with all the oslim data
% error cell with the std for every interval within a test
% means cell with the mean for every interval within a test
% timeline cell with the x-axis = [1:dt:length(oslimread)]

% plot oslim data
figure;
colorm = jet(9);                        
colorm = [colorm(1,:);colorm(6,:)];
for i = 1:size(oslimread,2)
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    plot(timeline{i},oslimread{i}/OPT.slope_calibration,'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:));
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('experiment time [seconds]')
ylabel('oslim [g/L]')


% plot errorbar
figure;
for i = 1:size(oslimread,2)
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    errorbar(OPT.shear,means{i},error{i},'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:))%'Linestyle',':','Color','m');
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('Shear stress [Pa]')
ylabel('Erosionrate [g/(m2*(dt*s))]')

figure;
% plot errorbar error rate in seconds
for i = 1:size(oslimread,2)
    if mod(i,2) == 0
        ls = '--';
    else
        ls = '-';
    end
    errorbar(OPT.shear,means2{i},error2{i},'LineWidth',2,'Linestyle',ls,'Color',colorm(i,:))%'Linestyle',':','Color','m');
    hold on;
end
legend(testname,'Location','NorthWest')
xlabel('Shear stress [Pa]')
ylabel('Erosionrate [g/(m2*s)]')