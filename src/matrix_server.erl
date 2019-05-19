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
-export([start_server/0, shutdown/0, mult/2, get_version/0, explanation/0, restarter/0]).

%% TODO: Don't forget to flush(). messages. probably will be tested.


start_server() ->
  io:format("dad1"),
  Pid = spawn(fun restarter/0).


shutdown() ->
  erlang:error(not_implemented).

mult(_Arg0, _Arg1) ->
  erlang:error(not_implemented).

get_version() ->
  erlang:error(not_implemented).

explanation() -> {"to answer1"}.

restarter()->
  io:format("~ndad2"),
  process_flag(trap_exit, true),
  %Pid = spawn_link(?MODULE, loop, []),
  Pid = spawn_link(fun loop/0),
  register(matrix_server, Pid),
  receive
    %% Sanity check
    {'EXIT', Pid, normal} -> io:format("normal~n"), ok;
    {'EXIT', Pid, shutdown} -> io:format("shut~n"), ok;
    {'EXIT', Pid, _} -> restarter()
    %% End of sanity check
  end.
%% TODO: loop should get State
loop() ->
  receive
  %% Sanity check
    {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
      spawn(fun() -> mult(Pid, MsgRef, Mat1, Mat2) end),
      loop();

    shutdown -> exit(whereis(matrix_server), shutdown);

    {Pid, MsgRef, get_version}->
      Pid ! {MsgRef, version_1},
      loop();
    %% TODO: sw_ipgrade should be implemented
    sw_upgrade -> io:format("Server's gotten a software upgrade request")
  %% End of sanity check
  end.

for(0,_) ->
  [];

multVec({Row, Col}) ->



mult(Pid, MsgRef, Mat1, Mat2) ->
  Mat1_rows_num = tuple_size(Mat1),
  Mat2_cols_num = tuple_size(element(1,Mat2)),
  ResMat = getZeroMat(Mat1_rows_num, Mat2_cols_num),
  Rows = tuple_to_list(Mat1),
  Cols = [matrix:getCol(Mat2,X) || X <- lists:seq(1,Mat2_cols_num)],
  RowsXcols = [{X,Y} || X <- Rows, Y <- Cols],
  [spawn(fun -> multVec(Tup) || Tup <- RowsXcols],

  %% [{X,Y} || X <- lists:seq(1, Mat1_rows_num), Y <- lists:seq(1,Mat2_cols_num)].


  receive
    {Pid, MsgRef, {multiple, Mat1, Mat2}} ->

  end.

%%mult(Mat1, Mat2) ->
%%  receive
%%    {Pid, MsgRef, {multiple, Mat1, Mat2}} -> io:format("Server's gotten a multiplication request")
%%  end.
