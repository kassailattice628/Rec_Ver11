function reload_params(~, ~, Testmode)
% reload all paraemter and settings if changes from GUI
global figUIobj
global plotUIobj
global sobj
global recobj
global s
global capture
global lh
global dio
global DataSave
global ParamsSave
%% visual stimulus settings %%
% general %
sobj.MonitorDist = re_write(figUIobj.MonitorDist);
sobj.div_zoom = re_write(figUIobj.div_zoom);
sobj.dist = re_write(figUIobj.dist);
sobj.bgcol = re_write(figUIobj.bgcol);

sobj.divnum = re_write(figUIobj.divnum);
set(figUIobj.divnumN, 'string', ['(=> ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)']);

sobj.center_pos_list = get_stim_center_mat;

sobj.fixpos = re_write(figUIobj.fixpos);
set(figUIobj.fixposN,'string',['(<= ' num2str(sobj.divnum) ' x ' num2str(sobj.divnum) ' Matrix)']);

recobj.prestim = re_write(figUIobj.prestimN);
recobj.cycleNum = 0- recobj.prestim;
set(figUIobj.prestim,'string',['loops = > ',num2str(recobj.prestim * (recobj.rect/1000 + recobj.interval)),' sec'],'Horizontalalignment','left');

%% %%% stim 1 %%%%%
modelist = get(figUIobj.mode,'string'); % {'Random', 'Fix_Rep', 'Ordered'};
sobj.mode = modelist{get(figUIobj.mode,'value')};

pattern_list = get(figUIobj.pattern,'string');
sobj.pattern = pattern_list{get(figUIobj.pattern,'value'),1};
switch sobj.pattern
    case {'B/W', 'Gabor'}
    sobj.bgcol = sobj.gray;
end

sobj.shape = sobj.shapelist{get(figUIobj.shape, 'value'), 1};

sobj.stimlumi = re_write(figUIobj.stimlumi);
sobj.stimcol = sobj.stimlumi * sobj.stimRGB;

sobj.stimlumi_list = linspace(sobj.bgcol, sobj.stimlumi, 5)';

sobj.flipNum = re_write(figUIobj.flipNum);
sobj.duration = sobj.flipNum*sobj.m_int;

sobj.delayPTBflip = re_write(figUIobj.delayPTBflip);
sobj.delayPTB = sobj.delayPTBflip*sobj.m_int;

stimsz_deg_list = [0.5; 1; 3; 5; 10];
sobj.size_pix_list = repmat(round(Deg2Pix(stimsz_deg_list, sobj.MonitorDist, sobj.pixpitch)),1,2);

if get(figUIobj.auto_size,'value')==1
    %set(figUIobj.auto_size,'value',0,'string','Auto OFF')
else
    sobj.stimsz = stim_size(sobj.MonitorDist, figUIobj.size, sobj.pixpitch);
end

sobj.shiftDir = get(figUIobj.shiftDir,'value');
sobj.shiftSpd = sobj.shiftSpd_list(get(figUIobj.shiftSpd,'value'));
sobj.gratFreq = sobj.gratFreq_list(get(figUIobj.gratFreq, 'value'));
sobj.ImageNum = re_write(figUIobj.ImageNum);

%% chekc_concentric_position (Max distance = sobj.dist, number of division = sobj.div_zoom)
sobj.concentric_dist_deg_list = sobj.dist/sobj.div_zoom:(sobj.dist/sobj.div_zoom):sobj.dist;
conc_dist_pix_list = Deg2Pix(sobj.concentric_dist_deg_list, sobj.MonitorDist, sobj.pixpitch);

if get(figUIobj.shiftDir, 'value') < 9
    % when angle is fixed
    prep_mat = [[0,1:sobj.div_zoom]; [0, get(figUIobj.shiftDir, 'value')*ones(1, sobj.div_zoom)]];
    deg_list = linspace(0, 315, 8);
    sobj.concentric_angle_deg_list = deg_list(get(figUIobj.shiftDir, 'value'));
    conc_angle_rad_list = linspace(0, 2*pi- 2*pi/8, 8);
    num_directions = get(figUIobj.shiftDir, 'value');
else
    if get(figUIobj.shiftDir, 'value') < 11
        % when angle is random or ordered
        num_directions = 8;
    else
        num_directions = 16;
    end
    % 8 or 16 directions and center (: +1)
    prep_mat = zeros(2,sobj.div_zoom*num_directions + 1);
    for i_div = 1:sobj.div_zoom
        prep_mat(1,num_directions*(i_div-1)+2:num_directions*i_div+1) = i_div*ones(1,num_directions);
    end
    prep_mat(2,:) = [0,repmat(1:num_directions, 1,sobj.div_zoom)];
    sobj.concentric_angle_deg_list = 0: 360/num_directions: 360-360/num_directions;
    conc_angle_rad_list = 0: 2*pi/num_directions: 2*pi-2*pi/num_directions;
end

%% for BW:Black/White concentric mapping (position + color)
%1st: distance, 2nd: direction, 3rd: 1=white, 2=black
sobj.concentric_mat = ones(size(prep_mat,2)*2, 3);
sobj.concentric_mat(:, 1:2) = repmat(prep_mat', 2, 1);
sobj.concentric_mat(1+size(sobj.concentric_mat,1)/2:end, 3) = 2;
for n = 1:sobj.div_zoom
    %distance in pixel length
    sobj.concentric_mat(sobj.concentric_mat(:,1)==n, 1) = conc_dist_pix_list(n);
end
for n = 1:num_directions
    sobj.concentric_mat(sobj.concentric_mat(:,2)==n, 2) = conc_angle_rad_list(n);
end

%% Select Image Set
sobj.img_list = randperm(256);
sobj.img_sublist = sobj.img_list(1:sobj.ImageNum)';

%% %%% stim 2 %%%%%
sobj.shape2 = sobj.shapelist{get(figUIobj.shape2, 'value'), 1};
sobj.stimlumi2 = re_write(figUIobj.stimlumi2);
sobj.stimcol2 = sobj.stimlumi2 * sobj.stimRGB;

sobj.flipNum2 = re_write(figUIobj.flipNum2);
sobj.duration2 = sobj.flipNum2*sobj.m_int;

sobj.delayPTBflip2 = re_write(figUIobj.delayPTBflip2);
sobj.delayPTB2 = sobj.delayPTBflip2*sobj.m_int;

sobj.stimsz2 = stim_size(sobj.MonitorDist,figUIobj.size2, sobj.pixpitch);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% NIDAQ Recording %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

recobj.interval = re_write(figUIobj.interval);
recobj.sampf = str2double(get(figUIobj.sampf,'string'))*1000;


recobj.recp = recobj.sampf*recobj.rect/1000;

recobj.pulseDuration = re_write(figUIobj.pulseDuration);
recobj.pulseDelay = re_write(figUIobj.pulseDelay);
recobj.pulseAmp = re_write(figUIobj.pulseAmp);

recobj.stepCV(1,1) = re_write(figUIobj.Cstart);
recobj.stepCV(1,2) = re_write(figUIobj.Cend);
recobj.stepCV(1,3) = re_write(figUIobj.Cstep);
recobj.stepCV(2,1) = re_write(figUIobj.Vstart);
recobj.stepCV(2,2) = re_write(figUIobj.Vend);
recobj.stepCV(2,3) = re_write(figUIobj.Vstep);

plotnum = get(figUIobj.plot, 'value')+1;
recobj.stepAmp = recobj.stepCV(plotnum,1):recobj.stepCV(plotnum,3):recobj.stepCV(plotnum,2);

% TTL
recobj.durationTTL3 = re_write(figUIobj.durationTTL3);
recobj.delayTTL3 = re_write(figUIobj.delayTTL3);

%% DAQ
if Testmode == 0
    % DAQ sessions are not defined in the TEST-mode
    if s.IsRunning
        s.stop;
        disp('stop s')
    end
    
    s.Rate = recobj.sampf;
    %s.DurationInSeconds = recobj.rect/1000;%sec, when AO channel is set, s.DurationInSeconds is replaced with 's.scansqued/s.rate'.
    
    % data capture settings
    % Specify triggered capture timespan, in seconds
    capture.TimeSpan = recobj.rect/1000;% sec
    
    % Specify continuous data plot timespan
    capture.plotTimeSpan = 2; %sec
    
    % Determine the timespan corresponding to the block of samples supplied
    % to the DataAvailable event callback function.
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    
    % Determine required buffer timespan, seconds
    capture.bufferTimeSpan = max([capture.TimeSpan * 3, callbackTimeSpan * 3]);
    
    % Determine data buffer size
    capture.bufferSize =  round(capture.bufferTimeSpan * s.Rate);
    
    delete(lh)% <-- important!!!
    DataSave =[]; %reset save data
    ParamsSave =[]; % reset save parameters
    lh = addlistener(s, 'DataAvailable', @(src,event) dataCaptureNBA(src, event, capture, figUIobj, get(figUIobj.plot,'value')));
    
    % dio reset
    outputSingleScan(dio.TrigAIFV,[0,0])
    outputSingleScan(dio.VSon,0)
    outputSingleScan(dio.TTL3,0)
    disp('reset s, dio, EventListener')
end
%% figures
if isfield(plotUIobj, 'plot')
    switch get(figUIobj.plot, 'value') %V-plot or I-plot
        case 0
            col = 'b';
        case 1
            col = 'r';
    end
    set(plotUIobj.plot1, 'Color', col);
end


%% check vars

end



%% %%%%%%%%%%%%%%%%%%%%   sub functions   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function y = re_write(h)
y = str2double(get(h,'string'));
end

%%
function centerXY_list= get_stim_center_mat
global sobj
sizeX = sobj.ScreenSize(1)/sobj.divnum;
sizeY = sobj.ScreenSize(2)/sobj.divnum;
center_div = floor([sizeX/2:sizeX:(sobj.ScreenSize(1)-sizeX/2);...
    sizeY/2:sizeY:(sobj.ScreenSize(2)-sizeY/2)]);

centerXY_list = zeros(sobj.divnum^2,2);

for m = 1:sobj.divnum
    centerXY_list(sobj.divnum*(m-1)+1:sobj.divnum*m,1) = center_div(1,m);
    centerXY_list((1:sobj.divnum:sobj.divnum^2)+(m-1),2) = center_div(2,m);
end
end

%%
function size = stim_size(dist , h, pixpitch)
size = round(ones(1,2)*Deg2Pix(str2double(get(h,'string')), dist, pixpitch));
end



