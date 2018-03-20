function [newIm flag newPxCount] = imAreaResize(im, targetPxCount, frame)


% resize image to have the proper target pixel count
% pad image to fill a frame
% error if the image doesn't fit in the frame size (by how much is it
% over?)


imBW        = mean(im,3);
imThresh    = imBW<253;
pxCount     = sum(imThresh(:));
pxTotal     = length(imThresh(:));
pctArea     = pxCount/pxTotal * 100;

% 
subplot(1,2,1)
imshow(imBW./255);  axis square;
subplot(1,2,2)
imshow(imThresh); axis square;
% write saVe figure function here
keyboard

% compute the size it has to be to achieve the target Px Count
scaleFactor = sqrt(targetPxCount/pxCount);

% critical step here!
newIm = imresize(im, scaleFactor);

% recalculate new px count
imBW        = mean(newIm,3);
imThresh    = imBW<253;
newPxCount  = sum(imThresh(:));

% [targetPxCount newPxCount]
% size(newIm)

if size(newIm, 1)>frame
    % if the new image doesn't fit in the frame error
    flag=1;
    disp(['Image does not fit in frame: ' num2str(size(newIm,1)) ' pixels'])
else
    % if it fits, center it in the frame
    flag=0;
    blankIm = repmat(255, [frame frame 3]);
    offset = floor((frame-size(newIm,1))/2);
    blankIm(offset+1:offset+(size(newIm,1)), offset+1:offset+(size(newIm,1)),:) = newIm;
    newIm = blankIm;
end

