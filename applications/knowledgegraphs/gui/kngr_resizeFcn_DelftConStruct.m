function kngr_resizeFcn_DelftConStruct

hlblfrmtxt = findobj('tag','lblfrmtxt');
hfrmtxt    = findobj('tag','frmtxt');
hlbltotxt  = findobj('tag','lbltotxt');
htotxt     = findobj('tag','totxt');
hlbltype   = findobj('tag','lbltype');
htype      = findobj('tag','type');
hlblin     = findobj('tag','lblin');
htxtin     = findobj('tag','txtin');
hlblout    = findobj('tag','lblout');
htxtout    = findobj('tag','txtout');

pos = kngr_getPosition(0.94, .15, 0.1,  get(gcf,'position'),10,40);
set(hlblfrmtxt,'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
pos = kngr_getPosition(0.92, .15, 0.1,  get(gcf,'position'),10,40);
set(hfrmtxt,   'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);

pos = kngr_getPosition(0.88, .15, 0.1,  get(gcf,'position'),10,40);
set(hlbltotxt, 'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
pos = kngr_getPosition(0.86, .15, 0.1,  get(gcf,'position'),10,40);
set(htotxt,    'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);

pos = kngr_getPosition(0.82, .15, 0.1,  get(gcf,'position'),10,40);
set(hlbltype,  'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
pos = kngr_getPosition(0.80, .15, 0.1,  get(gcf,'position'),10,40);
set(htype,     'Position',[pos(1) pos(2) pos(3) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);

scrsize  = get(gcf,'position');
pos = kngr_getPosition(0.01, .40, 0.2,  get(gcf,'position'),10,40);
set(hlblin ,   'Position',[pos(1)+.2*scrsize(3) pos(2)+15 pos(3) pos(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2);
set(htxtin ,   'Position',[pos(1)+.2*scrsize(3) pos(2)    pos(3) pos(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2);
set(hlblout,   'Position',[pos(1)+.6*scrsize(3) pos(2)+15 pos(3) pos(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2);
set(htxtout,   'Position',[pos(1)+.6*scrsize(3) pos(2)    pos(3) pos(4) ],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'max',2);
