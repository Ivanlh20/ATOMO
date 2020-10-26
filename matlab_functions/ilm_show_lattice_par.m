function ilm_show_lattice_par(v_r)
    v_a = v_r(1, :);
    v_b = v_r(2, :);
    v_c = v_r(3, :);

    a = norm(v_a);
    b = norm(v_b);
    c = norm(v_c);

    alpha = acos(dot(v_c, v_b)/(c*b));
    beta = acos(dot(v_c, v_a)/(c*a));
    gamma = acos(dot(v_a, v_b)/(a*b));

    f = '%4.2f';
    fn = 180/pi;
    s = ['[a, b, c, alpha, beta, gamma] = [', num2str(a, f), ', ', num2str(b, f), ', ', num2str(c, f), ', '];
    s = [s, num2str(alpha*fn, f), ', ', num2str(beta*fn, f), ', ', num2str(gamma*fn, f), ']'];
    disp(s)
end

