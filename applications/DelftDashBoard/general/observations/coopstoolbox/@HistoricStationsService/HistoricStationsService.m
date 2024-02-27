function obj = HistoricStationsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/HistoricStations';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/historicstations/wsdl/HistoricStations.wsdl';

obj = class(obj,'HistoricStationsService');

