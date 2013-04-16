-module(plists).
-export([pmap/2,pforeach/2,npforeach/2]).

pmap(F, L) ->
    S = self(),
    Pids = lists:map(fun(I) -> spawn(fun() -> pmap_f(S, F, I) end) end, L),
    pmap_gather(Pids).

pmap_gather([H|T]) ->
    receive
        {H, Ret} -> [Ret|pmap_gather(T)]
    end;
pmap_gather([]) ->
    [].

pmap_f(Parent, F, I) ->
    Parent ! {self(), (catch F(I))}.

pforeach(F, L) ->
  S = self(),
  Pids = pmap(fun(I) -> spawn(fun() -> pforeach_f(S,F,I) end) end, L),
  pforeach_wait(Pids).

pforeach_wait([H|T]) ->
  receive
    H -> pforeach_wait(T)
  end;
pforeach_wait([]) -> ok.

pforeach_f(Parent, F, I) ->
  _ = (catch F(I)),
  Parent ! self().

npforeach(F, L) ->
  S = self(),
  Pid = spawn(fun() -> npforeach_0(S,F,L) end),
  receive Pid -> ok end.

npforeach_0(Parent,F,L) ->
  S = self(),
  Pids = pmap(fun(I) -> spawn(fun() -> npforeach_f(S,F,I) end) end, L),
  npforeach_wait(S,length(Pids)),
  Parent ! S.

npforeach_wait(_S,0) -> ok;
npforeach_wait(S,N) ->
  receive
    S -> npforeach_wait(S,N-1)
  end.

npforeach_f(Parent, F, I) ->
  _ = (catch F(I)),
  Parent ! Parent.