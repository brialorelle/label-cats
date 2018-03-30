function copyAndResaveImages()

% get sets
topDir=pwd;
stimDir='setImages'
sets = getVisibleFolders(stimDir)

for s=1:length(sets)
    thisSet = sets(s).name
    setDir = fullfile(topDir, stimDir, thisSet);
    categoryList = getVisibleFolders(setDir);
  
    for c=1:length(categoryList)
        thisCategory = categoryList(c).name;
        categoryDir = fullfile(setDir, thisCategory);
        %
        stimSaveDir = ['allImages' filesep thisCategory]
        if exist(stimSaveDir)
            rmdir(stimSaveDir,'s')
        end
        mkdir(stimSaveDir)
        imList =  getVisibleFiles(categoryDir)
        
    for i=1:length(imList)
        im = imread(fullfile(topDir, stimDir, thisSet, thisCategory, imList(i).name));
        saveName = [thisCategory '_' num2str(i) '.jpg'];
        saveFileName = [stimSaveDir filesep saveName]
        imwrite(im, saveFileName, 'jpg');
    end
    
end

end

end

function files = getVisibleFolders(stimDir)
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

function files = getVisibleFiles(stimDir)
% don't get invisible files or foldres
files = dir(stimDir)
dropThese=[];
for i=1:length(files)
    if strfind(files(i).name(1),'.')
        dropThese(end+1)=i;
    end
    if files(i).isdir
         dropThese(end+1)=i;
    end
end
files(dropThese)=[];

end




