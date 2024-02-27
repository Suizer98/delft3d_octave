function [Vremaining,Vrequired] = KPZSS_XBeach_visualisation_simple_2(n,s,c,zss,Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,limits,lwb,dir_xboutput,fig_path)

%   --------------------------------------------------------------------
%   Matlab script to read, plot and save Xbeach output
%   M.Q.T. Groenewegen 
%   maurits.groenewegen@rws.nl
%   3-nov-2021
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

cd(dir_xboutput) 

color = {[0.8157 0.9137 0.9137]...  % Color water
    , [0.3686 0.7255 0.8863]...     % Color stormpeil lijn
    , [0.949 0.3608 0.1686]...      % Color initial profile
    , [250/255 194/255 195/255]...  % Color profile change
    , [245/255 133/255 60/255]};    % Color A volume

k=n;
    if( isnumeric(Profiles.(fn{k})) )
        folder_name = sheets(k);
        cd(folder_name);
               
        if s ==1
            b = 2:5;
        elseif s ==2
            b = [2 6:8];
        elseif s ==3
            b = [2 9:11];
        elseif s ==4
            b = [2 12:14];
        elseif s ==5
            b = [2 15:17]; 
        elseif s ==6
            b = [2 18:20];
        end
        
        if zss == 0
            i = b(1);
            count = 3;
        elseif zss == 1 
            i = b(2);
            count = 4;
        elseif zss == 2 
            i = b(3);
            count = 5;
        elseif zss == 3 
            i = b(4);
            count = 6;
        end     
         
      	if c == 1
          	Rp_in2 = Rp_in.Rp_I;
         	Hs_in2 = Hs_in.Hs_I;
          	Tp_in2 = Tp_in.Tp_I;   
            ctitle = 'Cat Iv';
       	elseif c == 2 
           	Rp_in2 = Rp_in.Rp_II;
          	Hs_in2 = Hs_in.Hs_II;
          	Tp_in2 = Tp_in.Tp_II;
            ctitle = 'Cat IIv';
      	elseif c == 3                     
          	Rp_in2 = Rp_in.Rp_III;
         	Hs_in2 = Hs_in.Hs_III;
          	Tp_in2 = Tp_in.Tp_III; 
            ctitle = 'Cat IIIv';
      	elseif c == 4 
          	Rp_in2 = Rp_in.Rp_IV;
           	Hs_in2 = Hs_in.Hs_IV;
           	Tp_in2 = Tp_in.Tp_IV; 
            ctitle = 'Cat IVv';
      	elseif c == 5 
           	Rp_in2 = Rp_in.Rp_V;
         	Hs_in2 = Hs_in.Hs_V;
           	Tp_in2 = Tp_in.Tp_V; 
            ctitle = 'Cat Vv';
        end 
                
    	Rp = Rp_in2(k,count);
     	Hs = Hs_in2(k,count);
      	Tp = Tp_in2(k,count);
     	folder_name_2 = Scenarios(i-1);
      	folder_name_3 = Category(c);
      	cd(folder_name_2); cd(folder_name_3); cd('input');
        
        if isfile('XBerror.txt') ==0
        figure()
      	xbo = xb_read_output('xboutput.nc');
       	z_xb = xs_get(xbo, 'zb');
      	DIMS = xs_get(xbo, 'DIMS');
       	x_xb = xs_get(DIMS, 'x');
       	time = xs_get(DIMS, 't'); 
            
      	zIni = (z_xb(1,:))'; 
      	zEnd = (z_xb(end,:))';
       	zEndTemp = zEnd;
       	for idx = find(zIni < Rp)   % replace XBoutput below Rp to zIni
          	zEndTemp(idx) = zIni(idx);
       	end; clear idx
       	diff = zIni - zEndTemp;     % difference between ini and end
      	diff(diff < 0) = 0;         % no negative differences used
%        	AVolXB = trapz(x_xb, diff); % use trapz to get volume
        
        [AVolD] = calcVolume(x_xb, zIni, zEnd, Rp);
        AVolXB = AVolD;
 
        % Set x-values to RSP

        Profielen = [];
        Profielen = Profiles.(fn{k});
        Profielen(any(isnan(Profielen), 2), :) = [];
        x_Jrk = Profielen(:,1);
        x_Jrk = rmmissing(x_Jrk);
        [x] = XBeach2RSP(x_xb, x_Jrk);
        x_xb = x;
     
        set(gca, 'XDir','reverse')
        
       	[xcr zcr] = findCrossings([min(x_xb)-1 max(x_xb)+1], [Rp Rp], x_xb,zEnd);  
  
     	hold on; 
      	set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.35, 0.8, 0.6]);
            
      	%   plot waterlevel
            if isempty(xcr) == 1;
                h(1) = patch([min(x_xb) min(x_xb) max(x_xb) max(x_xb)], ...
                [min(zIni) Rp Rp min(zIni)], color{1});
                h(2) = plot([min(x_xb) max(x_xb)],[Rp Rp],'color',color{2},'LineWidth',2);
            else
                h(1) = patch([max(x_xb) max(x_xb) max(xcr) max(xcr)], ...
                [min(zIni) Rp Rp min(zIni)], color{1});
                h(2) = plot([max(x_xb) max(xcr)],[Rp Rp],'color',color{2},'LineWidth',2);
            end
            
      	%   plot initial profile
            h(3) = patch([max(x_xb); x_xb; min(x_xb)], [min(zIni)-5; zIni; min(zIni)-5], color{3});  % start
            
       	%   plot difference initial- and final profile
            h(4) = patch([x_xb; flipud(x_xb)], [zIni; flipud(zEnd)], color{4}); % XBeach erosie [1 .6 0]
            
       	%   plot erosion volume above waterlevel
            if isempty(xcr) == 0 && max(zEnd)<100;
                h(5) = patch([x_xb(zIni>Rp); flipud(x_xb(zEnd>Rp))],...           
                    [zIni(zIni>Rp); flipud(zEnd(zEnd>Rp))], color{5}); % A volume XBeach [1 .2 0]
            end
             
      	%   plot lines intial- and final profile
            h(6) = plot(x_xb, zIni,'k','LineWidth',2);            % start as line   
            h(7) = plot(x_xb, zEnd,':k','LineWidth',2);            % end as line 
            
        %   Remove values landward of landward boundary
            indices = find(x_xb < lwb(n));
            x_xb(indices) = [];
            zIni(indices) = [];
            zEnd(indices) = [];
            
                if isnan(lwb(n))==1
                    lwb(n) = min(x_xb);
                end
                h(13) = plot([lwb(n) lwb(n)],[-10,20],'m:','linewidth',2); 

            
      	%   plot point P
            P = findCrossings(x_xb,zEnd,[min(x_xb),max(x_xb)],[Rp, Rp]);
            if isempty(xcr) == 0 && max(zEnd)<100;
                h(8) = plot(max(P),Rp,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor', 'k','MarkerSize', 5,'HandleVisibility', 'on','LineStyle','none');
                text(max(P)+3,Rp-0.5,'P','FontSize',14)
            else
                Vremaining = NaN;
                Vrequired = NaN;
            end
            
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            
%             if isempty(P) ==0
%                 if size(P,1)>1
%                     xBasePosition = P(2);
%                 else 
%                     xBasePosition = max(x_xb);
%                 end 
%                         %   plot remaining volume    
%                 Gindex = find(x_xb>min(P) & x_xb<xBasePosition);
%                 AAx = [xBasePosition x_xb(Gindex)' min(P)]';
%                 AAz = [Rp zEnd(Gindex)' Rp]';
%                 h(10) = patch(AAx',AAz','y');
%                 h(9) = patch(AAx',AAz',[146/255 208/255 80/255]);
% 
%                 AAxx = [];
%                 Vremaining = 0;
%                 for u = 1:size(AAx,1)-1
%                     AAxx(u) = abs(AAx(u+1)-AAx(u));
%                     AAzz(u) = abs(AAz(u+1)-AAz(u))/2+min(AAz(u),AAz(u+1))-Rp;
%                     Vremaining = Vremaining + AAxx(u)*AAzz(u);
%                 end
% 
%             %   calculate required (boundary profile) volume
%                 kruinhoogte = 0.12*Tp*sqrt(Hs);
%                 Vrequired = (3*0.5*kruinhoogte+3)*kruinhoogte;
%             end
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
                
                xCrossings_2 = flip(P);
                
                if rem(length(xCrossings_2),2) == 1
                    xCrossings_2 = [xCrossings_2; min(x_xb)];
                end
                
                kruinhoogte = 0.12*Tp*sqrt(Hs);
                Vrequired = (3*0.5*kruinhoogte+3)*kruinhoogte; 
                
                Vremaining = [];
                xBasePosition = [];
                rowstodelete = [];
                if  ~isempty(P) == 0
                    Vremaining = 0;
                elseif  rem(length(xCrossings_2),2) == 0
                    for w = 1:length(xCrossings_2)/2
                        if xCrossings_2(w*2)<=max(P)
                        Gindex = find(x_xb>xCrossings_2(w*2) & x_xb<xCrossings_2(w*2-1));
                        AAx = [xCrossings_2(w*2-1) x_xb(Gindex)' xCrossings_2(w*2)]';
                        AAz = [Rp zEnd(Gindex)' Rp]';
                        AAxx = []; AAzz = [];
                        Vremaining = 0;
                        
                        % Only select the remaining area without the eroded
                        % volume
                        
%                         if max(P) > min(AAx) && max(P) < max(AAx)
%                             rowstodelete = AAx > xrPoint;
%                             AAx(rowstodelete) = [];
%                             AAx = [AAx; xpPoint];
%                             AAz(rowstodelete) = [];
%                             AAz = [AAz; zpPoint];
%                         end
%                         
                        for u = 1:size(AAx,1)-1
                            AAxx(u) = abs(AAx(u+1)-AAx(u));
                            AAzz(u) = abs(AAz(u+1)-AAz(u))/2+min(AAz(u),AAz(u+1))-Rp;
                            Vremaining = Vremaining + AAxx(u)*AAzz(u);
                        end
                        if isempty(xBasePosition)==1 && Vremaining-Vrequired >= 0
                            xBasePosition = xCrossings_2(w*2);
                            break
                        end
                        end
                            
                    end            
            
                h(10) = patch(AAx',AAz','y');
                h(9) = patch(AAx',AAz',[146/255 208/255 80/255]);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
      
            
      	%   legend
            if isempty(xcr) == 1
                lgd = legend(h([2:4 13 6:7]),['Max Stormvloedpeil (', num2str(Rp),' m + NAP)'], 'Beginprofiel', ...
                'XBeach profiel wijzigen',['Landwaartse grens (',num2str(round(lwb(n))), ' m + RSP)'],'Beginprofiel (lijn)', 'Eindprofiel (lijn)',...
                'Location','northwest');                
                
            else
                lgd = legend(h([2:5 13 6:10]),['Max Stormvloedpeil (', num2str(Rp),' m + NAP)'], 'Beginprofiel', ...
                'XBeach profiel wijzigen', ['A volume (', num2str(round(AVolXB)), ' m^3/m)'], ...
                 ['Landwaartse grens (',num2str(round(lwb(n))), ' m + RSP)'],'Beginprofiel (lijn)', 'Eindprofiel (lijn)',...
                 ['P (',num2str(round(max(P))), ' m + RSP)'],['Remaining volume (',num2str(round(Vremaining)), ' m^3/m)'], ...
                 ['Required volume (',num2str(round(Vrequired)), ' m^3/m)'],'Location','northwest');
            end
            
       	htitle = get(lgd,'Title');
       	set(htitle,'String',Scenarios(i-1),'Interpreter', 'none') 
             
       	ylabel('Hoogte [m+NAP]'); xlabel('Afstand in dwarsrichting [m+RSP]');
            
       	xlim([limits(k,1) limits(k,2)]);
       	ylim([limits(k,3) limits(k,4)]);
     
                
      	xticks([-800 -750 -700 -650 -600 -550 -500 -450 -400 -350 ...
          	-300 -250 -200 -150 -100 -50 0 50 100 150 200 250 300 ...
          	350 400 450 500 550 600 650 700 750 800]);

      	yticks([-5 0 5 10 15 20])
        
%         title(['XBeach - ', num2str(sheets(n)), ' - Scenario ', num2str(s), ' - ',num2str(zss),'m ZSS - ',ctitle ],'Interpreter', 'none')
        title(['XBeach - ', num2str(sheets(n)), ' - ',num2str(zss),'m ZSS - ',ctitle ],'Interpreter', 'none')
        
      	grid on; box on;
        
        uistack(h(6),'top')
        uistack(h(7),'top')
            
      	hold off;          

        cd(fig_path)

        fig = gcf;
        fig.PaperUnits = 'centimeters';
        fig.PaperPosition = [0 0 22 15];
        print('-dpng',['XBeach_4 - ',num2str(sheets(n)),' - Scenario ', num2str(s), ' - ',num2str(zss),'m ZSS - ',ctitle ],'-r300')
        else
            Vremaining = NaN;
            Vrequired = NaN;
        end
    end
    
end