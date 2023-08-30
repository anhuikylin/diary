rm(list = ls())
snp <- read.delim("./data/125M_numerical_genotype_10000.txt",row.names = 1)
# while
trait <- sample(c(0,1), 540, replace = TRUE)
trait <- snp[,1]
# fisher.test
fisht <- fisher.test(trait,snp[,2])
fisht$p.value
# 开始计时
start_time <- Sys.time()
# 运行你的R程序
len <- 0
for (i in 1:9999) {
  fisht <- fisher.test(trait,snp[,i])
  if (fisht$p.value <= 0.000001) {
    print(paste0(colnames(snp)[i],":",fisht$p.value))
    len <- len+1
  } 
}
print(len)
# 结束计时
end_time <- Sys.time()
execution_time <- end_time - start_time
print(execution_time)
