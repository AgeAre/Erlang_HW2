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
-export([start_server/0, shutdown/0, mult/2, get_version/0, explanation/0, restarter/0, loop/0]).

%% TODO: Don't forget to flush(). messages. probably will be tested.


start_server() ->
  spawn(fun() -> restarter() end).


shutdown() ->
  case whereis(matrix_server) of
    true -> matrix_server ! shutdown
  end.

mult(Mat1, Mat2) ->
  mult(self(),1,Mat1, Mat2),
  receive
    {1,X} -> X
  end.


get_version() -> version_1.
explanation() -> {"to answer1"}.

restarter()->
  process_flag(trap_exit, true),
  Pid = spawn_link(fun() -> ?MODULE:loop() end), %TODO try matrix_server:loop and see if it also works
  register(matrix_server, Pid),
  receive
    %{'EXIT', Pid, normal} -> ok;
    {'EXIT', Pid, shutdown} -> ok;
    {'EXIT', Pid, _} -> restarter()
  end.

loop() ->
  receive
    {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
      spawn(fun() -> mult(Pid, MsgRef, Mat1, Mat2) end),
      ?MODULE:loop();

    shutdown -> exit(self(), shutdown);

    {Pid, MsgRef, get_version}->
      Pid ! {MsgRef, get_version()},
      loop();

    sw_upgrade ->
      ?MODULE:loop()

  end.

dotProduct(A,B) when length(A) == length(B) -> dotProduct(A,B,0);
dotProduct(_,_) -> erlang:error('Vectors must have the same length.').

dotProduct([H1|T1],[H2|T2],P) -> dotProduct(T1,T2,P+H1*H2);
dotProduct([],[],P) -> P.

multVec(Pid, {I,J}, Mat1, Mat2) ->
  Row = tuple_to_list(matrix:getRow(Mat1, I)),
  Col = tuple_to_list(matrix:getCol(Mat2, J)),
  Pid ! {dotProduct(Row, Col),I,J}.

mult(Pid, MsgRef, Mat1, Mat2) ->
  Mat1_rows_num = tuple_size(Mat1),
  Mat2_cols_num = tuple_size(element(1,Mat2)),
  NumElements = Mat1_rows_num * Mat2_cols_num,
  MultPid = self(),
  [spawn_link(fun() -> multVec(MultPid,{X,Y}, Mat1, Mat2) end) || X <- lists:seq(1, Mat1_rows_num), Y <- lists:seq(1,Mat2_cols_num)],
  ZeroMat = matrix:getZeroMat(Mat1_rows_num, Mat2_cols_num),
  %% [{X,Y} || X <- lists:seq(1, Mat1_rows_num), Y <- lists:seq(1,Mat2_cols_num)].
GetMsg = fun(_F,0, ResMat) -> Pid ! {MsgRef, ResMat}; %io:format("~n~n~p , ~p~n~n", [ResMat, Pid]);
  (F,N,ResMat) when N > 0 ->
    receive
      {Res, I, J} ->
        F(F,N - 1, matrix:setElementMat(I,J,ResMat,Res))
    end
 end,
  GetMsg(GetMsg, NumElements, ZeroMat).

