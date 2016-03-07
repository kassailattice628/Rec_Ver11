function Random_luminance
% Random_luminace
% Use Michelson contrast:(L_max - L_min)/(L_max + L_min)
%L_max = sobj.stimlumi;
%L_min = sobj.bgcol;

global sobj
global recobj
global figUIobj
m = 1:5;
% make test luminance list
if recobj.cycleNum == 0- recobj.prestim
    stimlumi = str2double(get(figUIobj.stimlumi,'string'));
    bgcol = str2double(get(figUIobj.bgcol,'string'));
    sobj.Lumi_list = round((stimlumi - bgcol)/length(m))*m + bgcol;
end

sobj.i_luminace = m;

% re-randomize in every loop
if recobj.cycleNum >= 0
    k = rem(recobj.cycleNum, length(m));
else
    k = length(m);
end

if k == 0
    k = length(m);
elseif k == 1
    sobj.i_luminace = randperm(length(m));
end
sobj.stimlumi_rand = sobj.Lumi_list(sobj.i_luminace(k));
