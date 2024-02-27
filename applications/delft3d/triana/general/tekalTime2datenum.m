function t=tekalTime2datenum(dates,times)

% TEKALTIME2DATENUM - Converts tekal times (yyyymmdd hhmmss) to datenum
% 
% Usage: 
%     t=tekalTime2datenum(dates,times)
%     
% in which:
% 
%     dates = array of date integers [yyyymmdd]     
%     times = array of time integers [hhmmss] 
%     t     = time in Matlab datenum
%     
% R. Morelissen, 2007

if nargin~=2
    error('tekalTime2Datenum needs 2 input arguments');
    return
end

datesStr=sprintf('%8.8i',dates);
datesStr=reshape(datesStr,8,numel(datesStr)/8)';
timesStr=sprintf('%6.6i',times);
timesStr=reshape(timesStr,6,numel(timesStr)/6)';

y=[datesStr(:,1:4) repmat(char(13),size(datesStr,1),1)]';
y=y(:)';
y=sscanf(y,'%d');
m=[datesStr(:,5:6) repmat(char(13),size(datesStr,1),1)]';
m=m(:)';
m=sscanf(m,'%d');
d=[datesStr(:,7:8) repmat(char(13),size(datesStr,1),1)]';
d=d(:)';
d=sscanf(d,'%d');

H=[timesStr(:,1:2) repmat(char(13),size(datesStr,1),1)]';
H=H(:)';
H=sscanf(H,'%d');
M=[timesStr(:,3:4) repmat(char(13),size(datesStr,1),1)]';
M=M(:)';
M=sscanf(M,'%d');
S=[timesStr(:,5:6) repmat(char(13),size(datesStr,1),1)]';
S=S(:)';
S=sscanf(S,'%d');


t=datenum(y,m,d,H,M,S);


