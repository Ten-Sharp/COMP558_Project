function I_overlay = plot_masked(I_masked,I,R,blocksize)
I_masked = uint8(I_masked);
I = uint8(I);
[horizontal_blocks,vertical_blocks] = size(R);
I_overlay = I .* 0.8;

for x = 1:horizontal_blocks
    for y = 1:vertical_blocks
        if R(x,y) == 1
            I_overlay((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize) = ...
                I_masked((y-1)*blocksize+1:y*blocksize,(x-1)*blocksize+1:x*blocksize);
        end
    end
end

end

