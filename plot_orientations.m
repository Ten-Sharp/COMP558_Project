function Im = plot_orientations(I,blocksize,orientations)
Im = uint8(I);
[horizontal_blocks,vertical_blocks] = size(orientations);
line_length = blocksize/2;

for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        block_orientation = orientations(x,y);

        center_x = x*blocksize - blocksize/2;
        center_y = y*blocksize - blocksize/2;


        x_offset = line_length * cos(block_orientation);
        y_offset = line_length * sin(block_orientation);
        x_start = center_x - x_offset;
        y_start = center_y - y_offset;
        x_end = center_x + x_offset;
        y_end = center_y + y_offset;

        % Draw the line
        Im = insertShape(Im, 'Line', ...
            [x_start, y_start, x_end, y_end], 'Color', 'red', 'LineWidth', 2);
    end
end

end

