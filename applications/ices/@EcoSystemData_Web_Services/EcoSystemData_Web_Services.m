function obj = EcoSystemData_Web_Services

obj.endpoint = 'http://ecosystemdata.ices.dk/webservices/EcoSystemWebServices.asmx';
obj.wsdl = 'http://ecosystemdata.ices.dk/webservices/EcoSystemWebServices.asmx?WSDL';

obj = class(obj,'EcoSystemData_Web_Services');

