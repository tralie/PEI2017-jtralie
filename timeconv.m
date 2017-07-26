function gnss_times=timeconv(weeknums,timeofweeks)
% gnss_times=timeconv(weeknums,timeofweeks)
% 
% Time conversions of what to what
%
% INPUT:
%
% weeknums           Is what
% timeofweeks        Is what?
%
% OUTPUT:
%
% gnss_times         Is what?
%
% Last modified by jtralie@princeton.edu on 07/26/2017

gnss_times = gadd(timeofweeks,gmultiply(weeknums,604800)); 
