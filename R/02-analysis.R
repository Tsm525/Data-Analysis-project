# All observations are independent 
# Different populations split by reared and/or measured temperatures

# Using two sample tests for data, could use anova / anova-like test but half the data isn't normalized so need different tests for now
# Can use print(Results) to see labelled results data 

#####################################
# A - Comparing Reared at RT and 29 #
#####################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Significant difference in distance traveled (p = 0.01841)
Results_RTRT_2929W <- obj_RT_at_RTW_$stats_all(obj_29_at_29W_)
Results_RTRT_2929PGRPLE <- obj_RT_at_RTPGRP_LE$stats_all(obj_29_at_29PGRP_LE)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

####################
# B - Reared at RT #
####################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# No Significance
Results_RTRT_RT29W <- obj_RT_at_RTW_$stats_all(obj_RT_at_29W_)
Results_RTRT_RT29PGRPLE <- obj_RT_at_RTPGRP_LE$stats_all(obj_RT_at_29PGRP_LE)

obj_RT_at_RTW_$n
obj_RT_at_29W_$n

obj_RT_at_RTPGRP_LE$n
obj_RT_at_29PGRP_LE$n

Results_RTRT_RT29W
# doesnt need to be taken out of mean as its 1 of 1, lazy convenience)
mean(obj_RT_at_RTW_$se_max_speed)
mean(obj_RT_at_29W_$se_max_speed) # greater

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


####################
# C - Reared at 29 #
####################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Significant difference for distance traveled (p = 0.02607)
Results_2929_29RTW <- obj_29_at_29W_$stats_all(obj_29_at_RTW_)
Results_2929_29RTPGRPLE <- obj_29_at_29PGRP_LE$stats_all(obj_29_at_RTPGRP_LE)
Results_2929_29RTPGRPLE


mean(obj_29_at_29PGRP_LE$max_speed)
mean(obj_29_at_29PGRP_LE$avg_speed)
obj_29_at_29PGRP_LE$se_max_speed
obj_29_at_29PGRP_LE$se_avg_speed
obj_29_at_29PGRP_LE$n


mean(obj_29_at_RTPGRP_LE$max_speed)
mean(obj_29_at_RTPGRP_LE$avg_speed)
obj_29_at_RTPGRP_LE$se_max_speed
obj_29_at_RTPGRP_LE$se_avg_speed
obj_29_at_RTPGRP_LE$n

obj_29_at_29W_$n
obj_29_at_RTW_$n

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



####################################
#        BETWEEN GENOTYPES         #
####################################


Cross_results_RTRT <- obj_RT_at_RTW_$stats_all(obj_RT_at_RTPGRP_LE) #NS
Cross_results_RT29 <- obj_RT_at_29W_$stats_all(obj_RT_at_29PGRP_LE)


#Graph
Cross_results_2929 <- obj_29_at_29W_$stats_all(obj_29_at_29PGRP_LE)
Cross_results_29RT <- obj_29_at_RTW_$stats_all(obj_29_at_RTPGRP_LE)
Cross_results_29RT


