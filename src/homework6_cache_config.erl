-module(homework6_cache_config).

-export([get_options/0]).
-export([get_option_value/1]).

-define(app_name, homework6).

get_options() ->
    lists:foldl(
        fun(Opt, Opts) -> Opts#{Opt => get_option_value(Opt)} end,
        #{},
        [cleanup_interval]
    ).

get_option_value(cleanup_interval = Opt) ->
    case application:get_env(?app_name, Opt) of
        {ok, Val} ->
            if
                is_integer(Val) andalso Val > 0 ->
                    Val;
                true ->
                    error({badopt, Opt, Val})
            end;
        undefined ->
            error({badopt, Opt, undefined})
    end.
