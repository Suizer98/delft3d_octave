function obj = WaterLevelRawOneMinService

obj.endpoint = 'http://localhost:8080/axis/services/WaterLevelRawOneMin';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelRawOneMin?wsdl';

obj = class(obj,'WaterLevelRawOneMinService');

