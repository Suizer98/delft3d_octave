function ploStruct = delft3d_part_open_plo(FileName)
%DELFT3D_PART_OPEN_PLO   Open Delft3D-PART *.plo file into struct
%
%    Struct=delft3d_part_open_plo(FileName)
%
%    opens the specified PART plo file and loads the information
%    into a structure.
%
%    The data included in the file can be accessed as any
%    DELWAQ HIS/MAP file by using routine DELWAQ.
%    [Time,Data]=DELWAQ('read',Struct,Substance,Segment,TStep)
%
% See also: DELWAQ

% Version 1.0 October 2008
%
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Y. Friocourt
%
%       yann.friocourt@deltares.nl
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%   --------------------------------------------------------------------

% $Id: delft3d_part_open_plo.m 2390 2010-03-30 16:19:59Z boer_g $
% $Date: 2010-03-31 00:19:59 +0800 (Wed, 31 Mar 2010) $
% $Author: boer_g $
% $Revision: 2390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/part/delft3d_part_open_plo.m $

% open file with regular delwaq routine
ploStruct = delwaq('open', FileName);

% add grid information (dimension, origin, and coordinates)
ploStruct.MNK = [ploStruct.GridSize(1), ploStruct.GridSize(2), ploStruct.K];
ploStruct.XY0 = [ploStruct.PlotWindow(1), ploStruct.PlotWindow(3)];
ploStruct.XY1 = [ploStruct.PlotWindow(2), ploStruct.PlotWindow(4)];
ploStruct.X   = zeros(ploStruct.MNK(1), ploStruct.MNK(2));
ploStruct.Y   = zeros(ploStruct.MNK(1), ploStruct.MNK(2));
X             = zeros(ploStruct.MNK(1), ploStruct.MNK(2));
Y             = zeros(ploStruct.MNK(1), ploStruct.MNK(2));
for j = 1:ploStruct.MNK(2)
    X(:,j) = ploStruct.XY0(1) + ...
        (ploStruct.XY1(1)-ploStruct.XY0(1))*[0:ploStruct.MNK(1)-1]/(ploStruct.MNK(1)-1);
end
for i = 1:ploStruct.MNK(1)
    Y(i,:) = ploStruct.XY0(2) + ...
        (ploStruct.XY1(2)-ploStruct.XY0(2))*[0:ploStruct.MNK(2)-1]/(ploStruct.MNK(2)-1);
end
ploStruct.X = X';
ploStruct.Y = Y';

return;
end
