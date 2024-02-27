function varargout = t_tide2html(D,varargin)
%t_tide2html store t_tide constituents as html table
%
% str = t_tide2html(D) where D = t_tide2struc() or D = t_tide_read()
%
% Example: t_tide2html(D,'filename','test.html');
%
%See also: t_tide, t_tide2struc, t_tide_read, t_tide2xml, t_tide2nc

warning('deprecated in favor of tide_iho.m method to_html')

% IHO xml keywords	 
   
D0.name                = '';
D0.country             = '';
D0.position.latitude   = '';
D0.position.longitude  = '';
D0.timeZone            = [];
D0.units               = '';
D0.observationStart    = '';
D0.observationEnd      = '';
D0.comments            = '';
   
OPT.filename           = '';

D = mergestructs('overwrite',D0,D);

%%

if nargin==0
    varargout = {OPT};
    return
end
OPT = setproperty(OPT,varargin);

str = '';
str = [str sprintf('<table bgcolor="#333333" cellpadding="4" cellspacing="1"><tbody>')];

str = [str sprintf('<tr><td colspan="4" bgcolor="#666666"><div style="color:#FFFFFF;">station</div></td>')];
str = [str sprintf('<tr><td colspan="2" bgcolor="#FFFFFF">%s </td><td colspan="2" bgcolor="#FFFFFF"> %s </td></tr>' ,'name'      ,D.name)];
str = [str sprintf('<tr><td colspan="2" bgcolor="#FFFFFF">%s </td><td colspan="2" bgcolor="#FFFFFF"> %s </td></tr>' ,'country'   ,D.country)];
str = [str sprintf('<tr><td colspan="2" bgcolor="#FFFFFF">%s </td><td bgcolor="#FFFFFF"> %s N</td><td bgcolor="#FFFFFF"> %s E</td></tr>','position',num2str(D.position.latitude),num2str(D.position.longitude))];
str = [str sprintf('<tr><td colspan="2" bgcolor="#FFFFFF">%s </td><td colspan="2" bgcolor="#FFFFFF"> %s </td></tr>' ,'timezone'  ,D.timeZone)];
str = [str sprintf('<tr><td colspan="2" bgcolor="#FFFFFF">%s </td><td bgcolor="#FFFFFF"> %s </td><td bgcolor="#FFFFFF"> %s </td></tr>','period',D.observationStart,D.observationEnd)];

str = [str sprintf('<tr><td colspan="4" bgcolor="#666666"><div style="color:#FFFFFF;">t_tide results</div></td>')];
str = [str sprintf('<tr><td bgcolor="#FFFFFF">%s </td><td bgcolor="#FFFFFF"> %s </td><td bgcolor="#FFFFFF"> %s</td><td bgcolor="#FFFFFF"> %s</td></tr>','name','speed [1/day]','amplitude','phaseAngle [degree]')];
for i=1:length(D.data.fmaj)
str = [str sprintf('<tr><td bgcolor="#FFFFFF">%s </td><td bgcolor="#FFFFFF"> %g </td><td bgcolor="#FFFFFF"> %g</td><td bgcolor="#FFFFFF"> %g</td></tr>',D.data.name(i,:),D.data.frequency(i),D.data.fmaj(i),D.data.pha(i))];
end

str = [str sprintf('</tbody></table>')];

if ~isempty(OPT.filename)
   savestr(OPT.filename,str)
end

if nargin==1
   varargout = {str};
end

