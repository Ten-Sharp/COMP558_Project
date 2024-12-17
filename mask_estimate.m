function [recoverable_region,masked_I,mask_map] = mask_estimate(I,blocksize,threshold,ratio_range,frequencies)
%MASK_ESTIMATE Summary of this function goes here
%   Detailed explanation goes here
% mask_map = ones(size(I,1),size(I,2));

horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

recoverable_region = ones(horizontal_blocks,vertical_blocks); 
recoverable_region(frequencies<=0) = 0;
masked_I = I;
null_value = I(1,1);

for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        
        pixel_classification = zeros(size(block));
        pixel_classification(block >= 130) = 1;

        num_zeros = nnz(pixel_classification(:) == 0);
        num_ones = nnz(pixel_classification(:) == 1);

        % Calculate the ratio of 0's to 1's
        ratio = num_zeros / num_ones;
        
        block_as_dbl = double(block);

        if std(block_as_dbl(:)) < threshold || ratio < 1 - ratio_range 
            recoverable_region(x,y) = 0;
            masked_I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = null_value;
        end

        
    end
end

for i = 1:size(recoverable_region,1)
    for j = 1:size(recoverable_region,2)
        mask_map((i-1)*blocksize+1:i*blocksize,(j-1)*blocksize+1:j*blocksize) = recoverable_region(i,j);
    end
end

end

