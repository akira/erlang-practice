-module(fork_holder).
-export([start/1]).

start(Position) -> 
  spawn( fun() -> dispense_fork(Position) end).
  
dispense_fork(Position) ->
  receive
    {request_fork, Pid} ->
      io:format("Dispensing Fork ~B~n", [Position]),    
      Pid ! {got_fork, self()},
      wait_for_fork(Position, Pid)
  end.
  
wait_for_fork(Position, Pid) ->
  receive
    {return_fork, Pid} ->
      io:format("Returning Fork ~B~n", [Position]),
      dispense_fork(Position)
  end.