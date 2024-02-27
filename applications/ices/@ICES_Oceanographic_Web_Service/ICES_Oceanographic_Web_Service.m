function obj = ICES_Oceanographic_Web_Service

obj.endpoint = 'http://ocean.ices.dk/webservices/hydchem.asmx';
obj.wsdl = 'http://ocean.ices.dk/webservices/hydchem.asmx?WSDL';

obj = class(obj,'ICES_Oceanographic_Web_Service');

