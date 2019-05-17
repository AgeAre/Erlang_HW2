%%%-------------------------------------------------------------------
%%% @author agear
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. May 2019 16:04
%%%-------------------------------------------------------------------
-module(matrix_server).
-author("ageare").

%% API
-export([start_server/0, shutdown/0, mult/2, get_version/0, explanation/0]).


start_server() ->
  spawn(?MODULE, matrix_server, []).

shutdown() ->
  erlang:error(not_implemented).

mult(_Arg0, _Arg1) ->
  erlang:error(not_implemented).

get_version() ->
  erlang:error(not_implemented).

explanation() -> {"to answer"}.

restarter()->
  process_flag(trap_exit, true),
  Pid = spawn_link(?MODULE, matrix_server, []),
  register(matrix_server, Pid),
  receive
    {'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, shutdown} -> ok;
    {'EXIT', Pid, _} -> restarter()
  end.

matrix_server() -> todo.