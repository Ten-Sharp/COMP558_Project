function Im = im_gabor_filter(I,orientations,frequencies,R,blocksize,ratio_x,ratio_y)


I = double(I);
% frequencies = round(frequencies.*100)./100;

I = padarray(I, [blocksize, blocksize], I(1,1), 'both');
R = padarray(R, [1, 1], 0, 'both');
frequencies = padarray(frequencies, [1, 1], 0, 'both');
orientations = padarray(orientations, [1, 1], 0, 'both');

horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

Im = zeros(size(I));


for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        if R(x, y) == 1
            freq = frequencies(x,y);
            rowRange = (x-1)*blocksize+1 : x*blocksize;
            colRange = (y-1)*blocksize+1 : y*blocksize;

            theta = rad2deg(orientations(x,y));

            sigma_x = ratio_x/freq;
            sigma_y = ratio_y/freq;

            g_size = round(3*max(sigma_y,sigma_x));
        
            [u,v] = meshgrid(-g_size:g_size,-g_size:g_size);
            % u= u.*cos(orientations(x,y)+pi/2) + v.*sin(orientations(x,y)+pi/2);
            % v = -u.*cos(orientations(x,y)+pi/2) + v.*sin(orientations(x,y)+pi/2);
            % filter = exp(-((u.^2)/sigma_x + (v.^2)/sigma_y)/2) .* cos(2*pi*freq*u);

            

            filt = exp(-((u.^2)/sigma_x + (v.^2)/sigma_y)/2) .* cos(2*pi*freq*u);
            filter = imrotate(filt,-(theta + 90),'bilinear','crop');
            

            % show(filter,6)
            filter_x = floor(size(filter,1)/2);
            filter_y = floor(size(filter,2)/2);
            
            rowRange_filter = (x-1)*blocksize+1-filter_x : x*blocksize + filter_x;
            colRange_filter = (y-1)*blocksize+1-filter_y: y*blocksize+filter_y;

            filter_block = I(colRange_filter,rowRange_filter);
            Im(colRange,rowRange) = filter2(filter,filter_block,'valid');
            
        end
    end
end


for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        if R(x,y) == 1
            block = Im((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
    
            block = normalise_im(block,0,10);
    
            % show(block,9)
            blk_mean = mean(block(:));
    
            % 
            block(block < blk_mean) = 1;
            block(block >= 0) = 0;
    
            Im((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = block;
    
        end
    end
end

Im = mat2gray(Im);
%1 is white
%0 is black
h = fspecial("gaussian",3,1);
Im = imfilter(Im,h,'replicate','same');

threshold = mean(Im(:));
Im(Im<threshold) = 0;
Im(Im>=threshold) = 1;

end

