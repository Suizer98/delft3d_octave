function varargout = ITHK_KMLtimespan(varargin)
%ITHK_KMLtimespan   kml string from dates
%
%   timeSpan = ITHK_KMLtimespan(i,'timeIn',ti,'timeOut',to,'dateStrStyle',...)
%   timeSpan = ITHK_KMLtimespan( ,'timeIn',ti,'timeOut',to,'dateStrStyle',...)
%
% where the optional i is the index into vectors ti and to.
%
% VERY SLOW (!) when ti en to are a vector of datenums,
%          fast when ti en to are matrix   of strings.
% So for many call apply datestr before you pass ti an to.
%
%See also: GooglePlot

   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 'yyyy-mm-ddTHH:MM:SS'; %29;
   
   if nargin==0; varargout = {OPT}; return; end

   if odd(nargin)
      ii = varargin{1};
      varargin = {varargin{2:end}};
   end

   OPT = setproperty(OPT,varargin{:});
   
   if isnumeric(OPT.timeIn) ; if length(OPT.timeIn) >1;disp('googlePlot: timeIn  as datestr is MUCH faster!');end;OPT.timeIn  = datestr(OPT.timeIn ,OPT.dateStrStyle);end
   if isnumeric(OPT.timeOut); if length(OPT.timeOut)>1;disp('googlePlot: timeOut as datestr is MUCH faster!');end;OPT.timeOut = datestr(OPT.timeOut,OPT.dateStrStyle);end
       
   if  ~isempty(OPT.timeIn)
       if length(OPT.timeIn)>1 && odd(nargin)
           tt = ii;
%        elseif iscellstr(OPT.timeIn)
%            timeIn  = OPT.timeIn{tt};
       else
           tt = 1;
       end
       if ~isempty(OPT.timeOut)
           timeSpan = sprintf([...
               '<TimeSpan>'...
               '<begin>%s</begin>'...% OPT.timeIn
               '<end>%s</end>'...    % OPT.timeOut
               '</TimeSpan>'],...
               OPT.timeIn(tt,:),OPT.timeOut(tt,:));
       else
           timeSpan = sprintf([...
               '<TimeStamp>'...
               '<when>%s</when>'...  % OPT.timeIn
               '</TimeStamp>'],...
               OPT.timeIn(tt,:));
       end
   else
       timeSpan ='';
   end
   
   varargout  = {timeSpan};
