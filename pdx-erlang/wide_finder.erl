-module(wide_finder).
-include_lib("eunit/include/eunit.hrl").
-export([top_five/1]).
-export([timer/3]).
%http://montsamu.blogspot.com/2007/02/erlang-parallel-map-and-parallel.html
-import(plists, [pmap/2]).

top_five_test_() ->
  [
    ?_assertEqual([
        ["/robots.txt", 22],
        ["/", 15],
        ["/styles/layout.css", 14],
        ["/favicon.ico", 13],
        ["/styles/style3.css", 12]
      ], top_five("access.log")
    )
  ].

timer(Module, Function, Values) ->
  {Time, _} = timer:tc(Module, Function, Values),
  Time / 1000000.

top_five(FileName) ->
  {ok, Logfile} = file:open(FileName, [read]),
  ListOfLines = file_into_array(Logfile),
  file:close(Logfile),
  ParsedList = plists:pmap(fun parse_path/1, ListOfLines),
  CountsMap = lists:foldl(fun accum_path_count/2, dict:new(), ParsedList),
  SortedMap = lists:reverse(lists:sort(fun({_,A},{_,B}) -> B > A end, dict:to_list(CountsMap))),
  SortedList = lists:map(fun({A,B}) -> [A,B] end, SortedMap),
  {TopFive,_} = lists:split(5, SortedList),
  TopFive.

parse_path(Line) ->
  parse_match(Line, re:run(Line, ".* (.*) HTTP.*$")).

parse_match(Line, {_,[{_,_},{Start,Length}]}) ->
  string:substr(Line, Start + 1, Length);
parse_match(_, _) ->
  "".

path_count(Path, Dict) ->
  case dict:find(Path, Dict) of
    {ok, Value} -> Value;
    error -> 0
  end.

accum_path_count(Path, Dict) ->
  dict:store(Path, path_count(Path, Dict) + 1, Dict).

file_into_array(Logfile) ->
  case io:get_line(Logfile, "") of
    eof -> [];
    Line ->
      [Line] ++ file_into_array(Logfile)
  end.