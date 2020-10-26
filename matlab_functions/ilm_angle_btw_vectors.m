function[theta]=ilm_angle_btw_vectors(u, v)
    theta = acosd(dot(u,v)/(norm(u)*norm(v)));
end