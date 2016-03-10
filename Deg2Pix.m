function Y = Deg2Pix(ang, dist,pixpitch)
% ang => (degree)
% dist => (mm)
% pixel pitch = 0.264mm/pixel;
Y = 2*dist*tan(ang/2*2*pi/360)/pixpitch;% ang(degree) ÇÃ pixelêî