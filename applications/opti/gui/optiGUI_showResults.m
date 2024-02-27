function optiGUI_showResults(fig)

if nargin==0
    [but,fig]=gcbo;
end

this=get(fig,'userdata');
nodg=length(this.input);
plotclr=[0 0 0; rand(nodg-1,3)];

axes(findobj(fig,'tag','weights'));
hold on;
plot([length(this.iteration):-1:1],sum(cell2mat({this.iteration.weights}'),2),'k.-');
plot(xlim,[1 1],'k:');
sliderPos=get(findobj(fig,'tag','conditionSlider'),'value');
set(gca,'xdir','reverse')
xlim([1 length(this.iteration)]);
ylim([0 2]);
plot([sliderPos sliderPos],ylim,'r');
ylabel('Sum of weights');
xlabel('Number of remaining conditions');

axes(findobj(fig,'tag','rmsRel'));
hold on;
plot([length(this.iteration):-1:1],100.*[this.iteration.rmsRelWeighted],'k.-');
plot(xlim,[100 100],'k:');
sliderPos=get(findobj(fig,'tag','conditionSlider'),'value');
set(gca,'xdir','reverse')
xlim([1 length(this.iteration)]);
ylim([0 20]);
plot([sliderPos sliderPos],ylim,'r');
ylabel('Relative weighted rms value [%]');
xlabel('Number of remaining conditions');

axes(findobj(fig,'tag','rms'));
hold on;
for dg=1:nodg
   for ii=1:length(this.iteration)
      rmsRel(ii)=this.iteration(ii).rmsRel(dg,this.iteration(ii).iteration);
   end
   plot([length(this.iteration):-1:1],100.*[rmsRel],'color',plotclr(dg,:),'Marker','.','LineStyle','-');
end
legend([repmat('data group ',nodg,1) num2str([1:nodg]')],2);
sliderPos=get(findobj(fig,'tag','conditionSlider'),'value');
set(gca,'xdir','reverse')
xlim([1 length(this.iteration)]);
ylim([0 20]);
plot([sliderPos sliderPos],ylim,'r');
ylabel('Relative rms value');
xlabel('Number of remaining conditions');

axes(findobj(fig,'tag','corr'));
hold on;
for dg=1:nodg
   for ii=1:length(this.iteration)
      corr(ii)=this.iteration(ii).corr(dg,this.iteration(ii).iteration);
   end
   plot([length(this.iteration):-1:1],[corr],'color',plotclr(dg,:),'Marker','.','LineStyle','-');
end
legend([repmat('data group ',nodg,1) num2str([1:nodg]')],2);
sliderPos=get(findobj(fig,'tag','conditionSlider'),'value');
set(gca,'xdir','reverse')
xlim([1 length(this.iteration)]);
ylim([0.90 1]);
plot([sliderPos sliderPos],ylim,'r');
ylabel('Correlation');
xlabel('Number of remaining conditions');

