function sobj = sobj_ini(i,pixpitch)
% initialize sobj (PTB parameters)

%scrsz=get(0,'ScreenSize');
MP = get(0,'MonitorPosition');%position matrix for malti monitors
screens = Screen('Screens');
sobj.ScrNum = max(screens);% 0: main, 1,2,...: sub(stim monitorj, !!Windwos, 1:main,2....sub
if sobj.ScrNum == 0
    sNum = sobj.ScrNum+1;
else
    sNum = sobj.ScrNum;
end

if i == 2 %Test Mac
    sobj.ScreenSize = [MP(sNum,3)-MP(sNum,1)+1, MP(sNum,4)-MP(sNum,2)+1];%monitor size of stim monitor
elseif i == 1
    sobj.ScreenSize = [MP(sNum,3),MP(sNum,4)];%for Windows8
end

sobj.pixpitch = pixpitch;
sobj.MonitorDist = 300;%(mm) = distance from moniter to eye, => sobj.MonitorDist*tan(1*2*pi/360)/sobj.pixpitch (pixel/degree)
sobj.stimsz = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist, pixpitch));% default: 1 deg
sobj.shapelist = [{'FillRect'};{'FillOval'}];
sobj.shape = 'FillOval'; % default Oval
sobj.pattern = 'Uni'; %uniform or Grating
sobj.mode = 'Random';
%sobj.filter = 1; % 1: None, 2: Gabor patch
sobj.div_zoom = 5;
sobj.flipNum = 75;
sobj.divnum = 2;
sobj.black = BlackIndex(sobj.ScrNum);
sobj.white = WhiteIndex(sobj.ScrNum);
sobj.gray = round((sobj.white+sobj.black)/2);
sobj.stimlumi = sobj.white;
sobj.bgcol = sobj.black;
if sobj.gray == sobj.stimlumi
    sobj.gray = sobj.white/2;
end
sobj.delayPTBflip = 20; %delay flip number
sobj.delayPTB = 0;% PTBflip * m_int
sobj.stimRGB = [1,1,1];
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

%% %VS2%%%%
sobj.stimsz2 = round(ones(1,2)*Deg2Pix(1,sobj.MonitorDist, pixpitch));% default: 1 deg
sobj.shape2 = 'FillOval'; % default Oval
sobj.stimlumi2 = sobj.white;
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;
sobj.flipNum2 = 75;
sobj.delayPTBflip2 = 20; %delay flip number
sobj.delayPTB2 = 0;% PTBflip * m_int

%%
sobj.tPTBon=0;
sobj.tPTBoff=0;
sobj.tPTBon2=0;
sobj.tPTBoff2=0;

sobj.fixpos = 1;

sobj.shiftSpd = 2;%Hz
sobj.shiftSpd_list = [0.5; 1; 2; 4; 8];%Hz

sobj.gratFreq = 0.08;% cycle/degree
sobj.gratFreq_list = [0.01;0.02;0.04;0.08;0.16;0.32];

sobj.shiftDir = 1;%1~8:direction, 9: 8 random directions, 10: 4 random directions
sobj.angle = 0;%savedata—p
sobj.angle_deg = linspace(0, 315,8);
sobj.angle16_deg = linspace(0,337.5,16);

sobj.dist = 15; %distance(degree) for 2nd stimulus for lateral inhibition

sobj.position = 0;
sobj.position_cord = zeros(1,4);
sobj.position_cord2 = zeros(1,4);
sobj.stim2_center = zeros(1,2);
sobj.dist_pix = 0;

%Zoom and Fine mapping
sobj.zoom_dist = 0;
sobj.zoom_ang = 0;

%Image presentation
sobj.img_i = 0;
sobj.ImageNum = 256;
sobj.list_img = 1:sobj.ImageNum;


end