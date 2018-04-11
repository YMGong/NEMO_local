#!/bin/sh
#SBATCH -t 06:00:00
#SBATCH -J DFS52
#SBATCH -N 1

FTP_HOST=ftp://ds.data.jma.go.jp
FTP_USER=jra04737
FTP_PASS=*****


DIR_BASE=JRA-55/Hist
DURATION=Daily #Monthly_diurnal # What to we want?
#VAR=anl_column anl_column125 anl_isentrop125 anl_land anl_land125 anl_mdl anl_p125 anl_snow anl_snow125 anl_surf anl_surf125 fcst_column fcst_column125 fcst_land fcst_land125 fcst_p125 fcst_phy2m fcst_phy2m125 fcst_phyland fcst_phyland125 fcst_surf fcst_surf125 ice ice125 minmax_surf




#ftp -n $FTP_HOST << EOF | tee -a ${LOCAL_LOG} | grep -q "${ERROR}"
#quote USER ${FTP_USER}
#quote pass ${FTP_PASS}
#cd ${DIRECTORY}
#EOF

#if [[ "${PIPESTATUS[2]}" -eq 1 ]]; then
#    echo ${DIRECTORY} exists
#else
#    echo ${DIRECTORY} does not exist
#fi

for data_nm in {01..20}
do
    DIRECTORY=/data"$data_nm"/"$DIR_BASE"/"$DURATION"
    
   wget -r --user="$FTP_USER" --password="$FTP_PASS" "$FTP_HOST"/data"$data_nm"/"$DIR_BASE"/"$DURATION"
done



#anl_column anl_column125 anl_isentrop125 anl_land anl_land125 anl_mdl anl_p125 anl_snow anl_snow125 anl_surf anl_surf125 fcst_column fcst_column125 fcst_land fcst_land125 fcst_p125 fcst_phy2m fcst_phy2m125 fcst_phyland fcst_phyland125 fcst_surf fcst_surf125 ice ice125 minmax_surf
