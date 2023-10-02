-module(homework6_cache_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_, _) ->
    Opts = homework6_cache_config:get_options(),
    homework6_cache_sup:start_link(Opts).

stop(_) ->
    ok.
