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
-export([start_server/0, shutdown/0, mult/2, get_version/0, explanation/0, restarter/0, matrix_server/0]).

%% TODO: Don't forget to flush(). messages. probably will be tested.


start_server() ->
  io:format("dad1"),
  Pid = spawn(?MODULE, restarter, []).


shutdown() ->
  erlang:error(not_implemented).

mult(_Arg0, _Arg1) ->
  erlang:error(not_implemented).

get_version() ->
  erlang:error(not_implemented).

explanation() -> {"to answer1"}.

restarter()->
  io:format("dad2"),
  process_flag(trap_exit, true),
  io:format("dad3"),
  Pid = spawn_link(?MODULE, matrix_server, []),
  io:format("dad4"),
  register(matrix_server, Pid),
  receive
    %% Sanity check
    {'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, shutdown} -> ok;
    {'EXIT', Pid, _} -> restarter()
    %% End of sanity check
  end.

matrix_server() ->
  receive
  %% Sanity check
    {Pid, MsgRef, {multiple, Mat1, Mat2}} -> io:format("Server's gotten a multiplication request");
    shutdown -> io:format("Server's gotten a shutdown request");
    {Pid, MsgRef, get_version}-> io:format("Server's gotten a get version request");
    sw_upgrade -> io:format("Server's gotten a software upgrade request")
  %% End of sanity check
  end.
