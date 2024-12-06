function orientations = orientation_estimation(I,blocksize)
%ORIENTATION_ESTIMATION Summary of this function goes here
horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

% orientations = zeros(horizontal_blocks,vertical_blocks); 
phix = zeros(horizontal_blocks,vertical_blocks);
phiy = zeros(horizontal_blocks,vertical_blocks);

[Gx,Gy] = imgradientxy(I);
Gx = imgaussfilt(Gx, 1, 'FilterSize', 5);
Gy = imgaussfilt(Gy, 1, 'FilterSize', 5);

for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        % block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);

        % [Gx,Gy] = imgradientxy(block);
        Gxb = Gx((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        Gyb = Gy((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        
        Sxy = sum(sum(Gxb .* Gyb));
        Sxx = sum(sum(Gxb.^2));
        Syy = sum(sum(Gyb.^2));

        block_orientation = 0.5 * atan2(2*Sxy,Sxx - Syy);
        % Vx = sum(sum((Gxb .* Gyb).*2));
        % Vy = sum(sum((Gxb.^2) - (Gyb.^2)));
        % 
        % block_orientation = 0.5 * atan(Vx/Vy);
        


        phix(x,y) = cos(2*block_orientation);
        phiy(x,y) = sin(2*block_orientation);
    end
end

h = fspecial('gaussian', [5,5], 3);
% h = fspecial("average",[5,5]);
phix_prime = imfilter(phix,h,"replicate");
phiy_prime = imfilter(phiy,h,"replicate");

orientations = 0.5 * atan2(phiy_prime,phix_prime);


% h2 = fspecial('gaussian',[3,3],1);
% orientations = imfilter(orientations,h2,'replicate');
% smoothed_XY = phiy_prime ./ phix_prime;
% 
% smoothed_XY(isnan(smoothed_XY)) = 0;
% smoothed_XY(isinf(smoothed_XY)) = 0; 
% 
% orientations = 0.5 .* atan(smoothed_XY);


end

