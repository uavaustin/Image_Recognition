function ShapeClassifier( img_orig, img_in, img_number )
%SHAPECLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

% 	clc;    % Clear the command window.
% 	close all;  % Close all figures (except those of imtool.)
% 	imtool close all;  % Close all imtool figures.
% 	clear;  % Erase all existing variables.
% 	workspace;  % Make sure the workspace panel is showing.
	fontSize = 20;

	figure,
	% Read in image into an array.
	rgbImage = img_in;
	[rows, columns, numberOfColorBands] = size(rgbImage); 
	% Display it.
	subplot(2, 2, 1);
	imshow(img_orig, []);
    input_title = sprintf('Input Image %d', img_number);
    noisy_title = sprintf('Initial (Noisy) Binary Image %d', img_number);
    clean_title = sprintf('Cleaned Binary Image %d', img_number);
	title(input_title, 'FontSize', fontSize);
	% Enlarge figure to full screen.
	set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
	% Give a name to the title bar.
	set(gcf,'name','Shape Recognition Demo','numbertitle','off') 
% 	% If it's monochrome (indexed), convert it to color. 
% 	if numberOfColorBands > 1
% 		grayImage = rgbImage(:,:,2);
% 		%grayImage = rgb2gray(grayImage);
% 	else
% 		% It's already a gray scale image.
% 		grayImage = rgbImage;
% 	end
% 	% Display it.
% 	subplot(2, 2, 2);
% 	imshow(grayImage);
% 	title('Grayscale Image', 'FontSize', fontSize);
% 	% Binarize the image.
% 	binaryImage = grayImage > 120;
	binaryImage = rgbImage;
	% Display it.
	subplot(2, 2, 2);
	imshow(binaryImage);
	title(noisy_title, 'FontSize', fontSize);
	% Remove small objects.
	binaryImage = bwareaopen(binaryImage, 50);
	% Display it.
	subplot(2, 2, 4);
	imshow(binaryImage, []);
	title(clean_title, 'FontSize', fontSize);
	[labeledImage, numberOfObjects] = bwlabel(binaryImage);
	blobMeasurements = regionprops(labeledImage,...
		'Perimeter', 'Area', 'FilledArea', 'Solidity', 'Centroid'); 
	% Get the outermost boundaries of the objects, just for fun.
	filledImage = imfill(binaryImage, 'holes');
	boundaries = bwboundaries(filledImage);
	% Collect some of the measurements into individual arrays.
	perimeters = [blobMeasurements.Perimeter];
	areas = [blobMeasurements.Area];
	filledAreas = [blobMeasurements.FilledArea];
	solidities = [blobMeasurements.Solidity];
	% Calculate circularities:
	circularities = perimeters .^2 ./ (4 * pi * filledAreas);
	% Print to command window.
	fprintf('#, Perimeter,        Area, Filled Area, Solidity, Circularity\n');
	numberOfObjects
	for blobNumber = 1 : numberOfObjects
		fprintf('%d, %9.3f, %11.3f, %11.3f, %8.3f, %11.3f\n', ...
			blobNumber, perimeters(blobNumber), areas(blobNumber), ...
			filledAreas(blobNumber), solidities(blobNumber), circularities(blobNumber));
	end
	% Say what shape they are.
	% IMPORTANT NOTE: depending on the aspect ratio of the rectangle or triangle
	% their circularity can go from some minimum number up to a huge number.
	for blobNumber = 1 : numberOfObjects
		% Outline the object so the user can see it.
		thisBoundary = boundaries{blobNumber};
		subplot(2, 2, 2); % Switch to upper right image.
		hold on;
		% Display prior boundaries in blue
		for k = 1 : blobNumber-1
			thisBoundary = boundaries{k};
			plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 3);
		end
		% Display this boundary in red.
		thisBoundary = boundaries{blobNumber};
		plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 3);

		%subplot(2, 2, 4); % Switch to lower right image.

		% Determine the shape.
		if circularities(blobNumber) < 1.2
	% 		message = sprintf('The circularity of object #%d is %.3f,\nso the object is a circle',...
	% 			blobNumber, circularities(blobNumber));
			shape = 'circle';
		elseif circularities(blobNumber) < 1.6
	% 		message = sprintf('The circularity of object #%d is %.3f,\nso the object is a square',...
	% 			blobNumber, circularities(blobNumber));
			shape = 'square';
		elseif circularities(blobNumber) > 1.6 && circularities(blobNumber) < 2.0
	% 		message = sprintf('The circularity of object #%d is %.3f,\nso the object is an isocoles triangle',...
	% 			blobNumber, circularities(blobNumber));
			shape = 'triangle';
		else
	% 		message = sprintf('The circularity of object #%d is %.3f,\nso the object is something else.',...
	% 			blobNumber, circularities(blobNumber));
			shape = 'something else';
		end

		% Display in overlay above the object
		if strcmp(shape, 'something else') == 0,
			overlayMessage = sprintf('Object #%d = %s\ncirc = %.2f, s = %.2f', ...
				blobNumber, shape, circularities(blobNumber), solidities(blobNumber));
			text(blobMeasurements(blobNumber).Centroid(1), blobMeasurements(blobNumber).Centroid(2), ...
				overlayMessage, 'Color', 'r');
            shape
		end
	% 	button = questdlg(message, 'Continue', 'Continue', 'Cancel', 'Continue');
	% 	if strcmp(button, 'Cancel')
	% 		break;
	% 	end
	end
end