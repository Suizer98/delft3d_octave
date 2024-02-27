function [status,result] = robocopy(source,destination,flags,quiet)
% ROBOCOPY calls robocopy
%
%   similar to syncdirs but uses robocopy for much better network
%   performance 
%
%   Syntax:
%   [status result] = syncdirs_robocopy(source, destination)
%
%   Input:
%   source      = string, directory
%   destination = string, directory
%   flags       = string, parameters to control robocopy
%   quiet       = true/false
%
%   Output:
%   status      = string, message
%   result      = string, message
%
%  explanation of the Robocopy flags 
%  (from http://ss64.com/nt/robocopy.html)
%
%   Source options
%                 /S : Copy Subfolders.
%                 /E : Copy Subfolders, including Empty Subfolders.
%  /COPY:copyflag[s] : What to COPY (default is /COPY:DAT)
%                       (copyflags : D=Data, A=Attributes, T=Timestamps
%                        S=Security=NTFS ACLs, O=Owner info, U=aUditing info).
%               /SEC : Copy files with SECurity (equivalent to /COPY:DATS).
%           /DCOPY:T : Copy Directory Timestamps. ##
%           /COPYALL : Copy ALL file info (equivalent to /COPY:DATSOU).
%            /NOCOPY : Copy NO file info (useful with /PURGE).
% 
%                 /A : Copy only files with the Archive attribute set.
%                 /M : like /A, but remove Archive attribute from source files.
%             /LEV:n : Only copy the top n LEVels of the source tree.
% 
%          /MAXAGE:n : MAXimum file AGE - exclude files older than n days/date.
%          /MINAGE:n : MINimum file AGE - exclude files newer than n days/date.
%                      (If n < 1900 then n = no of days, else n = YYYYMMDD date).
% 
%               /FFT : Assume FAT File Times (2-second date/time granularity).
%               /256 : Turn off very long path (> 256 characters) support.
% 
%    Copy options
%                 /L : List only - don't copy, timestamp or delete any files.
%               /MOV : MOVe files (delete from source after copying).
%              /MOVE : Move files and dirs (delete from source after copying).
% 
%                 /Z : Copy files in restartable mode (survive network glitch).
%                 /B : Copy files in Backup mode.
%                /ZB : Use restartable mode; if access denied use Backup mode.
%             /IPG:n : Inter-Packet Gap (ms), to free bandwidth on slow lines.
% 
%               /R:n : Number of Retries on failed copies - default is 1 million.
%               /W:n : Wait time between retries - default is 30 seconds.
%               /REG : Save /R:n and /W:n in the Registry as default settings.
%               /TBD : Wait for sharenames To Be Defined (retry error 67).
% 
%    Destination options
% 
%     /A+:[RASHCNET] : Set file Attribute(s) on destination files + add.
%     /A-:[RASHCNET] : UnSet file Attribute(s) on destination files - remove.
%               /FAT : Create destination files using 8.3 FAT file names only.
% 
%            /CREATE : CREATE directory tree structure + zero-length files only.
%               /DST : Compensate for one-hour DST time differences ##
%             /PURGE : Delete dest files/folders that no longer exist in source.
%               /MIR : MIRror a directory tree - equivalent to /PURGE plus all subfolders (/E)
% 
%    Logging options
%                 /L : List only - don't copy, timestamp or delete any files.
%                /NP : No Progress - don't display % copied.
%          /LOG:file : Output status to LOG file (overwrite existing log).
%       /UNILOG:file : Output status to Unicode Log file (overwrite) ##
%         /LOG+:file : Output status to LOG file (append to existing log).
%      /UNILOG+:file : Output status to Unicode Log file (append) ##
%                /TS : Include Source file Time Stamps in the output.
%                /FP : Include Full Pathname of files in the output.
%                /NS : No Size - don't log file sizes.
%                /NC : No Class - don't log file classes.
%               /NFL : No File List - don't log file names.
%               /NDL : No Directory List - don't log directory names.
%               /TEE : Output to console window, as well as the log file.
%               /NJH : No Job Header.
%               /NJS : No Job Summary.
% 
%  Repeated Copy Options
%             /MON:n : MONitor source; run again when more than n changes seen.
%             /MOT:m : MOnitor source; run again in m minutes Time, if changed.
% 
%      /RH:hhmm-hhmm : Run Hours - times when new copies may be started.
%                /PF : Check run hours on a Per File (not per pass) basis.
% 
%  Job Options
%       /JOB:jobname : Take parameters from the named JOB file.
%      /SAVE:jobname : SAVE parameters to the named job file
%              /QUIT : QUIT after processing command line (to view parameters). 
%              /NOSD : NO Source Directory is specified.
%              /NODD : NO Destination Directory is specified.
%                /IF : Include the following Files.
% 
% Advanced options you'll probably never use
%            /EFSRAW : Copy any encrypted files using EFS RAW mode. ##
%            /MT[:n] : Multithreaded copying, n = no. of threads to use (1-128) ###
%                      default = 8 threads, not compatible with /IPG and /EFSRAW
%                      The use of /LOG is recommended for better performance.
% 
%            /SECFIX : FIX file SECurity on all files, even skipped files.
%            /TIMFIX : FIX file TIMes on all files, even skipped files.
% 
%                /XO : eXclude Older - if destination file exists and is the same date
%                      or newer than the source - don't bother to overwrite it.
%          /XC | /XN : eXclude Changed | Newer files
%          /XX | /XL : eXclude eXtra | Lonely files and dirs. 
%                      An "extra" file is present in destination but not source, 
%                      excluding extras will delete from destination. 
%                      A "lonely" file is present in source but not destination
%                      excluding lonely will prevent any new files being added to the destination.
% 
% /XF file [file]... : eXclude Files matching given names/paths/wildcards.
% /XD dirs [dirs]... : eXclude Directories matching given names/paths.
%                      XF and XD can be used in combination  e.g.
%                      ROBOCOPY c:\source d:\dest /XF *.doc *.xls /XD c:\unwanted /S 
% 
%    /IA:[RASHCNETO] : Include files with any of the given Attributes
%    /XA:[RASHCNETO] : eXclude files with any of the given Attributes
%                /IS : Include Same, overwrite files even if they are already the same.
%                /IT : Include Tweaked files.
%                /XJ : eXclude Junction points. (normally included by default).
% 
%             /MAX:n : MAXimum file size - exclude files bigger than n bytes.
%             /MIN:n : MINimum file size - exclude files smaller than n bytes.
%          /MAXLAD:n : MAXimum Last Access Date - exclude files unused since n.
%          /MINLAD:n : MINimum Last Access Date - exclude files used since n.
%                      (If n < 1900 then n = n days, else n = YYYYMMDD date).
% 
%             /BYTES : Print sizes as bytes.
%                 /X : Report all eXtra files, not just those selected & copied.
%                 /V : Produce Verbose output log, showing skipped files.
%               /ETA : Show Estimated Time of Arrival of copied files.
% 
% ## = New Option in Vista (XP027) all other options on this page are for the XP version of Robocopy (XP010)
% ### = New Option in Windows 7 and Windows 2008 R2 
%
%  http://ss64.com/nt/robocopy.html
%
%   Example
%   robocopy(oetroot,[oetroot '..\matlab2'],'\MIR',0)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Sep 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: robocopy.m 7889 2013-01-09 17:12:29Z tda.x $
% $Date: 2013-01-10 01:12:29 +0800 (Thu, 10 Jan 2013) $
% $Author: tda.x $
% $Revision: 7889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/robocopy.m $
% $Keywords: $

%%
if isdeployed
    robocopy_path = 'robocopy.exe';
else
    robocopy_path = fullfile(fileparts(mfilename('fullpath')),'private','robocopy','robocopy.exe');
end
dosstring = sprintf('%s "%s " "%s " %s',robocopy_path,source,destination,flags);

if quiet
    [status,result] = system(dosstring);
else
    [status,result] = system(dosstring,'-echo');
end
