library(tidyverse)

#1. Uploading a Dataframe
d <- read_tsv('combined.tsv', col_names = c("DP", "Type"))
  
#2. Plotting
ggplot(d, aes(x = Type, y = DP)) +
  geom_boxplot(fill = "lavenderblush1") +
  scale_y_log10() +
  theme_bw() +
  labs(title = "Read Depth by Transitions and Transversions") +
  xlab("Point Mutation Type")
  ggsave("DPplot.png")


