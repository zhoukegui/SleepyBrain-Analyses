%-----------------------------------------------------------------------
% Job saved on 13-Jan-2015 10:43:19 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%---------------------------------------
% Script to perform 1st level analysis in the HANDS experiment. Onsetfiles contains onsetfiles without parametric modulations 
%--------------------------------
% Subjects who had 45 slices
root_path = '/data/stress/HANDS_AGE/45Slices';
folders = dir(root_path);
folders = folders(arrayfun(@(folder) ~strcmp(folder.name(1), '.'),folders));


for i = 1:length(folders)
    subject_session = folders(i).name
    subject = subject_session(1:3);
    session = subject_session(5);
    
    files = dir(strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/swua*.nii'));
    data = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/', file.name), files, 'UniformOutput', false);
    motionparameters = dir(strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/rp*.txt'));
    motionparameters = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/', file.name), motionparameters, 'UniformOutput', false);
    mkdir(strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/1st_level_modulated'));
    directory = cellstr(strcat('/data/stress/HANDS_AGE/45Slices/', subject_session, '/1st_level_modulated'));

    onsets = dir(strcat('/data/stress/HANDS_AGE/Onsetfiles_modulated/', subject_session, '*.mat'));
    onsets = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/Onsetfiles_modulated/', file.name), onsets, 'UniformOutput', false);
   

    matlabbatch{1}.spm.stats.fmri_spec.dir = directory;
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 3;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 45;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 2;

    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = data;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = motionparameters;
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Rated unpleasantness vs baseline';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Rated unpleasantness vs no pain';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Rated unpleasantness vs pain';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch)

    clear matlabbatch 

end

% In rating file for subject 253, session 1 - check that there are no NAs
% (remove otherwise)
% For subject 352, session 1, there is one rating missing (18 instead of 19
% (there are 19 pain events). One 0 should be added at the end. Probably
% after scanning stoped? Also no NAs should be there
% Subjects who had 46 slices
% Remove 190 and 354, because these participant rated 0 through the whole experiment
root_path = '/data/stress/HANDS_AGE/46Slices';
folders = dir(root_path);
folders = folders(arrayfun(@(folder) ~strcmp(folder.name(1), '.'),folders));


for i = 1:length(folders)
    subject_session = folders(i).name
    subject = subject_session(1:3);
    session = subject_session(5);
    
    files = dir(strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/swua*.nii'));
    data = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/', file.name), files, 'UniformOutput', false);
    motionparameters = dir(strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/rp*.txt'));
    motionparameters = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/', file.name), motionparameters, 'UniformOutput', false);
    mkdir(strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/1st_level_modulated'));
    directory = cellstr(strcat('/data/stress/HANDS_AGE/46Slices/', subject_session, '/1st_level_modulated'));

    onsets = dir(strcat('/data/stress/HANDS_AGE/Onsetfiles_modulated/', subject_session, '*.mat'));
    onsets = arrayfun(@(file) strcat('/data/stress/HANDS_AGE/Onsetfiles_modulated/', file.name), onsets, 'UniformOutput', false);
   

    matlabbatch{1}.spm.stats.fmri_spec.dir = directory;
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 3;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 46;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = data;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = onsets;
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = motionparameters;
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Rated unpleasantness vs baseline';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Rated unpleasantness vs no pain';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Rated unpleasantness vs pain';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    spm_jobman('run', matlabbatch)

    clear matlabbatch 

end