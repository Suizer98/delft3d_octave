function [AVolD] = calcVolume(x, zIni, zEnd, level)

    % calculate an erosion volume between an initial and erosion profile
    % above a user-defined level
    % INPUT
    % - x       x-axis
    % - zIni    intial profile
    % - zEnd    erosion profile
    % - level   level above which volume is calculated
      
    % default value
    if ~exist('level','var')
        level = 0;
    end
    
    % make a temporal XB end profile
    zEnd(zEnd < level) = level;     % set zEnd below level to level
    diff = zIni - zEnd;             % difference between ini and end
    diff(diff < 0) = 0;             % no negative differences used
    AVolD = trapz(x, diff);         % use trapz to get volume
    
end