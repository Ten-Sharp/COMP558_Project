function I = normalise_im(Im,Mo,Vo)
%NORMALISE_IM Summary of this function goes here
%   Detailed explanation goes here
I = im2double(Im);

M = mean(I(:));
V = var(I(:));

I(I>M) = Mo + sqrt((((I(I>M)-M).^2).*Vo)/V);
I(I<=M) = Mo - sqrt((((I(I<=M)-M).^2).*Vo)/V);

end

