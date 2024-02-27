function RefreshScreen

hm=guidata(findobj('Tag','MainWindow'));

i=hm.ActiveModel;
j=hm.ActiveContinent;

if hm.continents(j).nrModels>0

    set(hm.ListModels1       ,'Enable','on');
%     set(hm.ListModels2       ,'Enable','on');
%     set(hm.selectContinents2 ,'Enable','on');
    set(hm.editName          ,'Enable','on');
    set(hm.editAbbr          ,'Enable','on');
    set(hm.editRunid         ,'Enable','on');
    set(hm.selectContinent   ,'Enable','on');
    set(hm.editPosition1     ,'Enable','on');
    set(hm.editPosition2     ,'Enable','on');
    set(hm.selectSize        ,'Enable','on');
    set(hm.editXLim1         ,'Enable','on');
    set(hm.editXLim2         ,'Enable','on');
    set(hm.editYLim1         ,'Enable','on');
    set(hm.editYLim2         ,'Enable','on');
    set(hm.selectPriority    ,'Enable','on');
    set(hm.toggleNesting     ,'Enable','on');
    set(hm.editSpinUp        ,'Enable','on');
    set(hm.editRunTime       ,'Enable','on');
    set(hm.editTimeStep      ,'Enable','on');
    set(hm.editMapTimeStep   ,'Enable','on');
    set(hm.editHisTimeStep   ,'Enable','on');
    set(hm.editComTimeStep   ,'Enable','on');

    set(hm.ListModels1,'String',hm.continents(j).modelNames);
%     set(hm.ListModels2,'String',hm.continents(j).modelNames);

    n=strmatch(hm.models(i).name,hm.continents(j).modelNames,'exact');
    if isempty(n)
        hm.ActiveModel=hm.continents(j).models(1);
        i=hm.ActiveModel;
        n=1;
    end
    set(hm.ListModels1,'Value',n);

    ii=1;
    switch lower(hm.models(i).type)
        case{'delft3dflow'}
            ii=1;
        case{'delft3dflowwave'}
            ii=2;
        case{'ww3'}
            ii=3;
        case{'xbeach'}
            ii=4;
    end
    set(hm.selectType,'Value',ii);
        
%     if hm.models(i).nested
%         if ~isempty(hm.models(i).nestModel)
%             n=strmatch(hm.models(i).nestModel,hm.continents(j).modelAbbrs,'exact');
%         else
%             n=1;
%             hm.models(i).nestModel=hm.continents(j).modelAbbrs{1};
%         end
%     else
%         hm.models(i).nestModel=[];
%         n=1;
%     end
%     set(hm.ListModels2,'Value',n);
% 
%     if hm.models(i).nested
%         set(hm.selectContinents2,'Enable','on');
%         set(hm.ListModels2,'Enable','on');
%     else
%         set(hm.selectContinents2,'Enable','off');
%         set(hm.ListModels2,'Enable','off');
%     end
% 
    set(hm.editName       ,'String',hm.models(i).name);
    set(hm.editAbbr       ,'String',hm.models(i).Abbr);
    set(hm.editRunid      ,'String',hm.models(i).runid);
    icont=strmatch(hm.models(i).continent,hm.continentAbbrs,'exact');
    set(hm.selectContinent,'Value',icont);
    set(hm.editPosition1  ,'String',num2str(hm.models(i).Location(1)));
    set(hm.editPosition2  ,'String',num2str(hm.models(i).Location(2)));
    set(hm.selectSize     ,'Value' ,hm.models(i).size);
    set(hm.editXLim1      ,'String',num2str(hm.models(i).xLim(1)));
    set(hm.editXLim2      ,'String',num2str(hm.models(i).xLim(2)));
    set(hm.editYLim1      ,'String',num2str(hm.models(i).yLim(1)));
    set(hm.editYLim2      ,'String',num2str(hm.models(i).yLim(2)));
    set(hm.selectPriority ,'Value' ,hm.models(i).priority+1);
    set(hm.toggleNesting  ,'Value' ,hm.models(i).nested);
    set(hm.editSpinUp     ,'String',num2str(hm.models(i).spinUp));
    set(hm.editRunTime    ,'String',num2str(hm.models(i).runTime));
    set(hm.editTimeStep   ,'String',num2str(hm.models(i).timeStep));
    set(hm.editMapTimeStep,'String',num2str(hm.models(i).mapTimeStep));
    set(hm.editHisTimeStep,'String',num2str(hm.models(i).hisTimeStep));
    set(hm.editComTimeStep,'String',num2str(hm.models(i).comTimeStep));

else
    set(hm.ListModels1       ,'String',' ','Enable','off','Value',1);
%     set(hm.ListModels2       ,'String',' ','Enable','off','Value',1);
%     set(hm.selectContinents2 ,'Value',j   ,'Enable','off');
    set(hm.editName          ,'String','','Enable','off');
    set(hm.editAbbr          ,'String','','Enable','off');
    set(hm.editRunid         ,'String','','Enable','off');
    set(hm.selectContinent   ,'Value',j  ,'Enable','off');
    set(hm.editPosition1     ,'String','','Enable','off');
    set(hm.editPosition2     ,'String','','Enable','off');
    set(hm.selectSize        ,'Value' ,1 ,'Enable','off');
    set(hm.editXLim1         ,'String','','Enable','off');
    set(hm.editXLim2         ,'String','','Enable','off');
    set(hm.editYLim1         ,'String','','Enable','off');
    set(hm.editYLim2         ,'String','','Enable','off');
    set(hm.selectPriority    ,'Value' ,1 ,'Enable','off');
    set(hm.toggleNesting     ,'Value' ,0 ,'Enable','off');
    set(hm.editSpinUp        ,'String','','Enable','off');
    set(hm.editRunTime       ,'String','','Enable','off');
    set(hm.editTimeStep      ,'String','','Enable','off');
    set(hm.editMapTimeStep   ,'String','','Enable','off');
    set(hm.editHisTimeStep   ,'String','','Enable','off');
    set(hm.editComTimeStep   ,'String','','Enable','off');
end

guidata(gcf,hm);

			     