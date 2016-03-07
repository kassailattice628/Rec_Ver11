function Y = Deg2Pix(ang, dist)

% ang => (degree)
% dist => (mm)
% pixel pitch = 0.264mm/pixel;

Y = 2*dist*tan(ang/2*2*pi/360)/0.264;% ang(degree) ÇÃ pixelêî