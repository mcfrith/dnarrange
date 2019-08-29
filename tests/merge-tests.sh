#! /bin/sh

cd $(dirname $0)

PATH=..:$PATH

mat=rel3-4-train.mat

{
    dnarrange-merge --help
    dnarrange-merge groups.fa $mat groups.maf
    dnarrange-merge -g60 -p0.003 -W39 -m4 -z10 groups.fa $mat groups.maf
    tail -n29 groups.maf | dnarrange-merge groups.fa -
} | diff -u merge-tests.out -
