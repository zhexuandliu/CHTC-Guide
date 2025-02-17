# let's call this file "submit.R"
args = as.numeric(commandArgs(trailingOnly=TRUE)) # read the arguments
n = args[1]
d = args[2]

# load the data, and it should be transfered in the ".submit" file
load("submit.RData")

result = n * d * a

save(result, file = paste0("result_", n, "_", d, ".RData"))