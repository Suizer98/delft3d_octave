function [Summary,ctitle]= KPZSS_DUROS_visualisation_5(n,s,c,sheets,Profiles,fn,Scenarios,Rp_in,Hs_in,Tp_in,D50,limits,lwb)

%   --------------------------------------------------------------------
%   Matlab script to calculate, plot and save DUROS output
%   M.Q.T. Groenewegen 
%   maurits.groenewegen@rws.nl
%   03-nov-2021
%
%   Syntax:
%   [n,s,Profiles,sheets,fn,Scenarios,Waterlevel,limits]= KPZSS_XBeach_visualisation(dir_profiles,dir_hbc)
%
%   Input:
%   n               -   Profile number (see sheets)
%   s               -   Scenario number (see scenarios)
%   c               -   Flooding probability category
%   Profiles        -   Struct with morfological scenarios data 
%   sheets          -   Sheetnames of excel   
%   fn              -   Fieldnames of Profiles struct
%   Scenarios       -   Names of scenarios 
%   Waterlevel      -   Maximum storm search level
%   limits          -   x- and y-limits plots 
%   dir_xboutput    -   Directory with XBeach output 
%
%   Output:
%   Summary     -    Struct with morfological scenarios data 
%   --------------------------------------------------------------------



Summary = {};

A = {}; B = {}; C = []; D = []; E = []; F = []; G = []; H = [];

color = {[0.949 0.3608 0.1686]...       % Color initial profile
    , [250/255 194/255 195/255]...      % Color profile change
    , [245/255 133/255 60/255]...       % Color A volume
    , [0.5 0.5 0.5]...                  % Color T volume
    , [252/255 244/255 43/255]...       % Color boundary profile
    , [0.8157 0.9137 0.9137]...         % Color water
    , [0.3686 0.7255 0.8863]};          % Color stormpeil lijn


figure()
ha = tight_subplot(2,2,[.065 .05],[.08 .09],[.08 .08]);

for k=n:n %profile number
    if( isnumeric(Profiles.(fn{k})) )
            if s ==6
                b = [2 2 2 2];
            elseif s ==1
                b = 2:5;
            elseif s ==2
                b = [2 6:8];
            elseif s ==3
                b = [2 9:11];
            elseif s ==4
                b = [2 12:14];
            elseif s ==5
                b = [2 15:17];               
            end
            
            count = 2;
            for i=b
                count = count+1;
                xInitial = Profiles.(fn{k})(:,1);
                zInitial = Profiles.(fn{k})(:,i);
                
                if c == 1
                    Rp = Rp_in.Rp_I;
                    Hs = Hs_in.Hs_I;
                    Tp = Tp_in.Tp_I;
                    ctitle = 'Cat Iv';
                elseif c == 2 
                    Rp = Rp_in.Rp_II;
                    Hs = Hs_in.Hs_II;
                    Tp = Tp_in.Tp_II;
                    ctitle = 'Cat IIv';
                elseif c == 3                     
                    Rp = Rp_in.Rp_III;
                    Hs = Hs_in.Hs_III;
                    Tp = Tp_in.Tp_III;
                    ctitle = 'Cat IIIv';
                elseif c == 4 
                    Rp = Rp_in.Rp_IV;
                    Hs = Hs_in.Hs_IV;
                    Tp = Tp_in.Tp_IV;
                    ctitle = 'Cat IVv';
                elseif c == 5 
                    Rp = Rp_in.Rp_V;
                    Hs = Hs_in.Hs_V;
                    Tp = Tp_in.Tp_V; 
                    ctitle = 'Cat Vv';
                end
                    
                try
                [Result] = mpa_durosplus(xInitial, zInitial, D50(k,3), Rp(k,count), Hs(k,count), Tp(k,count));
                
                if s==6
                    axes(ha(count-2));
                elseif s==1
                    axes(ha(i-1));
                else
                    if i == 2
                        axes(ha(i-1));
                    else 
                        axes(ha(i-b(2)+2));
                    end
                end
                
                set(gca, 'XDir','reverse')
                
                h = [];                
                
                % Initial profile

                [xInitial, zInitial] = deal([Result(1).xLand; Result(1).xActive; Result(1).xSea], [Result(1).zLand; Result(1).zActive; Result(1).zSea]);
               
                h(1) = patch([min(xInitial); xInitial; max(xInitial)], [min(zInitial); zInitial; min(zInitial)], color{1});
                hold on;
                h(2) = plot(xInitial, zInitial,'Color','k','LineStyle','-','LineWidth',2);

                % Final profile 

                h(3) = plot(Result(1).xActive, Result(1).z2Active,'Color','r','LineStyle','-','LineWidth',1.5);

                % Area of change 
                
                for j=1
                    try
                        volumePatch = [Result(j).xActive' fliplr(Result(j).xActive'); Result(j).z2Active' fliplr(Result(j).zActive')]';
                        h(j+3) = patch(volumePatch(:,1), volumePatch(:,2),color{j+1});
                        waterLevel = Result(j).info.input.WL_t;
                    end
                end

                % Area of A 

                for j=2
                    try
                        if isempty(Result(j).Volumes.Erosion) == 0
                            volumePatch = [Result(j).xActive' fliplr(Result(j).xActive'); Result(j).z2Active' fliplr(Result(j).zActive')]';
                            h(j+3) = patch(volumePatch(:,1), volumePatch(:,2),color{j+1});
                            aVolume = Result(j).Volumes.Erosion;
                        else 
                            aVolume = 0;
                        end
                    catch
                        aVolume = 0;
                    end
                end

                % Area of T 

                for j=3
                    try
                        if isempty(Result(j).Volumes.Erosion) == 0 
                            volumePatch = [Result(j).xActive' fliplr(Result(j).xActive'); Result(j).z2Active' fliplr(Result(j).zActive')]';
                            h(j+3) = patch(volumePatch(:,1), volumePatch(:,2),color{j+1});
                            toeslagVolume = Result(j).Volumes.Erosion;
                            xpPoint = Result(3).VTVinfo.Xp;
                            zpPoint = Result(3).VTVinfo.Zp;
                            xrPoint = Result(3).VTVinfo.Xr;
                            zrPoint = Result(3).VTVinfo.Zr;

                            % P
                            h(8) = plot(xpPoint,zpPoint,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor', 'k','MarkerSize', 5,'HandleVisibility', 'on','LineStyle','none');
                            text(xpPoint-3,zpPoint-1,'P','FontSize',14)

                            % R
                            h(9) = plot(xrPoint,zrPoint,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor', 'k','MarkerSize', 5,'HandleVisibility', 'on','LineStyle','none');
                            text(xrPoint+9,zrPoint+1,'R','FontSize',14)
                        else
                            toeslagVolume = 0;
                            xpPoint = [];
                            zpPoint = [];
                            xrPoint = [];
                            zrPoint = [];                       
                        end 
                    catch
                        toeslagVolume = 0;
                    end                    
                end

                % Boundary profile
                
                indices = find(xInitial < lwb(n));
                xInitial(indices) = [];
                zInitial(indices) = [];                

                x0min = min(xInitial);
                x0max = max(xInitial);
                 
                Hsig_t = Result(1).info.input.Hsig_t;
                Tp_t = Result(1).info.input.Tp_t;

                % Find the back of the first dune row behind the erosion profile.
                xCrossings = findCrossings(xInitial,zInitial,[min(xInitial),max(xInitial)],[waterLevel, waterLevel]);
                
                % Remove crossings if there is no volume between two
                % crossings
                oo = [];
                o = find(zInitial==waterLevel);
                if zInitial(1) == waterLevel
                    o=o(2:end);
                end                
                oo(:,1) = zInitial(o-1) < waterLevel;
                oo(:,2) = zInitial(o+1) < waterLevel;
                for ooo = 1:length(o)
                    if sum(oo(ooo,:)) == 2 || sum(oo(ooo,:)) == 0
                        xCrossings(xCrossings==xInitial(o(ooo))) = [];
                    end
                end                
                
                xCrossings_2 = flip(xCrossings);

                if rem(length(xCrossings_2),2) == 1
                    xCrossings_2 = [xCrossings_2 x0min];
                end                
                
                kruinhoogte = 0.12*Tp_t*sqrt(Hsig_t);
                Vrequired = (3*0.5*kruinhoogte+3)*kruinhoogte; 
                
                Vremaining = [];
                xBasePosition = [];
                rowstodelete = [];
                if  ~isempty(xCrossings) == 0
                    Vremaining = 0;
                elseif  rem(length(xCrossings_2),2) == 0
                    for w = 1:length(xCrossings_2)/2
                        if xCrossings_2(w*2)<=xpPoint
                        Gindex = find(xInitial>xCrossings_2(w*2) & xInitial<xCrossings_2(w*2-1));
                        AAx = [xCrossings_2(w*2) xInitial(Gindex)' xCrossings_2(w*2-1)]';
                        AAz = [waterLevel zInitial(Gindex)' waterLevel]';
                        AAxx = []; AAzz = [];
                        Vremaining = 0;
                        
                        % Only select the remaining area without the eroded
                        % volume
                        
                        if Result(1).VTVinfo.Xp > min(AAx) && Result(1).VTVinfo.Xp < max(AAx)
                            rowstodelete = AAx > xrPoint;
                            AAx(rowstodelete) = [];
                            AAx = [AAx; xpPoint];
                            AAz(rowstodelete) = [];
                            AAz = [AAz; zpPoint];
                        end
                        
                        for u = 1:size(AAx,1)-1
                            AAxx(u) = AAx(u+1)-AAx(u);
                            AAzz(u) = abs(AAz(u+1)-AAz(u))/2+min(AAz(u),AAz(u+1))-waterLevel;
                            Vremaining = Vremaining + AAxx(u)*AAzz(u);
                        
                        end
                        if isempty(xBasePosition)==1 && Vremaining-Vrequired >= 0
                            xBasePosition = xCrossings_2(w*2);
                            break
                        end
                        end
                            
                    end
                elseif  rem(length(xCrossings),2) == 1
                    for w = 1:(length(xCrossings_2)+1)/2
                        if xCrossings_2(w*2)<=xpPoint
                        if w == (length(xCrossings_2)+1)/2
                            Gindex = find(xInitial>=x0min & xInitial<xCrossings_2(w*2-1));
                            AAx = [x0min xInitial(Gindex)' xCrossings_2(w*2-1)]';
                        else
                            Gindex = find(xInitial>xCrossings_2(w*2) & xInitial<xCrossings_2(w*2-1));
                            AAx = [xCrossings_2(w*2) xInitial(Gindex)' xCrossings_2(w*2-1)]';
                        end
                        
                        AAz = [waterLevel zInitial(Gindex)' waterLevel]';
                        
                        % Only select the remaining area without the eroded
                        % volume
                        if Result(1).VTVinfo.Xp > min(AAx) && Result(1).VTVinfo.Xp < max(AAx)
                            rowstodelete = AAx > xrPoint;
                            AAx(rowstodelete) = [];
                            AAx = [AAx; xpPoint];
                            AAz(rowstodelete) = [];
                            AAz = [AAz; zpPoint];
                        end
                        
                        
                        AAxx = []; AAzz = [];
                        Vremaining = 0;
                        for u = 1:size(AAx,1)-1
                            AAxx(u) = AAx(u+1)-AAx(u);
                            AAzz(u) = abs(AAz(u+1)-AAz(u))/2+min(AAz(u),AAz(u+1))-waterLevel;
                            Vremaining = Vremaining + AAxx(u)*AAzz(u);
                        end
                        if isempty(xBasePosition)==1 && Vremaining-Vrequired >= 0 && w*2 < length(xCrossings_2)
                            xBasePosition = xCrossings_2(w*2);
                            break
                        elseif isempty(xBasePosition)==1 && Vremaining-Vrequired >= 0 && w*2 > length(xCrossings_2) 
                            xBasePosition = x0min;
                            break
                        end                        
                        end
                    end
                end
                

                
               

                
                
                
                
                
                
                
                
                
%                 try
%                     xCrossings_2 = findCrossings(xInitial,zInitial,[min(xInitial),max(xInitial)],[8,8]);
%                     xCrId = xCrossings < min(xCrossings_2);
%                 catch
%                     xCrossings_2 = NaN;
%                     xCrId = xCrossings < Result(1).VTVinfo.Xp;
%                 end
%                 xBasePosition = x0min;
%                 if (any(xCrId))
%                     xBasePosition = max(xCrossings(xCrId));
%                 end
                % TODO: This leads to problems if the entier profile is below sea level
                % behind erosion profile. Check and bail out (no calculation possible).

                
                % Geometrische inpassing van het grensprofiel 
%                 boundaryG = [];
%                 try
%                 [boundaryG] = KPZSS_mpa_boundary_profile_geometric(...
%                     'xInitial',xInitial,...
%                     'zInitial',zInitial,...
%                     'WL_t', waterLevel,...
%                     'Hsig_t', Hsig_t,...
%                     'Tp_t', Tp_t,...
%                     'XBasePosition',xBasePosition,...
%                     'IterateLandward',false);                   
%                 end
                % Volumetrische inpassing van het grensprofiel
                boundaryV = [];
                try
                [boundaryV] = KPZSS_mpa_boundary_profile_volumetric(...
                    'xInitial',xInitial,...
                    'zInitial',zInitial,...
                    'WL_t', waterLevel,...
                    'Hsig_t', Hsig_t,...
                    'Tp_t', Tp_t,...
                    'XBasePosition',xBasePosition,...
                    'IterateLandward',false);  
                end
 
                
                % Bepalen breedte van grensprofiel
                boundary = [];
%                 if ~isempty(boundaryG) == 1 && ~isempty(boundaryV) ==1
%                     BaseG = max(boundaryG(1).xActive)-min(boundaryG(1).xActive);
%                     BaseV = max(boundaryV(1).xActive)-min(boundaryV(1).xActive);
%                 
%                 % Kies breedste grensprofiel
%                     if BaseG < BaseV
%                         boundary = boundaryV;
%                     else 
%                         boundary = boundaryG;
%                     end
%                 elseif ~isempty(boundaryG) == 1 && ~isempty(boundaryV) ==0
%                     boundary = boundaryG;
%                 elseif ~isempty(boundaryG) == 0 && ~isempty(boundaryV) ==1
%                     boundary = boundaryV;
%                 end

                if ~isempty(boundaryV) == 1
                    boundary = boundaryV;
                end

%                 if exist('boundary','var') == 1
                if ~isempty(boundary) == 1
                    % Plot grensprofiel
                    h(7) = patch([boundary(1).xActive;flipud(boundary(1).xActive)],[boundary(1).zActive;flipud(boundary(1).z2Active)],'y');

                    % Plot punt G
                    [Gx,Gz] = findCrossings(xInitial,zInitial,[max(boundary(1).xActive),max(boundary(1).xActive)-50],[boundary(1).zActive(find(max(boundary(1).xActive))), boundary(1).zActive(find(max(boundary(1).xActive)))+50]);

                    h(12) = plot(Gx,Gz,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor', 'k','MarkerSize', 5,'HandleVisibility', 'on','LineStyle','none');
                        text(Gx-3,Gz+1,'G','FontSize',14)
                else
                    Gx = NaN;
                    if ~isempty(rowstodelete) == 1
                        h(7) = patch(AAx',AAz',[146/255 208/255 80/255]);
                        if Vremaining/Vrequired > 1
                            Gx = xrPoint-0.01;
                        end
                        h(12) = 0;
                    end                    
                end

                % Water
                
                if isempty(xpPoint) == 0 
                    h(10) = patch([max(xInitial) max(xInitial) xpPoint xpPoint],[min(zInitial) waterLevel waterLevel min(zInitial)], color{6}); % [], 'FaceColor',
                    h(11) = plot([xpPoint max(xInitial) ],[waterLevel waterLevel],'color',color{7},'LineWidth',2);
                else 
                    h(10) = patch([max(xInitial) max(xInitial) min(xInitial) min(xInitial)],[min(zInitial) waterLevel waterLevel min(zInitial)], color{6}); % [], 'FaceColor',
                    h(11) = plot([min(xInitial) max(xInitial) ],[waterLevel waterLevel],'color',color{7},'LineWidth',2); 
                        xpPoint = 0;
                        zpPoint = 0;
                        xrPoint = 0;
                        zrPoint = 0;  
                end

                % Rearange plots
                uistack(h(3),'top')
                uistack(h(2),'top')
                try
                    uistack(h(8),'top')
                end
                try 
                    uistack(h(9),'top')
                end
                uistack(h(10),'bottom')
                
                % Plot landward boundary
                if isnan(lwb(n))==1
                    lwb(n) = x0min;
                end
                h(13) = plot([lwb(n) lwb(n)],[-10,20],'m:','linewidth',2); 

                % Legend
                if h(4) ==0
                    lgd = legend(h([11 1 13 2 3]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel', ...
                    ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',... 
                    'Location','northwest');  
                elseif h(5) ==0
                    lgd = legend(h([11 1 4 13 2 3]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel', ...
                    'Erosion/Accretion',...
                    ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',... 
                    'Location','northwest');              
                elseif h(6) ==0
                    lgd = legend(h([11 1 4 5 13 2 3]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel', ...
                    'Erosion/Accretion', ['A volume (', num2str(round(aVolume)), ' m^3/m)'], ...
                    ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',... 
                    'Location','northwest');
                elseif h(7) ==0
                    lgd = legend(h([11 1 4 5 6 13 2 3 8 9]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel',...
                    'Erosion/Accretion', ['A volume (', num2str(round(aVolume)), ' m^3/m)'],...
                    ['T volume (', num2str(round(toeslagVolume)), ' m^3/m)'],...
                    ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',... 
                    ['P (',num2str(round(xpPoint)), ' m + RSP)'],...
                    ['R (',num2str(round(xrPoint)), ' m + RSP)'],...
                    'Location','northwest');
                elseif h(12) ==0
                    lgd = legend(h([11 1 4 5 6 7 13 2 3 8 9]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel', ...
                    'Erosion/Accretion', ['A volume (', num2str(round(aVolume)), ' m^3/m)'], ...
                    ['T volume (', num2str(round(toeslagVolume)), ' m^3/m)'],...
                    ['Grensprofiel (', num2str(round(Vremaining/Vrequired*100)), ' %)'],...
                    ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',... 
                    ['P (',num2str(round(xpPoint)), ' m + RSP)'],...
                    ['R (',num2str(round(xrPoint)), ' m + RSP)'],...
                    'Location','northwest');                    
                else    
                    lgd = legend(h([11 1 4 5 6 7 13 2 3 8 9 12]),['Max Stormvloedpeil (', num2str(waterLevel),' m + NAP)'], 'Beginprofiel', ...
                    'Erosion/Accretion', ['A volume (', num2str(round(aVolume)), ' m^3/m)'], ...
                    ['T volume (', num2str(round(toeslagVolume)), ' m^3/m)'],...
                    ['Grensprofiel'], ['Landward boundary (',num2str(round(lwb(n))), ' m + RSP)'],...
                    'Beginprofiel (lijn)', 'Eindprofiel (lijn)',...
                    ['P (',num2str(round(xpPoint)), ' m + RSP)'],...
                    ['R (',num2str(round(xrPoint)), ' m + RSP)'],...
                    ['G (',num2str(round(Gx)), ' m + RSP)'],...
                    'Location','northwest');
                end
                
                % Limits              
                
                xlim([limits(k,1) limits(k,2)]);
                ylim([limits(k,3) limits(k,4)]);
                
                xticks([-800 -750 -700 -650 -600 -550 -500 -450 -400 -350 ...
                    -300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 ...
                    350 400 450 500 550 600 650 700 750 800 850 900 950 1000 1050 1100])
                yticks([-5 0 5 10 15 20])
                
                htitle = get(lgd,'Title');
                
                if s==6
                    set(htitle,'String',Scenarios(count-2),'Interpreter', 'none')
                else
                    if i==2
                        set(htitle,'String',Scenarios(1),'Interpreter', 'none')
                    else
                        set(htitle,'String',Scenarios(i+2),'Interpreter', 'none')
                    end
                end

             
                ylabel('Hoogte [m+NAP]'); xlabel('Afstand in dwarsrichting [m+RSP]');
                
                box on    
                grid on;
                hold off;


                if s==6
                    B{count-2} = Scenarios(count-2);
                    C(count-2) = aVolume; 
                    D(count-2) = toeslagVolume; 
                    F(count-2) = xpPoint; 
                    G(count-2) = xrPoint;
                    H(count-2) = Gx;
                elseif s==1
                    C(i-1) = aVolume; 
                    D(i-1) = toeslagVolume; 
                    F(i-1) = xpPoint; 
                    G(i-1) = xrPoint;
                    H(i-1) = Gx;
                    if i == 2
                        B{i-1} = Scenarios(i-1);
                    else
                        B{i-1} = Scenarios(i+2);
                    end
                else
                    if i == 2
                        B{i-1} = Scenarios(i-1);
                        C(i-1) = aVolume; 
                        D(i-1) = toeslagVolume; 
                        F(i-1) = xpPoint; 
                        G(i-1) = xrPoint;
                        H(i-1) = Gx;
                    else
                        try
                        B{i-b(2)+2} = Scenarios(i+2);                   
                        C(i-b(2)+2) = aVolume; 
                        D(i-b(2)+2) = toeslagVolume; 
                        F(i-b(2)+2) = xpPoint; 
                        G(i-b(2)+2) = xrPoint;
                        H(i-b(2)+2) = Gx;
                        end
                    end
                end 
                
                catch
                    
                if s==6
                    B{count-2} = Scenarios(count-2);
                    C(count-2) = 0; 
                    D(count-2) = 0; 
                    F(count-2) = 0; 
                    G(count-2) = 0;
                    H(count-2) = 0;
                elseif s==1
                    C(i-1) = 0; 
                    D(i-1) = 0; 
                    F(i-1) = 0; 
                    G(i-1) = 0;
                    H(i-1) = 0;
                    if i == 2;
                        B{i-1} = Scenarios(i-1);
                    else
                        B{i-1} = Scenarios(i+2);
                    end
                else
                    if i == 2
                        B{i-1} = Scenarios(i-1);
                        C(i-1) = 0; 
                        D(i-1) = 0; 
                        F(i-1) = 0; 
                        G(i-1) = 0;
                        H(i-1) = 0;
                    else
                        try
                        B{i-b(2)+2} = Scenarios(i+2);                   
                        C(i-b(2)+2) = 0; 
                        D(i-b(2)+2) = 0; 
                        F(i-b(2)+2) = 0; 
                        G(i-b(2)+2) = 0;
                        H(i-b(2)+2) = 0;
                        end
                    end
                end                     
                    
                end
            end
        end
end
                
% Summary = table(B',C',D',E',F',G',H','VariableNames',{'Scenario', 'A volume [m^3/m]', 'T volume [m^3/m]', 'G volume [m^3/m]', 'P [m+RSP]', 'R [m+RSP]', 'G [m+RSP]'});
Summary = table(B',C',D',F',G',H','VariableNames',{'Scenario', 'A volume [m^3/m]', 'T volume [m^3/m]', 'P [m+RSP]', 'R [m+RSP]', 'G [m+RSP]'});
  
sgtitle(['DUROS - ', num2str(sheets(n)), ' - Scenario ', num2str(s), ' - ',ctitle], 'Interpreter', 'none');
 
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 39.11 22];
print('-dpng',['fig/Duros_2 - ',num2str(sheets(n)),' - Scenario ', num2str(s), ' - ',ctitle],'-r300')
     
end