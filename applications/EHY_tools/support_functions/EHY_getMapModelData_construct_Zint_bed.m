% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17274 $
%$Date: 2021-05-08 03:40:31 +0800 (Sat, 08 May 2021) $
%$Author: chavarri $
%$Id: EHY_getMapModelData_construct_Zint_bed.m 17274 2021-05-07 19:40:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/EHY_tools/support_functions/EHY_getMapModelData_construct_Zint_bed.m $
%
%Compute the elevation of the interface of the substrate layers. 

function [Zint_bed,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed(inputFile,modelType,OPT)
        
%data is stored at different indices in thlyr and lyrfrac. We arrange everything in [time,face,bed_layer,sediment];
OPT_thlyr=OPT;
OPT_thlyr.varName='mesh2d_thlyr';
[~,dimsInd_thlyr,~] = EHY_getDimsInfo(inputFile,OPT_thlyr,modelType);

OPT_bl=OPT;
OPT_bl.varName='mesh2d_mor_bl';
[~,dimsInd_bl,~] = EHY_getDimsInfo(inputFile,OPT_bl,modelType);

Data_thlyr = EHY_getMapModelData(inputFile,OPT(:),'varName','mesh2d_thlyr');
Data_bl = EHY_getMapModelData(inputFile,OPT(:),'varName','mesh2d_mor_bl');

Data_thlyr.val  =permute(  Data_thlyr.val,[dimsInd_thlyr.time,dimsInd_thlyr.faces,dimsInd_thlyr.bed_layers]);
Data_bl.val     =permute(     Data_bl.val,[   dimsInd_bl.time,   dimsInd_bl.faces]);

%dims has the dimensions of a single partition, but I want all of the faces
[no_times,no_faces,no_bed_layers]=size(Data_thlyr.val);        
eta_subs=cumsum(Data_thlyr.val,dimsInd_thlyr.bed_layers); %distance from the bed to the bottom part of each underlayer
Zint_bed=repmat(Data_bl.val,1,1,no_bed_layers+1)-cat(3,zeros(no_times,no_faces),eta_subs); %[time,face,bed_layer]