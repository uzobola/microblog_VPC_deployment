#!/bin/bash
#
# This script will SSH into the "Application_Server" to run the "start_app.sh" script.


# SSH into the Application Server 
echo " SSH'ing into the Application Server"
sleep -2 


ssh -i /home/ubuntu/.ssh/microblog.pem ubuntu@10.0.137.42 << EOF
	source /home/ubuntu/scripts/start_app.sh
EOF


