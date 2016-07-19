function sleep_MPFC_PPI(pt)


cd(['e:\sleepdata\ds201_R0.9.0\GLMs\glm_t-tests\' pt '\'])

SPMmat = ['e:\sleepdata\ds201_R0.9.0\GLMs\glm_t-tests\' pt '\SPM.mat'];

matlabbatch{1}.spm.util.voi.spmmat = {['e:\sleepdata\ds201_R0.9.0\GLMs\glm_t-tests\' pt '\SPM.mat']};
matlabbatch{1}.spm.util.voi.adjust = 0;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'MPFC';
matlabbatch{1}.spm.util.voi.roi{1}.sphere.centre = [-2 58 28];
matlabbatch{1}.spm.util.voi.roi{1}.sphere.radius = 6;
matlabbatch{1}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.expression = 'i1';

spm_jobman('run',matlabbatch)

ppiflag = 'ppi';
VOI_name = ['e:\sleepdata\ds201_R0.9.0\GLMs\glm_t-tests\' pt '\VOI_MPFC_1.mat'];
design = [1 1 1; 2 1 -1];
PPI_name = 'AN_HA';

spm_peb_ppi(SPMmat,ppiflag,VOI_name,design, PPI_name, 0)

mkdir PPI
movefile(['PPI_' PPI_name '.mat'], ['PPI\PPI_' PPI_name '.mat'])
cd PPI

load(['PPI_' PPI_name '.mat'])

load ppi_1st_job.mat 


job.dir = {['e:\sleepdata\ds201_R0.9.0\GLMs\glm_t-tests\' pt '\PPI']}
job.sess.regress(1).val = PPI.ppi;
job.sess.regress(2).val = PPI.Y;
job.sess.regress(3).val = PPI.P;


cd(['e:\sleepdata\ds201_R0.9.0\' pt(1:8) '\ses-' pt(end) '\func']);
fname = ls('swuasub*.nii');
V=spm_vol(fname);
nscans = size(V,1); % number of TRs in the scan
job.sess.scans = {};
%set up scan names as SPM wants them
for rdx = 1:nscans
    ff=([pwd '\' fname ',' num2str(rdx)]);
    job.sess.scans(rdx) = {ff};
end
cd(job.dir{1})
if exist('SPM.mat', 'file');
    delete('SPM.mat')
end
spm_run_fmri_spec(job)

cd(job.dir{1} )
load SPM
spm_spm(SPM);
%the following line can be enabled to save residuals. 
% VRes = spm_write_residuals(SPM,NaN);

contrasts = [1 0 0 0]

analyze_spm_contrasts( job.dir{1}, contrasts, {'PPI_inter'});
