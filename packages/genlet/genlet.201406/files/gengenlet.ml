(* Generic let-insertion: 
     genlet code
inserts a let expression to bind 'code' as high as possible --
as high in the scope as still safe (creating no scope extrusion).

*)

(* We will be using delimited control. So we load it up and set up *)
(*
#directory "/home/oleg/Cache/ncaml4/caml-shift/";;
#directory "/usr/local/src/ncaml4/caml-shift/";;
#load "delimcc.cma";;
*)

open Delimcc;;
open Runcode;;                          (* To run the code *)

(* If we are going to use delimited control, we need to tell MetaOCaml,
   by adjusting its stackmark facility -- provide the implementation of
   stackmarks that works with delimcc.
*)
Trx.set_with_stack_mark {Trx.stackmark_region_fn = fun body ->
   let p = new_prompt () in
   push_prompt p (fun () -> body (fun () -> is_prompt_set p))}
;;

(* Let-insertion request (with an existential) 
   We ask to let-bind the code value and return the corresponding
   let-bound identifier.
   If the response is (c,true), the request was satisfied and
   c is the let-bound identifier.
   If the response is (c,false), the let-binding was unsuccessful
   and c is the original code from the request.
*)
type genlet_req = 
  | Done: genlet_req
  | Req: 'a code * ('a code * bool -> genlet_req) -> genlet_req
;;

(* The single prompt for let-insertion *)
let p : genlet_req prompt = new_prompt ()

(* Send the let-insertion request for a given code.
   If the prompt is not set, just return (c,false)
*)

let send_req : 'a code -> 'a code * bool = fun c ->
  if is_prompt_set p then
    shift0 p (fun k -> Req (c,k))
  else (c,false)

let genlet : 'a code -> 'a code = fun c ->
  fst @@ send_req c

(* We often use mutable variables as `communication channel', to appease
   the type-checker. The variable stores the `option' value --
   most of the time, None. One function writes a Some x value,
   and another function almost immediately reads the value -- exactly
   once. The protocol of using such a variable is a sequence of
   one write almost immediately followed by one read.
   We use the following helpers to access our `communication channel'.
*)
let from_option = function Some x -> x | None -> failwith "fromoption";;

let read_answer r = let v = from_option !r in r := None; v (* for safety *)

(* Check if a piece of code contains free variables that cannot
   be bound. We try to incorporate the received piece of code
   into a larger piece of code. At this point, MetaOCaml does
   the scope extrusion check, throwing an exception if the check fails.
*)
let is_well_scoped : 'a code -> bool = fun c ->
  try ignore (.<begin .~c; () end>.); true with e -> false

(* The point of inserting let: the handler for genlet_req
   Upon receiving the let-binding request and before satsifying
   it, we check if the request can be fulfilled by a handler
   upstream.
   That is, we try to insert let `as high as possible'.
 *)
let let_locus : (unit -> 'w code) -> 'w code = fun body ->
  let r = ref None in
  let rec loop = function
    | Done      -> read_answer r
    | Req (c,k) -> 
       if not (is_well_scoped c) then loop (k (c,false))
       else (* try higher *)
        begin 
          match send_req c with
          | (c,false) -> .<let t = .~c in .~(loop (k (.<t>.,true)))>.
          | x -> loop (k x)           (* c is a variable, inserted higher *)
        end
  in
  loop @@ push_prompt p @@ fun () ->
    r := Some (body ()); Done

(* Tests *)
let t1 = .<1 + .~(genlet .<2>.)>.
(* val t1 : int code = .<1 + 2>.  *)

let t2 = .<fun x -> 1 + .~(genlet .<2>.)>.
(* val t2 : ('a -> int) code = .<fun x_1  -> 1 + 2>.  *)

let t3 = let_locus (fun () -> .<fun x -> 1 + .~(genlet .<2>.)>.)
(* val t3 : ('_a -> int) code = .<let t_3 = 2 in fun x_2  -> 1 + t_3>. 
*)

let t4 = let_locus (fun () -> .<fun x -> 1 + .~(genlet .<x>.)>.)
(* val t4 : (int -> int) code = .<fun x_9  -> 1 + x_9>. 
*)

let t5 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<2+3>.)>.))
  >.))
  >.)
(*
val t5 : ('_a -> '_b -> int) code = .<
  let t_12 = 2 + 3 in fun x_10  y_11  -> 1 + t_12>. 
*)

let t51 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<2+x>.)>.))
  >.))
  >.)
(*
val t51 : (int -> '_a -> int) code = .<
  fun x_13  -> let t_15 = 2 + x_13 in fun y_14  -> 1 + t_15>. 
*)
let t52 = let_locus (fun () -> 
  .<fun x -> .~(let_locus (fun () ->
  .<fun y -> .~(let_locus (fun () ->
    .<1 + .~(genlet .<y+x>.)>.))
  >.))
  >.)
(*
val t52 : (int -> int -> int) code = .<
  fun x_16  y_17  -> let t_18 = y_17 + x_16 in 1 + t_18>. 
*)


(* Further examples *)

(* A simple DSL. See loop_motion_gen.ml for a realistic example *)
module type DSL = sig
  val sqr           : int code -> int code
  val make_incr_fun : (int code -> int code) -> (int -> int) code
end

(* Sample DSL expressions *)
module DSLExp(S: DSL) = struct
  open S
  let exp1 = sqr .<2+3>.
  let exp2 = make_incr_fun (fun x -> sqr .<2+3>.)
  let exp3 = make_incr_fun (fun x -> sqr .<.~x + 3>.)
end

(* The naive implementation of the DSL *)
module DSL1 = struct
  let sqr e = .<.~e * .~e>.
  let make_incr_fun body = .<fun x -> x + .~(body .<x>.)>.
end

let module M = DSLExp(DSL1) in
  (M.exp1, M.exp2, M.exp3)
(*
- : int code * (int -> int) code * (int -> int) code =
(.<(2 + 3) * (2 + 3)>. , 
 .<fun x_14  -> x_14 + ((2 + 3) * (2 + 3))>. , 
 .<fun x_15  -> x_15 + ((x_15 + 3) * (x_15 + 3))>. )
*)

(* Adding let-insertion, trasparently *)
module DSL2 = struct
  let sqr e = DSL1.sqr (genlet e)
  let make_incr_fun body = 
    let_locus @@ fun () ->
      DSL1.make_incr_fun @@ fun x ->
        let_locus @@ fun () -> 
          body x
end

let module M = DSLExp(DSL2) in
  (M.exp1, M.exp2, M.exp3)
(*
(.<(2 + 3) * (2 + 3)>. , 
 .<let t_17 = 2 + 3 in fun x_16  -> x_16 + (t_17 * t_17)>. , 
 .<fun x_18  -> x_18 + (let t_19 = x_18 + 3 in t_19 * t_19)>. )
*)
