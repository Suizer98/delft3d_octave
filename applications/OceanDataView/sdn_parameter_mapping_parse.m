function varargout = sdn_parameter_mapping_parse(sdn,varargin)
%SDN_PARAMETER_MAPPING_PARSE   parse a SeaDataNet ODV parameter
%
%    [name, parameter, units] = sdn_parameter_mapping_parse(sdn)
%    [name, parameter, units, ...
%
% splits SeaDataNet vocabulary term from SeaDataNet ODV file header into
%
%  <subject></subject>  local name
%  <object></object>    quantity name as defined in BODC vocabulary
%  <units></units>      units as defined in BODC vocabulary
%
% input can be:
% * full odv file line (incl leading comment characters //)
% * odv line contents
%
%    <parameter_description>, ...
%    <units__description>] = sdn_parameter_mapping_parse(sdn)
%
% optionally resolves SDN parameter and unit ecodes into descriptions
%
% Examples:
%
% [s,o,u] = sdn_parameter_mapping_parse('// <subject>SDN:LOCAL:WSALIN</subject><object>SDN:P011::ODSDM021</object><units>SDN:P061::UUUU</units>')
% [s,o,u,o_long,u_long] = sdn_parameter_mapping_parse('<subject>SDN:LOCAL:WSALIN</subject><object>SDN:P011::ODSDM021</object><units>SDN:P061::UUUU</units>')
%
%See also: OCEANDATAVIEW, sdn_parameter_mapping_resolve

   s1 = strfind(sdn,'<subject>');
   s2 = strfind(sdn,'</subject>');
   
   o1 = strfind(sdn,'<object');
   o2 = strfind(sdn,'</object>');
   
   u1 = strfind(sdn,'<units>');
   u2 = strfind(sdn,'</units>');
   
   if ~isempty(s1)
    subject = (sdn(s1+9:s2-1));
    object  = (sdn(o1+8:o2-1));
    units   = (sdn(u1+7:u2-1));
   else
    subject = [];
    object  = [];
    units   = [];
   end

   if nargout> 3
     object_description = sdn_parameter_mapping_resolve(object);
   end
   
   if nargout> 4
     units_description  = sdn_parameter_mapping_resolve(units);
   end

if     nargout==1
   varargout = {subject};
elseif nargout==2
   varargout = {subject,object};
elseif nargout==3
   varargout = {subject,object,units};
elseif nargout==4
   varargout = {subject,object,units,object_description};
elseif nargout==5
   varargout = {subject,object,units,object_description,units_description};
end

%% EOF

