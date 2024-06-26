function [stationId,stationName,latitude,longitude,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unit,sensorOrientation,binNumber,binDistance,data] = getCurrentsAndMetadata(obj,stationId,beginDate,endDate,binNumber)
%getCurrentsAndMetadata(obj,stationId,beginDate,endDate,binNumber)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       binNumber = (string)
%   
%     Output:
%       stationId = (string)
%       stationName = (string)
%       latitude = (float)
%       longitude = (float)
%       dataSource = (string)
%       COOPSDisclaimer = (string)
%       beginDate = (string)
%       endDate = (string)
%       timeZone = (string)
%       unit = (string)
%       sensorOrientation = (string)
%       binNumber = (string)
%       binDistance = (float)
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   binNumber, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'binNumber', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/surveycurrents/wsdl', ...
    'getCurrentsAndMetadata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[stationId,stationName,latitude,longitude,dataSource,COOPSDisclaimer,beginDate,endDate,timeZone,unit,sensorOrientation,binNumber,binDistance,data] = parseSoapResponse(response);
