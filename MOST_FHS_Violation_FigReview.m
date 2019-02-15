function MOST_FHS_Violation_FigReview()

    %% ask user for folder to review FHS violation figure files
    source_dir = uigetdir(cd,'Select folder for FHS Violations figure review.');

    %% get paths to accept/reject/unsure folders or make them if they don't exist
    accept_dir = horzcat(source_dir,'\','Accept');
    reject_dir = horzcat(source_dir,'\','Reject');
    unsure_dir = horzcat(source_dir,'\','Unsure');

    if(~exist(accept_dir,'dir'))
        mkdir(accept_dir);
    end
    if(~exist(reject_dir,'dir'))
        mkdir(reject_dir);
    end
    if(~exist(unsure_dir,'dir'))
        mkdir(unsure_dir);
    end
    
    %% make save file for recording some info 
    save_file = horzcat(source_dir,'\','MOST_FHS_Violation_ReviewResults_',datestr(now,'yyyymmdd'),'.csv');
    

    %% get list of .fig files to review
    folder_properties = dir(source_dir); %search directory
    file_list_cell = {folder_properties(:).name}'; %list all the files in a cell

    fig_file_ext_match = regexpi(file_list_cell,'\.fig'); %look for .fig files using regular expressions
    fig_file_indices = ~cellfun(@isempty,fig_file_ext_match);

    fig_file_list_cell = file_list_cell(fig_file_indices,:); %list only the .fig files 

    %% loop through each .fig file, exiting not coded: please use Ctrl+C to exit instead

    for ix=1:size(fig_file_list_cell,1)

        % .fig file for this loop
        tmp_fig_filename = fig_file_list_cell{ix,1};

        % extract just the filename root (strip off the file extension)
        [~,fig_file_root,~] = fileparts(tmp_fig_filename);

        % construct the full path filename for the .fig and the .jpg as well
        tmp_fig_pathfile = horzcat(source_dir,'\',fig_file_root,'.fig');
        tmp_jpg_pathfile = horzcat(source_dir,'\',fig_file_root,'.jpg');

        % open the .fig file
        hf = open(tmp_fig_pathfile);
        set(hf,'Name',horzcat('Review #: ',num2str(ix)));
        set(hf,'Position',[1,31,1900,1080]);

        % load the saved metadata about this trial
        tmp_metadata = hf.UserData;

            % some useful info for future use
            tmp_fhs_data_filename = tmp_metadata.DataFile; % filename of source data file
            tmp_fhs_video_filename = tmp_metadata.VideoFile; %filename of source video file
            tmp_fhs_violationtype = tmp_metadata.ViolationType; %the FHS violation type
            tmp_fhs_video_len = tmp_metadata.VideoLength; %calculated time length of AVI video
            tmp_fhs_data_len = tmp_metadata.DataLength; %calculated time length of .txt data file

        % set the review buttons
        hbuttons{1,1} = uicontrol(hf,'Style','pushbutton','String','Accept','Units','normalized','Position',[0.45 0.05 0.1 0.05],'Callback',{@MoveReviewedFiles,tmp_fig_pathfile,tmp_jpg_pathfile,accept_dir, 'accept',save_file});
        hbuttons{2,1} = uicontrol(hf,'Style','pushbutton','String','Reject','Units','normalized','Position',[0.65 0.05 0.1 0.05],'Callback',{@MoveReviewedFiles,tmp_fig_pathfile,tmp_jpg_pathfile,reject_dir, 'reject',save_file});
        hbuttons{3,1} = uicontrol(hf,'Style','pushbutton','String','Unsure','Units','normalized','Position',[0.85 0.05 0.1 0.05],'Callback',{@MoveReviewedFiles,tmp_fig_pathfile,tmp_jpg_pathfile,unsure_dir, 'unsure',save_file});

        % pause the code until the figure is closed
        uiwait(hf);

        % continue with for-loop after the figure it closed
    end

function MoveReviewedFiles(varargin)

    % parse inputs from button click
    fig_pathfile_input = varargin{1,3};
    jpg_pathfile_input = varargin{1,4};
    destination_dir = varargin{1,5};
    review_result = varargin{1,6};
    save_file = varargin{1,7};
    
    % construct destination path file
    [~,fig_file_root_in,~] = fileparts(fig_pathfile_input);
    [~,jpg_file_root_in,~] = fileparts(jpg_pathfile_input);
    
    fig_pathfile_output = horzcat(destination_dir,'\',fig_file_root_in,'.fig');
    jpg_pathfile_output = horzcat(destination_dir,'\',jpg_file_root_in,'.jpg');
    
    % move the files
    movefile(fig_pathfile_input,fig_pathfile_output);
    movefile(jpg_pathfile_input,jpg_pathfile_output);
    
    % write the results in a csv file as well
    fid = fopen(save_file,'a');
    fprintf(fid,'%s',fig_pathfile_input);
    fprintf(fid,'%s',',');
    fprintf(fid,'%s',fig_pathfile_output);
    fprintf(fid,'%s',',');
    fprintf(fid,'%s',review_result);
    fprintf(fid,'%s\n','');
    fclose(fid);
    
    % close the figure now
    close(gcf);
