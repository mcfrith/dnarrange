# rearranged-sequence-clumps

This is a crude method to find rearrangements in DNA reads relative to
a genome sequence.

It does not really find individual rearrangements.  It finds
rearranged reads, and clumps reads that seem to share a rearrangement.
Finally, it draws one picture per clump of read-to-genome alignments.

## Usage

First, align your sequences as described
[here](https://github.com/mcfrith/last-rna/blob/master/last-long-reads.md).

* You can use `last-split` `-fMAF`, to reduce the file size, with no
  effect on `rearranged-sequence-clumps`.

Then, find clumps of rearranged sequences:

    rearranged-sequence-clumps myseq.maf > clumps.maf

This also works with `myseq.maf.gz`.  Finally, put pictures in a new
directory `clump-pics`:

    last-multiplot clumps.maf clump-pics

## Multiple input files

You can find clumps from multiple files, for example:

    rearranged-sequence-clumps -n2,3 child.maf mother.maf father.maf > child-only.maf

`-n2,3` tells it to exclude rearrangements in the 2nd and 3rd files:
it will discard any child DNA read that shares a rearrangement with
any mother or father read, then clump the remaining child reads.

## `rearranged-sequence-clumps` options

- `-h`, `--help`: show a help message, with default option values, and
  exit.

- `-m PROB`, `--max-mismap=PROB`: discard any alignment with mismap
  probability > PROB (default=1e-6).

- `-s N`, `--min-seqs=N`: minimum query sequences per clump
  (default=2).

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

- `-c N`, `--min-cov=N`: omit any query with any rearrangement shared
  by < N other queries (default=1).

- `-y FILENUMS`, `--yes=FILENUMS`: require clumps to include the
  specified files.

- `-n FILENUMS`, `--no=FILENUMS`: discard any DNA read that shares a
  rearrangement with any read from the specified files.

- `-v`, `--verbose`: show progress messages.

## Re-running `rearranged-sequence-clumps`

Suppose you run `rearranged-sequence-clumps` on a huge file.  Then you
change your mind, and want to re-run it with different options.  You
can save time by re-running it on the previous *output* (i.e. on
`clumps.maf`).  This works only if you make the options more (or
equally) restrictive: it cannot add missing sequences back in!

## `last-multiplot` details

`last-multiplot` has the same
[options](http://last.cbrc.jp/doc/last-dotplot.html) as
`last-dotplot`.

In fact, `last-multiplot` uses `last-dotplot`, so it requires the
latter to be [installed](http://last.cbrc.jp/doc/last.html) (i.e. in
your PATH).  This in turn requires the [Python Imaging
Library](https://pillow.readthedocs.io/) to be installed (good luck
with that).

## Tips for viewing the pictures

On a Mac, open the folder in Finder, and:

* View the pictures with "Cover Flow" (Command+4), or:

* Select all the pictures (Command+A), and view them in slideshow
  (Option+Spacebar) or "Quick Look" (Spacebar).  Use the left and
  right arrows to move between pictures.  In slideshow, Spacebar
  toggles "pause"/"play".
