function getListDatatypesResult = getListDatatypes(obj)
%getListDatatypes(obj)
%
%   Get the list of datatypes available in the database
%   
%     Input:
%   
%     Output:
%       getListDatatypesResult = (ArrayOfDatatypeList)

% Build up the argument lists.
values = { ...
   };
names = { ...
   };
types = { ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'iistest01.ices.local/EcoSystemData', ...
    'getListDatatypes', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    'iistest01.ices.local/EcoSystemData/getListDatatypes', ...
    soapMessage);
getListDatatypesResult = parseSoapResponse(response);