function enhance_test(fileName1, fileName2)
    filePath = './fingerprints';
    fileNames = {fileName1, fileName2};
    if isequal(fileNames, 0)
        disp('User canceled the operation.');
        return;
    end
    
    % Ensure two images are selected
    if length(fileNames) ~= 2
        error('Please select exactly two matching fingerprints.');
    end
    
    for i = 1:2
        imgPath = fullfile(filePath, fileNames{i})
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
end





