function orientations = orientation_estimation(I,blocksize,block_sigma,orientation_sigma)
%ORIENTATION_ESTIMATION Summary of this function goes here
I = double(I);
horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

% orientations = zeros(horizontal_blocks,vertical_blocks); 
phix = zeros(horizontal_blocks,vertical_blocks);
phiy = zeros(horizontal_blocks,vertical_blocks);

%Smooth the image to ensure gradient exists
g = fspecial("gaussian",[7,7],1);
%calculate gradient of gaussian
[gx,gy] = gradient(g);
%Get gradients of smoothed image

%Add 0 padding and no flip since gasussian symmetric
Gx = imfilter(I, gx, 'same', 'replicate', 'corr');
Gy = imfilter(I, gy, 'same', 'replicate', 'corr');


% [Gx,Gy] = imgradientxy(I);
% Gx = imgaussfilt(Gx, 1, 'FilterSize', 5);
% Gy = imgaussfilt(Gy, 1, 'FilterSize', 5);


for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        % block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);

        % [Gx,Gy] = imgradientxy(block);
        Gxb = Gx((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        Gyb = Gy((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        
        Gxx = Gxb .^ 2;
        Gyy = Gyb .^ 2;
        Gxy = Gxb .* Gyb;

        %Ensure that filter is odd and gaussian is properly represented
        %[-3*sigma , 3*sigma] 97.88% of area
        size_g = 2*floor(3*block_sigma) + 1;
        f = fspecial("gaussian",size_g,block_sigma);

        Gxx = imfilter(Gxx, f, 'same', 'replicate', 'corr');
        Gyy = imfilter(Gyy, f, 'same', 'replicate', 'corr');
        Gxy = imfilter(Gxy, f, 'same', 'replicate', 'corr');


        % Original implementation ----------
        % Sxy = sum(sum(Gxb .* Gyb));
        % Sxx = sum(sum(Gxb.^2));
        % Syy = sum(sum(Gyb.^2));
        % 
        % block_orientation = 0.5 * atan2(2*Sxy,Sxx - Syy);
        % 
        % phix(x,y) = cos(2*block_orientation);
        % phiy(x,y) = sin(2*block_orientation);
        % ------------------------------------

        %To avoid any imprefections with atan function, sin and cos double
        %angles are computed off the bat
        % tan = O/A
        
        hypotenus = sqrt(Gxy.^2 + (Gxx - Gyy).^2) + eps;
        phix(x,y) = sum(sum((Gxx - Gyy)./hypotenus));
        phiy(x,y) = sum(sum(Gxy./hypotenus));

    end
end

size_g = 2*floor(3*orientation_sigma) + 1;
h = fspecial('gaussian', size_g, 3);
% h = fspecial("average",[5,5]);
phix_prime = imfilter(phix,h,'replicate');
phiy_prime = imfilter(phiy,h,'replicate');

orientations = 0.5 * atan2(phiy_prime,phix_prime) + pi/2;


% h2 = fspecial('gaussian',[3,3],1);
% orientations = imfilter(orientations,h2,'replicate');
% smoothed_XY = phiy_prime ./ phix_prime;
% 
% smoothed_XY(isnan(smoothed_XY)) = 0;
% smoothed_XY(isinf(smoothed_XY)) = 0; 
% 
% orientations = 0.5 .* atan(smoothed_XY);


end

