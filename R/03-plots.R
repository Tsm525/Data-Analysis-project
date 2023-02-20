# Creating 3 plots, comparing what happens with acute temperature up shift, downshift, and any difference when both reared and measured at different temperatures.
# File is extremely concise now thanks to $graph_all() method, 
# The code is now essentially one line (excluding saving) and will work on any new data (in theory)

# Compare raising at different temperatures 
fig_RTRT_2929W <- obj_RT_at_RTW_$graph_all(obj_29_at_29W_, title= "Wildtype") 

# Could be part of the method in future, could be own function, not now due to time constraints, would use paste() to create filename from graph title maybe
# 12x9in only way to output everything in a spacious way
ggsave("figures/all variables RTRT x 2929W.png", 
       fig_RTRT_2929W, 
       width = 12, 
       height = 9, 
       units = "in")

# Compare crawling ability in reaction to acute increase
fig_RTRT_RT29W <- obj_RT_at_RTW_$graph_all(obj_RT_at_29W_, title= "Wildtype")
ggsave("figures/all variables RTRT x RT29W.png", 
       fig_RTRT_RT29W, 
       width = 12, 
       height = 9, 
       units = "in")

# Compare crawling ability in reaction to acute decrease
fig_2929_29RTW <- obj_29_at_29W_$graph_all(obj_29_at_RTW_, title= "Wildtype")
ggsave("figures/all variables 29RT x 2929W.png", 
       fig_2929_29RTW, 
       width = 12, 
       height = 9, 
       units = "in")


fig_RTRT_2929PGRPLE <- obj_RT_at_RTPGRP_LE$graph_all(obj_29_at_29PGRP_LE, title= "PGRP-LE") 

# Could be part of the method in future, could be own function, not now due to time constraints, would use paste() to create filename from graph title maybe
# 12x9in only way to output everything in a spacious way
ggsave("figures/all variables RTRT x 2929PGRP.png", 
       fig_RTRT_2929PGRPLE, 
       width = 12, 
       height = 9, 
       units = "in")

# Compare crawling ability in reaction to acute increase
fig_RTRT_RT29PGRPLE <- obj_RT_at_RTPGRP_LE$graph_all(obj_RT_at_29PGRP_LE, title= "PGRP-LE")
ggsave("figures/all variables RTRT x RT29PGRP.png", 
       fig_RTRT_RT29PGRPLE, 
       width = 12, 
       height = 9, 
       units = "in")

# Compare crawling ability in reaction to acute decrease
fig_2929_29RTPGRPLE <- obj_29_at_29PGRP_LE$graph_all(obj_29_at_RTPGRP_LE,title = "PGRP-LE")
ggsave("figures/all variables 29RT x 2929PGRP.png", 
       fig_2929_29RTPGRPLE, 
       width = 12, 
       height = 9, 
       units = "in")


##################################################################################

#Difference between W- and PGRP-LE


all_RTRT_cross <- obj_RT_at_RTW_$graph_all(obj_RT_at_RTPGRP_LE,x_lab = "Genotype",x_var = "genotype",title = "")
ggsave("figures/CROSS RTRT.png", 
       all_RTRT_cross, 
       width = 12, 
       height = 9, 
       units = "in")

all_RT29_cross <- obj_RT_at_29W_$graph_all(obj_RT_at_29PGRP_LE,x_lab = "Genotype",x_var = "genotype",title = "")
ggsave("figures/CROSS RT29.png", 
       all_RTRT_cross, 
       width = 12, 
       height = 9, 
       units = "in")

all_2929_cross <- obj_29_at_29W_$graph_all(obj_29_at_29PGRP_LE,x_lab = "Genotype",x_var = "genotype",title = "")
ggsave("figures/CROSS 2929.png", 
       all_2929_cross, 
       width = 12, 
       height = 9, 
       units = "in")

all_29RT_cross<- obj_29_at_RTW_$graph_all(obj_29_at_RTPGRP_LE,x_lab = "Genotype",x_var = "genotype",title = "")
ggsave("figures/CROSS 29RT.png", 
       all_29RT_cross, 
       width = 12, 
       height = 9, 
       units = "in")


grid.draw(all_29RT_cross)



















