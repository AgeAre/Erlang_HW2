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
-export([start_server/0, shutdown/0, mult/2, get_version/0, explanation/0, loop/0]).

start_server() ->
  spawn(fun() -> restarter:restarter() end).


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

explanation() -> {"It is better to separate the supervisor's module from the server's module because otherwise,
  in case of 2 or more code upgrading in a row, the server would crash and the supervisor with him.
  if they are in a saperated modules, the supervisor will not be effected by the server's module upgrade"}.


loop() ->
  receive
    {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
      spawn(fun() -> mult(Pid, MsgRef, Mat1, Mat2) end),
      loop();

    shutdown -> exit(self(), shutdown);

    {Pid, MsgRef, get_version}->
      Pid ! {MsgRef, get_version()},
      loop();

    sw_upgrade ->
      ?MODULE:loop();

    _ -> loop()

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

