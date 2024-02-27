function varargout=vs_let_stats(cmd,varargin)
%VS_LET_STATS_FOU
%
%Syntax:
% stat=vs_let_stats_fou(cmd,NFStruct,GroupName,GroupIndex,ElementName,...
% ElementIndex',<keyword>,<value>); 

%mandatory settings
NFStruct=varargin{1}; 
GroupName=varargin{2}; 
GroupIndex=varargin{3}; 
ElementName=varargin{4}; 
ElementIndex=varargin{5}; 

%setting optional keywords
OPT.latitude=52.5; 
OPT.depthaveraged=false;
OPT.exceedance_level=0; 
OPT.timezone=1; 
OPT.dt=5/(24*60); 
[OPT OPTset]=setproperty(OPT,varargin(6:end)); 

%read grid
grd=vs_meshgrid2dcorcen(NFStruct); 
grd.cend.x=nan(size(grd.cen.x)+[2 2]); grd.cend.x(2:end-1,2:end-1)=grd.cen.x; 
grd.cend.y=nan(size(grd.cen.y)+[2 2]); grd.cend.y(2:end-1,2:end-1)=grd.cen.y; 
time=vs_time(NFStruct); 



%read data from Nefis file either as scalar or as vector
hWB=waitbar(0,'Reading data.');
if iscell(ElementName) & length(ElementName)==2
    %vector data
   [val{1} val{2}]=vs_let_vector_cen(NFStruct,GroupName,GroupIndex,ElementName,ElementIndex); 
else
    %scalar data
    if strcmpi(ElementName,'depth')
        val{1}=vs_let(NFStruct,GroupName,GroupIndex,'S1',ElementIndex);
        
        size1=size(val{1}); 
        dep=grd.cen.dep(ElementIndex{1}-1,ElementIndex{2}-1); 
        dep=repmat(dep,[1 1 size1(1)]); dep=permute(dep,[3 1 2]); 
        val{1}=val{1}-dep; 
        
        val{1}(isnan(val{1}) | val{1}<0)=0; 
        
    else
        val{1}=vs_let_scalar(NFStruct,GroupName,GroupIndex,ElementName,ElementIndex);
    end
end

%average over depth if selected
if OPT.depthaveraged
    for l=1:length(val)
            val{l}=sum(val{l}.*vector2grid(grd.sigma_dz,size(val{l}),4),4);
    end
end %end if

waitbar(0,hWB,'Processing data.'); 
%Read data gridpoint by gridpoint
for l=1:length(val)
   sizeVal{l}=size(val{l});
   val{l}=reshape(val{l},sizeVal{l}(1),[]); 
   
   for k3=1:size(val{l},2)
       
       %fit spline
       tInterp=[time.datenum(GroupIndex{1}(1)):OPT.dt:time.datenum(GroupIndex{1}(end))];
       valInterp=interp1(time.datenum(GroupIndex{1}),val{l}(:,k3),tInterp,'spline');
       
       if strcmpi(cmd,'residual')
           [out{l}(k3) sigma_out]=local_residual(tInterp,valInterp);
       elseif strcmpi(cmd,'exceedance')
           if ~OPTset.exceedance_level
               error('exceedance_level must be set'); 
           end
           out{l}(k3)=local_exceedance(tInterp,valInterp,OPT.exceedance_level); 
       else
           error(sprintf('%s is an unknown statistic parameter.',cmd))
       end %end if cmd

       waitbar( ((l-1)*size(val{l},2)+k3)/(length(val)*size(val{l},2)) ,hWB);
   end
   
  
end
close(hWB);
    
%reshape output
for l=1:length(out)
   sizeVal{l}(1)=1;
   out{l}=reshape(out{l},sizeVal{l}); 
end

%output
varargout=out;  

end %end function vs_let_stats_fou

function [out sigma_out]=local_residual(t,y)
%LOCAL_RESIDUAL Residual 

%tidal period
T_tide=(12*60+25)/(24*60); 

%test input
if isempty(t)
    error('Non empty time series must be specified.'); 
end
if sum(isnan(t))>0
    error('t must be a real double array.'); 
end
y(isnan(y))=0; 

%find start and end period integration
n_tide=floor(diff(t([1,end]))/T_tide); 
mod_tide=mod(diff(t([1,end]))/T_tide,1);
if n_tide<1
    error('Length time series is too short to calculate residual.'); 
end %end if n_tide

it(1)=1; it(2)=find(t >= (t(it(1))+n_tide*T_tide),1,'first'); iMeanY=1; 
while t(it(2))<t(end)
   meanY(iMeanY)=trapz(t(it(1):it(2)),y(it(1):it(2)))/diff(t([it(1),it(2)]));
   
   find1=find(t>=t(it(1))+0.1*mod_tide*T_tide,1,'first'); 
   if isempty(find1)
       find1=it(1)+1; 
   end
   it(1)=max(it(1)+1,find1 ); 
   
   find1=find(t >= (t(it(1))+n_tide*T_tide),1,'first');
   if ~isempty(find1)
       it(2)=find1;
       iMeanY=iMeanY+1; 
   else
       break; 
   end
   
end %end while

out=mean(meanY); 
if length(meanY)>1
    sigma_out=std(meanY)/sqrt(length(meanY));
else
    sigma_out=NaN; 
end

end %end local_residual

function out=local_exceedance(t,y,y_min)

y_exceed=zeros(size(y)); 
y_exceed(y>y_min)=1;
out=trapz(t,y_exceed);


end %end local_exceedance