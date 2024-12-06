function g = gabor_filter(frequency,orientation,sigma,filter_size)

[x, y] = meshgrid(-filter_size/2:filter_size/2, -filter_size/2:filter_size/2);

% Rotate coordinates
xRot = x * cos(orientation) + y * sin(orientation);
yRot = -x * sin(orientation) + y * cos(orientation);

% Gabor kernel
gaussian = exp(-0.5 * ((xRot.^2 / sigma^2) + (yRot.^2 / sigma^2)));
sinusoid = cos(2 * pi * frequency * xRot);
g = gaussian .* sinusoid;

end

