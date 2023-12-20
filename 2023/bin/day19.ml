let data = Advent.read_file "input/day19.txt"

type workflow =
  { name : string
  ; rules : rule list
  }

and rule =
  | Rule of
      { part : char
      ; cond : int -> bool
      ; value : int
      ; op : char
      ; target : string
      }
  | Default of string

let match_rule rule_str =
  if String.exists (Char.equal ':') rule_str
  then (
    let colon_pos = String.index rule_str ':' in
    let value = int_of_string (String.sub rule_str 2 (colon_pos - 2)) in
    let op = rule_str.[1] in
    let cond = if op = '>' then fun x -> x > value else fun x -> x < value in
    let target =
      String.sub
        rule_str
        (colon_pos + 1)
        (String.length rule_str - colon_pos - 1)
    in
    Rule { part = rule_str.[0]; cond; value; op; target })
  else Default rule_str
;;

let parse_workflow str =
  let regex = Re.Perl.compile_pat "^([a-z]+)\\{(.+)\\}" in
  let parse_rule str =
    let rules = String.split_on_char ',' str in
    List.map match_rule rules
  in
  let group = Re.exec regex str in
  let name = Re.Group.get group 1 in
  let rules_str = Re.Group.get group 2 in
  { name; rules = parse_rule rules_str }
;;

let parse_part str =
  let regex = Re.Perl.compile_pat "\\{(.+)\\}" in
  let group = Re.exec regex str in
  let rec aux = function
    | [] -> []
    | h :: t ->
      (h.[0], int_of_string (String.sub h 2 (String.length h - 2))) :: aux t
  in
  Re.Group.get group 1 |> String.split_on_char ',' |> aux
;;

let parse_data strs =
  let rec aux in_work workflows parts = function
    | [] -> workflows, parts
    | "" :: t -> aux false workflows parts t
    | h :: t when in_work -> aux in_work (parse_workflow h :: workflows) parts t
    | h :: t -> aux in_work workflows (parse_part h :: parts) t
  in
  aux true [] [] strs
;;

let get_workflow name workflows =
  let rec aux acc = function
    | [] -> failwith "Not found"
    | w :: t -> if w.name = name then w, acc @ workflows else aux (w :: acc) t
  in
  aux [] workflows
;;

let rec get_part_value part = function
  | [] -> failwith "Part not found"
  | (name, value) :: t -> if name = part then value else get_part_value part t
;;

let rec sum_values = function
  | [] -> 0
  | (_, v) :: t -> v + sum_values t
;;

let verify_part parts workflows =
  let rec test_rules = function
    | [] -> assert false
    | Default target :: _ -> target
    | Rule { part; cond; target; _ } :: t ->
      let part_value = get_part_value part parts in
      if cond part_value then target else test_rules t
  in
  let rec verify cur_workflow remaining_workflows =
    match test_rules cur_workflow.rules with
    | "A" -> true
    | "R" -> false
    | target ->
      let nxt_wrk, remaining = get_workflow target remaining_workflows in
      verify nxt_wrk remaining
  in
  let starting_workflow, remaining_workflows = get_workflow "in" workflows in
  verify starting_workflow remaining_workflows
;;

let () =
  let workflows, parts = parse_data data in
  List.fold_left
    (fun acc part ->
      acc + if verify_part part workflows then sum_values part else 0)
    0
    parts
  |> Printf.printf "Part1: %d\n"
;;

let split_range range op value =
  match op, range with
  | '<', (lo, hi) when value < hi -> Some (lo, value - 1), (value, hi)
  | '>', (lo, hi) when value > lo -> Some (value + 1, hi), (lo, value)
  | _, (lo, hi) when lo > hi ->
    failwith (Printf.sprintf "Incorrect range (%d, %d)\n" lo hi)
  | _ -> None, range
;;

let get_splits x m a s rules =
  let rec aux acc x m a s = function
    | [] -> acc
    | Rule { part = 'x'; target; op; value; _ } :: rest ->
      (match split_range x op value with
       | None, range -> aux acc range m a s rest
       | Some r1, r2 -> aux ((target, r1, m, a, s) :: acc) r2 m a s rest)
    | Rule { part = 'm'; target; op; value; _ } :: rest ->
      (match split_range m op value with
       | None, range -> aux acc x range a s rest
       | Some r1, r2 -> aux ((target, x, r1, a, s) :: acc) x r2 a s rest)
    | Rule { part = 'a'; target; op; value; _ } :: rest ->
      (match split_range a op value with
       | None, range -> aux acc x m range s rest
       | Some r1, r2 -> aux ((target, x, m, r1, s) :: acc) x m r2 s rest)
    | Rule { part = 's'; target; op; value; _ } :: rest ->
      (match split_range s op value with
       | None, range -> aux acc x m a range rest
       | Some r1, r2 -> aux ((target, x, m, a, r1) :: acc) x m a r2 rest)
    | Default target :: t -> aux ((target, x, m, a, s) :: acc) x m a s t
    | _ -> assert false
  in
  aux [] x m a s rules
;;

let verify_workflows rng_x rng_m rng_a rng_s workflows =
  let rec aux acc queue =
    match queue with
    | [] -> acc
    | ("A", (xl, xu), (ml, mu), (al, au), (sl, su)) :: rest ->
      let count =
        (xu - xl + 1) * (mu - ml + 1) * (au - al + 1) * (su - sl + 1)
      in
      aux (acc + count) rest
    | ("R", _, _, _, _) :: rest -> aux acc rest
    | (cur, x, m, a, s) :: rest ->
      let wf, _ = get_workflow cur workflows in
      let splits = get_splits x m a s wf.rules in
      aux acc (splits @ rest)
  in
  let queue = [ "in", rng_x, rng_m, rng_a, rng_s ] in
  aux 0 queue
;;

let () =
  let workflows, _ = parse_data data in
  Printf.printf
    "Part2: %d\n"
    (verify_workflows (1, 4000) (1, 4000) (1, 4000) (1, 4000) workflows)
;;
