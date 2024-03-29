function [stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,unit,data] = getVisibilityAndMetadata(obj,stationId,beginDate,endDate)
%getVisibilityAndMetadata(obj,stationId,beginDate,endDate)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
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
%       unit = (string)
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/visibility/wsdl', ...
    'getVisibilityAndMetadata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
[stationId,stationName,latitude,longitude,state,dataSource,COOPSDisclaimer,beginDate,endDate,unit,data] = parseSoapResponse(response);
