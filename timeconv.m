%% Time conversions
function gnss_times=timeconv(weeknums,timeofweeks);
gnss_times = gadd(timeofweeks,gmultiply(weeknums,604800)); 
