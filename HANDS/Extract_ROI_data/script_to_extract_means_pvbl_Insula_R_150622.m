root_path = '/data/stress/HANDS_AGE/45Slices';
folders = dir(root_path);
folders = folders(arrayfun(@(folders) ~strcmp(folders.name(1), '.'),folders));

for i = 1:length(folders)
    subject_session = folders(i).name;
    s = subject_session(1:3);
    subject = str2num(s);
    ses = subject_session(5);
    session = str2num(ses);
    LammMask = mean(spm_summarise(strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/1st_level_150320/con_0001.nii'), struct('def', 'mask', 'spec', '/data/stress/HANDS_AGE/Factorial_sleep_age/PainvsBaseline/AgeXsleep_pvsbl_Insula_R.nii')));

   if i == 1
       data = [subject, session, LammMask];
   else
       data = [data; subject, session, LammMask];
   end
end

root_path = '/data/stress/HANDS_AGE/46Slices';
folders = dir(root_path);
folders = folders(arrayfun(@(folders) ~strcmp(folders.name(1), '.'),folders));

for i = 1:length(folders)
    subject_session = folders(i).name;
    s = subject_session(1:3);
    subject = str2num(s);
    ses = subject_session(5);
    session = str2num(ses);
    LammMask = mean(spm_summarise(strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/1st_level_150320/con_0001.nii'), struct('def', 'mask', 'spec', '/data/stress/HANDS_AGE/Factorial_sleep_age/PainvsBaseline/AgeXsleep_pvsbl_Insula_R.nii')));

   if i == 1
       data2 = [subject, session, LammMask];
   else
       data2 = [data2; subject, session, LammMask];
   end
end

data = [data; data2];

cd /data/stress/HANDS_AGE/ExtractedData_150622/
csvwrite('Data_Insula_R_sleepXage_pvsbl_150828', data)