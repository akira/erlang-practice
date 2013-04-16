-module(dining).
-export([start/0]).
-import(philosopher, [start/3]).
-import(fork_holder, [start/1]).

start() -> 
  F1 = fork_holder:start(1),
  F2 = fork_holder:start(2),
  F3 = fork_holder:start(3),
  F4 = fork_holder:start(4),
  F5 = fork_holder:start(5),
  P1 = philosopher:start(1, F1, F2),
  P2 = philosopher:start(2, F2, F3),
  P3 = philosopher:start(3, F3, F4),
  P4 = philosopher:start(4, F4, F5),
  P5 = philosopher:start(5, F5, F1).
