open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

module Type = struct
  type t =
  | Float64
  | Int
  | Int64
  | String of int

  let to_string = function
  | Float64  -> "Float64"
  | Int      -> "Int"
  | Int64    -> "Int64"
  | String _ -> "String"

  let wsize = function
  | Float64 | Int | Int64 -> 1
  | String length -> (length + 7) / 8
end

module Field = struct
  type t = {
    id         : string;
    name       : string;
    type_      : Type.t;
    ocaml_type : Longident.t;
    seek       : bool;
  }
end

let rec extract_fields expression =
  match expression.pexp_desc with
  | Pexp_sequence (expression1, expression2) ->
    extract_fields expression1 @ extract_fields expression2
  | Pexp_apply ({ pexp_desc = Pexp_ident { txt = id; _ }; pexp_loc; _ }, expressions) ->
    let id =
      match id with
      | Lident id -> id
      | _ ->
        raise (Location.Error (Location.error ~loc:pexp_loc (Printf.sprintf
          "[%%h5struct] invalid field %s, field identifiers must be simple"
            (Longident.last id))))
    in
    begin match expressions with
    | (_, name) :: (_, type_) :: expressions ->
      let name =
        match name.pexp_desc with
        | Pexp_constant (Const_string (name, _)) -> name
        | _ ->
          raise (Location.Error (Location.error ~loc:name.pexp_loc (Printf.sprintf
            "[%%h5struct] invalid field %s, field name must be a string constant" id)))
      in
      let type_, ocaml_type =
        match type_ with
        | { pexp_desc = Pexp_construct (type_, expression_opt); pexp_loc = loc; _ } ->
          begin match type_.txt with
          | Lident type_ ->
            begin match type_ with
            | "Discrete" ->
              let ocaml_type =
                match expression_opt with
                | Some { pexp_desc = Pexp_ident { txt; _ }; _ } -> txt
                | _ ->
                  raise (Location.Error (Location.error ~loc (Printf.sprintf
                    "[%%h5struct] invalid field %s, field type Discrete requires type"
                    id)))
              in
              Type.Int, ocaml_type
            | "Float64"  -> Type.Float64, Longident.Lident "float"
            | "Int"      -> Type.Int    , Longident.Lident "int"
            | "Int64"    -> Type.Int64  , Longident.Lident "int64"
            | "String"   ->
              let type_ =
                match expression_opt with
                | Some { pexp_desc = Pexp_constant (Const_int length); _ } ->
                  Type.String length
                | _ ->
                  raise (Location.Error (Location.error ~loc (Printf.sprintf
                    "[%%h5struct] invalid field %s, field type String requires length"
                    id)))
              in
              type_, Longident.Lident "string"
            | _ ->
              raise (Location.Error (Location.error ~loc (Printf.sprintf
                "[%%h5struct] invalid field %s, unrecognized type %s" id type_)))
            end
          | _ ->
            raise (Location.Error (Location.error ~loc (Printf.sprintf
              "[%%h5struct] invalid field %s, field type must be simple" id)))
          end
        | _ ->
          raise (Location.Error (Location.error ~loc:type_.pexp_loc (Printf.sprintf
            "[%%h5struct] invalid field %s, field type must be a construct" id)))
      in
      let seek = ref false in
      List.iter (fun (_, expression) ->
        match expression.pexp_desc with
        | Pexp_construct ({ txt = Lident "Seek"; _ }, None) -> seek := true
        | _ ->
          raise (Location.Error (Location.error ~loc:expression.pexp_loc (Printf.sprintf
            "[%%h5struct] invalid field %s, unexpected modifiers" id)))) expressions;
      [ { Field.id; name; type_; ocaml_type; seek = !seek } ]
    | _ ->
      raise (Location.Error (Location.error ~loc:pexp_loc (Printf.sprintf
        "[%%h5struct] invalid field %s, exactly two arguments expected: name and type"
          id)))
    end
  | _ ->
    raise (Location.Error (Location.error ~loc:expression.pexp_loc
      "[%h5struct] accepts a list of fields, \
        e.g. [%h5struct time \"Time\" Int; price \"Price\" Float64]"))

let rec construct_fields_list fields loc =
  match fields with
  | [] -> Exp.construct ~loc { txt = Longident.Lident "[]"; loc } None;
  | field :: fields ->
    Exp.construct ~loc { txt = Longident.Lident "::"; loc } (Some (
      Exp.tuple ~loc [
        Exp.apply ~loc
          (Exp.ident { txt = Longident.(
            Ldot (Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Field"), "create")); loc })
          [ "", Exp.constant ~loc (Const_string (field.Field.name, None));
            "",
            Exp.construct ~loc
              { loc; txt = Longident.(
                  Ldot (
                    Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Type"),
                    match field.Field.type_ with
                    | Type.Float64  -> "Float64"
                    | Type.Int      -> "Int"
                    | Type.Int64    -> "Int64"
                    | Type.String _ -> "String")) }
              ( match field.Field.type_ with
                | Type.String length -> Some (Exp.constant ~loc (Const_int length))
                | _ -> None ) ];
        construct_fields_list fields loc ]))

let construct_function ~loc name args body =
  let rec construct_args = function
  | [] -> body
  | (arg, typ) :: args ->
    Exp.fun_ ~loc "" None
      (Pat.constraint_ ~loc (Pat.var ~loc { txt = arg; loc })
        (Typ.constr ~loc { txt = typ; loc } []) )
      (construct_args args)
  in
  Str.value ~loc Nonrecursive [
    Vb.mk ~loc
      (Pat.var ~loc { txt = name; loc }) (construct_args args) ]

let construct_function_call ~loc name args =
  Exp.apply ~loc
    (Exp.ident ~loc { txt = name; loc })
    (List.map (fun arg ->
      "",
      match arg with
      | `Exp e -> e
      | `Int i -> Exp.constant ~loc (Const_int i)
      | `Var v -> Exp.ident ~loc { txt = Longident.Lident v; loc }) args)

let construct_field_get field pos loc =
  construct_function ~loc field.Field.id [ "t", Longident.Lident "t" ] (
    Exp.constraint_ ~loc
      (construct_function_call ~loc Longident.(Ldot (Lident "Obj", "magic"))
        [`Exp (
          construct_function_call ~loc
            Longident.(Ldot (Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Ptr"),
              ( match field.Field.type_ with
                | Type.Float64    -> "get_float64"
                | Type.Int        -> "get_int"
                | Type.Int64      -> "get_int64"
                | Type.String _   -> "get_string" )))
            (   [ `Var "t" ]
              @ ( match field.Field.type_ with
                  | Type.Float64
                  | Type.Int
                  | Type.Int64 -> [ `Int pos ]
                  | Type.String length -> [ `Int (pos * 8); `Int length ] ) ))])
      (Typ.constr ~loc { txt = field.Field.ocaml_type; loc } []))

let construct_field_set field pos loc =
  construct_function ~loc ("set_" ^ field.Field.id)
    [ "t", Longident.Lident "t"; "v", field.Field.ocaml_type ]
    (construct_function_call ~loc
      Longident.(Ldot (Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Ptr"),
        ( match field.Field.type_ with
          | Type.Float64    -> "set_float64"
          | Type.Int        -> "set_int"
          | Type.Int64      -> "set_int64"
          | Type.String _   -> "set_string" )))
      (   [ `Var "t" ]
        @ ( match field.Field.type_ with
            | Type.Float64
            | Type.Int
            | Type.Int64 -> [ `Int pos ]
            | Type.String length -> [ `Int (pos * 8); `Int length ] )
        @ [ `Var "v" ] ))

let construct_field_seek field ~bsize pos loc =
  construct_function ~loc ("seek_" ^ field.Field.id)
    [ "t", Longident.Lident "t"; "v", field.Field.ocaml_type ]
    (construct_function_call ~loc
      Longident.(Ldot (Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Ptr"),
        ( match field.Field.type_ with
          | Type.Float64    -> "seek_float64"
          | Type.Int        -> "seek_int"
          | Type.Int64      -> "seek_int64"
          | Type.String _   -> "seek_string" )))
      ( [ `Var "t"; `Int (bsize / 2) ]
        @ (
          match field.Field.type_ with
          | Type.Float64
          | Type.Int
          | Type.Int64 -> [ `Int pos ]
          | Type.String len -> [ `Int (pos * 8); `Int len ] )
        @ [ `Var "v" ] ))

let construct_set_all_fields fields loc =
  let rec construct_sets = function
  | [] -> assert false
  | field :: fields ->
    let set =
      Exp.apply ~loc
        (Exp.ident ~loc { txt = Longident.Lident ("set_" ^ field.Field.id); loc })
        [ "", Exp.ident ~loc { txt = Longident.Lident "t"; loc };
          "", Exp.ident ~loc { txt = Longident.Lident field.Field.id; loc } ] in
    match fields with
    | [] -> set
    | _ -> Exp.sequence ~loc set (construct_sets fields)
  in
  let rec construct_funs = function
  | [] -> construct_sets fields
  | field :: fields ->
    Exp.fun_ ~loc field.Field.id None
      (Pat.var ~loc { txt = field.Field.id; loc })
      (construct_funs fields)
  in
  Str.value ~loc Nonrecursive [
    Vb.mk ~loc (Pat.var ~loc { txt = "set"; loc })
      (Exp.fun_ ~loc "" None (Pat.var ~loc { txt = "t"; loc })
        (construct_funs fields)) ]

let construct_size_dependent_fun name ~bsize ~index loc =
  let call =
    Exp.apply ~loc
      (Exp.ident ~loc
        { loc; txt =
            Longident.(Ldot (Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Ptr"), name)) })
      ( [ "",
            Exp.apply ~loc
              (Exp.ident ~loc { txt = Longident.(Ldot (Lident "Obj", "magic")); loc })
              [ "", Exp.ident ~loc { txt = Longident.Lident "t"; loc } ]]
        @ (
          if index
          then [ "", Exp.ident ~loc { txt = Longident.Lident "i"; loc } ]
          else [])
        @ [ "", Exp.constant ~loc (Const_int (bsize / 2)) ])
  in
  Str.value ~loc Nonrecursive [
    Vb.mk ~loc (Pat.var ~loc { txt = name; loc })
      (Exp.fun_ ~loc "" None
        (Pat.constraint_ ~loc
          (Pat.var ~loc { txt = "t"; loc })
          (Typ.constr ~loc { txt = Longident.Lident "t"; loc } []))
        ( if index
          then Exp.fun_ ~loc "" None (Pat.var ~loc { txt = "i"; loc }) call
          else call )) ]

let map_structure_item mapper structure_item =
  match structure_item with
  | { pstr_desc = Pstr_extension (({txt = "h5struct"; _}, payload), _); pstr_loc = loc }
    ->
    let fields =
      match payload with
      | PStr [{ pstr_desc = Pstr_eval (expression, _); _ }] ->
        extract_fields expression
      | _ ->
        raise (Location.Error (Location.error ~loc
          "[%h5struct] accepts a list of fields, \
            e.g. [%h5struct time \"Time\" Int; price \"Price\" Float64]"))
    in
    let include_ =
      Str.include_ ~loc (
        Incl.mk ~loc
          (Mod.apply ~loc
            (Mod.ident ~loc { loc; txt = Longident.(
              Ldot (Ldot (Lident "Hdf5_caml", "Struct"), "Make")) })
            (Mod.structure ~loc [
              Str.value ~loc Nonrecursive [
                Vb.mk ~loc (Pat.var ~loc { txt = "fields"; loc })
                  (construct_fields_list fields loc)]])))
    in
    let bsize = 8 *
      List.fold_left (fun sum field -> sum + Type.wsize field.Field.type_) 0 fields in
    let pos = ref 0 in
    let functions =
      List.map (fun field ->
        let functions =
          [ construct_field_get field !pos loc;
            construct_field_set field !pos loc ]
          @ (
            if field.Field.seek then [ construct_field_seek field ~bsize !pos loc ]
            else [] ) in
        pos := !pos + (
          match field.Field.type_ with
          | Type.Float64 | Type.Int | Type.Int64 -> 1
          | Type.String length -> (length + 7) / 8);
        functions) fields
      |> List.concat
    in
    Str.include_ ~loc (Incl.mk ~loc (Mod.structure ~loc (
      include_ :: functions @ [
        construct_set_all_fields fields loc;
        construct_size_dependent_fun "unsafe_next" ~bsize ~index:false loc;
        construct_size_dependent_fun "unsafe_prev" ~bsize ~index:false loc;
        construct_size_dependent_fun "unsafe_move" ~bsize ~index:true  loc;
        construct_size_dependent_fun "next"        ~bsize ~index:false loc;
        construct_size_dependent_fun "prev"        ~bsize ~index:false loc;
        construct_size_dependent_fun "move"        ~bsize ~index:true  loc])))
  | s -> default_mapper.structure_item mapper s

let h5struct_mapper _ = { default_mapper with structure_item = map_structure_item }

let () = register "h5struct" h5struct_mapper
