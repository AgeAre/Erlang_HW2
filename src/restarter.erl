%%%-------------------------------------------------------------------
%%% @author agear
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. May 2019 13:43
%%%-------------------------------------------------------------------
-module(restarter).
-author("agear").
-export([restarter/0]).

restarter()->
  process_flag(trap_exit, true),
  Pid = spawn_link(fun() -> matrix_server:loop() end),
  register(matrix_server, Pid),
  receive
  %{'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, shutdown} -> ok;
    {'EXIT', Pid, _} -> restarter()
  end.

%% API

