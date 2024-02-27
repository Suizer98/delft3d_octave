%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18415 $
%$Date: 2022-10-10 19:07:38 +0800 (Mon, 10 Oct 2022) $
%$Author: chavarri $
%$Id: S3_read_crosssectiondefinitions.m 18415 2022-10-10 11:07:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_read_crosssectiondefinitions.m $
%
%Reads:
%   -cross section definition file Sobek3
%   -cross section definition file FM
%   -cross section location file FM
%
%INPUT
%   -path_csloc = path to the file to read
%
%OUPUT
%   -csloc_in = raw ascii read of cross-sections-location file; cell(nl,1); nl=number of lines of file
%   -cs       = structure of cross-sections-location; struct
%
%OPTIONAL 
%   -'file_type' = type of file: 
%       1=cross section definition file Sobek3; 
%       2=cross section definition file FM
%       3=cross section location file FM


function [csloc_in,cs]=S3_read_crosssectiondefinitions(path_csloc,varargin)

%% PARSE

parin=inputParser;
addOptional(parin,'file_type',1);
parse(parin,varargin{:});
file_type=parin.Results.file_type;

%% FM or SOBEK3

%fcnts = function to apply to the string we get:
%    1 = get rid of the first string
%    2 = convert to double
%    3 = convert to double and make integer (take only number before .)

str_dec='[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)';
switch file_type
    case 1 %SOBEK 3 cross-section definition
        tag_cs='[CrossSection]';
        tags ={'id'            ,'branchid'      ,'chainage'            ,'name'          ,'shift'              ,'definition'    };            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec) ,'\w+([.-]?\w+)*',sprintf('%s',str_dec),'\w+([.-]?\w+)*'};
        fcnts=[1               ,1               ,2                     ,1               ,2                    ,1               ];
    case 2 %FM cross-section definition zw
        tag_cs='[Definition]';
        tags ={'id'            ,'type'          ,'thalweg'  ,'numLevels'  ,'levels'   ,'flowWidths'  ,'totalWidths'  ,'leveeCrestLevel'  ,'leveeFlowArea'  ,'leveeTotalArea','leveeBaseLevel','mainWidth','fp1Width','fp2Width','isShared'};            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec),'\d+'        ,sprintf('%s',str_dec),sprintf('%s',str_dec)   ,sprintf('%s',str_dec)    ,sprintf('%s',str_dec)        ,'\d+.\d+'        ,'\d+.\d+'       ,sprintf('%s',str_dec)     ,'\d+.\d+'  ,'\d+.\d+' ,'\d+.\d+' ,'\d+'     };
        fcnts=[1               ,1               ,2          ,3            ,2          ,2             ,2              ,2                  ,2                ,2               ,2               ,2          ,2         ,2         ,2         ];
    case 3 %FM cross-section location  
        tag_cs='[CrossSection]';
        tags ={'id'            ,'branchId'      ,'chainage'  ,'shift'    ,'definitionId'    };            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec),sprintf('%s',str_dec),'\w+([.-]?\w+)*'  };
        fcnts=[1               ,1               ,2         ,2        ,1                 ];
    case 4 %FM cross-section definition xyz
        tag_cs='[Definition]';
        tags ={'id'            ,'type'          ,'thalweg'  ,'xyzCount'  ,'xCoordinates' ,'yCoordinates' ,'zCoordinates' ,'conveyance'     ,'sectionCount'  ,'frictionIds'};            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec),'\d+'       ,sprintf('%s',str_dec)    ,sprintf('%s',str_dec)    ,sprintf('%s',str_dec)    ,'\w+([.-]?\w+)*' ,'\d+'           ,'\w+([.-]?\w+)*'};
        fcnts=[1               ,1               ,2          ,2           ,2              ,2              ,2              ,1                ,2               ,1               ];
    case 5 %FM cross-section definition yz
        tag_cs='[Definition]';
        tags ={'id'            ,'type'          ,'thalweg'  ,'yzCount'  ,'yCoordinates' ,'zCoordinates' ,'conveyance'     ,'sectionCount'  ,'frictionIds'};            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec),'\d+'       sprintf('%s',str_dec)    ,sprintf('%s',str_dec)    ,'\w+([.-]?\w+)*' ,'\d+'           ,'\w+([.-]?\w+)*'};
        fcnts=[1               ,1               ,2          ,2           ,2              ,2              ,1                ,2               ,1               ];
    case 6 %FM cross-section definition rectangle
        tag_cs='[Definition]';
        tags ={'id'            ,'type'          ,'thalweg'  ,'width'     ,'height'       ,'closed'};            
        exprs={'\w+([.-]?\w+)*','\w+([.-]?\w+)*',sprintf('%s',str_dec),sprintf('%s',str_dec) ,sprintf('%s',str_dec)    ,'\w+([.-]?\w+)*'};
        fcnts=[1               ,1               ,2          ,2           ,2              ,1];
    case 7 %Global block
        tag_cs='[Global]';
        tags ={'leveeTransitionHeight'};            
        exprs={sprintf('%s',str_dec)            };
        fcnts=[2                      ];
end

ntags=numel(tags);

%%
csloc_in=read_ascii(path_csloc);

nlcsin=numel(csloc_in);
cs=struct();
kcs=1;
for kl=1:nlcsin
    str_loc=csloc_in{kl,1};
    if contains(str_loc,tag_cs)
        kl2=kl+1;
        str_loc2=csloc_in{kl2,1};
        go=true;
        while go
            str_aux_r=regexp(str_loc2,'\w+','match');
            if ~isempty(str_aux_r)
                tag_loc2=str_aux_r{1,1};
                for ktags=1:ntags
%                     if strcmp(tag_loc2,tags{1,ktags})
                    if strcmpi(tag_loc2,tags{1,ktags})
                        str_aux_l3=regexp(str_loc2,exprs{1,ktags},'match');
                        strconv=rework_str(str_aux_l3,fcnts(ktags));
                        cs(kcs).(tags{ktags})=strconv;
                    end
                end
            end
            %next line
            kl2=kl2+1;

            if kl2>nlcsin
                go=false;
            else
                %check if already next block
                str_loc2=csloc_in{kl2,1};
                if contains(str_loc2,tag_cs)
                    go=false;
                end
            end
        end
        %update cross-section counter
        kcs=kcs+1;
    end
end

end %function

%%

function strconv=rework_str(str_aux_r,fcnts_loc)

switch fcnts_loc
    case 1 %get rid of the first string
        strconv=str_aux_r{1,2};
    case 2 %convert to double
%         strconv=str2double(str_aux_r{1,1});
        strconv=str2double(str_aux_r);
    case 3 %make integer
        %20.00 -> 20
        strconv=str2double(str_aux_r);
        if numel(strconv)>1
            strconv=strconv(1);
        end
end

end %rework_str