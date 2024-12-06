I = imread("DB1_B\102_2.tif");
% resized_img = imresize(I, [1500, 1000]);
% 
% % Save the resized image
% imwrite(resized_img, 'resized_image.tif', 'Resolution', [500 500]);
% 
% I = imread('resized_image.tif');

I = im2gray(I);



I = imresize(I, [640,480]);
Im = fingerprint_enhancer(I,128,150,32,7,7,0.9,128,11,4);



% Create a 1x2 grid for displaying
figure;

subplot(1, 2, 1); % First image
imshow(I);
title('original');

subplot(1, 2, 2); % Second image
imshow(Im);
title('Enhanced');

cos(pi/2) - cos(-pi/2)



