function cm = detran_makeSedconcColMap;
%DETRAN_MAKESEDCONCCOLMAP Create sediment concentration colormap
%
% The routine creates a variable with the sediment concentration colormap data.
%
%   Syntax:
%   cm = detran_makeSedconcColMap
%
%   See also detran, colormap

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




cm=[1.0000    1.0000    1.0000
    0.9937    0.9945    0.9571
    0.9875    0.9890    0.9141
    0.9812    0.9835    0.8712
    0.9749    0.9780    0.8282
    0.9686    0.9725    0.7853
    0.9624    0.9671    0.7424
    0.9561    0.9616    0.6994
    0.9498    0.9561    0.6565
    0.9435    0.9506    0.6135
    0.9373    0.9451    0.5706
    0.9310    0.9396    0.5276
    0.9247    0.9341    0.4847
    0.9184    0.9286    0.4418
    0.9122    0.9231    0.3988
    0.9059    0.9176    0.3559
    0.8996    0.9122    0.3129
    0.8933    0.9067    0.2700
    0.8871    0.9012    0.2271
    0.8808    0.8957    0.1841
    0.8745    0.8902    0.1412
    0.8648    0.8796    0.1415
    0.8550    0.8690    0.1417
    0.8452    0.8585    0.1420
    0.8355    0.8479    0.1423
    0.8257    0.8373    0.1425
    0.8160    0.8267    0.1428
    0.8062    0.8161    0.1431
    0.7964    0.8056    0.1434
    0.7867    0.7950    0.1436
    0.7769    0.7844    0.1439
    0.7672    0.7738    0.1442
    0.7574    0.7632    0.1445
    0.7477    0.7527    0.1447
    0.7379    0.7421    0.1450
    0.7281    0.7315    0.1453
    0.7184    0.7209    0.1456
    0.7086    0.7104    0.1458
    0.6989    0.6998    0.1461
    0.6891    0.6892    0.1464
    0.6793    0.6786    0.1466
    0.6696    0.6680    0.1469
    0.6598    0.6575    0.1472
    0.6501    0.6469    0.1475
    0.6403    0.6363    0.1477
    0.6306    0.6257    0.1480
    0.6208    0.6151    0.1483
    0.6110    0.6046    0.1486
    0.6013    0.5940    0.1488
    0.5915    0.5834    0.1491
    0.5818    0.5728    0.1494
    0.5720    0.5622    0.1497
    0.5622    0.5517    0.1499
    0.5525    0.5411    0.1502
    0.5427    0.5305    0.1505
    0.5330    0.5199    0.1508
    0.5232    0.5093    0.1510
    0.5135    0.4988    0.1513
    0.5037    0.4882    0.1516
    0.4939    0.4776    0.1518
    0.4842    0.4670    0.1521
    0.4744    0.4565    0.1524
    0.4647    0.4459    0.1527
    0.4549    0.4353    0.1529];