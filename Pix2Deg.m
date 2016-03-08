function Y = Pix2Deg(pix, dist)
global sobj
% pix => (pixel number)
% dist => (mm)
% pixel pitch = 0264mm/pixle
Y = 2*atand(sobj.pixpitch*pix/2/dist);