function this = optiStruct

% OPTI - 'Constructor' for opti-structure
%
% DO NOT EDIT/HACK YOUR SPECIFIC SETTINGS INTO THIS FILE!
% USE AS optiStruct=optiStruct;  AND MODIFY THE SETTINGS IN A SEPARATE,
% PROJECT SPECIFIC SCRIPT.
%

this.input.inputType=[];
this.input.trimTimeStep=[];
this.input.dataType='';
this.input.transParameter='';
this.input.transportMode='nett';
this.input.dataFileRoot ='';
this.input.dataDirPrefix= 'merge';
this.input.dataFilePrefix= '';
this.input.dataGridInfo= []; %If gridded data is loaded, the [M N] size is stored

this.input.dataSedimentFraction=[1]; %Specify fraction to use (for transports). As subfield 1:N for N fractions. Subfield N+1 is the sum of all fractions.
this.input.dataTransect=[]; %Specify transects with a LDB with 2-point lines separated by 999.999 by means of optiReadTransects  
                      %Stored as [2x2xN] = [xstart ystart N; xend yend N]
this.input.dataPolygon=[]; %Specify polygon with a POL-file with sections separated by 999.999 by means of optiReadPolygon  
                      %Stored as [MxN] with M x-coordinates and N y-coordinates and sections seperated by [nan nan]
this.input.coords=[]; %[Mx2] array with x- and y-coordinates
this.input.target = []; %[Nx1] 'year averaged' target conditions to meet with as few as possible conditions (associated weight factors) from this.data
this.input.data = []; %[NxM] array with N datapoints (transects, crosssections, gridcells, whatever) and M (initial) conditions

this.weights = []; %[1xM] array with M weight factors
this.dataGroupWeights=1;

this.optiSettings.maxIter = 500;
this.optiSettings.method = 'smarterOpti';
this.optiSettings.transectInterpMethod = 'optiArbcross';
this.optiSettings.scaleTol=1;
%this.optiSettings.randCondMax=3;

%this.iteration([1xM]) information for each of the M situations/iterations,
%in which one condition is dropped each time
this.iteration.conditions=[]; %remaining conditions from original list
this.iteration.weights=[];    %associated weights


