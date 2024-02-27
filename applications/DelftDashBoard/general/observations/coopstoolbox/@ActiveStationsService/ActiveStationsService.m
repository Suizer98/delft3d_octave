function obj = ActiveStationsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/ActiveStations';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/activestations/wsdl/ActiveStations.wsdl';

obj = class(obj,'ActiveStationsService');

