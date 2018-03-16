% make all images same pixel count

addpath('HelperCode')


% parameters
frame       = 600;

% chose these parameters so that all images could be resized to these
% dimesnsions without any problems...
visSize      = 15; % percent of frame area

% helpers
frameArea       = frame*frame;
visPixelCount   = frameArea * visSize/100;

% get conditions by reading image files folder
topDir=pwd;
stimDir='Step0b-SelectedCategories'
folderContents=dir(stimDir);
dropThese=[];
for i=1:length(folderContents)
    if strfind(folderContents(i).name,'.')
        dropThese(end+1)=i;
    end
end
folderContents(dropThese)=[];
conditions=folderContents

% remove that directory if it's already there:
saveDir = 'Step1-ResizedImages-Selected';
if exist(saveDir, 'dir')
    rmdir(saveDir, 's')
end
mkdir(saveDir)

% loop through all images:
for s=1:length(conditions)
    % get list
    imList = dir(fullfile(topDir, stimDir, conditions(s).name, '*.jpg'))
    
    stimSaveDir=[saveDir filesep conditions(s).name]
    if exist(stimSaveDir)
        rmdir(stimSaveDir,'s')
    end
    mkdir(stimSaveDir)
    countCat=0;
    
    for i=1:length(imList)
        try
        % read in image
        im = imread(fullfile(topDir, stimDir, conditions(s).name, imList(i).name));
        
        [resizedIm flag] = imAreaResize(im, visPixelCount, frame);
        
        if any(size(mean(im,3))<300) % don't get low-res images
            flag=1
        end
        
        if ~flag & countCat<20 %only get 10 per cat right now
            disp(['saving... ' imList(i).name])
            countCat=countCat+1;
            if countCat<10
                imageStr=['0' num2str(countCat)];
            else 
                imageStr=num2str(countCat);
            end
            
            fn = fullfile(saveDir, [conditions(s).name], [imageStr '_' conditions(s).name '_'  imList(i).name]);
            imwrite(resizedIm./255, fn, 'png');
        end
        catch
            disp(['error with image' imList(i).name])
        end
    end
    
end


s








