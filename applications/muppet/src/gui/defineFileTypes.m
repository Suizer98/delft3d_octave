function filetypes=defineFileTypes

filetypes =  {'D3D',                   'D3D',                   'trim-*.dat;trih-*.dat;com-*.dat;wavm-*.dat;hwgxy*.dat;*.dat', 'Delft3D Output File'; ...
              'Polyline',              'Polyline',              '*.ldb;*.pol',                                                 'TEKAL Landboundary File (*.ldb,*.pol)'; ...
              'TekalVector',           'TekalVector',           '*.map;*.tek',                                                 'TEKAL Vector File (*.map)'; ...
              'TekalMap',              'TekalMap',              '*.map;*.tek',                                                 'TEKAL Map File (*.map)'; ...
              'TekalTime',             'TekalTime',             '*.tek',                                                       'TEKAL Time Series File (*.tek)'; ...
              'TekalXY',               'TekalXY',               '*.tek',                                                       'TEKAL XY File (*.tek)'; ...
              'TekalTimeStack',        'TekalTimeStack',        '*.tek',                                                       'TEKAL Time Stack File (*.tek)'; ...
%              'Mat',                   'Mat',                   '*.mat',                                                       'Matlab File (*.mat)'; ...
              'Annotation',            'Annotation',            '*.ann',                                                       'Annotation File (*.ann)'; ...
              'Kubint',                'Kubint',                '*.kub',                                                       'KUBINT File (*.kub)'; ...
              'Lint',                  'Lint',                  '*.int',                                                       'LINT File (*.int)'; ...
              'Samples',               'Samples',               '*.xyz',                                                       'Samples file (*.xyz)'; ...
              'Windrose',              'Windrose',              '*.ros',                                                       'Wind Rose (*.ros)'; ...
              'D3DWaq',                'D3D',                   '*.map;*.his;*.hda;*.ada',                                     'Delwaq file (*.map,*.his,*.hda,*.ada)'; ...
              'Bar',                   'Bar',                   '*.bar',                                                       'Bar File (*.bar)'; ...
              'TrianaA',               'TrianaA',               '*.tab;*.tba',                                                 'Triana Table A (*.tab,*.tba)'; ...
              'TrianaB',               'TrianaB',               '*.tab;*.tbb',                                                 'Triana Table B (*.tab,*.tbb)'; ...
              'XBeach',                'XBeach',                '*.dat',                                                       'X-Beach (dims.dat)'; ...
%              'UCITxyz',               'UCITxyz',               '*.mat',                                                       'UCIT xyz file (*.mat)'; ...
              'D3DMonitoring',         'D3DMonitoring',         'trih-*.dat;*.dat',                                            'Delft3D Monitoring Points'; ...
              'Unibest',               'Unibest',               '*.daf',                                                       'Unibest/Durosta file (*.daf)'; ...
              'UnibestCL',             'UnibestCL',             '*.prn',                                                       'UnibestCL file (*.prn)'; ...
              'D3DBoundaryConditions', 'D3DBoundaryConditions', '*.bct;*.bcc',                                                 'Delft3D Boundary Conditions (*.bct,*.bcc)'; ...
              'D3DGrid',               'D3DGrid',               '*.grd',                                                       'Delft3D Grid (*.grd)'; ...
              'D3DDepth',              'D3DDepth',              '*.dep',                                                       'Delft3D Depth (*.dep)'; ...
              'HIRLAM',                'HIRLAM',                '*.*',                                                         'HIRLAM File'; ...
              'D3DMeteo',              'D3DMeteo',              '*.amu;*.amv;*.amp',                                           'D3D Meteo File'; ...
              'SimonaSDS',             'SimonaSDS',             '*.*',                                                         'Simona SDS File (sds*)'; ...
              'Image',                 'Image',                 '*.jpg;*.png;*.bmp;*.tif',                                     'Image File (*.jpg,*.png,*.bmp,*.tif,*.gif)'};