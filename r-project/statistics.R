## Statistics

library(ggplot2)
library(ggthemes)
setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")

## load data
kobo <- read.csv("KoboData.csv")

# limits=c("2","1","0.5")

#ggplot(kobo, aes(x=krankheit)) + geom_bar(width = 0.5, color="black", fill="light grey")+ 
#  theme_classic() + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

Krank <- table(kobo$krankheit)
Blatt <- table(kobo$befallBlatt)
Menge <- table(kobo$befallmenge)
Wtyp  <- table(kobo$weintyp)


# Erstelle Barplots
names(Krank) <- c("Botrytis", "Echter Mehltau", "Esca", "Falscher Mehltau", "Gar keine", "Kirschessigfliege", "Schwarzhilzkrankheit")
barplot(Krank,las=2)
names(Blatt) <- c("0% -2.5%", "2.5%-10%","25%-50%","50%-100%")
barplot(Blatt)
names(Menge) <- c("0%", "bis 20%", "bis 40%", "bis 60%", "bis 80%", "bis 100%")
barplot(Menge)
names(Wtyp) <- c("Andere", "Chardonay", "Malbec", "Merlot", "Pinor Gris", "Pinor Noir", " Riesling Sylvaner", "Sauvignon Blanc")
barplot(Wtyp,las=2)
