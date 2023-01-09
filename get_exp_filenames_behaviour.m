function [ full_filenames, fileIDs ] = get_exp_filenames_behaviour( parent_directory, experiment, extract_or_analyse, rats, drugs )
%GET_EXP_FILENAMES Give list of filenames for a given pharmacology experiment.
%
%   INPUTS: 
%
%   parent_directory - string of location of parent folder of data
%   
%   experiment - name of the folder where the data for the
%   experiment is kept, e.g. 'systemic_D1antagonist_cohort2'
%
%   extract_or_analyse - extract for extracting data from MED-PC files,
%   analyse for analysing data from .mat files
%
%   rats - rats to be analysed in format {'13','14'} etc. (must be 2
%   characters)
%
%   drugs - drugs to be analysed in format {'sal_','skfh'} etc. (must be 4
%   characters)
%
%   NOTE: filenames are always in the following format: exp no, animal no,
%   training stage, drug, date

exp_directory = fullfile(parent_directory,experiment,'/');

% get all filenames based on intention to extract (without .mat extension) or analyse (with .mat extension)
if extract_or_analyse == 'extract' 
    data_files_info = dir([exp_directory,]);
    files = {data_files_info.name};
    files(ismember(files,{'.','..','.DS_Store'})) = [];
    myindices = find(~cellfun(@isempty,strfind(files,'mat'))); % If there are already .mat files in the folder, find them
    files([myindices])=[]; % And remove them from file list
    files = strcat(exp_directory,files); % Add the folder directory to the list of files
else
    data_files_info = dir([exp_directory,'*.mat']); % find the .mat files
    files = {data_files_info.name};
    files = strcat(exp_directory,files);
end

% take only the files that match the rats and drugs required
for ifile = 1:length(files)
    fileID    = erase(files{ifile},experiment);
    fileID    = erase(fileID,parent_directory); % identify the name of the session
    animal_no = fileID(6:7);
    drug      = fileID(15:18);
    fileID    = fileID(2:end);
    if ismember(animal_no,rats) && ismember(drug,drugs) % if numbers and drugs match inputted, take files
        full_filenames{ifile} = files{ifile};
        fileIDs{ifile}        = fileID; 
    end
end

full_filenames = full_filenames(~cellfun('isempty',full_filenames)); % remove empty cells
fileIDs        = fileIDs(~cellfun('isempty',fileIDs));

end