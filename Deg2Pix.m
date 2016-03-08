function Y = Deg2Pix(ang, dist)
global sobj
% ang => (degree)
% dist => (mm)
% pixel pitch = 0.264mm/pixel;
Y = 2*dist*tan(ang/2*2*pi/360)/sobj.pixpitch;% ang(degree) ÇÃ pixelêî