function [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unit,data] = getWaterTemperatureAndMetadata(obj,stationId,beginDate,endDate,unit,timeZone)
%getWaterTemperatureAndMetadata(obj,stationId,beginDate,endDate,unit,timeZone)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       unit = (string)
%       timeZone = (int)
%   
%     Output:
%       stationId = (string)
%       stationName = (string)
%       latitude = (float)
%       longitude = (float)
%       state = (string)
%       dataSource = (string)
%       COOPSDisclaimer = (string)
%       beginDate = (string)
%       endDate = (string)
%       timeZone = (string)
%       unit = (string)
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   unit, ...
   timeZone, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'unit', ...
   'timeZone', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/watertemperature/wsdl', ...
    'getWaterTemperatureAndMetadata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unit,data] = parseSoapResponse(response);
