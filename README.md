# dnarrange

This is a method to find rearrangements in "long" DNA reads relative
to a genome sequence.

### Step 1: Align the reads to the genome

You can use [this
recipe](https://github.com/mcfrith/last-rna/blob/master/last-long-reads.md).

* You can use `last-split` `-fMAF`, to reduce the file size, with no
  effect on the following steps.

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

### Step 3: Draw pictures of the groups

Draw a picture of each group, showing the read-to-genome alignments,
in a new directory `group-pics`:

    last-multiplot groups.maf group-pics

`last-multiplot` has the same
[options](http://last.cbrc.jp/doc/last-dotplot.html) as
`last-dotplot`.

In fact, `last-multiplot` uses `last-dotplot`, so it requires the
latter to be [installed](http://last.cbrc.jp/doc/last.html) (i.e. in
your PATH).  This in turn requires the [Python Imaging
Library](https://pillow.readthedocs.io/) to be installed (good luck
with that).

### Step 4: Check and (if necessary) hand-edit the groups

The step after this infers how the groups are linked, but it uses only
the topmost read in each group.  So we need to ensure that the topmost
read represents the whole group, and covers all the group's
rearrangement breakpoints.  We can check this by looking at the
pictures.

If necessary, we can hand edit `groups.maf`.  This file begins with a
summary of each group, like this:

    # group7-2
    # readA+ chr19:17558023>17557054 chr18:23830954<23831466
    # readB- chr19:17558023>17557056 chr18:23830970<23831547

This shows how each read aligns to the genome.  We can edit the
summary, e.g.  move another read to the top of the group, or create a
fake topmost read with all the breakpoints.

It may be useful to "clean" the groups like this:

    dnarrange -c1 groups.maf > clean-groups.maf

This discards any read with a rearrangement not shared by any other
read.

### Step 5: Reconstruct the rearranged chromsomes

    dnarrange-link groups.maf > linked.txt

You might get a warning message like this:

    WARNING: 256 equally-good ways of linking ends in chr8

In this case, `dnarrange-link` arbitrarily picks one of these
ways to link the ends in chr8.

The reconstructed chromosomes are given names like `der1`, `der2`.  If
a reconstructed chromosome has widely-separated rearrangements, it's
broken into parts like `der2a`, `der2b`.  You can control this
breaking with option `-m` (see `dnarrange-link --help`).

### Step 6: Draw pictures of the rearranged chromosomes

    last-multiplot linked.txt linked-pics

To make the pictures clearer, you may wish to:

* Change the `dnarrange-link` `-m` parameter.  Large values best show
  the "big picture", and small values magnify small-scale
  rearrangements.

* Draw a subset of derived sequences with [option
  -2](http://last.cbrc.jp/doc/last-dotplot.html#choosing-sequences):

      last-multiplot -2 'der[257]*' linked.txt linked-pics

* Hand-edit `linked.txt`, to lengthen the topmost and bottommost
  segments of a derived chromosome.

## `dnarrange` options

- `-h`, `--help`: show a help message, with default option values, and
  exit.

- `-s N`, `--min-seqs=N`: minimum query sequences per group
  (default=2).  A value of `0` tells it to not bother grouping: it
  will simply find rearranged query sequences.

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

- `-d BP`, `--max-diff=BP`: maximum query-length difference for shared
  rearrangement (default=1000).

- `-c N`, `--min-cov=N`: omit any query sequence that has any
  rearrangement shared by < N other queries (default=0).

- `-m PROB`, `--max-mismap=PROB`: discard any alignment with mismap
  probability > PROB (default=1).

- `--shrink`: write the output in a compact format.  This format can
  be read by `dnarrange`.

- `-v`, `--verbose`: show progress messages.

## Tips for viewing the pictures

On a Mac, open the folder in Finder, and:

* View the pictures with "Cover Flow" (Command+4), or:

* Select all the pictures (Command+A), and view them in slideshow
  (Option+Spacebar) or "Quick Look" (Spacebar).  Use the left and
  right arrows to move between pictures.  In slideshow, Spacebar
  toggles "pause"/"play".
