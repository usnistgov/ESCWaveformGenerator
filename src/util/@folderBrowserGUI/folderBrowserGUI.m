classdef folderBrowserGUI < matlab.apps.AppBase
    %Folder browser GUI with sort numbered files
    %   Example usage:
    %             dialogText='Select waveforms folder';
    %             defaultExt='dat';
    %             defaultDir='C:\'
    %             folderBrowser=folderBrowserGUI(defaultDir,dialogText,defaultExt)
    %             folderBrowser=SelectFolder(folderBrowser,SomeUIFig);
    %             waveformNames=getFileNames(folderBrowser,'withext');
    %             waveformPaths=getFullFileNamesWithPath(folderBrowser,'withext');
    
    properties (Access=protected)
        defaultDir
        dialogText
        defaultExt
        fileNames
        directoryName
        UIFigure     matlab.ui.Figure
    end
   
    
    methods
        function folderBrowser=folderBrowserGUI(defaultDir,dialogText,defaultExt)
            if nargin > 0
                folderBrowser.defaultDir=defaultDir;
                folderBrowser.dialogText=dialogText;
                folderBrowser.defaultExt=defaultExt;
            end
        end
        function folderBrowser=setDefaultDir(folderBrowser,defaultDir)
            folderBrowser.defaultDir=defaultDir;
        end
        function folderBrowser=setDialogText(folderBrowser,dialogText)
            folderBrowser.dialogText=dialogText;
        end
        function folderBrowser=setDefaultExt(folderBrowser,defaultExt)
            folderBrowser.defaultExt=defaultExt;
        end
        
        function fileNames=getFileNames(folderBrowser,ext)
            % return cell arry of file names
            if nargin > 1 && strcmp(ext,'withoutext')
                for f_in=1:length(folderBrowser.fileNames)
                    folderBrowser.fileNames{f_in}= folderBrowser.fileNames{f_in}(1:end-4);
                end
            end
            fileNames=folderBrowser.fileNames;
            
        end
        function directoryName=getCurrentDir(folderBrowser)
            directoryName=folderBrowser.directoryName;
        end
        function fullFileNames=getFullFileNamesWithPath(folderBrowser,ext)
            % return cell arry of file names with paths
            if nargin > 1 && strcmp(ext,'withoutext')
                for f_in=1:length(folderBrowser.fileNames)
                    filesN{f_in}= folderBrowser.fileNames{f_in}(1:end-4);
                end
            else
            filesN=folderBrowser.fileNames;
            end
            for I=1:length(filesN)
            fullFileNames{I}=fullfile(folderBrowser.directoryName,filesN{I});
            end
            fullFileNames=fullFileNames.';
        end
        function folderBrowser=SelectFolder(folderBrowser,UIFigure)
            folderBrowser.directoryName = uigetdir(folderBrowser.defaultDir,folderBrowser.dialogText);
            if folderBrowser.directoryName~=0
                default_ext=strcat('*.',folderBrowser.defaultExt);
                dirSearch=fullfile(folderBrowser.directoryName,default_ext);
                dr = dir(dirSearch);
                if isempty(dr)
                    if nargin > 1
                        uialert(UIFigure,folderBrowser.directoryName,['No ', folderBrowser.defaultExt,' files found in']);
                    end
                    %return;
                else
                    for f_in=1:length(dr)
                        file_name_cell{f_in}= dr(f_in).name;
                    end
   
                    folderBrowser.fileNames=utilFun.sortByNunbers(file_name_cell.');
                    
                end
            else
                    folderBrowser.fileNames=[];
            end
        end
        
        end

end
