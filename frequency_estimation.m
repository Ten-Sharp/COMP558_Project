function frequencies = frequency_estimation(I,orientations,blocksize,window_size)
%FREQUENCY_ESTIMATION Summary of this function goes here
%   Detailed explanation goes here
l = floor(window_size(1)/2);
w = floor(window_size(2)/2);

frequencies = zeros(size(orientations));

I = padarray(I, [blocksize, blocksize], I(1,1), 'both');
orientations = padarray(orientations, [1, 1], 0, 'both');


horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

for x = 2:horizontal_blocks-1
    for y = 2:vertical_blocks-1
        block = I((y-2)*blocksize+1:(y+1)*blocksize,(x-2)*blocksize+1:(x+1)*blocksize);
        
        block_orientation = orientations(x,y);

        deg = rad2deg(block_orientation);
        rotated_block = imrotate(block,deg,'bilinear', 'crop');

        centerx = floor(size(rotated_block,1)/2);
        centery = floor(size(rotated_block,2)/2);

        window = rotated_block(centerx-(w-1):centerx+w,centery-(l-1):centery+l);

        x_signature = sum(window,1) / size(window,1);

        [~, peaks] = findpeaks(x_signature);
    
        % Compute distances between consecutive peaks
        if numel(peaks) > 1
            distances = abs(diff(peaks));
            avg_ridge_valley_dist = mean(distances); % Average distance between peaks
            frequency = 1 / avg_ridge_valley_dist;   % Compute frequency

            if frequency < 0.04 || frequency > 0.333333333333
                frequency = -1;
            end
        else
            frequency = -1; % Assign -1 if no valid peaks are found
        end

        frequencies(x-1,y-1) = frequency;

    end
end

h = fspecial('gaussian', [7, 7], 9);
h2 = fspecial("gaussian",[5,5],1);

maxcount = 1;
count = 0;
while any(frequencies(:) == -1) && count <= maxcount
    padded_frequencies = padarray(frequencies, [4, 4], 0, 'both');
    % [row_idx, col_idx] = find(padded_frequencies == -1)
    mask = padded_frequencies == -1;
    
    inv_mask = mask == 0;
    
    padded_frequencies(padded_frequencies <= 0) = 0; 
    
    numerator = imfilter(padded_frequencies,h,'same');
    denominator = imfilter(inv_mask,h,'same');
    
    estimated_error_frequencies = numerator ./ denominator;
    estimated_error_frequencies(isnan(estimated_error_frequencies)) = 0;
    
    padded_frequencies(mask == 1) = estimated_error_frequencies(mask == 1);
    
    frequencies = padded_frequencies(5:end-4,5:end-4);
    

    frequencies(frequencies < 0.04) = -1;
    frequencies(frequencies > 0.333333333333) = -1;
    
    count = count +1;
end

frequencies = imfilter(frequencies,h2,'same');
frequencies(frequencies == Inf) = 0;

end

