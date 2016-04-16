function sobj = sobj_ini(pixpitch)
% initialize sobj (PTB parameters)

% get monitor information
MP = get(0,'MonitorPosition'); %position matrix for malti monitors
sobj.screens = Screen('Screens');

% the number of displays connected
sobj.Num_screens = size(sobj.screens,2);

%% select stim-presentatin monitor
% Set 2nd display for stim presentation
sobj.ScrNum = max(sobj.screens);
% Set Primally monitor for stim preseintation
%sobj.ScrNum = min(sobj.screens);

% OSX, main=0, sub(stim monitor) = 1,2,...
% Windwos, main=1, sub(stim monitor) = 2,3,...

%% Set horizontal cordinate for GUI Controler
if sobj.Num_screens > 1
    if sobj.ScrNum == 0;
        sobj.GUI_Display_x = MP(3) + 1;
    else
        sobj.GUI_Display_x = 0;
    end
else %single display
    sobj.GUI_Display_x = 0;
end

%%
sobj.pixpitch = pixpitch;
sobj.MonitorDist = 300; % (mm) = distance from moniter to eye, => sobj.MonitorDist*tan(1*2*pi/360)/sobj.pixpitch (pixel/degree)
sobj.stimsz = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist, pixpitch)); % default: 1 deg
sobj.stimsz_deg_list = [0.5; 1; 3; 5; 10];

sobj.shapelist = [{'FillRect'};{'FillOval'}];
sobj.shape = 'FillOval'; % default Oval

sobj.pattern = 'Uni'; % uniform or Grating

sobj.mode = 'Random';

sobj.flipNum = 75;

sobj.divnum = 3;
% position in matrix
sobj.fixpos = 5;

sobj.black = BlackIndex(sobj.ScrNum);
sobj.white = WhiteIndex(sobj.ScrNum);
sobj.gray = round((sobj.white+sobj.black)/2);

sobj.stimlumi = sobj.white;
sobj.bgcol = sobj.black;
if sobj.gray == sobj.stimlumi
    sobj.gray = sobj.white/2;
end
sobj.stimRGB = [1,1,1]; % white
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

sobj.delayPTBflip = 20; %delay flip number
sobj.delayPTB = 0;% PTBflip * m_int

% grating_params
sobj.shiftSpd = 2; % Hz
sobj.shiftSpd_list = [0.5; 1; 2; 4; 8]; % Hz

sobj.gratFreq = 0.08; % cycle/degree
sobj.gratFreq_list = [0.01; 0.02; 0.04; 0.08; 0.16; 0.32];

sobj.shiftDir = 1; % 1~8:direction, 9: 8 random directions, 10: 4 random directions

% looming
sobj.loomingSpd_list = [5; 10; 20; 40; 80; 160];
sobj.looming_Size = 40;

%
sobj.div_zoom = 5;
sobj.dist = 15; % distance(degree) for 2nd stimulus for lateral inhibition

%Image presentation
sobj.img_i = 0;
sobj.ImageNum = 256;
sobj.list_img = 1:sobj.ImageNum;

%Mosiac dots
sobj.dots_density = 30;%


%% VS2 %%
sobj.stimsz2 = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist, pixpitch)); % default: 1 deg
sobj.shape2 = 'FillOval'; % default Oval
sobj.stimlumi2 = sobj.white;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
sobj.flipNum2 = 75;
sobj.delayPTBflip2 = 20; % delay flip number
sobj.delayPTB2 = 0; % PTBflip * m_int
%%

end
