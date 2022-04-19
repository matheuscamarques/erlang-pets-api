-module(pets_handler).
-export([
    init/2,
    allowed_methods/2,
    content_types_provided/2,
    content_types_accepted/2,
    get_handler/2,
    post_handler/2,
    delete_resource/2
]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>, <<"PUT">>, <<"DELETE">>], Req, State}.

content_types_accepted(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, '*'}, post_handler}
        ], Req, State}.

content_types_provided(Req, State) ->
    {
        [
            {<<"application/json">>, get_handler},
            {<<"application/json">>, post_handler}
        ],
        Req,
        State
    }.

delete_resource(Req, State) ->
    Id = cowboy_req:binding(id, Req , false),
    case pets_repo:getById(Id) of
        {Id,_} ->
            pets_repo:delete(Id),
            {true, Req, State};
        false ->
            Req1 = cowboy_req:reply(404, Req),
            {stop, Req1, State}
    end.
    
get_handler(Req = #{method := <<"GET">>}, State) -> 
    Id = cowboy_req:binding(id, Req , false),
    get_handler(Req, State,Id).

% Get all pets
get_handler(Req, State,false) ->
    Pets = [#{<<"id">> => Id, <<"name">> => Name} || {Id, Name} <- pets_repo:getAll()],
    Body = jiffy:encode(Pets),
    {Body, Req, State};

% Get pet by id
get_handler(Req, State,Id) ->
    case pets_repo:getById(Id) of
        {Id,Name} ->
            Body = jiffy:encode(#{<<"id">> => Id, <<"name">> => Name}),
            {Body, Req, State};
        false ->
            Req1 = cowboy_req:reply(404, Req),
            {stop, Req1, State}
    end.

% Create new pet
post_handler(Req0 = #{method := <<"POST">>}, State) ->
    {ok, Data, Req1} = cowboy_req:read_body(Req0),
    Pet     = jiffy:decode(Data,[return_maps]),
    PetName = maps:get(<<"name">>,Pet),
    Id      = pets_repo:insert(PetName),
    Req2    = cowboy_req:set_resp_body(Id, Req1),
    {true, Req2, State};

% Update Pet by id
post_handler(Req = #{method := <<"PUT">>}, State) ->
    Id = cowboy_req:binding(id, Req , false),
    put_handler(Req, State,Id).

put_handler(Req, State,Id) ->
    case pets_repo:getById(Id) of
        {Id,_} ->
            {ok, Data, Req1} = cowboy_req:read_body(Req),
            Pet     = jiffy:decode(Data,[return_maps]),
            PetName = maps:get(<<"name">>,Pet),
            true = pets_repo:update({Id,PetName}),
            Req2    = cowboy_req:set_resp_body(Id, Req1),
            {true, Req2, State};
        false ->
            Req1 = cowboy_req:reply(404, Req),
            {stop, Req1, State}
end.
    