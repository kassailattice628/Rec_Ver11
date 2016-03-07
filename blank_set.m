function blank_set
global recobj
global figUIobj

recobj.prestim = re_write(figUIobj.prestimN);
recobj.cycleNum = 0- recobj.prestim;
set(figUIobj.prestim,'string',['loops = > ',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),' sec'],'Horizontalalignment','left');
