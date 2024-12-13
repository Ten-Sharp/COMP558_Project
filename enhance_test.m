[fileNames, filePath] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, ...
    'Select Two Images', 'MultiSelect', 'on');

if isequal(fileNames, 0)
    disp('User canceled the operation.');
    return;
end

% Ensure two images are selected
if length(fileNames) ~= 2
    error('Please select exactly two matching fingerprints.');
end

for i = 1:2
    imgPath = fullfile(filePath, fileNames{i});
    Im = imread(imgPath);

    dimensions = size(Im);

    if length(dimensions) == 3
        Im = rgb2gray(Im);
    end

    Im_enhanced = fingerprint_enhancer(Im,128,150,16,6,0.9,0.5,0.5);

    [~, name, ext] = fileparts(fileNames{i});
    newFileName = fullfile(filePath, [name, '_enhanced', ext]);

    imwrite(Im_enhanced, newFileName);
end


% Im = fingerprint_enhancer(I,128,150,16,6,0.9,0.5,0.5);






