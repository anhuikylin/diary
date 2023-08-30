# 以管理员方式运行
library(rstudioapi)
convertTheme(
  'e:/count/liangfei2021_12_22.tmTheme',#文件路径
  add = TRUE,#是否添加
  # outputLocation = 'C:/Program Files/RStudio/resources/themes',#主题路径
  outputLocation = 'C:/Program Files/RStudio/resources/app/resources/themes',
  apply = TRUE,#是否应用
  force = TRUE,#是否强制操作并覆盖现有的同名文件
  globally = FALSE #TRUE这将尝试为所有用户安装主题
)
