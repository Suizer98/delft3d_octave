function createcoopsservices
%CREATECOOPSSERVICES  updates createClassFromWsdl for all COOPS to coopstoolbox
%
%See also: createClassFromWsdl, getcoopsdata, http://opendap.co-ops.nos.noaa.gov/axis/

%% remember current dir before moving to coops dir

   dir0 = pwd;
   cd(fileparts(mfilename('fullpath')))

%% Water Level - Preliminary Data 

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelrawsixmin/wsdl/WaterLevelRawSixMin.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelRawOneMin?wsdl'
   createClassFromWsdl(url);

%% Water Level - Verified Data 

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedsixmin/wsdl/WaterLevelVerifiedSixMin.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhourly/wsdl/WaterLevelVerifiedHourly.wsdl';
   createClassFromWsdl(url);
   
   % parsing error 2013-04-10
   %url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhighlow/wsdl/WaterLevelVerifiedHighLow.wsdl'
   %createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifieddaily/wsdl/WaterLevelVerifiedDaily.wsdl';
   createClassFromWsdl(url);

%% Meteorological & Ancillary 

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/airtemperature/wsdl/AirTemperature.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/barometricpressure/wsdl/BarometricPressure.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/conductivity/wsdl/Conductivity.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/rainfall/wsdl/RainFall.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/relativehumidity/wsdl/RelativeHumidity.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/watertemperature/wsdl/WaterTemperature.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/wind/wsdl/Wind.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/visibility/wsdl/Visibility.wsdl';
   createClassFromWsdl(url);

%% Tide Predictions 

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/predictions/wsdl/Predictions.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/highlowtidepred/wsdl/HighLowTidePred.wsdl';
   createClassFromWsdl(url);

%% Currents Data 

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/currents/wsdl/Currents.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/surveycurrents/wsdl/SurveyCurrents.wsdl';
   createClassFromWsdl(url);

%% Stations

  %url='http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveStations?wsdl'; % double, listed ny NOAA, does not work
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/activestations/wsdl/ActiveStations.wsdl'; % double, not listed by NOAA, but does work
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/historicstations/wsdl/HistoricStations.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/datainventory/wsdl/DataInventory.wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveCurrentStations?wsdl';
   createClassFromWsdl(url);
   
   url='http://opendap.co-ops.nos.noaa.gov/axis/services/SurveyCurrentStations?wsdl';
   createClassFromWsdl(url);

%% Harmonic Constituents

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/harmonicconstituents/wsdl/HarmonicConstituents.wsdl';
   createClassFromWsdl(url);

%% Datums

   url='http://opendap.co-ops.nos.noaa.gov/axis/webservices/datums/wsdl/Datums.wsdl';
   createClassFromWsdl(url);

%% Real Time PORTS Conditions

   url='http://opendap.co-ops.nos.noaa.gov/axis/services/portsconditions?wsdl';

%% go back to where we were

   cd(dir0);
%% test log 2013-04-10

% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelRawOneMin?wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedsixmin/wsdl/WaterLevelVerifiedSixMin.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhourly/wsdl/WaterLevelVerifiedHourly.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifieddaily/wsdl/WaterLevelVerifiedDaily.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/airtemperature/wsdl/AirTemperature.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/barometricpressure/wsdl/BarometricPressure.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/conductivity/wsdl/Conductivity.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/rainfall/wsdl/RainFall.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/relativehumidity/wsdl/RelativeHumidity.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/watertemperature/wsdl/WaterTemperature.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/wind/wsdl/Wind.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/visibility/wsdl/Visibility.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/predictions/wsdl/Predictions.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/highlowtidepred/wsdl/HighLowTidePred.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/currents/wsdl/Currents.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/surveycurrents/wsdl/SurveyCurrents.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/activestations/wsdl/ActiveStations.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveStations?wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/historicstations/wsdl/HistoricStations.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/datainventory/wsdl/DataInventory.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveCurrentStations?wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/services/SurveyCurrentStations?wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/harmonicconstituents/wsdl/HarmonicConstituents.wsdl'
% Retrieving document at 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/datums/wsdl/Datums.wsdl'
