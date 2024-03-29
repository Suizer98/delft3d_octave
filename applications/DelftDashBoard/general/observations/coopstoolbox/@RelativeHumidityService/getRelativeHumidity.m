function data = getRelativeHumidity(obj,stationId,beginDate,endDate,timeZone)
%getRelativeHumidity(obj,stationId,beginDate,endDate,timeZone)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       timeZone = (int)
%   
%     Output:
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   timeZone, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'timeZone', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/relativehumidity/wsdl', ...
    'getRelativeHumidity', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
data = parseSoapResponse(response);
