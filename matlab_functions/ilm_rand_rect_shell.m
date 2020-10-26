function[r] = ilm_rand_rect_shell(a, b, a_i, b_i)
    x_0 = (a-a_i)/2;
    x_e = x_0 + a_i;
    y_0 = (b-b_i)/2;
    y_e = y_0 + b_i;

    while true
       r = [a, b].*rand(1, 2);
       b_i = (x_0<=r(1))&&(r(1)<=x_e)&&(y_0<=r(2))&&(r(2)<=y_e);
       if(~b_i)
           break;
       end
    end
end