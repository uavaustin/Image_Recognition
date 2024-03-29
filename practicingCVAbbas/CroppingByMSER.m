colorImage = imread('test_images\IMG_2376.jpg');
%colorImage = imread('test_images\2014-10-26.jpg');
%colorImage = imread('test_images\2014-10-26_triangle.jpg');
arrSize = size(colorImage);
%arrSize
threshold = 900;
if max(arrSize) > threshold
    rSize = threshold / (max(arrSize));
    %rSize
    colorImage = imresize(colorImage, rSize);
end
origImage = colorImage;
figure; imshow(colorImage); title('Image');
bw = rgb2gray(colorImage);
hsv = rgb2hsv(colorImage);
%figure; imshow(bw); title('bw');
%figure;imshow(hsv);title('hsv');
for i=1:3
    histImage = hsv(:,:,i);
    %histImage2 = histeq(histImage);
    %histImage3 = histeq(rgb2hsv(origImage));

    %figure;imshow(histImage);
    %figure;imshow(histImage2);
    %figure;imshow(histImage3);

    %filter image by hue w/o equalizer
    %colorImage = rgb2hsv(colorImage);
    %histImage = colorImage(:,:,1);
    %figure; imshow(hue);

    %filter image to grayscale
    % colorImage = rgb2gray(colorImage);
    % histImage = colorImage;
    % figure; imshow(histImage);

    mserRegions = detectMSERFeatures(histImage);
    mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));  % extract regions
%     figure; imshow(histImage); title('MSER Regions');
%     hold on;
%     plot(mserRegions, 'showPixelList', true, 'showEllipses', false);
%     plot(mserRegions);

    mserMask = false(size(histImage));
    if (size(mserRegionsPixels) > 0)
        ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
    end
    mserMask(ind) = true;

    se1=strel('disk',25);
    se2=strel('disk',7);

    afterMorphologyMask = imclose(mserMask,se1);
    afterMorphologyMask = imopen(mserMask,se2);

    areaThreshold = threshold; % threshold in pixels
    connComp = bwconncomp(afterMorphologyMask);
    stats = regionprops(connComp,'BoundingBox','Area');
    boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
    for i=1:size(boxes,1)
        figure;
        imshow(imcrop(origImage, boxes(i,:))); % Display segmented text
        title('Text region')
    end
end