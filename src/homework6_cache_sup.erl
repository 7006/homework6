-module(homework6_cache_sup).

-behaviour(supervisor).

-export([init/1]).
-export([start_link/1]).
-export([start_cache_worker/1]).

init(Opts) ->
    SupFlags = #{
        strategy => simple_one_for_one,
        intensity => 10,
        period => 5
    },
    ChildSpec = #{
        id => cache_worker,
        start => {homework6_cache_worker, start_link, [Opts]},
        type => worker
    },
    {ok, {SupFlags, [ChildSpec]}}.

start_link(Opts) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, Opts).

start_cache_worker(Tab) ->
    supervisor:start_child(?MODULE, [Tab]).
