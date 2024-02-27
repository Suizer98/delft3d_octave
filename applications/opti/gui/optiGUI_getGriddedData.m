function data=optiGUI_getGriddedData(this,sliderValue,dg);

switch this.input(dg).dataType
    case 'sedero'
        if ~isempty(this.input(dg).dataPolygon)
            coord=this.input(dg).origCoord;
            [dum,ib]=ismember(this.input(dg).coord,this.input(dg).origCoord,'rows');
            data=repmat(nan,size(coord,1),1);
            if ~isempty(sliderValue)
                data(ib)=this.input(dg).data*this.iteration(length(this.iteration)-sliderValue+1).weights';
            else
                data(ib)=this.input(dg).target;
            end
        else
            coord=this.input(dg).coord;
            data=this.input(dg).data*this.iteration(length(this.iteration)-sliderValue+1).weights';
        end
        coord(find(ismember(coord,[0 0],'rows')),1)=nan;
        coord(find(ismember(coord,[0 0],'rows')),2)=nan;     
        mn=this.input(dg).dataGridInfo;
        xCor=reshape(coord(:,1),mn);
        yCor=reshape(coord(:,2),mn);
        val=reshape(data,mn);
        xComp=[];
        yComp=[];
        XUnits='m';
        YUnits='m';        
        Time=now;
        Name='cum. erosion/sedimentation';
        Units='m';
    case 'transport'		    
        if isempty(this.input(dg).dataTransect)
            if ~isempty(this.input(dg).dataPolygon)
                coord=this.input(dg).origCoord;
                [dum,ib]=ismember(this.input(dg).coord,this.input(dg).origCoord,'rows');
                dataX=repmat(nan,size(coord,1),1);
                dataY=repmat(nan,size(coord,1),1);                    
                lengthData=length(ib);
                if ~isempty(sliderValue)
                    dataX(ib)=this.input(dg).data(1:lengthData,:)*this.iteration(length(this.iteration)-sliderValue+1).weights';
                    dataY(ib)=this.input(dg).data(1+lengthData:end,:)*this.iteration(length(this.iteration)-sliderValue+1).weights';                    
                else
                    dataX(ib)=this.input(dg).target(1:lengthData,:);
                    dataY(ib)=this.input(dg).target(1+lengthData:end,:); 
                end
                
            else
                coord=this.input(dg).coord;
                lengthData=size(coord,1);
                if ~isempty(sliderValue)
                    dataX=this.input(dg).data(1:lengthData,:)*this.iteration(length(this.iteration)-sliderValue+1).weights';
                    dataY=this.input(dg).data(1+lengthData:end,:)*this.iteration(length(this.iteration)-sliderValue+1).weights';                    
                else
                    dataX=this.input(dg).target(1:lengthData,:);
                    dataY=this.input(dg).target(1+lengthData:end,:);
                end
            end
            coord(find(ismember(coord,[0 0],'rows')),1)=nan;
            coord(find(ismember(coord,[0 0],'rows')),2)=nan;
            transMagData=sqrt(dataX.^2+dataY.^2);
            mn=this.input(dg).dataGridInfo;
            xCor=reshape(coord(:,1),mn);
            yCor=reshape(coord(:,2),mn);
            val=reshape(transMagData,mn);
            xComp=reshape(dataX,mn);
            yComp=reshape(dataY,mn);
            XUnits='m';
            YUnits='m';        
            Time=now;
            Name=this.input(dg).transParameter;
            Units='m^3/s/m';
        else
            transects=this.input(dg).dataTransect;
            if ~isempty(sliderValue)
%                 transData=optiComputeResultingCrossTransectTransport(this,dg,length(this.iteration)-sliderValue+1);
                transData=this.input(dg).data*this.iteration(length(this.iteration)-sliderValue+1).weights';transData(:,2)=transData; % workaround for 2nd column
            else
%                 transData=optiComputeCrossTransectTransport(this,dg);
                transData=this.input(dg).target;transData(:,2)=transData; % workaround for 2nd column
            end
            alfaline=atan2(squeeze(diff([transects(1,2,:) transects(2,2,:)])),squeeze(diff([transects(1,1,:) transects(2,1,:)])));
            alfaline(alfaline<0)=alfaline(alfaline<0)+2*pi; 
            xCor=[squeeze(transects(1,1,:)) squeeze(transects(2,1,:))];
            yCor=[squeeze(transects(1,2,:)) squeeze(transects(2,2,:))];
            xComp=cos(0.5*pi+alfaline).*transData(:,2);
            yComp=sin(0.5*pi+alfaline).*transData(:,2);
            val=transData(:,2);
            XUnits='m';
            YUnits='m';        
            Time=now;
            Name=this.input(dg).transParameter;
            Units='m^3/year';            
        end
end
data=struct('X',xCor,'Y',yCor,'XComp',xComp,'YComp',yComp,'Val',val,'XUnits',XUnits,'YUnits',YUnits,'Time',Time,'Name',Name,'Units',Units);