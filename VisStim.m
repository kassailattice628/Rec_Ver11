function VisStim(mode)

global recobj
global sobj

%Set stim position
if recobj.cycleNum <= 0 %prestimulus
    i = 1;
    sobj.position = 0;
elseif mode == 1 || mode == 3 %Random or Order
    i = rem(recobj.cycleNum, sobj.divnum^2);
    if i == 0
        i = sobj.divnum^2;
    end
elseif fmode == 2 %Fixed position
    i = 1;
end

%Luminance Random
if get(figUIobj.lumi, 'value') == 2 %Random Lumi
    %Random_luminace;
    %sobj.stimlumi = sobj.stimlumi_rand;
end

%% stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if recobj.cycleNum > 0 %Stimulus ON
    if i == 1 %reset, random position
        ch_position;
    end
    sobj.position = sobj.poslist(i);
    
    disp('sobj.pattern')
    switch sobj.pattern
        case 'Uni'
        case 'BW'
        case {'Sin', 'Rect', 'Gabor'}
        case {'Size_rand'}
        case 'Zoom'
        case '2stim'
        case 'Image'
    end
else %prestimulus
    disp('prestim')
    %Uni_stim_BG(i, sobj, bgcol);
end

