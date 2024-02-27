function obj = SurveyCurrentStationsService

obj.endpoint = 'http://localhost:8080/axis/services/SurveyCurrentStations';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/services/SurveyCurrentStations?wsdl';

obj = class(obj,'SurveyCurrentStationsService');

