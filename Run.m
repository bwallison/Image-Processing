% MATLAB script for Assessment Item-1
close all;

% ----- Step-1: Load input image -----
% Uses imread to read in the .jpg image and assigns to matrix I
% Then uses imshow to display the image on a 3x4 subplot with a title

I = imread('AssignmentInput.jpg');
subplot(3,4,1)
imshow(I, []);
title({'Step-1: Load input image:', 'imread'});

% ----- Step-2: Conversion of input image to greyscale -----
% The function rgb2gray converts the 3d colour matrix to a 2d greyscale
% matrix and reassigns it to I

I = rgb2gray(I);
subplot(3,4,2)
imshow(I, []);
title({'Step-2: Conversion of input image to greyscale:', 'rg2gray'})

% ----- Step-3: Noise removal -----
% FilteredImage is created by a 3x3 median filter being applied to the
% greyscale image I

FilteredImage = medfilt2(I,[3 3]);

subplot(3,4,3)
imshow(FilteredImage, []);
title({'Step-3: Noise removal:', 'Filtered Image with 3x3 median filter'});

% ----- Alternative method of noise removal -----
% Filtering image with a 5x5 median filter
% FilteredImage = medfilt2(I,[5 5]);

% ----- Alternative method of noise removal -----
% Noise removal using fspecial to use a average of the 3x3 surrounding
% pixel to remove noise

% h = fspecial('average', 3);
% FiltedImageNoise = filter2(fspecial('average',3),I)/255;
% subplot(3,3,3)
% imshow(FiltedImageNoise);
% title('Filtered Image with 3x3 average filter');

% ----- Step-4: Enhance the image -----
% Once the noise is removed histogram equalization is done to adjust the
% intensity range of the pixel to create a image which features can be more
% distinguished from each other.

FilteredImageEnhanced = histeq(FilteredImage, 256);

% imhist is used to display the pixel intensity ranges of both the image
% before and after histogram equalization

subplot(3,4,4)
imhist(FilteredImage, 256);
title({'Step-4: Enhance the image', 'histogram of image before histeq'});

subplot(3,4,5)
imhist(FilteredImageEnhanced, 256);
title({'Step-4: Enhance the image', 'histogram of image after histeq'});

% Display the new enhanced image FilteredImageEnhanced on the subplot

subplot(3,4,6)
imshow(FilteredImageEnhanced);
title({'Step-4: Enhance the image', 'histeq with 256 bins'});

% ----- Step-5: Segment the image into foreground and background. -----

% ----- Alternative method of segmentation -----
% Adaptive filtering using segmented blocks of the image
%  fun = @(block_struct) imcomplement(imbinarize(block_struct.data, 'adaptive', 'Sensitivity', 0.62));
%  BW = blockproc(FilteredImage, [100 100], fun);

% imbinarize converts the image to a binary image with a adaptive threshold
% 0.62 as a starting threhold provided the best segmentation of the image
% from foreground and background

BW = imcomplement(imbinarize(FilteredImage, 'adaptive', 'Sensitivity', 0.62));

subplot(3,4,7)
imshow(BW, []);
title({'Step-5: Segment the image into foreground and background:', 'imbinarize & imcomplement'});


% ----- Step-6: Use morphological processing -----

% Two structuring element are creating one larger than the other for the
% open operation to remove joins from starfish and other objects more. A
% disk is used to help save more quality from a star shape.

seOpen = strel('disk', 2);
seClose = strel('disk', 1);

% Erodes an image and then dilates the eroded image using the different 
% structuring elements for both operations.
% imopen as doing imdilate((imerode(BW, seOpen)), seOpen);
% imclose as doing imerode((imdilate(BW, seClose)), seClose);
% imfill fills in any holes in the objects for later object recognition

morphedBW = imclose(imopen(BW, seOpen), seClose);
morphedBW = imfill(morphedBW, 'holes');

% ----- Alternative method of morphological processing -----
% morphedBW = imopen(imclose(BW, seClose), seOpen);
% morphedBW = imfill(morphedBW, 'holes');

subplot(3,4,8)
imshow(morphedBW, []);
title({'Step-6: Use morphological processing:', 'imopen using structuring element'});

% ----- Step-7: Recognition of starfishes -----

% A label is created from the shapes with connectivity of 8 from the binary
% image. numObjects stores how many there are and imageObjects store the
% objects.

[imageObjects, numObjects] = bwlabel(morphedBW, 8);

% regionprops is used on imageObjects to get statistical values for area
% and perimeter of each shape.

stats = regionprops(imageObjects, 'Area', 'Perimeter');

% a metric is initialised of the number of objects recognised

metric = (1);

% the loop goes through each object calculating the metric and storing each
% one using the area and perimeter stored in stats for each object.

for k = 1:numObjects

metric(k) = 4*pi*stats(k).Area/stats(k).Perimeter^2;

end

% the metric indicates the roundness of the objects, closer to 1 the more
% circular they are and the closer to 0 the sharper the edges. Therefor
% 0.21 is used as a threshold to find all indexes of the objects less than
% 0.21 in the metric measure as these are starfish.
% ismember is then used to get the matrix with the objects which have these
% indexes.

indexOfStarfish = find(metric < 0.21);
imageObjects = ismember(imageObjects, indexOfStarfish);

subplot(3,4,9)
imshow(imageObjects);
title({'Step-7: Recognition of starfishes:', 'regionprops & metrics'});

% ----- Extra operations -----
% Different display option for starfish, converted the imageObjects to a
% rgb colour and displays them

starFishColour = label2rgb(imageObjects, 'jet', 'k', 'shuffle');

subplot(3,4,10)
imshow(starFishColour);
title({'Step-7: Recognition of starfishes:', 'Coloured'});

% calculate the boundaries of all starfish, not accounting for holes

% The following operations calculate the boundaries of the starfish and
% displays the starfish objects on the FilteredImage and
% FilteredImageEnhanced.

[bwB, boundNum] = bwboundaries(imageObjects, 'noholes');
subplot(3,4,11)
imshow(FilteredImage);

% hold on tells matlab to first execute the for loop before plotting the
% FilteredImage.

hold on

% this  loops through bwB, the boundaries of the starfish plotting them onto the
% imshow with a cyan colour with a width of 1.

for k = 1:length(bwB)
    boundary = bwB{k};
    plot(boundary(:,2), boundary(:,1), 'cyan', 'LineWidth', 1);
end

title({'Step-8: Recognition of starfishes extended:', 'Boundaries Greyscale'});

subplot(3,4,12)
imshow(FilteredImageEnhanced);

% hold on tells matlab to first execute the for loop before plotting the
% FilteredImageEnhanced.

hold on

% this  loops through bwB, the boundaries of the starfish plotting them onto the
% imshow with a cyan colour with a width of 1. It does the same operation
% as the one before but with a different input image on imshow.

for k = 1:length(bwB)
    boundary = bwB{k};
    plot(boundary(:,2), boundary(:,1), 'cyan', 'LineWidth', 1);
end

title({'Step-9: Recognition of starfishes extended:', 'Boundaries Greyscale Enhanced'});
