function colorfix(varargin)
% COLORFIX Converts color indices into RGB color values.
%      COLORFIX(Handles,CLim,CMap)
%      Fixates the colors of the specified objects and
%      all their child-objects (default all objects in
%      the current figure) using the specified color
%      limits and colormap. If the color limits are not
%      specified the limits from the parent axes are taken.
%      If no colormap is specified, the map of the parent
%      figure is used. Arguments may be specified in any
%      order.
%
%      Note:  Interpolation between adjacent surface points
%             may change due to the conversion from
%             indexed to true color shading.
 
% (c) 1998-2000 H.R.A. Jagers
%               WL | Delft Hydraulics, Delft, The Netherlands
 
colit=[];
clim=[];
cmapuser=[];
for i=1:nargin,
  if all(ishandle(varargin{i})),
    colit=varargin{i};
  elseif isequal(size(varargin{i}),[1 2]),
    clim=varargin{i};
  elseif size(varargin{i},2)==3 & ndims(varargin{i})==2,
    cmapuser=varargin{i};
  else,
    error(sprintf('Unknown argument %i',i));
  end;
end;
if isempty(colit),
  colit=get(0,'CurrentFigure');
  if isempty(colit),
    error('No current figure.');
  end;
end;
climmanual=~isempty(clim);
 
colh=findobj(colit); % find all children of selected objects
axh=findobj(0,'type','axes'); % find all axes
for axt=1:length(axh),
  ax=axh(axt);
  chandles=intersect(get(ax,'children'),colh);
  if ~climmanual,
    clim=get(ax,'clim');
  end;
  for i=1:length(chandles),
    tp=get(chandles(i),'type');
    switch tp,
    case {'patch'}
      % cdata
      cdat=get(chandles(i),'facevertexcdata');
      if size(cdat,2)==1,
        scal=get(chandles(i),'cdatamapping');
        ax=get(chandles(i),'parent');
        fig=get(ax,'parent');
        if isempty(cmapuser),
          cmap=get(fig,'colormap');
        else,
          cmap=cmapuser;
        end;
        if strcmp(scal,'scaled'),
          lcm=size(cmap,1);
          cdat=round(1+(lcm-1)*(min(clim(2),cdat)-clim(1))/(clim(2)-clim(1)));
        else,
          cdat=round(cdat);
        end;
        cdat=max(min(cdat,size(cmap,1)),1);
        cdat3=zeros([length(cdat) 3]);
        cdatnan=isnan(cdat);
        cdat(find(cdatnan))=1;
        cmap_red=cmap(:,1);
        cdat3(:,1)=cmap_red(cdat);
        cmap_green=cmap(:,2);
        cdat3(:,2)=cmap_green(cdat);
        cmap_blue=cmap(:,3);
        cdat3(:,3)=cmap_blue(cdat);
        cdat3(cdatnan,:)=NaN;
        set(chandles(i),'facevertexcdata',cdat3);
      end;
    case {'hggroup'}
      % cdata
      ch=get(chandles(i),'Children');
      sz=size(ch);
      for i2=1:size(ch,1)
        tp1=get(ch(i2),'Type');
        if strcmp(lower(tp1),'line')==0 & strcmp(lower(tp1),'text')==0
            cdat=get(ch(i2),'facevertexcdata');
            if size(cdat,2)==1,
                scal=get(ch(i2),'cdatamapping');
                ax=get(ch(i2),'parent');
                fig=get(ax,'parent');
                if isempty(cmapuser),
                    cmap=get(gcf,'colormap');
                else,
                    cmap=cmapuser;
                end;
                if strcmp(scal,'scaled'),
                    lcm=size(cmap,1);
                    cdat=round(1+(lcm-1)*(min(clim(2),cdat)-clim(1))/(clim(2)-clim(1)));
                else,
                    cdat=round(cdat);
                end;
                cdat=max(min(cdat,size(cmap,1)),1);
                cdat3=zeros([length(cdat) 3]);
                cdatnan=isnan(cdat);
                cdat(find(cdatnan))=1;
                cmap_red=cmap(:,1);
                cdat3(:,1)=cmap_red(cdat);
                cmap_green=cmap(:,2);
                cdat3(:,2)=cmap_green(cdat);
                cmap_blue=cmap(:,3);
                cdat3(:,3)=cmap_blue(cdat);
                cdat3(cdatnan,:)=NaN;
                set(ch(i2),'facevertexcdata',cdat3);
            end;
        end
      end;
    case {'surface','image'}
      % cdata
      cdat=get(chandles(i),'cdata');
      if ndims(cdat)<3,
        scal=get(chandles(i),'cdatamapping');
        ax=get(chandles(i),'parent');
        fig=get(ax,'parent');
        if isempty(cmapuser),
          cmap=get(fig,'colormap');
        else,
          cmap=cmapuser;
        end;
        if strcmp(scal,'scaled'),
          lcm=size(cmap,1);
          cdat=round(1+(lcm-1)*(min(clim(2),cdat)-clim(1))/(clim(2)-clim(1)));
        else,
          cdat=round(cdat);
        end;
        cdat=max(min(cdat,size(cmap,1)),1);
        cdat3=zeros([size(cdat) 3]);
        cdatnan=isnan(cdat);
        cdat(find(cdatnan))=1;
        cmap_red=cmap(:,1);
        cdat3(:,:,1)=cmap_red(cdat);
        cmap_green=cmap(:,2);
        cdat3(:,:,2)=cmap_green(cdat);
        cmap_blue=cmap(:,3);
        cdat3(:,:,3)=cmap_blue(cdat);
        sz=size(cdat3);
        cdat3=reshape(cdat3,[sz(1)*sz(2) sz(3)]);
        cdat3(cdatnan,:)=NaN;
        cdat3=reshape(cdat3,sz);
        set(chandles(i),'cdata',cdat3);
      end;
    case 'light'
      % color
      % no change necessary
    case 'axes'
      % color, xcolor, ycolor, zcolor, ambientlightcolor
      % no change necessary
    case 'line'
      % color, markeredgecolor, markerfacecolor
      % no change necessary
    case 'figure'
      % color
      % no change necessary
    case 'text'
      % color
      % no change necessary
    case 'uicontrol'
      % foregroundcolor, backgroundcolor
      % no change necessary
    end;
  end;
end;
