function yr=getyear(yr,VERBOSE)
% getyear - convert 2 digit year date to 4 digits
% 
% CALL
%     yr=getyear(yr,VERBOSE)
%     
% INPUT
%   yr     : 2 digit year (4 digits are allowed)
%   VERBOSE: display warning when making interpretation
% 
% OUTPUT
%     yr: interpreted year

%WIJZ ZIJPP 20100611: vectorize

if nargin==0
    yr=[5,10,25,1857,2005,2030];
    yr=getyear(yr)
    return
end

if nargin==1
    VERBOSE=false;
end

if VERBOSE & any(yr<100)
    disp('LET OP! 2 cijferige jaaraanduiding is niet eenduidig!');
end
    
selset=yr<20;
yr(selset)=yr(selset)+2000;

selset=yr<100;
yr(selset)=yr(selset)+1900;

%Oude code
%     if yr<100
%         %2 digit year
%         if yr<20
%             yr=2000+yr;
%         else
%             yr=1900+yr;
%         end
%         if VERBOSE
%             dsprintf('LET OP! jaaraanduiding %d (verwerkt als %d) is niet eenduidig!',yr,yr1);
%         end
%     else
%         yr1=yr;
%     end