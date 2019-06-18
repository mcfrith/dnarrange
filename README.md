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

## `dnarrange` options

- `-h`, `--help`: show a help message, with default option values, and
  exit.

- `-m PROB`, `--max-mismap=PROB`: discard any alignment with mismap
  probability > PROB (default=1e-6).

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
  rearrangement shared by < N other queries (default=0).  Suggestion:
  if your output looks messy, try cleaning it by applying `-c1` to the
  output.

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
