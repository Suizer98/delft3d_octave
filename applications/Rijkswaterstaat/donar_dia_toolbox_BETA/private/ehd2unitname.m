function longname = ehd2unitname(code)
%ehd2unitname convert donar units short_name to units long_name
%
%   longname = ehd2unitname(code)
%
% Example: ehd2unitname('doC') = 'decigrade Celsius'
%
%
%see also: convert_units, donarname2standardnames

ehd_database = { ...
    '%'     ,'percent'; ...
    '/d'    ,'per day'; ...
    '/h'    ,'per hour'; ...
    '/h/km' ,'per hour per kilometer'; ...
    '/km2'  ,'per square kilometre'; ...
    '/l'    ,'per litre'; ...
    '/m'    ,'per metre'; ...
    '/m2'   ,'per square metre'; ...
    '/mg'   ,'per milligram'; ...
    '/ml'   ,'per millilitre'; ...
    '1/m'   ,'coefficient per meter'; ...
    'a'     ,'year'; ...
    'B'     ,'Beaufort'; ...
    'Bq/kg' ,'Becquerels per kilogram'; ...
    'Bq/m3' ,'Becquerels per cubic metre'; ...
    'c/s'   ,'Counts per second'; ...
    'cm'    ,'centimetre'; ...
    'cm/s'  ,'centimetres per second'; ...
    'cm2'   ,'square centimetre'; ...
    'cm2/Hz','square centimetres per Hertz'; ...
    'cm2s'  ,'square centimetre second'; ...
    'coC'   ,'centigrade Celsius'; ...
    'd'     ,'day'; ...
    'dB'    ,'Decibel'; ...
    'dBar'  ,'deciBar'; ...
    'DIMSLS','Dimensionless'; ...
    'dm'    ,'decimetre'; ...
    'dm/s'  ,'decimetres per second'; ...
    'dm3/s' ,'cubic decimetres per second'; ...
    'doC'   ,'decigrade Celsius'; ...
    'ds'    ,'decisecond'; ...
    'FINDX' ,'F-index'; ...
    'FTU'   ,'Formazine Turbidity Units'; ...
    'g'     ,'gram'; ...
    'g/a'   ,'grams per year'; ...
    'g/d'   ,'grams per day'; ...
    'g/kg'  ,'grams per kilogram'; ...
    'g/m2'  ,'grams per square metre'; ...
    'g/m3'  ,'grams per cubic metre'; ...
    'g/s'   ,'grams per second'; ...
    'graad' ,'degree'; ...
    'h'     ,'hour'; ...
    'hPa'   ,'hectoPascal'; ...
    'Hz'    ,'Hertz'; ...
    'j'     ,'Year'; ...
    'JTU'   ,'Jackson Turbidity Units'; ...
    'kg'    ,'kilogram'; ...
    'kg/a'  ,'kilograms per year'; ...
    'kg/km2','kilogram per quare meter'; ...
    'kg/m3' ,'kilograms per cubic metre'; ...
    'KHz'   ,'kiloHertz'; ...
    'l'     ,'litre'; ...
    'm'     ,'metre'; ...
    'm/s'   ,'metres per second'; ...
    'm2'    ,'square metre'; ...
    'm3'    ,'Cubic metre'; ...
    'm3/a'  ,'cubic metres per year'; ...
    'm3/d'  ,'cubic metres per day'; ...
    'm3/h'  ,'cubic metres per hour'; ...
    'm3/s'  ,'cubic metres per second'; ...
    'mBq/l' ,'milliBecquerels per litre'; ...
    'meq/l' ,'milli equivalent per liter'; ...
    'mg/g'  ,'milligrams per gram'; ...
    'mg/kg' ,'milligrams per kilogram'; ...
    'mg/l'  ,'milligrams per litre'; ...
    'mg/ml' ,'milligram per liter'; ...
    'mHz'   ,'milliHertz'; ...
    'min'   ,'minute'; ...
    'MJ/s'  ,'megaJoule per second'; ...
    'ml'    ,'per millilitre'; ...
    'ml/l'  ,'millilitres per litre'; ...
    'mm'    ,'millimetre'; ...
    'mm/h'  ,'mm per hour'; ...
    'mm2'   ,'square millimetre'; ...
    'mm3/l' ,'cubic millimetres per litre'; ...
    'mmol/l','millimol per liter'; ...
    'mnd'   ,'month'; ...
    'mS/m'  ,'milliSiemens per metre'; ...
    'ng/g'  ,'nangram per liter'; ...
    'ng/kg' ,'nanongrams per kilogram'; ...
    'ng/l'  ,'nanongrams per litre'; ...
    'ng/ml' ,'nanongrams per millilitre'; ...
    'nmol/mg','nanomol per milligram'; ...
    'NTU'    ,'Nephelometric Turbidity Units'; ...
    'oC'     ,'degrees Celsius'; ...
    'oD'     ,'German hardness grade'; ...
    'Pa'     ,'Pascal'; ...
    'pmol/mg','picomol per milligram'; ...
    'PROMLE' ,'PROMILLE'; ...
    'PtCo'   ,'Pt-Co scale'; ...
    's'      ,'second'; ...
    'S/m'    ,'Siemens per metre'; ...
    't/a'    ,'tons per year'; ...
    'tds'    ,'Tonnes dry matter'; ...
    'TEQ'    ,'Toxity Equivalents'; ...
    'TU'     ,'Toxic Units'; ...
    'U'      ,'Unit'; ...
    'uE'     ,'microEinstein'; ...
    'ug/g'   ,'micrograms per gram'; ...
    'ug/kg'  ,'micrograms per kilogram'; ...
    'ug/l'   ,'micrograms per litre'; ...
    'um'     ,'micrometre'; ...
    'um2'    ,'square micrometre'; ...
    'us'     ,'microsecond'; ...
};


longname = ehd_database{strcmpi(ehd_database(:,1),code),2};