fast_stats.jl
===========

Returns N50 (or N of your choice) and other stats of a fasta file of sequences. 
N50 is calculated as the sequence length above which 50% of the total sequence 
length lies when the sequences are sorted in order of descending length.

### Dependencies

Requires the [ArgParse](http://docs.julialang.org/en/release-0.1/stdlib/argparse/) 
module for parsing the command line arguments. You can install it by opening an 
interactive Julia prompt and typing:
	
	Pkg.add("ArgParse")

### Usage

    julia fast_stats.jl --in <infile> --n 50

> ##### Arguments

> `--in` The fasta file for which you want to calculate the stats.

> `--n` The value of n (usually 50) that you want to use.

> `--h` Displays help.
