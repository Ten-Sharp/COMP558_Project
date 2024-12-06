function I_enhanced = fingerprint_enhancer(I,norm_m,norm_v,blocksize,freq_window,mask_threshold,ratio_range,binarization_cutoff,gabor_size,gabor_sigma)
%FINGERPRINT_ENHANCER Summary of this function goes here
%   Detailed explanation goes here

I = double(I);
mean_I = mean(I(:));
var_I = var(I(:));

normalized_I = zeros(size(I));

indices_above_mean = find(I > mean_I);
other_indices = find(I <= mean_I);

normalized_I(indices_above_mean) = ...
    norm_m + sqrt((((I(indices_above_mean) - mean_I).^2).*norm_v)./var_I);

normalized_I(other_indices) = ...
    norm_m - sqrt((((I(other_indices) - mean_I).^2).*norm_v)./var_I);

% normalized_I = sqrt(norm_v / var_I) * (I - mean_I) + norm_m

I = uint8(normalized_I);


horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

orientations = orientation_estimation(I,blocksize);

% frequencies = frequency_estimation(I,orientations,blocksize,freq_window);
frequencies = freq_estimate_taken(I,orientations,blocksize,freq_window);

% [R,masked_I] = mask_estimate(I,blocksize,mask_threshold,ratio_range);


% for x = 1:horizontal_blocks
%     for y = 1:vertical_blocks
%         block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
% 
%         % if (R(x,y) == 1)
%             try
%                 f = frequencies(x,y);
%                 orientation = orientations(x,y);
% 
%                 g = gabor_filter(f,orientation,gabor_sigma,gabor_size);
%                 filtered_block = uint8(conv2(double(block), g, 'same'));
%                 I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = filtered_block;
%                 % 
%                 % g = gabor_filter(f,orientation,gabor_sigma,gabor_size);
%                 % 
%                 % filtered_block = uint8(imfilter(double(block), g, "symmetric"));
%                 % 
%                 % I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = filtered_block;
%                 % g = gabor(1/f,orientation);
% 
%                 % orientation = rad2deg(orientations(x,y)) + 180;
%                 % filtered_block = imgaborfilt(block,1/f,orientation);
%                 % 
%                 % % imshow(filtered_block)
%                 % 
%                 % I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = fliplr(filtered_block);
% 
% 
%             catch
%                 disp('skipped block')
%             end
%         % else
%         %     I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = 256;
%         % end
%     end
% end

% I(I <= binarization_cutoff) = 0;
% I(I > binarization_cutoff) = 256;


%------------------------ OTHER IMPLEMENTATION
for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);


        f = frequencies(x,y);
        orientation = orientations(x,y);

        g = gabor_filter(f,orientation,gabor_sigma,gabor_size);
        filtered_block = uint8(conv2(double(block), g, 'same'));
        I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = filtered_block;
        % 
        % g = gabor_filter(f,orientation,gabor_sigma,gabor_size);
        % 
        % filtered_block = uint8(imfilter(double(block), g, "symmetric"));
        % 
        % I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = filtered_block;
        % g = gabor(1/f,orientation);

        % orientation = rad2deg(orientations(x,y)) + 180;
        % filtered_block = imgaborfilt(block,1/f,orientation);
        % 
        % % imshow(filtered_block)
        % 
        % I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = fliplr(filtered_block);



        % else
        %     I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = 256;
        % end
    end
end

%---------------------------------------------------









% % Modify the brightness of img1 (creating a 'hue-like' effect)
% img1_hue = masked_I * 1.5; % Increase brightness
% img1_hue(img1_hue > 255) = 255; % Ensure values stay in range
% 
% % Overlay the images
% overlay_img = imfuse(img1_hue, I, 'blend', 'Scaling', 'joint');
% 
% % Display the result
% imshow(overlay_img);

% img = I(8*blocksize -1:9*blocksize,8*blocksize -1:9*blocksize);
% imshow(img)
% [x, y] = ginput(1);
% 
% % Retrieve the pixel intensity value at (x, y)
% intensity = img(round(y), round(x));  % Round to ensure integer indices
% disp(['Pixel intensity at (' num2str(x) ',' num2str(y) ') is: ' num2str(intensity)]);





for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
%         block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
%         [rows,cols] = size(block);
%         % [Gx,Gy] = imgradientxy(block);
%         % [Gxx,~] = imgradientxy(Gx);
%         % [~,Gyy] = imgradientxy(Gy);
%         % 
%         % % Gx = imfilter(double(block),sobelx);
%         % % Gy = imfilter(double(block),sobely);
%         % 
%         % Vx = sum(sum((Gx .* Gy).*2));
%         % Vy = sum(sum((Gx.^2) - (Gy.^2)));
%         % 
%         % block_orientation = 0.5 * atan(Vx/Vy);
%         % 
%         % if isnan(block_orientation)
%         %     block_orientation = 0;
%         % end
%         % 
% 
        block_orientation = orientations(x,y);

%         
%         deg = rad2deg(block_orientation);
%         rotated_block = imrotate(block,deg,'bilinear', 'crop');
% 
%         rotated_block = imresize(rotated_block,[32*4,32*4],"bilinear");
% 
% 
%         cropsze = fix(4*rows/sqrt(2));
%         offset = fix((4*rows-cropsze)/2);
%         rotated_block = rotated_block(offset:offset+cropsze, offset:offset+cropsze);
% 
%         ridge_proj = sum(rotated_block, 2)';
%         % frequencies = abs(fft(ridge_proj));
%         % frequencies = frequencies(1:floor(end/2)); % Retain positive frequencies
%         % [~, peak_idx] = max(frequencies); % Index of the peak frequency
%         % ridge_frequency = peak_idx / length(ridge_proj)
%         % imshow(rotated_block)
%         F = fft(ridge_proj);
%         power_spectrum = abs(F).^2;
% 
%         % Find the frequency corresponding to the maximum power
%         [~, idx] = max(power_spectrum(2:end));  % Ignore the DC component at index 1
%         ridge_frequency = idx / length(ridge_proj);
% 
%         % [mag,phase] = imgaborfilt(I,wavelength,orientation);
        center_x = x*blocksize - blocksize/2;
        center_y = y*blocksize - blocksize/2;


        x_offset = 6 * cos(block_orientation + pi/2);
        y_offset = 6 * sin(block_orientation + pi/2);
        x_start = center_x - x_offset;
        y_start = center_y - y_offset;
        x_end = center_x + x_offset;
        y_end = center_y + y_offset;

        % Draw the line
        I = insertShape(I, 'Line', ...
            [x_start, y_start, x_end, y_end], 'Color', 'white', 'LineWidth', 1);
    end
end
I_enhanced = I;

end

