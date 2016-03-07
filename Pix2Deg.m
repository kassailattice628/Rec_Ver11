function Y = Pix2Deg(pix, dist)
% pix => (pixel number)
% dist => (mm)
% pixel pitch = 0264mm/pixle

% 
Y = 2*atand(0.264*pix/2/dist);

