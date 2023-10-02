-module(homework6_SUITE).

-export([all/0]).
-export([init_per_testcase/2, end_per_testcase/2]).

-export([
    test_config_cleanup_interval_option/1,
    test_config_options/1,
    test_create_one_cache/1,
    test_create_many_caches/1,
    test_insert_and_lookup/1,
    test_lookup_unknown_key/1,
    test_auto_cleaning/1,
    test_stats/1
]).

-include_lib("common_test/include/ct.hrl").

all() ->
    [
        test_config_cleanup_interval_option,
        test_config_options,
        test_create_one_cache,
        test_create_many_caches,
        test_insert_and_lookup,
        test_lookup_unknown_key,
        test_auto_cleaning,
        test_stats
    ].

-define(one_second, 1_000).
-define(two_second, 2_000).
-define(one_minute, 60_000).

init_per_testcase(test_auto_cleaning, Config) ->
    ok = application:start(homework6),
    ok = application:set_env(homework6, cleanup_interval, ?one_second),
    Config;
init_per_testcase(_, Config) ->
    ok = application:start(homework6),
    Config.

end_per_testcase(test_auto_cleaning, Config) ->
    ok = application:set_env(homework6, cleanup_interval, ?one_minute),
    ok = application:stop(homework6),
    Config;
end_per_testcase(_, Config) ->
    ok = application:stop(homework6),
    Config.

test_config_cleanup_interval_option(_) ->
    ?one_minute = homework6_cache_config:get_option_value(cleanup_interval).

test_config_options(_) ->
    Opts = homework6_cache_config:get_options(),
    true = maps:is_key(cleanup_interval, Opts).

test_create_one_cache(_) ->
    ok = homework6:create(my_cache).

test_create_many_caches(_) ->
    ok = homework6:create(my_cache1),
    ok = homework6:create(my_cache2),
    ok = homework6:create(my_cache3).

test_insert_and_lookup(_) ->
    ok = homework6:create(my_cache),
    ok = homework6:insert(my_cache, k1, v1),
    ok = homework6:insert(my_cache, k2, v2),
    v1 = homework6:lookup(my_cache, k1),
    v2 = homework6:lookup(my_cache, k2).

test_lookup_unknown_key(_) ->
    ok = homework6:create(my_cache),
    undefined = homework6:lookup(my_cache, unknown_key).

test_auto_cleaning(_) ->
    ok = homework6:create(my_cache),
    ok = homework6:insert(my_cache, k, v, 1),
    timer:sleep(?two_second),
    undefined = homework6:lookup(my_cache, k).

test_stats(_) ->
    ok = homework6:create(my_cache),

    Stats = fun() ->
        timer:sleep(?one_second),
        Pid = ets:info(my_cache, owner),
        Pid ! cleanup,
        homework6_cache_worker:stats(Pid)
    end,

    #{run_at := {{Year, Month, Day}, {Hour, Minute, Second1}}, total_runs := TotalRuns1} = Stats(),
    #{run_at := {{Year, Month, Day}, {Hour, Minute, Second2}}, total_runs := TotalRuns2} = Stats(),

    true = Second2 > Second1,
    1 = TotalRuns2 - TotalRuns1.
