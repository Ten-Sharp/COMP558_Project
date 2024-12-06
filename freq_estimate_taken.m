function frequencies = freq_estimate_taken(I,orientations,blocksize,window_size)
%FREQUENCY_ESTIMATION Summary of this function goes here
%   Detailed explanation goes here

frequencies = zeros(size(orientations));

horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        block = I((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        [rows,~] = size(block);

        block_orientation = orientations(x,y);

        deg = rad2deg(block_orientation);
        rotated_block = imrotate(block,deg,'bilinear', 'crop');

        cropsze = fix(rows/sqrt(2)); offset = fix((rows-cropsze)/2);
        rotated_block = rotated_block(offset:offset+cropsze, offset:offset+cropsze);

        proj = sum(rotated_block);

        dilation = ordfilt2(proj, window_size, ones(1,window_size));
        maxpts = (dilation == proj) & (proj > mean(proj));
        maxind = find(maxpts);

        if length(maxind) < 2
	        frequencies(x,y) = 0;
        else
	        N_peaks = length(maxind);
	        waveLength = (maxind(end)-maxind(1))/(N_peaks-1);
	    if waveLength > 5 && waveLength < 15
	        frequencies(x,y) = 1/waveLength;
	    else
	        frequencies(x,y) = 0;
	    end
        end
    end
end

% h = fspecial("gaussian",5,3);
% 
% frequencies = conv2(frequencies,h,'same');

% h = fspecial('gaussian', [7, 7], 9);
% h2 = fspecial("gaussian",[5,5],1);
% 
% maxcount = 1;
% count = 0;
% while any(frequencies(:) == -1) && count <= maxcount
%     padded_frequencies = padarray(frequencies, [4, 4], 0, 'both');
%     % [row_idx, col_idx] = find(padded_frequencies == -1)
%     mask = padded_frequencies == -1;
% 
%     inv_mask = mask == 0;
% 
%     padded_frequencies(padded_frequencies <= 0) = 0; 
% 
%     numerator = imfilter(padded_frequencies,h,'same');
%     denominator = imfilter(inv_mask,h,'same');
% 
%     estimated_error_frequencies = numerator ./ denominator;
%     estimated_error_frequencies(isnan(estimated_error_frequencies)) = 0;
% 
%     padded_frequencies(mask == 1) = estimated_error_frequencies(mask == 1);
% 
%     frequencies = padded_frequencies(5:end-4,5:end-4);
% 
% 
%     frequencies(frequencies < 0.04) = -1;
%     frequencies(frequencies > 0.333333333333) = -1;
% 
%     count = count +1;
% end
% 
% frequencies = imfilter(frequencies,h2,'same');
% frequencies(frequencies == Inf) = 0;
% 
end
% 
