# 1.导入包 -------------------------------------------------------------------

library(openxlsx)
library(tidyverse)

# 2.读取数据 ------------------------------------------------------------------
# load("D:/R项目/Molecular Plant/mGWAS-main/inputfiles/snps2016.RData")
rm(list = ls())
# 测试数据
# col：样本，row：代谢物
trait <- read.xlsx("./data/mGWASqual.xlsx",rowNames = T)[1:200,1:540]
trait <- t(trait)
trtfin<-array(rep(NA,540*2000),dim=c(540,2000))

sl<-as_tibble(ifelse(is.na(trait[,1]),0,1)) %>% count(value)
sl
sl<-as_tibble(ifelse(is.na(trait[,1]) | trait[,1] == 0, 0, 1)) %>% count(value)
sl
# 3.构建函数 ------------------------------------------------------------------

select_traits <- function(trait,n_NA) {
  trait <- t(trait)
  result <- tibble(.rows = 540)
  for (i in 1:ncol(trait)) {
    sl<-as_tibble(ifelse(is.na(trait[,i]) | trait[,i] == 0, 0, 1)) %>% 
      count(value) %>% 
      filter(value == 0) %>% 
      select(n) %>% 
      map(as.numeric) %>% 
      unlist()
    if (sl > n_NA & sl < 270) {
      result <- result %>% 
        select(everything()) %>% 
        mutate(!!colnames(trait)[i] := ifelse(is.na(trait[,i]) | trait[,i] == 0, 0, 1))
    } else {
      result <- result
    }
  }
  return(result)
}

# 4.运行函数 ------------------------------------------------------------------
# col：样本，row：代谢物
trait <- read.xlsx("./data/mGWASqual.xlsx",rowNames = T)[1:2000,1:540]
# trait <- t(trait)
select_traits(trait = trait,n_NA = 10)
result <-  select_traits(trait = trait,n_NA = 10)
rm(result)
