function[seed_thr] = ilm_seed_thr(n_data, n_thread, idx_thread, seed)
    n_data_thr = ceil(n_data/n_thread) + 1;
    seed_thr = seed + n_data_thr*(idx_thread-1);
end