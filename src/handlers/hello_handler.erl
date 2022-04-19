-module(hello_handler).

-export([
        init/2,
        content_types_provided/2,
        hello_to_json/2
    ]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
		{<<"application/json">>, hello_to_json}
	], Req, State}.


hello_to_json(Req, State) ->
	HelloWorld = {
            [
                {status, <<"Online">> },
                {version, <<"0.0.1">>},
                {autor, <<"Web-Engenharia">>}
            ]
    },
    Body = jiffy:encode(HelloWorld),
	{Body, Req, State}.
