function varargout = GetICEData(obj,ParameterCode,FromYear,ToYear,FromMonth,ToMonth,FromLongitude,ToLongitude,FromLatitude,ToLatitude,FromPressure,ToPressure,varargin)
%GetICEData Get ICES Bottle and low resolution CTD data
%
%   D = GetICEData(obj,ParameterCode,FromYear,ToYear,FromMonth,ToMonth,...
%                  FromLongitude,ToLongitude,FromLatitude,ToLatitude,FromPressure,ToPressure)
%
%   Get Bottle and low resolution CTD data
%   
%     Input:
%       ParameterCode = (ParameterCodeEnum)
%            TEMP = Temperature [deg C]
%            PSAL = Salinity [psu]
%            DOXY = Oxygen [O2, ml/l]
%            PHOS = Phosphate Phosphorus [PO4-P, umol/l]
%            TPHS = Total Phosphorus [P, umol/l]
%            AMON = Ammonium [NH4-N, umol/l]
%            NTRI = Nitrite Nitrogen [NO2-N, umol/l]
%            NTRA = Nitrate Nitrogen [NO3-N, umol/l]
%            NTOT = Total Nitrogen [N, umol/l]
%            SLCA = Silicate Silicon [SiO4-Si, umol/l]
%            H2SX = Hydrogen Sulphide Sulphur [H2S-S, umol/l]
%            PHPH = Hydrogen Ion Concentration [H]
%            ALKY = Alkalinity [meq/l]
%            CPHL = Chlorophyll a [ug/l]
%       FromYear      = (int)
%       ToYear        = (int)
%       FromMonth     = (int)
%       ToMonth       = (int)
%       FromLongitude = (double)
%       ToLongitude   = (double)
%       FromLatitude  = (double)
%       ToLatitude    = (double)
%       FromPressure  = (double)
%       ToPressure    = (double)
%    
%     Output:
%       GetICEDataResult = (ArrayOfICEData)
%
%See also: GetICEDataAverage

OPT.debug = 1;
OPT.cache = 0;

OPT = setproperty(OPT,varargin);

% Build up the argument lists.
values = { ...
   ParameterCode, ...
   FromYear, ...
   ToYear, ...
   FromMonth, ...
   ToMonth, ...
   FromLongitude, ...
   ToLongitude, ...
   FromLatitude, ...
   ToLatitude, ...
   FromPressure, ...
   ToPressure, ...
   };
names = { ...
   'ParameterCode', ...
   'FromYear', ...
   'ToYear', ...
   'FromMonth', ...
   'ToMonth', ...
   'FromLongitude', ...
   'ToLongitude', ...
   'FromLatitude', ...
   'ToLatitude', ...
   'FromPressure', ...
   'ToPressure', ...
   };
types = { ...
   '{http://ocean.ices.dk/webservices/}ParameterCodeEnum', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}int', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   '{http://www.w3.org/2001/XMLSchema}double', ...
   };

%%  make the call, ...

   if OPT.debug
      tic
      disp('busy: soapMessage')
   end
   
   soapMessage = createSoapMessage( ...
       'http://ocean.ices.dk/webservices/', ...
       'GetICEData', ...
       values,names,types,'document');

%% ...make the call,...

   if OPT.debug
      %xmlwrite('soapMessage.xml',soapMessage);       
      toc
      disp('busy: callSoapService')
   end
   
   soapResponse = callSoapService( ...
       obj.endpoint, ...
       'http://ocean.ices.dk/webservices/GetICEData', ...
       soapMessage);

%%  ...and convert the response into a variable.

   if OPT.cache
      savestr(['soapResponse.xml'],char(soapResponse));
   end
   
   if OPT.debug
      toc
      disp('busy: parseSoapResponse')
   end
   
   GetICEDataResult = parseSoapResponse(soapResponse);

   if OPT.debug
      toc       
      disp('done: parseSoapResponse')
   end

   if     nargout==1
      varargout = {GetICEDataResult};
   elseif nargout==2
      varargout = {GetICEDataResult,soapResponse};
   else
      varargout = {GetICEDataResult,soapResponse,soapMessage};
   end