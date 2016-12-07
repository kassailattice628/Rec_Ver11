function check_stim_lumi(~, ~)
% check stim luminace: range (0-255)

global figUIobj

stimlumi = str2double(get(figUIobj.stimlumi,'string'));
stimlumi2 = str2double(get(figUIobj.stimlumi2,'string'));
bgcol = str2double(get(figUIobj.bgcol,'string'));

if stimlumi > 255 || stimlumi < 0
    errordlg('Stim. Lumience is out of range!!');
    set(figUIobj.stimlumi,'string', 255);
end

if stimlumi2 > 255 || stimlumi2 < 0
    errordlg('Stim. Lumience is out of range!!');
    set(figUIobj.stimlumi2,'string', 255);
end

%
if bgcol > 255 || bgcol <0 %|| bgcol > stimlumi || bgcol > stimlumi2
    errordlg(' BackGround Lumience is out of range!!');
    set(figUIobj.bgcol,'string',0);
end


end