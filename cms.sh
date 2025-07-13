# this script runs on Great Lakes to start the CMS app
# it is called by scripts run_remote_cms.sh/bat

module load R/4.4.3
cd /nfs/turbo/path-wilsonte-turbo/website/wilsonte-umich.github.io
Rscript cms.R
