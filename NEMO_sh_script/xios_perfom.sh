##########################################
# this file is to test the performance of#
# xios when running parallelly with      #
# different number of procceses          #
# -------------------------------------- # 
# by yongmei.gong@helsinki.fi            #
# 21-03-2018                             #
##########################################

#!//bin/bash -l

RUN_NAME=xio
Template=Nemo_templt_xios.sh

for XIOS_PROCES in 60 72
do
    job_dir=${RUN_NAME}_${XIOS_PROCES}
    rm -rf $job_dir
    mkdir $job_dir
    cd $job_dir
    cp ../librunscript.sh .
    cp ../nemconf.cfg .

    cp ../$Template ${RUN_NAME}_${XIOS_PROCES}.sh
    
    CMD="sed -i "s/RUN_NAME/${RUN_NAME}/g" ${RUN_NAME}_${XIOS_PROCES}.sh"
    echo $CMD
    $CMD
    
    CMD="sed -i "s/XIOS_PROCES/${XIOS_PROCES}/g" ${RUN_NAME}_${XIOS_PROCES}.sh"
    echo $CMD
    command $CMD
    
    CMD="sbatch ${RUN_NAME}_${XIOS_PROCES}.sh"
    echo $CMD
    $CMD

    cd ..
done
    