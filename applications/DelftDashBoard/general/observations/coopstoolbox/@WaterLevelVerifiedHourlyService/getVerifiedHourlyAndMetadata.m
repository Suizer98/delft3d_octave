function [stationId,stationName,latitude,longitude,state,dataSource,beginDate,endDate,datum,unit,timeZone,data] = getVerifiedHourlyAndMetadata(obj,stationId,beginDate,endDate,datum,unit,timeZone)
%getVerifiedHourlyAndMetadata(obj,stationId,beginDate,endDate,datum,unit,timeZone)
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
%       stationId = (string)
%       stationName = (string)
%       latitude = (float)
%       longitude = (float)
%       state = (string)
%       dataSource = (string)
%       beginDate = (string)
%       endDate = (string)
%       datum = (string)
%       unit = (string)
%       timeZone = (string)
%       data = (ArrayOfData)

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
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhourly/wsdl', ...
    'getVerifiedHourlyAndMetadata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[stationId,stationName,latitude,longitude,state,dataSource,beginDate,endDate,datum,unit,timeZone,data] = parseSoapResponse(response);