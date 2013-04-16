-module(dining).
-export([start/0]).

start() -> 
  spawn( fun() -> loop([]) end).
  
loop(X) ->
  receive
    Any ->
      io:format("Received:~p~n",[Any]), 
      loop(X)
  end.