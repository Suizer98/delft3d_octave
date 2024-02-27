function obj = CurrentsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/SurveyCurrents';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/surveycurrents/wsdl/SurveyCurrents.wsdl';

obj = class(obj,'CurrentsService');

