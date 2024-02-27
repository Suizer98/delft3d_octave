function getStatisticalGridResult = getStatisticalGrid(obj,tblCodeID_Dataset,tblCodeID_Param,tblCodeID_Matrx,intYear,tblCodeID_Taxa,tblCodeID_Area)
%getStatisticalGrid(obj,tblCodeID_Dataset,tblCodeID_Param,tblCodeID_Matrx,intYear,tblCodeID_Taxa,tblCodeID_Area)
%
%   Get the grid per ICES statistical rectangles
%   
%     Input:
%       tblCodeID_Dataset = (string)
%       tblCodeID_Param = (string)
%       tblCodeID_Matrx = (string)
%       intYear = (string)
%       tblCodeID_Taxa = (string)
%       tblCodeID_Area = (string)
%   
%     Output:
%       getStatisticalGridResult = (ArrayOfICESStatisticalRectanglesGrid)

% Build up the argument lists.
values = { ...
   tblCodeID_Dataset, ...
   tblCodeID_Param, ...
   tblCodeID_Matrx, ...
   intYear, ...
   tblCodeID_Taxa, ...
   tblCodeID_Area, ...
   };
names = { ...
   'tblCodeID_Dataset', ...
   'tblCodeID_Param', ...
   'tblCodeID_Matrx', ...
   'intYear', ...
   'tblCodeID_Taxa', ...
   'tblCodeID_Area', ...
   };
types = { ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   '{http://www.w3.org/2001/XMLSchema}string', ...
   };

% Create the message, make the call, and convert the response into a variable.
soapMessage = createSoapMessage( ...
    'iistest01.ices.local/EcoSystemData', ...
    'getStatisticalGrid', ...
    values,names,types,'document');
response = callSoapService( ...
    obj.endpoint, ...
    'iistest01.ices.local/EcoSystemData/getStatisticalGrid', ...
    soapMessage);
getStatisticalGridResult = parseSoapResponse(response);
