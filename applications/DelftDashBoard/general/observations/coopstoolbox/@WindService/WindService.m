function obj = WindService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/Wind';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/wind/wsdl/Wind.wsdl';

obj = class(obj,'WindService');

