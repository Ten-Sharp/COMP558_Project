function [I_enhanced,I_binary,ori_map,freq_map,mask_map] = fingerprint_enhancer(Im,norm_m,norm_v,blocksize,mask_threshold,ratio_range,ratio_x,ratio_y)

I_norm = normalise_im(Im,norm_m,norm_v);

% show(uint8(I_norm),1)

[orientations,ori_map] = orientation_estimation(I_norm,blocksize,1,5);
I_orientations = plot_orientations(Im,blocksize,orientations);
% show(I_orientations,2)

[frequencies,med_freq,freq_map] = frequency_estimation(I_norm,orientations,blocksize,[32,16],500);
% [frequencies,med_freq,freq_map] = freq_estimation_fft(I_norm,blocksize,1/18,1/3);
% show(freq_map,3)

[R,masked_I,mask_map] = mask_estimate(I_norm,blocksize,mask_threshold,ratio_range,frequencies);
masked_I = plot_masked(masked_I,I_norm,R,blocksize);
% show(masked_I,4)


I = im_gabor_filter(I_norm,orientations,frequencies,R,blocksize,ratio_x,ratio_y);
% show(I,5)
I = I(blocksize+1:end-blocksize,blocksize+1:end-blocksize);

I_binary = I;

I_inv = I == 0;
I_thinned = bwmorph(I_inv, 'thin', Inf);
I = I_thinned == 0;


% show(I,6)
I_enhanced = I;

end