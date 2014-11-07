This is a tutorial in setting up SURPI pipeline on CentOS

SURPI is a pipeline to findout the pathogens from clinical metagenomics samples. It is tested only on Ubuntu and it assumes many things about your installation.

The github page of SURPI https://github.com/chiulab/surpi.

Make sure:
  1. The  `create_snap_to_nt.sh` program uses `-Ofactor` as 1000, on line 29, which may not work for your machine. You need to figure out the correct value and make necessary changes.
  2. The abyss instalation requires `mmap`. Make sure you have installed it.       http://hackage.haskell.org/package/mmap-0.5.9/mmap-0.5.9.tar.gz 
  3. Make sure `formatdb` is there in your path. It can be downloaded from ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/LATEST/
  4. The `taxonomy_lookup.pl` program, at line 84 has `sort --parallel=$cores`, where you may need to remove `--parallel=$cores` option, if the sort utility on you machine does not support --parallel option.
  5. The `abyss_minimus.sh` program tries to use `mpirun` to make it parallel. If the mpirun is not configured properly, you need to remove the option 'np=$cores' in line 86, so that it will not be run parallelly. 
  6. The `ribo_snap_bac_euk.sh` program is hardcoded to use the 10,75 as arguments to `crop_reads.csh`, which you may need to change in line 43.
  7. The `coveragePlot.py` program uses `mlab.load()` at line 47, which is deprecated in latest version of matplotlib. Hence, you may need to change it to `np.load()`
