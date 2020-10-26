function[str]=ilm_run(str)
    if(ispc)
        str = [str, '.bat'];
    else
        str = ['./', str, '.sh'];
    end
    eval(['!', str]);
end