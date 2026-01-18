#!/usr/bin/env escript
%% Coinflip backup (not wired).

-module(coinflip).
-export([main/1]).

main(_) ->
  {_, _Seed} = rand:seed(exs1024),
  Result = case rand:uniform(2) of
    1 -> <<"heads">>;
    _ -> <<"tails">>
  end,
  io:format("{\"result\":\"~s\"}~n", [Result]).
