function obj = RelativeHumidityService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/RelativeHumidity';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/relativehumidity/wsdl/RelativeHumidity.wsdl';

obj = class(obj,'RelativeHumidityService');

