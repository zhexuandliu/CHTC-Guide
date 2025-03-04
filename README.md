# Guide to running R in CHTC

## Create a Docker image to run your R code in

1. Create a folder containing the `Dockerfile`.

   ```dockerfile
   # the file MUST be named "Dockerfile", with NO suffix
   # Base image https://rocker-project.org/images/versioned/r-ver.html
   FROM rocker/r-ver:4
   
   RUN apt-get update
   RUN apt-get install -y git vim
   
   # install packages you need
   RUN Rscript -e "install.packages('Rtsne')" # install from CRAN
   RUN Rscript -e "install.packages('remotes')"
   RUN Rscript -e "remotes::install_github('zhexuandliu/RtsneWithP')" # install from GitHub
   
   RUN chmod -R 777 /usr/local/lib/ /root/ /tmp/
   ENV HOME /root/
   ENV USER root
   ```

2. Open a terminal at the folder, then run

   ```bash
   docker login
   docker buildx build --platform linux/amd64 -t your_image_name --load .
   docker tag your_image_name yourusername/tag:latest
   docker push yourusername/tag:latest
   ```

   Note that you need to first register an account at [Docker](https://www.docker.com).

## Prepare the files to run in CHTC

Generally, other than the `Dockerfile`, you would need a `.sh` file, a `.submit` file, a `.R` file. Or if you want to run multiple jobs parallelly, you would also need a `.txt` file to pass the changing parameters to the `.R` file. Sometimes, the `.R` file needs to read some `.RData` file, so you would also have these files ready.

### `.submit` file

```bash
# let's call this file "submit.submit"
universe=docker
docker_image=yourusername/tag:latest # specify the Docker image to use

log=submit$(job_id).log # job_id is passed from the "args.txt"
error=submit$(job_id).err
output=submit$(job_id).out

executable=submit.sh # put the ".sh" file here
arguments=$(job_id) $(n) $(d) # we have two parameters, "n" and "d" that are parallelized

transfer_input_files= args.txt, submit.R, submit.RData # include all the files needed here
should_transfer_files = YES
when_to_transfer_output = ON_EXIT

request_cpus=2
request_memory=16GB
request_disk=16GB
requirements=(has_avx == true)

queue job_id, n, d from args.txt
```

### `.sh` file

```bash
# let's call this file "submit.sh"
#!/bin/bash
Rscript submit.R $2 $3 # run submit.R and pass the second and the third parameters to submit.R
```

### `.R` file

```R
# let's call this file "submit.R"
args = as.numeric(commandArgs(trailingOnly=TRUE)) # read the arguments
n = args[1]
d = args[2]

# load the data, and it should be transfered in the ".submit" file
load("submit.RData")

result = n * d * a

save(result, file = paste0("result_", n, "_", d, ".RData"))

```

## Submit jobs to CHTC

1. First of all, you should have a CHTC account, which you can apply at the CHTC [website](https://chtc.cs.wisc.edu/uw-research-computing/form.html).

2. Log into your account in the terminal.

   ```bash
   ssh username@ap2002.chtc.wisc.edu
   ```

3. Upload all the files to CHTC. I prefer using [Cyberduck](https://cyberduck.io/download/) to upload/download files.

4. Submit your jobs.

   ```
   condor_submit submit.submit
   ```

5. Other commands in `HTCondor` that I find useful.

   ```bash
   # query your jobs
   condor_q job_id
   
   # query jobs on hold
   condor_q -hold
   
   # analyze a job (e.g., why a job keeps idle)
   condor_q -better-analyze job_id
   
   # remove a job
   condor_rm job_id
   ```

## Resources

1. [CHTC Examples](https://xinranmiao.github.io/blog/20230313chtc/) by Xinran Miao.
