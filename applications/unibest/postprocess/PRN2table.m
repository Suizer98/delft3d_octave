function PRN2table(jaar,locaties)
% PRN2table  Exports PRNdata to text file
%
%    This function extracts data from PRN files,
%    Exports coastline change (m), coastline angle (°N) at a certain location
%    A pop-up will ask you for the location of the considered PRN-file.
%
%   Syntax:
%       PRN2table(jaar,locaties)
%
%   Input:
%      jaar=[1 2 5];
%      locaties=[20 25 33 50 100]; 
%
%   Output:
%      The output will be a text-file in the form: ['outputPRN_' filename '.txt']
%
%   Example
%      jaar=[1 2 5];
%      locaties=[20 25 33 50 100];
%      PRN2table(jaar,locaties)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       huism_b
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 19 Jun 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $


clear data
data=readPRN4; %reads the PRN-file(s)


    fid2=fopen(['outputPRN_' data.files{1}(1:end-4) '.txt'],'wt');   
    %fprintf(fid2,'\n Shoreline after %02.0f years \n',jaar(ii));

    fprintf(fid2,'---------------------------------------------------------\n');
    fprintf(fid2,'input data:');
    fprintf(fid2,'\njaren:   ');
    for aantal=1:length(jaar)
        fprintf(fid2, [num2str(jaar(aantal),'%2.1f')] );
        if aantal<length(jaar);fprintf(fid2,', ');end
    end
    
    
    fprintf(fid2,'\n---------------------------------------------------------\n');
    fprintf(fid2,'\tDistance\tbasis\t\tafter 1yr\tafter 2yr\tafter 5yr\n');
    fprintf(fid2,'      location\t  [m]\t[deg]\t[m]\t[deg]\t[m]\t[deg]\t[m]\t[deg]\t[m]\n');
    
    for iii=1:length(locaties) 
        Loc=locaties(iii);
        Xdist=data.xdist(locaties(iii),1);
        Cangle0=data.alfa(locaties(iii),1);
        distZ0=data.z(locaties(iii),1);
        
        plotdata=[Loc,Xdist,Cangle0,distZ0];
        fprintf(fid2,'Loc :\t%6.0f\t%5.0f\t%6.2f\t%3.1f',plotdata);
        
        for iiii=1:length(jaar)
            clear Cangle offset
            difference=abs(data.jaar-jaar(iiii));
            id=find(difference==min(difference));
                                
            Cangle{iiii}=data.alfa(locaties(iii),id(1));
            offset{iiii}=data.zminz0(locaties(iii),id(1));
            plotdata=[Cangle{iiii},offset{iiii}];
            fprintf(fid2,'\t%6.2f\t%3.1f',plotdata);
        end
        fprintf(fid2,'\n');
        %wo5=data.zminz0(locaties(iii),2*jaar(3)+1);
        %maxOffset=max([basis,woI6,woDWF,woREV]);
    end
    
    fclose(fid2);
    clear Loc Xdist Cangle0 distZ0 plotdata Cangle offset fid2 iii iiii
    fclose all;
    
    
   % fid2=fopen('outputPRN.txt','wt');
   % jaar=[5 10 25];
   % locaties=[93 94 184 185 186 188 192 255 256 257 264 272]; 
   % %fprintf(fid2,'\n Shoreline after %02.0f years \n',jaar(ii));
   %     fprintf(fid2,'               Distance     basis             after 1yr          after 2yr          after 5yr         \n');
   %     fprintf(fid2,' location         [m]       [deg]     [m]     [deg]      [m]     [deg]      [m]     [deg]      [m]  \n');
   % 
   %     for iii=1:length(locaties) 
   %         Loc=locaties(iii);
   %         Xdist=data.xdist(locaties(iii),1);
   %         Cangle=data.alfa(locaties(iii),1);
   %         basis=data.zminz0(locaties(iii),1);
   %         Cangle2=data.alfa(locaties(iii),2*jaar(1)+1);
   %         wo1=data.zminz0(locaties(iii),2*jaar(1)+1);
   %         Cangle3=data.alfa(locaties(iii),2*jaar(2)+1);
   %         wo2=data.zminz0(locaties(iii),2*jaar(2)+1);
   %         Cangle4=data.alfa(locaties(iii),2*jaar(3)+1);
   %         wo5=data.zminz0(locaties(iii),2*jaar(3)+1);
   %         %maxOffset=max([basis,woI6,woDWF,woREV]);
   %            plotdata=[Loc,Xdist,Cangle,basis,Cangle2,wo1,Cangle3,wo2,Cangle4,wo5];
   %         fprintf(fid2,'Loc  : %6.0f     %5.0f     %6.2f     %3.0f     %6.2f     %3.0f     %6.2f     %3.0f     %6.2f     %3.0f   \n',plotdata);
   %     end
   % fclose(fid2);
   %
   % clear Loc Xdist basis wo1 wo2 wo5 Cangle Cangle2 Cangle3 Cangle4 fid2 locaties jaar tijd ii iii plotdata offsetX offsetY legenda fonts fignr h
%