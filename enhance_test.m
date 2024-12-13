I = imread("DB1_B\102_2.tif");

% I = fingerprint image to process
% normalization mean
% normalization variance
% blocksize
% Mask variance threshold
% Mask lower threshold
% x wavelengths ratio
% y wavelength ratio
Im = fingerprint_enhancer(I,128,150,16,6,0.9,0.5,0.5);






