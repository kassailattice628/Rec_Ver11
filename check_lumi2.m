function check_lumi2
global sobj
global figUIobj

if get(figUIobj.lumi,'value') == 2
    Random_luminance;
end

% stimlumi ‚ª •Ï‚È’l‚¾‚Á‚½‚ç 255 ‚ÉÝ’è
if sobj.stimlumi > 255 || sobj.stimlumi < 0
    errordlg('Stim. Lumience is out of range!!');
    sobj.stimlumi = 255;
    set(figUIobj.stimlumi,'string', 255);
end

if sobj.stimlumi2 > 255 || sobj.stimlumi2 < 0
    errordlg('Stim. Lumience is out of range!!');
    sobj.stimlumi2 = 255;
    set(figUIobj.stimlumi2,'string', 255);
end

% bgcol ‚ª •Ï‚È’l‚¾‚Á‚½‚ç 0 ‚ÉÝ’è
if sobj.bgcol > 255 || sobj.bgcol <0
    errordlg(' BackGround Lumience is out of range!!');
    sobj.bgcol = 0;
    set(figUIobj.bgcol,'string',0);
end

sobj.stimcol = sobj.stimlumi * sobj.stimRGB;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;