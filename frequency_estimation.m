function [frequencies,median_freq,freq_map] = frequency_estimation(I,orientations,blocksize,window_size,error_iters)
%FREQUENCY_ESTIMATION Summary of this function goes here
%   Detailed explanation goes here

%L is usually the larger one ex [32,16]
l = window_size(1);
w = window_size(2);

frequencies = zeros(size(orientations));
freq_map = zeros(size(I));

I = padarray(I, [blocksize, blocksize], I(1,1), 'both');
orientations = padarray(orientations, [1, 1], 0, 'both');


horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);

for x = 2:horizontal_blocks-1
    for y = 2:vertical_blocks-1
        block = I((y-2)*blocksize+1:(y+1)*blocksize,(x-2)*blocksize+1:(x+1)*blocksize);
        
        block_orientation = orientations(x,y);
        
        %add pi/2 to make ridges vertical
        deg = rad2deg(block_orientation + pi/2);
        rotated_block = imrotate(block,deg,'nearest', 'crop');

        centerx = floor(size(rotated_block,1)/2);
        centery = floor(size(rotated_block,2)/2);
        
        winlen = floor(l/2);
        winwid = floor(w/2);

        window = rotated_block(centerx-(winwid-1):centerx+winwid,centery-(winlen-1):centery+winlen);

        x_signature = sum(window,1) / l;

        dilation = ordfilt2(x_signature, 5, ones(1,5));
        maxpts = (dilation == x_signature) & (x_signature > mean(x_signature));
        peaks = find(maxpts);
        % [~, peaks] = findpeaks(x_signature);

        % Compute distances between consecutive peaks
        if numel(peaks) > 1
            num_peaks = length(peaks);
            wavelength = (peaks(end)-peaks(1))/(num_peaks-1);
            frequency = 1/wavelength;
            if frequency < 0.04 || frequency > 0.333333333333
                frequency = 0;
            end
        else
            frequency = 0; % Assign -1 if no valid peaks are found
        end

        frequencies(x-1,y-1) = frequency;
        freq_map(((y-1)-1)*blocksize+1:(y-1)*blocksize,((x-1)-1)*blocksize+1:(x-1)*blocksize) = frequency;

    end
end

h = fspecial('gaussian', [7, 7], 9);
% h2 = fspecial("gaussian",[5,5],1);


count = 0;
while any(frequencies(:) == -1) && count <= error_iters
    % padded_frequencies = padarray(frequencies, [4, 4], 0, 'both');
    % [row_idx, col_idx] = find(padded_frequencies == -1)
    mask = frequencies == -1;

    mu = frequencies;
    mu(mu <= 0) = 0;

    delta = frequencies > 0;

    numerator = imfilter(mu,h,'same');
    denominator = imfilter(delta,h,'same') + eps;

    estimated_error_frequencies = numerator ./ denominator;
    % estimated_error_frequencies(isnan(estimated_error_frequencies)) = 0;

    frequencies(mask == 1) = estimated_error_frequencies(mask == 1);

    % frequencies = padded_frequencies(5:end-4,5:end-4);


    frequencies(frequencies < 0.04) = -1;
    frequencies(frequencies > 0.333333333333) = -1;

    count = count +1;
end

% frequencies = imfilter(frequencies,h2,'same');
% frequencies(frequencies == Inf) = 0;
median_freq = median(frequencies(frequencies>0)); 

end

