function [m] = second_2_minute(s)
m1 = floor(s / 60);
if (m1 < 10)
    m2 = ['0' num2str(m1)];
else
    m2 = num2str(m1);
end

s1 = floor(s - m1*60);
if (s1 < 10)
    s2 = ['0' num2str(s1)];
else
    s2 = num2str(s1);
end
m = [m2 ':' s2];