#!/bin/bash                                                                                                                                           
alias check_gpus="sudo salt '*' cmd.run runas=bria 'nvidia-smi'"
alias whos_gpus="sudo salt '*' cmd.run 'nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs -I {} ps -p {} -o user=' | sort | uniq -c |\
 awk '!/colfax/' | sort -k1nr"

# displays which user is running how many processes across all GPUs                                                                                   
gpustats () {
    sudo salt '*' cmd.run 'nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs -I {} ps -p {} -o user=' | sort | uniq -c | awk '!/colfa\
x/' | sort -k1nr
}

# displays which GPU is used by which user                                                                                                            
gpuusage () {
    sudo salt '*' cmd.run 'nvidia-smi --query-compute-apps=pid --format=csv,noheader | xargs -I {} ps -p {} -o user='
}

# displays free GPUs on cluster                                                                                                                       
gpufree () {
    sudo salt '*' cmd.run "nvidia-smi --query-gpu=memory.used --format=csv,noheader | awk '{print \$1}' | xargs -n 1 bash -c 'echo \$((\$1<1000))' ar\
gs| awk '"\!"/0/' | awk '{ printf \"FREE GPU: %s\n\", \$1}'"
    }