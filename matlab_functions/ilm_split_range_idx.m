function[i0, ie] = ilm_split_range_idx(n_t, n_p, ip)
   n_p = min(n_t, n_p);
   
   il = mod(n_t, n_p); 
   nf = round((n_t-il)/n_p);
   ir = nf*ones(n_p, 1);
   ir(1:il) = ir(1:il) + 1;
   
   ie = sum(ir(1:ip));
   i0 = ie-ir(ip)+1;
end