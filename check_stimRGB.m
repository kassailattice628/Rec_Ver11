function check_stimRGB
global sobj
global figUIobj

% [{'BW'},{'Blu'},{'Gre'},{'Yel'},{'Red'}];
switch get(figUIobj.stimRGB,'value')
    case 1
        sobj.stimRGB = [1,1,1];
    case 2
        sobj.stimRGB = [0,0,1];
    case 3
        sobj.stimRGB = [0,1,0];
    case 4
        sobj.stimRGB = [1,1,0];
    case 5
        sobj.stimRGB = [1,0,0];
end

sobj.stimcol = sobj.stimlumi * sobj.stimRGB;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
