function varargout = detran_prepareTransPlot(varargin)
%DERTAN_PREPARETRANSPLOT Detran function to calculate the requested transport rates
%
% This routine is part of the Detran and manages the calculation of the 
% required transport rates before plotting them. It is used by the GUI and 
% also by the command line Detran application. For the latter, input and 
% output arguments are required (see below).
%
%   Syntax:
%   [tr, trPos, trNeg] = detran_prepareTransPlot (detranData, transType, fraction);
%
%   Input:
%   detranData  Detran data structure, created by detran_importData and
%               with transect coordinates added to structure in the field 
%               'transects' as [M x 4] double with M number of transects 
%               and each transect specified as: [x1 y1 x2 y2].
%   transType   Sepcify transport type, 'bed','suspended' or 'total'.
%   fraction    Specify the fraction to use (1,2,3, etc), set to 0 for the 
%               sum of fractions
%
%   Output:
%   tr          Nett transport rate through transects
%   trPos       Positive component of gross transort rare through transects
%   trNeg       Negative component of gross transort rare through transects
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

if nargin == 0 % GUI use
    [but,fig]=gcbo;
    
    data=get(fig,'userdata');
    
    if isempty(data.input)
        return
    end
    
    transTypeVal=get(findobj(fig,'tag','detran_transType'),'Value');
    switch transTypeVal
        case 1
            transType='total';
        case 2
            transType='bed';
        case 3
            transType='suspended';
    end
    
    fraction=get(findobj(fig,'tag','detran_fraction'),'Value');
    
else % command line use
    data = varargin{1};
    transType = varargin{2};
    fraction = varargin{3};
end

avgTransData=data.input;

if isfield(avgTransData,'xcor') % then data from trim-file is used
    
    strucNames=fieldnames(avgTransData);
    for ii=1:length(strucNames)
        eval([strucNames{ii} '=avgTransData.' strucNames{ii} ';']);
    end
    
    % cater for multiple domain input
    if length(xcor)>1
        NoD = length(xcor);
        D = str2num(char(inputdlg(['Multiple domain input detected (' num2str(NoD) ' domains available), which domain do you want to use?'],'plotTransArbCrossSec',1)));
    else
        D = 1;
    end
    
    edit.xcor   	=  xcor    {D};
    edit.ycor   	=  ycor    {D};
    edit.alfa   	=  alfa    {D};
    tsu    	=  tsu     {D};
    tsv    	=  tsv     {D};
    tbu    	=  tbu     {D};
    tbv    	=  tbv     {D};
    tsuPlus	=  tsuPlus {D};
    tsuMin 	=  tsuMin  {D};
    tsvPlus	=  tsvPlus {D};
    tsvMin 	=  tsvMin  {D};
    tbuPlus	=  tbuPlus {D};
    tbuMin 	=  tbuMin  {D};
    tbvPlus	=  tbvPlus {D};
    tbvMin  =  tbvMin  {D};
    
    
    switch transType
        case 'total'
            edit.yatu = tsu + tbu;
            edit.yatv = tsv + tbv;
            edit.yatuPlus = tsuPlus + tbuPlus;
            edit.yatuMin = tsuMin + tbuMin;
            edit.yatvPlus = tsvPlus + tbvPlus;
            edit.yatvMin = tsvMin + tbvMin;
        case 'bed'
            edit.yatu = tbu;
            edit.yatv = tbv;
            edit.yatuPlus = tbuPlus;
            edit.yatuMin = tbuMin;
            edit.yatvPlus = tbvPlus;
            edit.yatvMin = tbvMin;
        case 'suspended'
            edit.yatu = tsu;
            edit.yatv = tsv;
            edit.yatuPlus = tsuPlus;
            edit.yatuMin = tsuMin;
            edit.yatvPlus = tsvPlus;
            edit.yatvMin = tsvMin;
    end
    
    if fraction<=size(edit.yatu,3) && fraction>0
        edit.yatu = edit.yatu(:,:,fraction);
        edit.yatv = edit.yatv(:,:,fraction);
        edit.yatuPlus = edit.yatuPlus(:,:,fraction);
        edit.yatuMin  = edit.yatuMin(:,:,fraction);
        edit.yatvPlus = edit.yatvPlus(:,:,fraction);
        edit.yatvMin  = edit.yatvMin(:,:,fraction);
    else
        edit.yatu = sum(edit.yatu,3);
        edit.yatv = sum(edit.yatv,3);
        edit.yatuPlus = sum(edit.yatuPlus,3);
        edit.yatuMin  = sum(edit.yatuMin,3);
        edit.yatvPlus = sum(edit.yatvPlus,3);
        edit.yatvMin  = sum(edit.yatvMin,3);
    end
    
    edit.ycor(edit.ycor==0)=nan;
    edit.xcor(edit.xcor==0)=nan;
    
    data.edit=edit;
    
    if ~isempty(data.transects)
        ldb=data.transects;
        hw=waitbar(0,'Please wait while loading transects...');
        for ii=1:size(ldb,1)
            [xt,yt]=detran_uvData2xyData(edit.yatu,edit.yatv,edit.alfa);
            [CS(ii),plusCS(ii),minCS(ii)]=detran_TransArbCSEngine(edit.xcor,edit.ycor,xt,yt,ldb(ii,1:2),ldb(ii,3:4));
            waitbar(ii/size(ldb,1),hw);
        end
        close(hw);
        data.transectData=[CS' plusCS' minCS'];
    end
    
else % data from trih-file is used
    
    % cater for multiple domain input
    if length(data.input)>1
        NoD = length(data.input);
        D = str2num(char(inputdlg(['Multiple domain input detected (' num2str(NoD) ' domains available), which domain do you want to use?'],'plotTransArbCrossSec',1)));
    else
        D = 1;
    end
    
    if fraction<=size(avgTransData{D}.total,2) && fraction>0
        CS = eval(['data.input{D}.' transType '(:,fraction);']);
    else
        CS = eval(['sum(data.input{D}.' transType ',2);']);
    end
    data.transectData = [CS repmat(0,length(CS),1) repmat(0,length(CS),1)];
end

if nargout == 0
    set(fig,'userdata',data);
else
    varargout = {data.transectData(:,1),data.transectData(:,2),data.transectData(:,3),data,edit};
end
