# kuboble-solver

Simple BFS solver for https://kuboble.com/

## Runnable version:

Change your level at the last line of  
https://play.nim-lang.org/#ix=4nIW  
(just keep in mind the playground is 100 times slower than a release build run locally)

## Level format

This program can parse the [official format](https://kuboble.com/levels/featured.csv), but it is also more general:

- each square is described by 2 characters
- if the character pair contains `#` it means a block
- if it contains an uppercase letter, it means a stone
- if it contains a lowercase letter, it means a goal for the corresponding stone
- `;` or `\n` can be used to separate rows
- used lowercase and uppercase must match, except when there's no `x`, `X` may be used instead of `#`
