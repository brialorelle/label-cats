function resizeImages()
% make all images same pixel count
addpath('HelperCode')

% parameters
frame       = 600;

% percent of frame area
visSize      = 10; 

% helpers
frameArea       = frame*frame;
visPixelCount   = frameArea * visSize/100;

% get categories by reading image files folder
topDir=pwd;
stimDir='set1'
categories = getVisibleFiles(stimDir)

% remove that directory if it's already there:
saveDir = 'set1_resized';
if exist(saveDir, 'dir')
    rmdir(saveDir, 's')
end
mkdir(saveDir)

% loop through all images:
for s=1:length(categories)
    % get list
    imageDir = fullfile(topDir, stimDir, categories(s).name);
    imList = getVisibleFiles(imageDir);
    
    stimSaveDir=[saveDir filesep categories(s).name]
    if exist(stimSaveDir)
        rmdir(stimSaveDir,'s')
    end
    mkdir(stimSaveDir)
    countCat=0;
    
    for i=1:length(imList)
        try
        % read in image
        im = imread(fullfile(topDir, stimDir, categories(s).name, imList(i).name));
        
        % image(im) % show me the image
        % imageBW = mean(im,3)./255;
        
        [resizedIm flag newPxCount] = imAreaResize(im, visPixelCount, frame);
        
        if any(size(mean(im,3))<300) % don't get low-res images
            disp('image too small!')
            flag=1
        end
        
        if ~flag 
            disp(['saving... ' imList(i).name])
            countCat=countCat+1;
            if countCat<10
                imageStr=['0' num2str(countCat)];
            else 
                imageStr=num2str(countCat);
            end
            
            fn = fullfile(saveDir, [categories(s).name], [imageStr '_' categories(s).name '_'  imList(i).name]);
            imwrite(resizedIm./255, fn, 'png');
        end
        
        catch
            disp(['error with image' imList(i).name])
        end
    end
    
end


s

end

function files = getVisibleFiles(stimDir)
% don't get invisible files
files=dir(stimDir);
dropThese=[];
for i=1:length(files)
    if strfind(files(i).name(1),'.')
        dropThese(end+1)=i;
    end
end
files(dropThese)=[];

end




