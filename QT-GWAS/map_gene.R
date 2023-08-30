# 1.导入程序包 -----------------------------------------------------------------

library(tidyverse)
library(stringr)

# 2.导入数据 ------------------------------------------------------------------

rm(list = ls())
data <- read.delim("./data/ZmB73_5a.59_WGS.gff3",header = FALSE)

gene_infornation <- data %>% 
  filter(V3 != "chromosome")

# 3.定义函数 ------------------------------------------------------------------
# snp：fisher.test()筛选的显著的snp位点。eg:161134994
# Chr：所在染色体。eg:6
# range:default 30 kb up- and 30 kb downstream
# gene_ann:ZmB73_5a.59_WGS.gff3文件
map_gene <- function(snp, Chr, range = 30, gene_ann) {
  start <- as.numeric(snp) - range*1000
  end <- as.numeric(snp) + range*1000
  range <- paste0(start,"--",end)
  # start:V4 end:V5
  gene <- gene_ann %>% 
    filter(V4 >= start, V5 <= end, V1 == paste0("Chr",Chr),
           str_detect(V9, "ID"), !str_detect(V9, "Parent")) %>% 
    mutate(V10 = str_extract(V9, "(?<=\\ID=).+?(?=\\;Name)")) %>% 
    select(V1, V4, V5, V10) %>% 
    rename(Chr = V1, start = V4,
           end = V5, gene_id = V10) %>% 
    mutate(Significant_snp = as.numeric(snp))
  # output
  information <- list(start = start, 
                      end = end,
                      range = range,
                      gene = gene)
  class(information) <- append(class(information), "result")
  return(information)
}

# 4.运行函数 ------------------------------------------------------------------

result <- map_gene(snp = 200730202,
                   Chr = 2,
                   range = 30,
                   gene_ann = gene_infornation)
result$start
result$end
result$range
result$gene



