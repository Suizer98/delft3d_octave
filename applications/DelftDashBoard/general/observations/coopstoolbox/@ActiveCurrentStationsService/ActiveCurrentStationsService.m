function obj = ActiveCurrentStationsService

obj.endpoint = 'http://localhost:8080/axis/services/ActiveCurrentStations';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveCurrentStations?wsdl';

obj = class(obj,'ActiveCurrentStationsService');

