-module(homework6).

-export([create/1]).
-export([insert/3, insert/4]).
-export([lookup/2]).

create(Tab) ->
    {ok, _} = homework6_cache_sup:start_cache_worker(Tab),
    ok.

insert(Tab, Key, Val) ->
    homework6_cache_table:insert(Tab, Key, Val),
    ok.

insert(Tab, Key, Val, Ttl) ->
    homework6_cache_table:insert(Tab, Key, Val, Ttl),
    ok.

lookup(Tab, Key) ->
    homework6_cache_table:lookup(Tab, Key).
