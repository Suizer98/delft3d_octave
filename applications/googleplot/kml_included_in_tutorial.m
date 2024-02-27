%% Include KML in web page tutorial
% 
% <html>
% With the <a href="http://code.google.com/intl/nl/apis/earth/">Google Earth API</a> that can be
% used in web pages, it is possible to interactively include kml files in the tutorials or other
% webpages on the OpenEarth wiki. This tutorial explaines how to include a google earth API in a web
% page.
% </html>
%

%% Google earth API licence key
% <html>
% How to include a google Earth API in a html file is described in the <a
% href="http://code.google.com/intl/nl/apis/earth/documentation/index.html#using_the_google_earth_ap
% i">Google Earth API documentation</a>. Keys are freely available, but they only work at child 
% pages of the base url for which it was registered. At this moment there are two keys registered 
% that can be used to include google earth on the wiki:
% <table border="1">
%   <tr>
%     <th>Key</th>
%     <th>Useage</th>
%   </tr>
%   <tr>
%     <td>ABQIAAAA9KO06BPsmsvzw4PogoawhRSy_gnlezoEvdu0tA7HZgv5qdaupRRCGAytCifAIns0R25EQD_uP7lUDw</td>
%     <td>This key can be used directly in all OpenEarth wiki pages whereas it was registered for http://public.deltares.nl (which actually is the base url of the server that hosts the OpenEarth wiki) </td>
%   </tr>
%   <tr>
%     <td>ABQIAAAA9KO06BPsmsvzw4PogoawhRRxYg1slSMvxuda9W0Kolc-SbeLlhQGHwE9W-XlCfe8WtZh74R56zOChQ</td>
%     <td>This key needs to be used in order to get the tutorials working. The key was registered for http://crucible.deltgeosystems.nl (which is used to host all files that are in the repository - including version info etc. -) </td>
%   </tr>
% </table>
% </html>
%


%% Google Earth in OpenEarth matlab tutorials
% To make life easier the code necessary to run the google api in a html page is included in the
% openearth tutorial template. It is enough to include the following code in your tutorial:

%
% <html>
%    <div class="geapi" url="http://dtvirt5.deltares.nl/kml/Examples/Ameland - Jarkus Raaien.kmz"
%         id="testGeApi" 
%         style="height: 600px; width: 800px;" 
%         lon=53.44
%         lat=5.69
%         rot=210
%         tilt=70
%         alt=15418>
%    </div>
% </html>
%

%%
% In this example:
%
% <html>
%   <table border="1">
%    <tr>
%     <th>Attribute</th>
%     <th>Value</th>
%     <th>Explanation</th>
%    </tr>
%    <tr>
%     <td>class</td>
%     <td>"geapi"</td>
%     <td>The class of the div must always be "geapi". This is used to identify all divs that have to be converted to a google earth api.</td>
%    </tr>
%    <tr>
%     <td>id</td>
%     <td>a unique name (string)</td>
%     <td>The id of the div (unique name) is used by the code to create an instance of the google earth api and therefore must be included (and be unique in the html page)</td>
%    </tr>
%    <tr>
%     <td>style</td>
%     <td>Any valid style string</td>
%     <td>The style determines the look of the div that contains the google api. Style can also be specified using css (to determine the style of all .geapi at once.).</td>
%    </tr>
%    <tr>
%     <td>url</td>
%     <td>full url to the kml or kmz file that must be shown</td>
%     <td>This must be the full url to the kml or kmz file that must be shown. The google api does not support relative url's at this moment.</td>
%    </tr>
%    <tr>
%     <td>lon</td>
%     <td>double</td>
%     <td>longitude at which the camera position aims (decimal notation)</td>
%    </tr>
%    <tr>
%     <td>lat</td>
%     <td>double</td>
%     <td>latitude at which the camera position aims (decimal notation)</td>
%    </tr>
%    <tr>
%     <td>rot</td>
%     <td>double</td>
%     <td>rotation of the camera</td>
%    </tr>
%    <tr>
%     <td>tilt</td>
%     <td>double</td>
%     <td>tilt of the camera</td>
%    </tr>
%    <tr>
%     <td>alt</td>
%     <td>double</td>
%     <td>altitude of the camera</td>
%    </tr>
%   </table>
% </html>
%
% Next to the relative url's that do not work the API cannot be hidden at this point. therefore the
% openearth tutorial forces any chapter that contains a GE-API to be opened at all times.

%% Example
% Lets include the API according to the code explained in the previous chapter
%
% <html>
%    <div class="geapi" url="http://dtvirt5.deltares.nl/kml/Examples/Ameland - Jarkus Raaien.kmz"
%         id="testGeApi" 
%         style="height: 600px; width: 800px;" 
%         lon=53.44
%         lat=5.69
%         rot=210
%         tilt=70
%         alt=15418>
%    </div>
% </html>
%
% Have fun playing with it.....

