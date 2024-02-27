# Modify kml file GroundOverlay + LinearRing produced by OpenEarthTools KMLfigure_tiler.m
#
# Solve deal rendering issues around MSL (Mean Sea Level)
# at high zoom levels. At high zoom levels (aka LoD: Levels of Detail)
# the DEM (Digital Elevation Model) of Google Earth obtains
# high resolution, and sometimes an undershoot below MSL.
# The warping of image overlays becomes erroneous when the
# DEM is below MSL. In those cases Google Earth
# assumes the image to be below sea level, and it becomes
# invisible, i.e. it is rendered underneath the regular aereal imagery.. 
# Around MSL, it is not possible to view (fly) from underneath
# the water as has been introduced with Google Earth's ocean option.
# the propblem is known to Google Earth staff via their product forum
# and awaits prioritization:
# http://productforums.google.com/forum/#!searchin/earth/GroundOverlay/earth/x7d5abMkibo/NlgUJpCc5nYJ
#
# This problem has been solved here by overlaying the images twice 
# above certain zoom levels (actually drawOrder level): we create two 
# '<GroundOverlay> elements of the same image. This does not 
# make the kml png collection larger, as is introduces onyl extra links
# to existing images. For or <Placemark><Polygon><LinearRing> is does
# require doubling of coordinate data.
# (i)  the default 'ClampToGround' is maintained where 
#      Google Earth uses the highest available DEM data, 
# (ii) assigning the image to an alsolute altitude level
#      that is not below MSL, i.e. 1 seems to suffice for 
#      drawOrderMin > 17
# At any zoom level above drawOrderMin, now at least one of the two
# is visible, sometimes both.
#
# A noteworthy side effect of this Python is that is
# replaces linux-style end-of-line characters with
# windows-style end-of-line characters so file comparison
# when no kml was modified fails on windows.
# http:stackoverflow.com/questions/10020325/make-python-stop-emitting-a-carriage-return-when-writing-newlines-to-sys-stdout

# Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
# $Id: KMLscatter.m 7803 2012-12-07 11:19:30Z boer_g $
# $Date: 2012-12-07 12:19:30 +0100 (vr, 07 dec 2012) $
# $Author: boer_g $
# $Revision: 7803 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLscatter.m $
# $Keywords: $

# You can call this from the pyton command prompt with [1st time]
# >> import KMLfigure_tiler_fix
# after any (outside) modification to the script [2nd+ time]
# >> reload(KMLfigure_tiler_fix)

def kmlfile_change_GroundOverlay(file):
# change one kml file

   import fileinput, string, sys

# KML CODE EXAMPLE TO BE MODIFIED
#
#   <GroundOverlay>
#   <name>00320103123222312330</name>
#   <drawOrder>21</drawOrder>
#   <Icon><href>Bathymetry2012_00320103123222312330.png</href></Icon>
#   <LatLonAltBox><north>40.79360962</north><south>40.79292297</south><west>-74.14260864</west><east>-74.14192200</east></LatLonAltBox>
#   </GroundOverlay>

   drawOrderMin     = 17 # above this drawOrder level ... (19 not enough, 18 gives some tiny issues)
   absoluteAltitude = 1  # absolute altitude rendering is added to the relative one

   collect    = False
   block2copy = []
   drawOrder  = None # not present in all files
   for line in fileinput.input(file,inplace=1): # includes any LF EOL, linux-style in KMLfigure_tiler case.
       i0         = 0
       i1         = 0
       i0 = string.find(line, r'<GroundOverlay>')
       i1 = string.find(line, r'</GroundOverlay>')
       sys.stdout.write(line)                   # writes Windows-style CR+LF EOL
       if i0 >=0:
          collect = True
          block2copy = []
       if collect:
          tmp = line
          ii0 = string.find(tmp, r'<GroundOverlay>')
          if ii0 >=0:
             tmp = tmp[ii0:]
          ii1 = string.find(tmp, r'</GroundOverlay>')
          if ii1 >=0:
             tmp = tmp[ii1:]
          block2copy.append(tmp)
          i2 = string.find(line, r'<drawOrder>')
          if i2 >=0:
             r   = line.rsplit(r'<drawOrder>')[1]
             drawOrder = float(r.split(r'</drawOrder>')[0])
             block2copy.append(r'<altitude>' + str(absoluteAltitude) + r'</altitude><altitudeMode>absolute</altitudeMode>')
       if collect and i1 >=0:
          collect = False
          if drawOrder > drawOrderMin:
             for line2 in block2copy:
                 sys.stdout.write(line2)
          block2copy = []
             
def kmlfile_change_LinearRing(file):
# change one kml file

   import fileinput, string, sys

# KML CODE EXAMPLE TO BE MODIFIED
#
#   <Polygon>
#   <altitudeMode>clampToGround</altitudeMode>
#   <outerBoundaryIs>
#   <LinearRing>
#   <coordinates>
#   -74.14250117,40.79285773,0.000
#   -74.14226673,40.79316057,0.000
#   -74.14245023,40.79324237,0.000
#   -74.14268333,40.79294241,0.000
#   -74.14250117,40.79285773,0.000
#   </coordinates>
#   </LinearRing>
#   </outerBoundaryIs>
#   </Polygon>

   absoluteAltitude = 1  # absolute altitude rendering is added to the relative one

   collect    = False
   block2copy = []
   LinearRing = False
   for line in fileinput.input(file,inplace=1): # includes any LF EOL, linux-style in KMLfigure_tiler case.
       i0         = 0
       i1         = 0
       i0 = string.find(line, r'<Placemark>')
       i1 = string.find(line, r'</Placemark>')
       sys.stdout.write(line)                   # writes Windows-style CR+LF EOL
       if i0 >=0:
          collect = True
          block2copy = []
       if collect:
          tmp = line
          ii0 = string.find(tmp, r'<Placemark>')
          LinearRing = LinearRing or string.find(line, r'<LinearRing>') >= 0
          if ii0 >=0:
             tmp = tmp[ii0:]
          ii1 = string.find(tmp, r'</Placemark>')
          if ii1 >=0:
             tmp = tmp[ii1:]
          i2 = string.find(tmp, r'<altitudeMode>clampToGround</altitudeMode>')
          if i2 >=0:
             block2copy.append(r'<altitudeMode>absolute</altitudeMode>')
             block2copy.append(r'<altitude>' + str(absoluteAltitude) + r'</altitude>')
          else:
             block2copy.append(tmp)
       if collect and i1 >=0:
          collect = False
          if LinearRing:
             for line2 in block2copy:
                 sys.stdout.write(line2)
          block2copy = []

def kmlfolder_change(path,exts='.kml'):
# change kml files in one folder (not recursive)

   import glob, os

   files = glob.glob(path + "/*")
   if files is not []:
       for j, file  in enumerate(files):
           print float(j)/len(files)*100 , '%', file
           if os.path.isfile(file):
               if exts is None or exts.count(os.path.splitext(file)[1]) is not 0:
               
                  kmlfile_change_GroundOverlay(file)
                  kmlfile_change_LinearRing(file)

def kmlroot_change(path,pattern='*.kml'):
# change kml files in one folder root (fully recursive)

   import os, fnmatch

   results = []
   
   for base, dirs, files in os.walk(path):
   
     goodfiles = fnmatch.filter(files, pattern)
     
     results.extend(os.path.join(base, f) for f in goodfiles)
     
     print 'scanning base ' , base
     
   for j, file  in enumerate(results):
   
           print float(j)/len(results)*100 , '%', file
               
           kmlfile_change_GroundOverlay(file)
           kmlfile_change_LinearRing(file)
