
function timeCoverage = timeCoverage_complete(timeCoverage)

   if isnan(timeCoverage.start)
   timeCoverage.start    = timeCoverage.end   - timeCoverage.duration;
   end
   
   if isnan(timeCoverage.duration)
   timeCoverage.duration = timeCoverage.end   - timeCoverage.start;
   end
   
   if isnan(timeCoverage.end)
   timeCoverage.end      = timeCoverage.start + timeCoverage.duration;
   end
