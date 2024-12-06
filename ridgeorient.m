function orientim = ridgeorient(im, gradientsigma, blocksigma, orientsmoothsigma)

if ~exist('orientsmoothsigma', 'var')
    orientsmoothsigma = 0;
end

% Calculate image gradients.
sze = fix(6*gradientsigma);
if ~mod(sze,2)
    sze = sze+1;
end

% Generate Gaussian filter.
f = fspecial('gaussian', sze, gradientsigma);

% Gradient of Gausian.
[fx,fy] = gradient(f);

Gx = filter2(fx, im); % Gradient of the image in x
Gy = filter2(fy, im); % ... and y

% Estimate the local ridge orientation at each point by finding the
% principal axis of variation in the image gradients.

Gxx = Gx.^2;       % Covariance data for the image gradients
Gxy = Gx.*Gy;
Gyy = Gy.^2;

% Now smooth the covariance data to perform a weighted summation of the
% data.
sze = fix(6*blocksigma);
if ~mod(sze,2);
    sze = sze+1;
end
f = fspecial('gaussian', sze, blocksigma);
Gxx = filter2(f, Gxx);
Gxy = 2*filter2(f, Gxy);
Gyy = filter2(f, Gyy);

% Analytic solution of principal direction
denom = sqrt(Gxy.^2 + (Gxx - Gyy).^2);
% Sine and cosine of doubled angles
sin2theta = Gxy./denom;
cos2theta = (Gxx-Gyy)./denom;

% Smoothed sine and cosine of doubled angles
sze = fix(6*orientsmoothsigma);
if ~mod(sze,2);
    sze = sze+1;
end
f = fspecial('gaussian', sze, orientsmoothsigma);
cos2theta = filter2(f, cos2theta);
sin2theta = filter2(f, sin2theta);

orientim = pi/2 + atan2(sin2theta,cos2theta)/2;
end