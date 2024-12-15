function [orientations,ori_map] = orientation_estimation(I,blocksize,block_sigma,orientation_sigma)
%ORIENTATION_ESTIMATION Summary of this function goes here

horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

orientations = zeros(horizontal_blocks,vertical_blocks);

%Smooth the image to ensure gradient exists
g = fspecial("gaussian",[7,7],1);
%calculate gradient of gaussian
[gx,gy] = gradient(g);

%Get gradients of smoothed image
%Add 0 padding and no flip since gasussian symmetric
Gx = imfilter(I, gx, 'same', 'replicate', 'corr');
Gy = imfilter(I, gy, 'same', 'replicate', 'corr');

Gxx = Gx .^ 2;
Gyy = Gy .^ 2;
Gxy = Gx .* Gy;

%Ensure that filter is odd and gaussian is properly represented
%[-3*sigma , 3*sigma] 97.88% of area
size_g = 2*floor(3*block_sigma) + 1;
f = fspecial("gaussian",size_g,block_sigma);

Gxx = imfilter(Gxx, f, 'same', 'replicate', 'corr');
Gyy = imfilter(Gyy, f, 'same', 'replicate', 'corr');
Gxy = 2*imfilter(Gxy, f, 'same', 'replicate', 'corr');


hypotenus = sqrt(Gxy.^2 + (Gxx - Gyy).^2) + eps;
phix = (Gxx - Gyy)./hypotenus;
phiy = Gxy./hypotenus;

size_g = 2*floor(3*orientation_sigma) + 1;
h = fspecial('gaussian', size_g, 3);
% h = fspecial("average",[5,5]);
phix_prime = imfilter(phix,h,'same', 'replicate', 'corr');
phiy_prime = imfilter(phiy,h,'same', 'replicate', 'corr');


%takes the mean orientations per block
for x = 1:horizontal_blocks
    for y = 1:vertical_blocks

        phix_block = phix_prime((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        phiy_block = phiy_prime((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        cosorient = mean(phix_block(:));
        sinorient = mean(phiy_block(:));

        orientation = 0.5 * atan2(sinorient,cosorient) + pi/2;

        if orientation < 0
            orientation = orientation + pi;
        end
        if orientation > pi
            orientation = orientation - pi;
        end

        orientations(x,y) = orientation;
    end
end

for i = 1:size(orientations,1)
    for j = 1:size(orientations,2)
        ori_map((i-1)*blocksize+1:i*blocksize,(j-1)*blocksize+1:j*blocksize) = orientations(i,j);
    end
end


end

