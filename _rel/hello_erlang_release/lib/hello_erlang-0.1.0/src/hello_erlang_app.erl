-module(hello_erlang_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start_ets() ->
    ets:new(pets, [set, public, named_table]).

start(_Type, _Args) ->
    start_ets(),
	Dispatch = cowboy_router:compile([
        {'_', [
            {"/", hello_handler, []},
            {"/pets", pets_handler, []},
            {"/pets/:id", pets_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_tls(my_https_listener,
        [
            {port, 9000},
            {certfile, "/home/sanonichan/erlang/hello_erlang/certs/example.crt"},
            {keyfile, "/home/sanonichan/erlang/hello_erlang/certs/example.key"}
        ],
        #{env => #{dispatch => Dispatch}}
    ),
    hello_erlang_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(my_https_listener).
