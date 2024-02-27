function optiGUI_conditionSlider(but,fig);

if nargin==0
    [but,fig]=gcbo;
end

this=get(fig,'userdata');
sliderValue=round(get(but,'value'));
hLines=findobj(fig,'type','line','color','r');

for ii=1:length(hLines);
   set(hLines(ii),'XData',[sliderValue sliderValue]);
end

set(findobj(fig,'tag','condBox'),'string',[repmat('Condition ',sliderValue,1)... 
   num2str(this.iteration(length(this.iteration)-sliderValue+1).conditions','%3.3i')... 
   repmat(' ,weight: ',sliderValue,1)...
   num2str(this.iteration(length(this.iteration)-sliderValue+1).weights(this.iteration(length(this.iteration)-sliderValue+1).weights~=0)','%4.4f')]);

set(findobj(fig,'tag','numOfCond'),'string',num2str(sliderValue));
set(findobj(fig,'tag','sumOfWeights'),'string',num2str(sum(this.iteration(length(this.iteration)-sliderValue+1).weights),'%4.4f'));
set(findobj(fig,'tag','rmsValue'),'string',[num2str(100.*this.iteration(length(this.iteration)-sliderValue+1).rmsRelWeighted,'%4.2f') '%']);
noIt=this.iteration(length(this.iteration)-sliderValue+1).iteration;
corr=this.iteration(length(this.iteration)-sliderValue+1).corr(:,noIt);
set(findobj(fig,'tag','corrValue'),'string',[repmat('data group ',length(corr),1) num2str([1:length(corr)]') repmat(': ',length(corr),1) num2str(corr,'%3.3f')]);
