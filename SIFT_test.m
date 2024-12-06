I = imread("istockphoto-165025235-612x612.jpg");
I = rgb2gray(I);

corners = detectSIFTFeatures(I);
imshow(I); 
hold on;
plot(corners.selectStrongest(500));