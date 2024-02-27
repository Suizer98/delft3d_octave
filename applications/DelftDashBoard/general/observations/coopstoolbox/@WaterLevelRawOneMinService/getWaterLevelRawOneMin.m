function [station_id,station_name,latitude,longitude,state,sensor_id,dcp,data_source,COOPS_disclaimer,beginDate,endDate,datum,unit,timeZone,data] = getWaterLevelRawOneMin(obj,stationId,beginDate,endDate,datum,unit,timeZone)
%getWaterLevelRawOneMin(obj,stationId,beginDate,endDate,datum,unit,timeZone)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       datum = (string)
%       unit = (int)
%       timeZone = (int)
%   
%     Output:
%       station_id = (string)
%       station_name = (string)
%       latitude = (float)
%       longitude = (float)
%       state = (string)
%       sensor_id = (string)
%       dcp = (string)
%       data_source = (string)
%       COOPS_disclaimer = (string)
%       beginDate = (string)
%       endDate = (string)
%       datum = (string)
%       unit = (string)
%       timeZone = (string)
%       data = (item)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   datum, ...
   unit, ...
   timeZone, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'datum', ...
   'unit', ...
   'timeZone', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelrawonemin/wsdl', ...
    'getWaterLevelRawOneMin', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[station_id,station_name,latitude,longitude,state,sensor_id,dcp,data_source,COOPS_disclaimer,beginDate,endDate,datum,unit,timeZone,data] = parseSoapResponse(response);
