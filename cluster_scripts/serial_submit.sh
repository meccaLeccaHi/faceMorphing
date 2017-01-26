#!/bin/bash 

# serial_submit.sh

slots=3;
queue="UI";

echo "#Set the name of the job. This will be the first part of the error/output filename.     
#$ -N Rmf$1-$2_${slots}sl
     
#Set the shell that should be used to run the job.
#$ -S /bin/bash

#Set the current working directory as the location for the error and output files.
#(Will show up as .e and .o files)
#$ -cwd

#Select the queue to run in (UI or all.q)
#$ -q $queue

#Opt for jobs to be resheduled in the event of failure
#$ -r yes

#Select the number of slots the job will use
#(Up to 16)
#$ -pe smp $slots

#Print information from the job into the output file
/bin/echo Running on host: `hostname`.
/bin/echo In directory: `pwd`
/bin/echo Starting on: `date`

#Send e-mail at beginning/end/suspension of job
#$ -m es

#E-mail address to send to
#$ -M ajones173@gmail.com

#Actual job
Rscript /Users/apjons/R/faceMorphingTool/faceMorphWrap.R $1 $2

#Print the end date of the job before exiting
echo Job finished at: `date`"  > batch_job$1-$2_${slots}sl.sh

	chmod +x batch_job$1-$2_${slots}sl.sh

	qsub batch_job$1-$2_${slots}sl.sh

	rm batch_job$1-$2_${slots}sl.sh

done



