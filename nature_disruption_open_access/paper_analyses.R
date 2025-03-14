####################################### Plotting Nobel and Nature, PNAS, Science Plots #######################################

# packages
library(ggplot2)
library(ggrepel)
library(extrafont)

# function for generating plot legends
get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

# setting working directory for data
setwd("data/analytical/")



###########NOBEL PRIZE PAPER PLOT###########

# import data
df_nobel <- read.csv("wos_nobel_papers.csv", header = TRUE)

# labels of specific Nobel prize papers
df_nobel$label[df_nobel$record_id == "366747"] <- "Dirac (1928)"
df_nobel$label[df_nobel$record_id == "2033062"] <- "Watson & Crick (1953)"
df_nobel$label[df_nobel$record_id == "4018517"] <- "Kohn & Sham (1965)"
df_nobel$label[df_nobel$record_id == "9580564"] <- "Sanger et al. (1977)"
df_nobel$label[df_nobel$record_id == "11281657"] <- "Katsuki & Sharpless (1980)"
df_nobel$label[df_nobel$record_id == "15992988"] <- "Saiki et al. (1985)"
df_nobel$label[df_nobel$record_id == "16823428"] <- "Bednorz & Müller (1986)"
df_nobel$label[df_nobel$record_id == "29155183"] <- "Riess et al. (1998)"

# create scatter plot of Nobel prize papers
nobel_plot <- ggplot(data = df_nobel, aes(x = pubyear, y = cd_5, label = label)) +
  geom_point(alpha = 1, aes(color = factor(field))) +
  geom_smooth(method = "loess", se = TRUE, colour="#000000", size=1.5) +
  geom_label_repel(point.padding = unit(.1, "lines"),  size = 4, fill="#ffffffaa", family = "Arial",
                   min.segment.length = .0001, force = 15,
                   segment.size = 0.5) +
  labs(x = "Year", y = expression(CD["5"]))+
  scale_color_manual(name  = "Fields", labels = c("Chemistry", "Medicine", "Physics"), values = c("#348ABD", "#f77911", "#03911f")) +
  theme_bw(base_family = "Arial") +
  theme(axis.text = element_text(family = "Arial", size = 16),
        axis.title = element_text(size = 16),
        legend.box.background = element_rect(colour = "#000000", size=0),
        legend.title=element_blank(),
        legend.box = "horizontal",
        legend.position=c(0.8895, .1),
        legend.spacing = unit(0, "cm"),
        legend.key.size = unit(0.2, "cm"),
        legend.margin=margin(-4,3,3,3),
        legend.text=element_text(size=15),
        plot.caption = element_text(size = 10.5, hjust = 0, vjust = -.4, lineheight = 1.2, face="italic"),
        panel.grid = element_blank(),
        panel.border = element_rect(linetype = "solid", colour = "#000000", size=1)) +
  guides(col = guide_legend(nrow = 3)) +
  scale_y_continuous(breaks = c(-1, -.8, -.6, -.4, -.2, 0, .2, .4, .6, .8, 1), limits = c(-1, 1)) +
  scale_x_continuous(breaks = seq(1900, 2010, by = 20))

# save plot
ggsave("figure_5_main.svg", 
       path = "results", nobel_plot)

nobel_plot