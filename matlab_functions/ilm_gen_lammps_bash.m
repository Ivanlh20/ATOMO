function[] = ilm_gen_lammps_bash(par)
    bb_omp = par.n_omp>1;
    
    lmp_name = 'lmp_mpi';
    
    if bb_omp
        lmp_name = [lmp_name, ' -sf omp -pk omp ', num2str(par.n_omp)];
    end
    
    if(ispc)
        fn_bash = [par.fn_bash, '.bat'];

        n_proc = par.n_proc;
        if par.device==2
            n_proc = par.np_gpu;
        end
        
        pf = 'set ';
        str = '';
    else
        fn_bash = [par.fn_bash, '.sh'];
        
        if par.device==1
            n_proc = par.n_proc;
        else
            n_gpu = par.id_gpu_e-par.id_gpu_0+1;
            lmp_name = ['lmps -sf gpu -pk gpu ', num2str(n_gpu), ' gpuID ', num2str(par.id_gpu_0), ' ', num2str(par.id_gpu_e)];
            n_proc = n_gpu*par.np_gpu;
        end
       
        pf = 'export ';
        str = ['#!/bin/bash', newline];
        str = [str, 'clear', newline];
    end

    bb_proc = n_proc>1;
    
    if(~bb_omp && ~bb_proc && ~ispc)
        lmp_name = 'lmp';
    end
    
    if bb_proc
        str_exec = ['mpiexec -np ', num2str(n_proc), ' ', lmp_name];
    else
        str_exec = lmp_name;
    end
    
    str = [str, pf, 'OMP_NUM_THREADS=', num2str(par.n_omp), newline];
    str = [str, str_exec, ' -in ', par.fn_lmp];
    
    if ~isfield(par, 'bb_screen')
        par.bb_screen = 1;
    end
    
    if ~par.bb_screen
        str = [str, ' -screen none'];
    end
    
    fileID = fopen(fn_bash, 'w');
    fprintf(fileID, '%s', str);
    fclose(fileID);
    if isunix
        fileattrib(fn_bash, '+x');
    end
end