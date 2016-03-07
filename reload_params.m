function reload_params(~, ~, varargin)
% reload all paraemter and settings if changes from GUI

%%
global figUIobj
global sobj
global recobj

%% visual stimulus settings %%
% general %
sobj.MonitorDist = re_write(figUIobj.MonitorDist);
sobj.div_zoom = rewrite(figUIobj.div_zoom);
sobj.dist = rewrite(figUIobj.dist);
sobj.bgcol = re_write(figUIobj.bgcol);
sobj.divnum = get(figUIobj.divnum, 'value');
sobj.divnum = re_write(figUIobj.divnum);
sobj.fixpos = re_write(figUIobj.fixpos);

%%%%% stim 1 %%%%%
sobj.shape = sobj.shapelist{get(figUIobj.shape2, 'value'), 1};
sobj.stimlumi = re_write(figUIobj.stimlumi);
sobj.flipNum = re_write(figUIobj.flipNum);
sobj.delayPTBflip = re_write(figUIobj.delayPTBflip);
sobj.stimsz = stim_size(sobj.MonitorDist,figUIobj.size);

sobj.shiftDir = get(figUIobj.shiftDir,'value');
sobj.shiftSpd2 = sobj.shiftSpd_list(get(figUIobj.shiftSpd,'value'));
sobj.gratFreq2 = sobj.gratFreq_list(get(figUIobj.gratFreq, 'value'));
sobj.ImageNum = re_write(figUIobj.ImageNum);

%%%%% stim 2 %%%%%
sobj.shape2 = sobj.shapelist{get(figUIobj.shape2, 'value'), 1};
sobj.stimlumi2 = re_write(figUIobj.stimlumi2);
sobj.flipNum2 = re_write(figUIobj.flipNum2);
sobj.delayPTBflip2 = re_write(figUIobj.delayPTBflip2);
sobj.stimsz2 = stim_size(sobj.MonitorDist,figUIobj.size2);

%% Recording %%
recobj.sampf = str2double(get(figUIobj.sampf,'string'))*1000;
recobj.rect = re_write(figUIobj.rect);
recobj.interval = re_write(figUIobj.interval);

recobj.delayTTL2 = re_write(figUIobj.delayTTL2);

recobj.plot = get(figUIobj.plot, 'value')+1;
recobj.yaxis = get(figUIobj.yaxis,'value');
recobj.yrange(1) = re_write(figUIobj.VYmin);
recobj.yrange(2) = re_write(figUIobj.VYmax);
recobj.yrange(3) = re_write(figUIobj.CYmin);
recobj.yrange(4) = re_write(figUIobj.CYmax);
recobj.pulseDuration = re_write(figUIobj.pulseDuration);
recobj.pulseDelay = re_write(figUIobj.pulseDelay);
recobj.pulseAmp = re_write(figUIobj.pulseAmp);

end

function y = re_write(h)
y = str2double(get(h,'string'));
end

function size = stim_size(dist,h)
size = round(ones(1,2)*Deg2Pix(str2double(get(h,'string')), dist));
end