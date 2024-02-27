function selectOBISdataResult = selectOBISdata(obj,scientificName,year,dateTime)
%selectOBISdata(obj,scientificName,year,dateTime)
%
%   Select OBIS Schema Species information
%   
%     Input:
%       scientificName = (string)
%       year = (string)
%       dateTime = (string)
%   
%     Output:
%       selectOBISdataResult = (ArrayOfOBISrecord)

% Build up the argument lists.
values = { ...
   scientificName, ...
   year, ...
   dateTime, ...
   };
names = { ...
   'scientificName', ...
   'year', ...
   'dateTime', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'iistest01.ices.local/EcoSystemData', ...
    'selectOBISdata', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    'iistest01.ices.local/EcoSystemData/selectOBISdata', ...
    soapMessage);
selectOBISdataResult = parseSoapResponse(response);