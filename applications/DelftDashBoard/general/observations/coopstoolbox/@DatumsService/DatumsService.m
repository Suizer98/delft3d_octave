function obj = DatumsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/Datums';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/datums/wsdl/Datums.wsdl';

obj = class(obj,'DatumsService');

