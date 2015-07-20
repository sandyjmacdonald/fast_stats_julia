# Returns N50 (or N of your choice) and other stats of a fasta/q file (can be
# gzipped) of sequences. N50 is calculated as the sequence length above which
# 50% of the total sequence length lies when the sequences are sorted in order
# of descending length.

#require("argparse")
using ArgParse
#require("gzip")
using GZip


# Adds the command line arguments.

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--in", "-i"
            help = "fasta/q-formatted input file"
            arg_type = String
        "--n", "-n"
            help = "A number between 1 and 100"
            arg_type = Int
            default = 50
    end
    return parse_args(s)
end

# Calculate the Nx where x is a number between 1 and 100.

function get_n(lengths, total_length, n)
    cumulative_length = 0
    n_value = 0
    i = 1

    while cumulative_length < total_length*(n/100)
        l = lengths[i]
        cumulative_length += l
        n_value = l
        i += 1
    end
    return n_value
end

# Runs the main program, and parses all of the command line arguments.

function main()
    parsed_args = parse_commandline()

    for pa in parsed_args
        if pa[1] == "in"
            global fh = pa[2]
        elseif pa[1] == "n"
            global n = pa[2]
        end
    end

    # Create an empty array to add lengths to.

    lengths = Int64[]

    if endswith(fh, ".gz")
        f = gzopen(fh)
    else
        f = open(fh)
    end

    seq_len = 0

    # Parse the file line by line and add lengths to array.

    if endswith(fh, ".fq") | endswith(fh, ".fastq") | endswith(fh, ".fq.gz") |
                endswith(fh, ".fastq.gz")
        line_num = 1
        for line in eachline(f)
            if line_num % 4 == 1
                seen_header = true
            end
            if line_num % 2 == 0
                if seen_header == true
                    push!(lengths, length(chomp(line)))
                    seen_header = false
                end
            end
            line_num += 1
        end

    elseif endswith(fh, ".fasta") | endswith(fh, ".fa") | endswith(fh, ".fn") |
                    endswith(fh, ".fasta.gz") | endswith(fh, ".fa.gz") |
                    endswith(fh, ".fn.gz")
        for line in eachline(f)
            if beginswith(line, ">")
                if seq_len > 0
                    push!(lengths, seq_len)
                end
                seq_len = 0
            else
                seq_len += length(chomp(line))
            end
        end
        push!(lengths, seq_len)
    end

    # Sort the array of lengths ready to calculate the N50 and
    # calculate the average, median, total, etc.

    num_seqs = length(lengths)
    sort!(lengths, rev = true)
    average_length = int(mean(lengths))
    med_length = int(median(lengths))
    total_length = sum(lengths)
    n_value = get_n(lengths, total_length, n)
    min_length = lengths[end]
    max_length = lengths[1]

    # Print a summary of the results to STDOUT.

    println("\n***Results for $(fh)***\n")
    println("There are $(num_seqs) sequences")
    println("The N$(n) is: $(n_value)")
    println("The average length is: $(average_length)")
    println("The median length is: $(med_length)")
    println("The total length is: $(total_length)")
    println("The shortest length is: $(min_length)")
    println("The longest length is: $(max_length)\n")
    println("***\n")

end

main()
