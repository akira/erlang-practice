-module(philosopher).
-export([start/3]).

start(Position, LeftHolder, RightHolder) -> 
  spawn( fun() -> request_forks(Position, LeftHolder, RightHolder) end).

request_forks(Position, LeftHolder, RightHolder) ->
  LeftHolder ! {request_fork, self()}, 
  RightHolder ! {request_fork, self()},   
  receive
    {got_fork, LeftHolder} ->
      io:format("~B:Got Left Fork ~n",[Position]),
      wait_fork(RightHolder, Position, LeftHolder, RightHolder);
    {got_fork, RightHolder} ->
      io:format("~B:Got Right Fork ~n",[Position]),
      wait_fork(LeftHolder, Position, LeftHolder, RightHolder)
  end.

wait_fork(WaitHolder, Position, LeftHolder, RightHolder) ->
  receive
    {got_fork, WaitHolder} ->
      io:format("~B:Got Other Fork~n",[Position]),
      eat(Position, LeftHolder, RightHolder)
  end.
      

eat(Position, LeftHolder, RightHolder) ->
  io:format("~B:Eating~n",[Position]), 
  think(Position, LeftHolder, RightHolder).
  
think(Position, LeftHolder, RightHolder) ->
  io:format("~B:Thinking~n",[Position]), 
  timer:sleep(random:uniform(500)),
  RightHolder ! {return_fork, self()},     
  LeftHolder ! {return_fork, self()}, 
  request_forks(Position, LeftHolder, RightHolder).