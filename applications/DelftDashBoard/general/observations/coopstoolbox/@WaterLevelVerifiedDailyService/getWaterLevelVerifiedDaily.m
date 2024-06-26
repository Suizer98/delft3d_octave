function data = getWaterLevelVerifiedDaily(obj,stationId,beginDate,endDate,datum,unit)
%getWaterLevelVerifiedDaily(obj,stationId,beginDate,endDate,datum,unit)
%
%     Input:
%       stationId = (string)
%       beginDate = (string)
%       endDate = (string)
%       datum = (string)
%       unit = (int)
%   
%     Output:
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   beginDate, ...
   endDate, ...
   datum, ...
   unit, ...
   };
names = { ...
   'stationId', ...
   'beginDate', ...
   'endDate', ...
   'datum', ...
   'unit', ...
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
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifieddaily/wsdl', ...
    'getWaterLevelVerifiedDaily', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
data = parseSoapResponse(response);
