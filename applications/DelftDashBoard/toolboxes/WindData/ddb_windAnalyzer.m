function [hS,hD]=ddb_windAnalyzer(windData,h);

% function=ddb_windAnalyzer(windData,period);
%
% Creates a statistical box plot of wind data (from getOnlineWindData)
% Required: matlab statistic toolbox
%
% Input arguments:
%       - windData: [Nx3] array, with datenums, wind speed and direction
%       - period  : Specification of the variation to analyze, 'Daily' or 'Yearly'
% A.C.S. Mol, September 2005

if nargin==0
    [nam,pat]=uigetfile('*.mat','Please select mat-file with wind data');
    windData=load([pat nam]);
    strucNames=fieldnames(windData);
    for ii=1:length(strucNames)
        eval([strucNames{ii} '=windData.' strucNames{ii} ';']);
    end

end

if nargin<2
    h=[];
end

windSpeed=[];
windDir=[];

if isempty(h)
    h=questdlg('Analyze daily or yearly wind cycle?','Wind Analyzer','Daily','Yearly','Daily');
end

if strcmp(h,'Daily')==1
    for ii=1:24
        windSpeed{ii}=windData(find(str2num(datestr(windData(:,1),'HH'))==(ii-1)),2);
        windDir{ii}=windData(find(str2num(datestr(windData(:,1),'HH'))==(ii-1)),3);
        size(ii)=length(windSpeed{ii});
    end

else
    for ii=1:12
        windSpeed{ii}=windData(find(str2num(datestr(windData(:,1),'mm'))==ii),2);
        windDir{ii}=windData(find(str2num(datestr(windData(:,1),'mm'))==ii),3);
        size(ii)=length(windSpeed{ii});
    end
end

Speed=repmat(nan,max(size),length(windDir));
Dir=repmat(nan,max(size),length(windDir));

for jj=1:length(windDir)
    Speed(1:length(windSpeed{jj}),jj)=windSpeed{jj};
    Dir(1:length(windDir{jj}),jj)=windDir{jj};
end

subplot(2,1,1)
[q1,q2,q3]=freeBoxPlot(Speed);
hS=[q1; q2; q3];
if strcmp(h,'Daily')==1
    set(gca,'XTick',[1:24],'XTickLabel',num2str([0:23]'));
    xlabel('time (hours)');
else
    xlabel('time (months)');
end
ylabel('wind speed [m/s]');

subplot(2,1,2)
[q1,q2,q3]=freeBoxPlot(Dir,1,1,1);
hD=[q1; q2; q3];
if strcmp(h,'Daily')==1
    set(gca,'XTick',[1:24],'XTickLabel',num2str([0:23]'));
    xlabel('time (hours)');
else
    xlabel('time (months)');
end
ylim([0 360]);
ylabel('wind direction [degr. N]');
set(gca,'ytick',[0:60:360]);

% md_paper('a4p','wl',{strvcat(['Analysis of wind data (' char(h) ' basis)'],['Period data: ' datestr(windData(1,1),1) ' - ' datestr(windData(end,1),1)],['Source: www.wunderground.com, stationID:']),'','','','',''})
