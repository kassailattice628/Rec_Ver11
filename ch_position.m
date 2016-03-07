function ch_position(~, ~, hGui)

global figUIobj
global sobj
%%
fmode = get(hGui.mode,'value');
sizeX = sobj.ScreenSize(1)/sobj.divnum;
sizeY = sobj.ScreenSize(2)/sobj.divnum;
%•ªŠ„‰æ–Ê‚Å‚ÌŽhŒƒ‚Ì’†S
sobj.pos = floor([sizeX/2:sizeX:(sobj.ScreenSize(1)-sizeX/2);sizeY/2:sizeY:(sobj.ScreenSize(2)-sizeY/2)]);
stimset=1:sobj.divnum^2;
stimset_mat = reshape(stimset,sobj.divnum,sobj.divnum);
stimset_x = zeros(1,sobj.divnum^2);
stimset_y = stimset_x;

if fmode ==1 %random position
    set(figUIobj.fixpos,'BackGroundColor','w');
    %randamize
    stimset_rand = randperm(sobj.divnum^2);
    sobj.poslist = stimset_rand;
    
    for m = 1:length(stimset_rand)
        [stimset_x(m),stimset_y(m)] = find(stimset_mat== stimset_rand(m));
    end
    sobj.X = stimset_x;
    sobj.Y = stimset_y;
    
elseif  fmode ==2 %fixed position
    set(figUIobj.fixpos,'BackGroundColor','g');
    %%%% position error %%%%
    if sobj.fixpos > sobj.divnum^2
        errordlg(['Fixed Pos. must be lower than the ' num2str(sobj.divnum) '^2 (= ' num2str(sobj.divnum^2) '). !!']);
        sobj.fixpos = 1;
        set(figUIobj.fixpos,'string',num2str(sobj.fixpos));
        %
    else
        [sobj.X, sobj.Y] = find(stimset_mat == sobj.fixpos);
    end
    %%%%%%%%%%%%%%%%
    sobj.poslist = sobj.fixpos;
    
    
elseif fmode==3% oredered
    set(figUIobj.fixpos, 'BackGroundColor','w');
    sobj.poslist = stimset;
    for m = 1:length(stimset)
        [stimset_x(m),stimset_y(m)] = find(stimset_mat== stimset(m));
    end
    sobj.X = stimset_x;
    sobj.Y = stimset_y;
end
