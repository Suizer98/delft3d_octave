function [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,datum,unit,timeZone,dataInterval,data] = getPredictionsAndMetadata(obj,stationId,beginDate,endDate,datum,unit,timeZone,dataInterval)
%getPredictionsAndMetadata(obj,stationId,beginDate,endDate,datum,unit,timeZone,dataInterval)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       datum = (string)
%       unit = (int)
%       timeZone = (int)
%       dataInterval = (int)
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
%       datum = (string)
%       unit = (string)
%       timeZone = (string)
%       dataInterval = (string)
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   datum, ...
   unit, ...
   timeZone, ...
   dataInterval, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'datum', ...
   'unit', ...
   'timeZone', ...
   'dataInterval', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/predictions/wsdl', ...
    'getPredictionsAndMetadata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,datum,unit,timeZone,dataInterval,data] = parseSoapResponse(response);
