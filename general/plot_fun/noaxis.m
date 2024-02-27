function noaxis(varargin)
%NOAXIS  makes all axes infor white (hence invisible on print)
%
%   noaxis                 for all axes of current figure
%   noaxis(fig)            for all axes of figure fig
%   noaxis(gca)            for current axes (array possible)
%   noaxis(foo,color)      makes all axes info color (default: 'w')
%
% ©, G.J. de Boer, March 2006

   color = 'w';
   
   if nargin==0
      fig  = gcf;
      ch   = get(fig,'children');
   else
      if istype(varargin{1},'axes')
         ch  = varargin{1};
      elseif istype(varargin{1},'figure')
         fig = varargin{1};
         ch  = get(fig,'children');
      else
         error('syntax: noaxis(figurehandle) or noaxis(axeshandle)')
      end
   end   
   
   if nargin>1
      color = varargin{2};
   end

   set(gcf,'InvertHardcopy','off')
   set(gcf,'color',color)

   for ich = 1:length(ch)
      if strcmp(lower(get(ch(ich),'Type')),'axes')
         set(ch(ich),'xcolor',color); % 'none'); 2015
         set(ch(ich),'ycolor',color); % 'none');
         set(ch(ich),'zcolor',color); % 'none');
        %set(ch(ich),'xticklabel',{});
        %set(ch(ich),'yticklabel',{});
        %set(ch(ich),'zticklabel',{});
         set(ch(ich),'color' ,'none')
      end
   end
