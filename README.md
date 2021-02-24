# dnarrange

This is a method to find rearrangements in "long" DNA reads relative
to a genome sequence.

### Step 1: Align the reads to the genome

You can use [this
recipe](https://github.com/mcfrith/last-rna/blob/master/last-long-reads.md).

### Step 2: Find rearrangements

1. Find rearranged reads
2. Discard "case" reads that share rearrangements with "control" reads
3. Group "case" reads that overlap the same rearrangement

Like this:

    dnarrange case.maf : control1.maf control2.maf > groups.maf

The input files may be gzipped (`.gz`).

It's OK to not use "control" files, or use them in a separate step:

    dnarrange case.maf > groups0.maf
    dnarrange groups0.maf : control1.maf control2.maf > groups.maf

It's OK to use more than one "case" file: `dnarrange` will only output
groups that include reads from all case files.

`dnarrange` tries to flip the reads' strands so all the reads in a
group are on the same strand.  A `-` at the end of a read name
indicates that it's flipped, `+` unflipped.

Each group is given a name, such as `group5-28`.  The first number
(`5`) is a serial number for each group, and the second number (`28`)
is the number of reads in the group.

#### Low coverage

By default, `dnarrange` finds rearrangements supported by at least 2
reads.  To find also rearrangements with just 1 read, use `-s1`:

    dnarrange -s1 case.maf > groups0.maf

You can get an intermediate level of leniency by using `-c0` instead
of `-s1`: this finds groups with at least 2 reads, but does not
require each consecutive pair of rearranged fragments to be supported
by 2 reads.  If you use either `-s1` or `-c0`, it may be useful to
apply "strict control filtering" with `-f0`:

    dnarrange -c0 -f0 case.maf : control1.maf control2.maf > groups.maf

`-f0` makes it discard any case read with any two rearranged fragments
in common with any control read.  The default is to discard case reads
whose "strongest" rearrangement type is shared with a control read,
where "strength" is defined by: inter-chromosome > inter-strand >
non-colinear > big gap.

### Step 3: Draw pictures of the groups

Draw a picture of each group, showing the read-to-genome alignments,
in a new directory `group-pics`:

    last-multiplot groups.maf group-pics

`last-multiplot` has the same
[options](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-dotplot.rst)
as `last-dotplot`.  In fact, `last-multiplot` uses `last-dotplot`, so
it requires the latter to be
[installed](https://gitlab.com/mcfrith/last) (i.e. in your PATH).
This in turn requires the [Python Imaging
Library](https://pillow.readthedocs.io/) to be installed.

* A useful option is `--rmsk1`, to show repeats, which often cause
  rearrangements.

Tips for viewing the pictures on a Mac: open the folder in Finder, and

* View the pictures with "Cover Flow" (Command+4), or:
* Select all the pictures (Command+A), and view them in slideshow
  (Option+Spacebar) or "Quick Look" (Spacebar).  Use the left and
  right arrows to move between pictures.  In slideshow, Spacebar
  toggles "pause"/"play".

Try to check for bad groups, e.g. rearrangements that look like
sequencing artifacts.  It may be useful to require at least 3 (instead
of 2) reads per group:

    dnarrange -s3 groups.maf > strict.maf

### Step 4: Merge each group into a consensus sequence

    dnarrange-merge reads.fq myseq.par groups.maf > merged.fa

This uses 3 input files: the read sequences (in fastq or fasta
format), `myseq.par` from the alignment step, and the groups.  It
requires [lamassemble][] to be installed (which in turn requires LAST
and [MAFFT][] to be installed).

Then
re-[align](https://github.com/mcfrith/last-rna/blob/master/last-long-reads.md)
the merged reads to the genome (it's recommended to do this without
repeat-masking):

    lastdb -P8 -uNEAR -R01 mydb genome.fa
    last-train -P8 mydb merged.fa > merged.par
    lastal -P8 -p merged.par mydb merged.fa | last-split > merged.maf

And draw pictures:

    dnarrange -s1 merged.maf > final.maf
    last-multiplot final.maf merged-pics

`dnarrange` may omit some consensus sequences, if it doesn't consider
their alignments to be rearranged.  If this is a problem, try reducing
`dnarrange`'s minimum thresholds for rearrangement, e.g. with option
`-r1`.

Merging doesn't always work well, especially if the reads have large
tandem duplications so it's easy to merge the wrong parts of the
reads.  Try to check this by comparing the merged and unmerged
pictures.

### Step 5: Find the order and orientation of groups

A large rearrangement might include several groups of rearranged
reads.  To understand it, we need to know the order and orientation of
the groups in the rearranged sequence:

    dnarrange-link -g3,7,8,12 final.maf > linked.txt

This tells it to use groups 3, 7, 8, and 12.  (If you don't specify
any groups, it will use them all: ideally that would work, but the
groups may not all be perfectly accurate, complete, and
uniquely-linkable.)

You can give it groups before or after merging.  It uses only the
topmost read in each group, so we need to ensure that the topmost read
represents the whole group, and covers all the group's rearrangement
breakpoints.  We can check this by looking at the pictures.

If necessary, we can hand-edit the input file.  It begins with a
summary of each group, like this:

    # group7-2
    # readA+ chr19:17558023>17557054 chr18:23830954<23831466
    # readB- chr19:17558023>17557056 chr18:23830970<23831547

This shows how each read aligns to the genome.  `dnarrange-link` uses
only the group names and topmost reads from the summary.

`dnarrange-link` may show a warning message like this:

    WARNING: 4 equally-good ways of linking ends in chr8

In this case, it arbitrarily picks one of these ways to link the ends
in chr8 (or you can use `-a` to get them all).

The output has reconstructed chromosomes with names like `der1`,
`der2`.  If a reconstructed chromosome has widely-separated
rearrangements, it's broken into parts like `der2a`, `der2b`.  You can
control this breaking with option `-m` (see `dnarrange-link --help`).

### Step 6: Draw pictures of the rearranged chromosomes

    last-multiplot linked.txt linked-pics

To make the pictures clearer, you may wish to:

* Change the `dnarrange-link` `-m` parameter.  Large values best show
  the "big picture", and small values magnify small-scale
  rearrangements.

* Draw a subset of derived sequences with [option
  -2](https://gitlab.com/mcfrith/last/-/blob/main/doc/last-dotplot.rst):

      last-multiplot -2 'der[257]*' linked.txt linked-pics

* Hand-edit `linked.txt`, to lengthen the topmost and bottommost
  segments of a derived chromosome.

## Public control files

You can use these [control files](https://zenodo.org/record/3445550)
to discard common rearrangements.  They were made with human reference
genome version `hg38`, so *you must use the same reference!* They were
"shrunk" with commands like:

    dnarrange --shrink -s0 -r1 -g100 control.maf > control.txt

They won't be fully effective if you use them with option `-g` < 100
(or non-default `-m`).

## `dnarrange-genes`

This is a simple script to find genes at or near rearrangement
breakpoints:

    dnarrange-genes refGene.txt groups.maf > groups.txt

You can give it genes in these formats: refGene.txt, refFlat.txt,
[BED][].  You can make it find genes up to, say, 5000 base-pairs away
from any breakpoint like this:

    dnarrange-genes -d5000 refGene.txt groups.maf > groups.txt

## `dnarrange` options

- `-h`, `--help`: show a help message, with default option values, and
  exit.

- `-s N`, `--min-seqs=N`: minimum query sequences per group
  (default=2).  A value of `0` tells it to not bother grouping: it
  will simply find rearranged query sequences.

- `-c N`, `--min-cov=N`: discard any query sequence that has a pair of
  consecutive rearranged fragments shared by < N other queries.  The
  default depends on the `-s` option: when s>1, the default is 1, else
  the default is 0.

- `-t LETTERS`, `--types=LETTERS`: rearrangement types:
  C=inter-chromosome, S=inter-strand, N=non-colinear, G=big gap
  (default=CSNG).

- `-g BP`, `--min-gap=BP`: minimum forward jump in the reference
  sequence counted as a "big gap" (default=10000).  The purpose of
  this is to exclude small deletions.

- `-r BP`, `--min-rev=BP`: minimum reverse jump in the reference
  sequence counted as "non-colinear" (default=1000).  The purpose of
  this is to exclude small tandem duplications, which can be
  overwhelmingly numerous.  To include everything, use `-r1`.

- `-f N`, `--filter=N`: discard case reads sharing any (0) or
  "strongest" (1) rearrangements with control reads (default=1).

- `-d BP`, `--max-diff=BP`: maximum query-length difference for shared
  rearrangement (default=500).

- `-m PROB`, `--max-mismap=PROB`: discard any alignment with mismap
  probability > PROB (default=1).

- `--shrink`: write the output in a compact format.  This format can
  be read by `dnarrange`.

- `-v`, `--verbose`: show progress messages.

## `dnarrange-merge` options

You can get the rearranged reads, without merging them, like this:

    dnarrange-merge all-reads.fq groups.maf > some-reads.fq

This may be useful if you wish to re-align the rearranged reads to the
genome more slowly-and-carefully (e.g. without repeat-masking).

`dnarrange-merge` also has options that it passes to `lamassemble`:
you can see them with `dnarrange-merge --help`, and they're described
at the [lamassemble] site.

[BED]: https://genome.ucsc.edu/FAQ/FAQformat.html#format1
[MAFFT]: https://mafft.cbrc.jp/alignment/software/
[lamassemble]: https://gitlab.com/mcfrith/lamassemble
