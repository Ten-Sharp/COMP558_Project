function [frequencies,median_freq,freq_map] = frequency_estimation(I,blocksize,min_freq,max_freq)
%FREQUENCY_ESTIMATION Summary of this function goes here
%   Detailed explanation goes here


horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);
freq_map = zeros(size(I));

frequencies = zeros(horizontal_blocks,vertical_blocks);

I = padarray(I, [blocksize, blocksize], I(1,1), 'both');

disp('here???')
disp(size(freq_map))


horizontal_blocks = floor(size(I,2)/blocksize);
vertical_blocks = floor(size(I,1)/blocksize);



winlen = 32; winwid = 32;
l = winlen/2;
w = winwid/2;

rows = 32;
cols = 32;

% Compute the center coordinates
center_row = rows / 2;
center_col = cols / 2;

% Create a grid of coordinates
[X, Y] = meshgrid(1:cols, 1:rows);

% Compute the distance of each point from the center
distance_from_center = sqrt((X - center_col).^2 + (Y - center_row).^2)/32;

mask = (distance_from_center >= min_freq) & (distance_from_center <= max_freq);

for x = 2:horizontal_blocks-1
    for y = 2:vertical_blocks-1
        block = I((y-2)*blocksize+1:(y+1)*blocksize,(x-2)*blocksize+1:(x+1)*blocksize);

        centerx = floor(size(block,1)/2);
        centery = floor(size(block,2)/2);

        window = block(centerx-(w-1):centerx+w,centery-(l-1):centery+l);

        F = fft2(window);

        F_centered = fftshift(F);
        F_centered = mask .* F_centered;


        if any(F_centered(:) ~= 0) 
            magnitude = abs(F_centered);
            upper_half = magnitude(1:floor(winwid/2), :);
            
            [row, col] = find(upper_half == max(upper_half(:)));
    
            max_v = col(1); % Horizontal frequency index
            max_u = row(1);
    
            F_vmin_one = abs(F(max_u,max_v - 1));
            F_vpls_one = abs(F(max_u,max_v + 1));
            F_umin_one = abs(F(max_u -1 ,max_v));
            F_upls_one = abs(F(max_u -1 ,max_v));
    
            if F_vmin_one > F_vpls_one
                u = max_u - (F_vmin_one/(F_vmin_one + abs(F(max_u,max_v))));
            else
                u = max_u + (F_vpls_one/(F_vpls_one + abs(F(max_u,max_v))));
            end
    
            if F_umin_one > F_upls_one
                v = max_v - (F_umin_one/(F_umin_one + abs(F(max_u,max_v))));
            else
                v = max_v + (F_upls_one/(F_upls_one + abs(F(max_u,max_v))));
            end
    
            frequency = sqrt((u-winlen/2)^2 + (v-winlen/2)^2) / winlen;
    
            frequencies(x-1,y-1) = frequency;
            freq_map(((y-1)-1)*blocksize+1:(y-1)*blocksize,((x-1)-1)*blocksize+1:(x-1)*blocksize) = frequency;
        else
            frequencies(x-1,y-1) = 0;
            freq_map(((y-1)-1)*blocksize+1:(y-1)*blocksize,((x-1)-1)*blocksize+1:(x-1)*blocksize) = 0;
        end

    end

    
end


median_freq = median(frequencies(frequencies>0)); 
frequencies = round(frequencies.*100)./100;


end

