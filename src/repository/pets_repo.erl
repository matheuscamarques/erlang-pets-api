-module(pets_repo).
-export([
    insert/1,
    update/1,
    getAll/0,
    delete/1,
    getById/1
]).

insert(Name) -> 
   Id = list_to_binary(uuid:uuid_to_string(uuid:get_v4())),  
   true = ets:insert(pets, {Id, Name}),
   Id.

update({Id, Name}) -> 
   true = ets:delete(pets, Id),
   ets:insert(pets, {Id, Name}).

getAll() -> 
    ets:tab2list(pets).

delete(Id) -> 
    ets:delete(pets, Id).

getById(Id) -> 
    case  ets:lookup(pets, Id) of
        [Pet] -> Pet;
        [] -> false
    end.

   
