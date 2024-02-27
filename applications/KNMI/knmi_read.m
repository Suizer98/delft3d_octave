function dataOut=knmi_read(fileIn)
%KNMI_READ   Reads data in interactive KNMI ASCII climate series to
%struct. 
%
%Syntax:
% dataOut = knmi_read(fileIn)
%
%Input:
% fileIn    = [string] path to file downloaded from
%             http://www.knmi.nl/klimatologie/uurgegevens/selectie.cgi
%
%Output:
% dataOut   = [struct] struct containing data in file; 
%
% See also: KNMI_POTWIND, KNMI_ETMGEG2NC, KNMI_ETMGEG_GET_URL, KNMI_ETMGEG_STATIONS

%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%       Arcadis Zwolle, The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%% PREPROCESSING

%check existence
if ~exist(fileIn,'file')
    error(sprintf('Cannot find %s.',fileIn)); 
else
    %open file
    fid=fopen(fileIn); 
end

%initiate output
dataOut=[]; 
stn=[]; 

%% STATION DATA

%Skip to location station data
line=fgetl(fid); 
while line~=-1
entry=regexp(line,{'STN','LON','LAT','ALT','NAME'});
iempty=cellfun('isempty',entry); 
if isempty(entry) | sum(iempty)>0
    %location data block not found. Take new line.
    line=fgetl(fid);
else
    %location data block found. Break searching. 
    line=fgetl(fid); 
    break; 
end
end %end while
if line==-1
    error('Cannont find station data in file.'); 
end

%read station data
while line~=-1
    entry=regexpi(line,'(\d+):\s*([0-9_.]*)\s*([0-9_.]*)\s*([0-9_.]*)\s*(\w+)','tokens');
    if isempty(entry) | cellfun('isempty',entry{1})>0
        %end of station data
        break; 
    end
    
    %convert strings 
    entry=strtrim(entry{1}); 
    entryNum=str2double(entry(1:end-1));
    
    %convert WGS84 to RD
    [xRD yRD]=convertCoordinates(entryNum(2),entryNum(3),'CS1.code',4326,'CS2.code',28992); 
    
    %write station data to 1 struct
    dataOut1=struct('stn',entryNum(1),'name',entry(end),'lon',entryNum(2),'lat',entryNum(3),...
        'x',xRD,'y',yRD,'z',entryNum(4)); 
    dataOut=[dataOut,dataOut1]; 
    stn=[stn,entryNum(1)]; 
    
    %new line
    line=fgetl(fid); 
end

%% READ MEASURED DATA

%find header line with quantities
while line~=-1
   entry=regexpi(line,{'STN','YYYYMMDD','HH'}); 
   if sum(cellfun('isempty',entry))>0
      line=fgetl(fid); 
   else
       break; 
   end
end

%read header quantities
line=line(line~='#'); 
entry=regexp(line,',','split');
entry=strtrim(entry);
if length(entry)<4
    error('No data in file'); 
else
    %skip stn, yyyymmdd, hhh
    entry=entry(4:end); 
    Parameters=entry; 
    nParameters=length(entry); 
end
for k=1:length(Parameters)
    data(1).(Parameters{k})=[]; 
end
line=fgetl(fid); 

%skip all other header lines
while line~=-1 & line(1)=='#'
    line=fgetl(fid); 
end
if line==-1
    error('No data in file.'); 
end

%read data
data=[]; 
format=repmat('%f, ',[1 nParameters-1]); 
while line~=-1
    entry=regexpi(line,',','split'); 
    entry=strtrim(entry); 
    entry=str2double(entry); 
    data=[data; entry]; 
    line=fgetl(fid); 
end


%write data to struct per station
for k=1:length(stn)
    %select all entries for station
    istn=find(stn(k)==data(:,1)); 
    data1=data(istn,2:end); 
    
    %calculate datenum
    year=floor(data1(:,1)*1e-4); 
    month=floor( (data1(:,1)*1e-4-year)*1e2 ); 
    day=floor( (data1(:,1)*1e-4-year-month*1e-2)*1e4); 
    hour=data1(:,2)-1; 
    dataOut(k).datenum=datenum( [year,month,day,hour,zeros(length(year),2)]); 
    
    %write data to station
    for l=1:nParameters
        dataOut(k).(Parameters{l})=data1(:,l+2);         
    end
    clear data1;
    
end


%% POSTPROCESSING

%close file
fclose(fid); 


