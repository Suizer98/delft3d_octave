function varargout = wms_image_plot(url,OPT)
%WMS_IMAGE_PLOT download WMS image, save to cache and it render georeferenced
%
% [url,OPT,lims] = wms('server',server,'layers','Ortho');
% wms_image_plot(url,OPT)
%
% Only plots CRS EPSG%3A4326.
%
%See also: wms, imread, urlwrite

if ~strcmp(OPT.crs,'EPSG%3A4326')
    error('only plots WGS 84 code EPSG%3A4326')
end

%% download cache of image

   OPT.cachename = [OPT.cachedir,filesep,mkvar(OPT.layers),'_time=',mkvar(OPT.time),'_elevation=',mkvar(OPT.elevation)];

   urlwrite(url,[OPT.cachename,OPT.ext]);
   
   disp(['Cached WMS image to:',OPT.cachename,OPT.ext])
  
%% make kml wrapper for cached image
   KMLimage(OPT.axis([2 4]),OPT.axis([1 3]),url,'fileName',[OPT.cachename,'.kml'])
  
%% TODO make world file  
  
%% plot georeferenced in matlab for testing
   [A,map,alpha] = imread([OPT.cachename,OPT.ext]);
   image(OPT.x,OPT.y,A)
   colormap(map)
   tickmap('ll');grid on;
   set(gca,'ydir','normal')
   %TODO if ~isempty(OPT.colorscalerange);clim([OPT.colorscalerange]);end
   %TODO colorbarwithvtext(OPT.layers)
   t = '';
   if ~isempty(OPT.time)
       t = ['time:',OPT.time];
   end
   if ~isempty(OPT.elevation)
       t = [t,' elevation:',OPT.elevation];
   end
   title(t)
   print2screensizeoverwrite([OPT.cachename,'_rendered'])
  
   if nargout > 0
      varargout = {A,map,alpha};
   end