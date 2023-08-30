# 1.玉米群体样本信息 --------------------------------------------------------------

# 根正常：373
# 根盐：343
# 叶盐：360
# 叶正常：357

# 2.加载包 -------------------------------------------------------------------

library(openxlsx)
library(tidyverse)
# 3.读取数据 ------------------------------------------------------------------
# load("D:/R项目/Molecular Plant/mGWAS-main/inputfiles/snps2016.RData")
rm(list = ls())
# 测试数据
# col：样本，row：代谢物
trait <- read.xlsx("./data/mGWASqual.xlsx",rowNames = T)[1:200,1:540]

# 4.构建函数 ------------------------------------------------------------------

select_traits <- function(trait) {
  trait <- t(trait)
  result <- tibble(.rows = 540)
  for (i in 1:ncol(trait)) {
    sl<-as_tibble(ifelse(is.na(trait[,i]) | trait[,i] == 0, 0, 1)) %>% 
      count(value) %>% 
      filter(value == 1) %>% 
      select(n) %>% 
      map(as.numeric) %>% 
      unlist()
    tryCatch(
      {if (sl >  270) {
        result <- result %>% 
          select(everything()) %>% 
          mutate(!!colnames(trait)[i] := ifelse(is.na(trait[,i]) | trait[,i] == 0, 0, 1))
        } else {
          result <- result
          }
      },
      error = function(err) {
        # message("出现错误：", conditionMessage(err))
        # message(paste0(i,"行全是NA"))
        # message(paste0("\033[38;5;202m", i, "行全是NA", "\033[0m"))
        message(paste0("\033[38;5;165m", i, "行全是NA", "\033[0m"))
        # 其他处理错误的代码
      },
      warning = function(wrn) {
        message("出现警告：", conditionMessage(wrn))
        # 其他处理警告的代码
      },
      finally = {
        result <- result}
    )
    
  }
  message(paste0("\033[38;5;51m",rep("质量性状筛选完成！！！",3), "\033[0m"))
  return(result)
}
# 5.运行函数 ------------------------------------------------------------------
# col：样本，row：代谢物
trait <- read.xlsx("./data/mGWASqual.xlsx",rowNames = T)[1:2000,1:540]
result <- select_traits(trait = trait[1:2000,])# 778
trait <- read.xlsx("./data/mGWASqual.xlsx",rowNames = T)[,1:540]
result <- select_traits(trait = trait)
# 6.对结果进行随机检验 ---------------------------------------------------------------

table(result[,sample(1:ncol(result),size = 1,replace = F)])
