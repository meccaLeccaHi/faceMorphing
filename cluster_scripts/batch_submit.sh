#!/bin/bash 

# batch_submit(begin_frame,end_frame)

slots=1;
queue="UI.q" # all.q

# loop for each frame from begin_frame to end_frame
for i in $(eval echo {$1..$2}); 
do
	# first, create shell script for each job to be submitted	
	echo "#Set the name of the job. This will be the first part of the error/output filename.     
	#$ -N Rmf${i}_${slots}sl
     
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
	/bin/echo Running on host: \`hostname\`.
	/bin/echo In directory: \`pwd\`
	/bin/echo Starting on: \`date\`

	#Send e-mail at beginning/end/suspension of job
	#$ -m es

	#E-mail address to send to
	#$ -M ajones173@gmail.com

	#Actual job
	Rscript /Users/apjons/R/faceMorphingTool/faceMorphBatch.R $i $i

	#Print the end date of the job before exiting
	echo Job finished at: \`date\`"  > batch_job${i}_${slots}sl.sh

	# make that shell script executable
	chmod +x batch_job${i}_${slots}sl.sh

	# submit that script
	qsub batch_job${i}_${slots}sl.sh

	# delete that script
	rm batch_job${i}_${slots}sl.sh

done



