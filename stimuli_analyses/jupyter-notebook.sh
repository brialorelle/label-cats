#!/bin/bash
# Try to guess an open uppper level port. This may be fragile.
CLIENTPORT=$(( ($UID % 60000 + 4096) ))
NOTEHOST=$(hostname -s)
NOTEPORT=$(( $CLIENTPORT + 1 ))
TUNNELHOST="login.sherlock.stanford.edu"

# Some instructions. 
echo "Notebook server is running on node: $(hostname -s)"
echo
echo "In a terminal on your local workstation or laptop run (entire line"
echo "is one command):"
echo
echo " ssh -L $CLIENTPORT:${NOTEHOST}:$NOTEPORT ${USER}@${TUNNELHOST}"
echo
echo "Then follow the notebook instructions below."
echo
echo
echo "Don't forget to exit the client/laptop/workstation ssh tunnel you "
echo "opened before attempting to start a new Jupyter notebook server."
echo 
echo


# Start a notebook, adjust the URL to match our convoluted tunnel above 
# so that the link will work without any extra effort. 
# unbuffer required to defeat stdout buffering. 

unbuffer jupyter-notebook --no-browser --ip=${NOTEHOST} --port=${NOTEPORT} | unbuffer -p sed "s/${NOTEHOST}:${NOTEPORT}/localhost:${CLIENTPORT}/g"