# 重演一篇傻瓜式GWAS分析 
# pink安装
wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200921.zip
unzip plink_linux_x86_64_20200921.zip
echo 'alias plink="/home/data/wangpanpan/plink"' >> ~/.bash_alias
source ~/.bash_alias


# emmax安装
wget http://csg.sph.umich.edu//kang/emmax/download/emmax-beta-07Mar2010.tar.gz
tar -zxvf emmax-beta-07Mar2010.tar.gz
# alias emmax
echo 'alias emmax="/home/data/wangpanpan/emmax-beta-07Mar2010/emmax"' >> ~/.bash_alias
echo 'alias emmax-kin="/home/data/wangpanpan/emmax-beta-07Mar2010/emmax-kin"' >> ~/.bash_alias
source ~/.bash_alias


# admixture软件安装
wget http://dalexander.github.io/admixture/binaries/admixture_linux-1.3.0.tar.gz
tar -zvxf admixture_linux-1.3.0.tar.gz
cp -r /home/data/wangpanpan/dist/admixture_linux-1.3.0 /home/data/wangpanpan/
rm -r "/home/data/wangpanpan/dist/"
cd admixture_linux-1.3.0
./admixture --version

echo 'alias admixture="/home/data/wangpanpan/admixture_linux-1.3.0/admixture"' >> ~/.bash_alias
source ~/.bash_alias
admixture

# bcftools安装
wget -c https://github.com/samtools/bcftools/releases/download/1.13/bcftools-1.13.tar.bz2
tar xjvf bcftools-1.13.tar.bz2
cd bcftools-1.13
make
make install
echo 'PATH=$PATH:/home/data/wangpanpan/GWAS_test/bcftools-1.13/htslib-1.13/bin:$PATH' >> ~/.bashrc
source ~/.bashrc



mkdir ~//GWAS_test
cd ~//GWAS_test
#样本VCF文件和表型数据下载
wget https://de.cyverse.org/dl/d/E0A502CC-F806-4857-9C3A-BAEAA0CCC694/pruned_coatColor_maf_geno.vcf.gz
wget https://de.cyverse.org/dl/d/3B5C1853-C092-488C-8C2F-CE6E8526E96B/coatColor.phen

# 解压pruned_coatColor_maf_geno.vcf.gz
gzip -d pruned_coatColor_maf_geno.vcf.gz
plink --vcf pruned_coatColor_maf_geno.vcf --recode 12 transpose --out emmax_in --allow-extra-chr --chr-set 37

# 计算群体结构
touch admixture.sh
chmod +x admixture.sh
# admixture.sh的内容
#!/bin/bash
for i in {1..5}
do
/home/data/wangpanpan/admixture_linux-1.3.0/admixture --cv emmax_in.bed ${i} -j48 >> emmax_cov.txt
done
# 去除\r字符
sed -i 's/\r//' admixture.sh

# 修改emmax_in.tfam和表型文件
# R脚本内容
library(tidyverse)
tfam <- read.table("emmax_in.tfam", header = F, stringsAsFactors = F)
tr <- read.table("coatColor.phen", header = F, check.names = F, stringsAsFactors = F)
head(tr)


df1 <- tfam %>% 
  mutate(V1 = paste0(V1,"_",V2),
         V2 = V1)
tfam %>% 
  mutate(V1 = paste0(V1,"_",V2),
         V2 = V1) %>% 
  write.table("emmax_in2.tfam",
              quote = FALSE,
              row.names = FALSE,
              col.names = FALSE,sep='\t')

df2 <- df1 %>% select(V1)
df3 <- tr %>% 
  select(V1,V3) %>% 
  right_join(.,df2,by = "V1") %>% 
  mutate(V2 = V1,
         V3 = ifelse(V3 == "dark", "1", V3),
         V3 = ifelse(V3 == "yellow", "0", V3)) %>% 
  select(V1,V2,V3)

df4 <- plyr::join(df2,df3,by = "V1")
write.table(df4,"coatColor2.phen",
            quote = FALSE,
            row.names = FALSE,
            col.names = FALSE,sep='\t')

# gwas分析
emmax -t emmax_in -p coatColor2.phen -k emmax_in.BN.kinf -o emmax_result