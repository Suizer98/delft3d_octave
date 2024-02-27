function result = plotProb2Bparametricresults(fileid, directory)
%PLOTPROB2BPARAMETRICRESULTS 	routine to visualize Prob2B results
%
%   Routine plot the results of a Prob2B calculation and to display
%   relevant information about the settings and the design point on the
%   screen
%
%   syntax:
%   result = plotProb2Bparametricresults(fileid, directory)
%
%   input:
%       directory       =   string containing the directory
%       fileid          =   (optional) integer expressing the file choice
%                               (e.g. 1 for the newest file)
%
%   example:
%
%
%   See also getFiNename, readProb2Bresults, plotProb2Bresults
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics / TU Delft 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, February 2008 (Version 1.0, February 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

%% get defaults
variables  = getInputVariables(mfilename);
default_values = {[], cd};
display_ind = zeros(size(variables));

getdefaults(variables, default_values, display_ind);

extension = 'txt';
exception = 'logger.txt';

%% Calculate:
fname = getFileName(directory, extension, exception, fileid);
if isempty(fname)
    return
end
result = readProb2Bresults(fname);

%% Visualize
if isfield(result, 'PARAMETRIC')
    k = length(fieldnames(result.PARAMETRIC));
    NrResults = length(result.results);
    
%% display parametric results
    fprintf('\n%s\n',fname)
    ParametricResults = zeros(NrResults, k+1);
    fprintf('\n')
    for i = 1:k
        fprintf('%15s',cell2mat(result.variable{i}))
    end
    fprintf('%15s%15s\n','Beta','P_f')
    for i = 1:NrResults
        for j = 1:k
            fprintf('%15.3e',result.results(i).values(j))
            ParametricResults(i,j) = result.results(i).values(j);
        end
        ParametricResults(i,k+1) = result.results(i).P_f;
        fprintf('%15.3e%15.3e\n', result.results(i).Beta, result.results(i).P_f)
    end
    
%% plot parametric results    
    for i = 1:k
        Values{i} = unique(ParametricResults(:,i)); %#ok<AGROW>
        if isempty(findstr(cell2mat(result.variable{i}), result.LIMIT))
            variableid = i;
        else
            limitid = i;
        end
    end
    if ~exist('variableid', 'var')
        variableid = 1;
    end
    
    FigureTitle = [result.SIGNATURE,' (',result.Methodtype,')'];
    FigureTitle(findstr(FigureTitle, '_')) = ' ';
    set(0,'Units','pixels') 
    position = get(0,'ScreenSize') + [0 30 0 -97];
    figure('Position',position,'NumberTitle','off',...
        'Name',FigureTitle,...
        'Color','w');
    linespec = {'-or' '-og' '-ob' '-oc' '-om' '-oy' '-ok' '-.or' '-.g'};
    
    if k == 2
        for j = 1:length(Values{variableid})
            rowids{j} = find(ParametricResults(:,variableid)==Values{variableid}(j)); %#ok<AGROW>
            semilogx(ParametricResults(rowids{j},3), ParametricResults(rowids{j},limitid), linespec{j})
            legendtext{j} = [cell2mat(result.variable{variableid}), ' = ', num2str(Values{variableid}(j)), ' ', result.Units{variableid}]; %#ok<AGROW>
            hold on
            exponents{j} = unique(ceil(log10(ParametricResults(rowids{j},end)))); %#ok<AGROW>
            exponents{j} = exponents{j}(1:end-1); %#ok<AGROW>
            NrCurves = length(Values{variableid});
        end
        legendtext{end+1} = 'Interpolated values';
    else
        rowids{k} = find(ParametricResults(:,variableid)==Values{variableid}); %#ok<AGROW>
        semilogx(ParametricResults(:,2),ParametricResults(:,1),'-o')
        hold on
        legendtext = {[FigureTitle, ' calculations'], 'Interpolated values'};
        exponents{k} = unique(ceil(log10(ParametricResults(rowids{k},end)))); %#ok<AGROW>
        exponents{k} = exponents{j}(1:end-1); %#ok<AGROW>
        NrCurves = 1;
    end
    minexp = min(cellfun(@min, exponents));
    maxexp = max(cellfun(@max, exponents));
    if limitid ~= variableid
        fprintf('\n%9s:',cell2mat(result.variable{variableid}))
        for j = 1:NrCurves
            fprintf('%10.0f',Values{variableid}(j))
        end
    else
        fprintf('\n')
    end
    fprintf('\n%10s','P_f')
    for j = 1:NrCurves
        fprintf('%10s','RD')
    end
    fprintf('\n')
    for n = minexp:maxexp %p = 1:length(exponents{j})
        for j = 1:NrCurves
            p = find(exponents{j}==n);
            if j == 1
                fprintf('%10.0e', eval(['1e' num2str(n)]))
            end
            if ~isempty(p)
                m{j} = exponents{j}(p); %#ok<AGROW>
                result.RDs{j}(p,:) = [interp1(log(ParametricResults(rowids{j},end)), ParametricResults(rowids{j},limitid), eval(['log(1e' num2str(m{j}) ')'])) eval(['1e' num2str(m{j})])];
                fprintf('%10.1f',result.RDs{j}(p,1))
                semilogx(result.RDs{j}(p,2),result.RDs{j}(p,1),'*r')
            else
                fprintf('          ')
            end
        end
        fprintf('\n')
    end
%     for j = 1:NrCurves
%         fprintf('\n%s',legendtext{j})
%         fprintf('\n%10s%10s\n','RD','P_f')
%         for p = 1:length(exponents{j})
%             m{j} = exponents{j}(p); %#ok<AGROW>
%             result.RDs{j}(p,:) = [interp1(log(ParametricResults(rowids{j},end)), ParametricResults(rowids{j},limitid), eval(['log(1e' num2str(m{j}) ')'])) eval(['1e' num2str(m{j})])];
%             fprintf('%10.1f%10.0e\n',result.RDs{j}(p,:))
%             semilogx(result.RDs{j}(p,2),result.RDs{j}(p,1),'*r')
%         end
%     end
    grid on
    xlabel('Probability of exceedance per year')
    ylabel('Retreat distance [m]','Rotation',270,'VerticalAlignment','top')
    legend(legendtext,2)
    set(gca,'XDir','reverse')
    if k == 1
        ax1 = gca;
        ytick = sort(result.RDs{k}(:,1));
        for p = 1:length(ytick)
            yticklabel{p} = num2str(ytick(p),'%.1f'); %#ok<AGROW>
        end
        ax2 = axes('YAxisLocation','right','YLim',get(ax1,'Ylim'),'YTick',ytick,'YTickLabel',yticklabel,'Color','none','XTick',[]); %#ok<NASGU>
    end
    
    printFigure(gcf, fname, 'overwrite')

%% plot sensitivity    
    if k == 2
        figure('Position',position,'NumberTitle','off',...
            'Name',FigureTitle,...
            'Color','w');
        counter = 1;
        clear legendtext;
        for exponent = min(cellfun(@min, exponents)) : max(cellfun(@max, exponents))
            for j = 1:length(Values{variableid})
                if ~isempty(find(exponents{j}==exponent, 1))
                    RD(j) = result.RDs{j}(exponents{j}==exponent,1); %#ok<AGROW>
                else
                    RD(j) = NaN; %#ok<AGROW>
                end
            end
            plot(Values{variableid}, RD, linespec{counter});
            legendtext{counter} = ['P_f = 10^{', num2str(exponent),'}']; %#ok<AGROW>
            hold on
            clear RD;
            counter = counter + 1;
        end
        xlabel([result.Description{variableid}, ' [', result.Units{variableid}, ']'])
        ylabel([result.Description{limitid}, ' [', result.Units{limitid}, ']'],'Rotation',270,'VerticalAlignment','top')
        grid on
        legend(legendtext,2)
        if sum(Values{variableid}==round(Values{variableid}))==length(Values{variableid}) % all values are integers
            set(gca,'XTick',Values{variableid},'XLim',[min(Values{variableid}) max(Values{variableid})]);
        end
        printFigure(gcf, fname)
    end
end