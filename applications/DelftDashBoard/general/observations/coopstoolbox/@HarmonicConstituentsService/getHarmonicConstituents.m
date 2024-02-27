function data = getHarmonicConstituents(obj,stationId,unit,timeZone)
%getHarmonicConstituents(obj,stationId,unit,timeZone)
%
%     Input:
%       stationId = (string)
%       unit = (int)
%       timeZone = (int)
%   
%     Output:
%       data = (ArrayOfData)

% Build up the argument lists.
values = { ...
   stationId, ...
   unit, ...
   timeZone, ...
   };
names = { ...
   'stationId', ...
   'unit', ...
   'timeZone', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'http://opendap.co-ops.nos.noaa.gov/axis/webservices/harmonicconstituents/wsdl', ...
    'getHarmonicConstituents', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    '', ...
    soapMessage);
data = parseSoapResponse(response);
