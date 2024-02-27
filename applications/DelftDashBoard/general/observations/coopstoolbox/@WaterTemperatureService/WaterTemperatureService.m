function obj = WaterTemperatureService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterTemperature';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/watertemperature/wsdl/WaterTemperature.wsdl';

obj = class(obj,'WaterTemperatureService');

