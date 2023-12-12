let data = Advent.read_file "input/day08.txt"

type node =
  { name : string
  ; left : string
  ; right : string
  }

let parse_line str =
  let regex = Re.Perl.compile_pat "[0-9A-Z]{3}" in
  let aux = function
    | [ name; left; right ] -> { name; left; right }
    | _ -> failwith ("could not parse " ^ str)
  in
  Re.matches regex str |> aux
;;

let rec parse_nodes = function
  | [] -> []
  | str :: t -> parse_line str :: parse_nodes t
;;

let parse_data strs =
  match strs with
  | dir :: _ :: nodes -> List.of_seq (String.to_seq dir), parse_nodes nodes
  | _ -> assert false
;;

let lookup_element node dir =
  match dir with
  | 'L' -> node.left
  | 'R' -> node.right
  | _ -> failwith "direction should be only L or R"
;;

let rec get_node node_name = function
  | [] -> failwith ("Could not find " ^ node_name)
  | node :: t -> if node.name = node_name then node else get_node node_name t
;;

let lookup src predicate directions nodes =
  let rec aux acc src' dirs =
    if predicate src'.name
    then acc
    else (
      match dirs with
      | [] -> aux acc src' directions
      | dir :: t ->
        let next_node = get_node (lookup_element src' dir) nodes in
        aux (acc + 1) next_node t)
  in
  aux 0 src directions
;;

let () =
  let directions, nodes = parse_data data in
  let aaa = get_node "AAA" nodes in
  lookup aaa (fun x -> x = "ZZZ") directions nodes |> Format.printf "Part1: %d\n"
;;

let rec gcd x y = if y = 0 then x else gcd y (x mod y)
let lcm m n = m * n / gcd m n

let () =
  let directions, nodes = parse_data data in
  let aaas = List.filter (fun node -> String.ends_with ~suffix:"A" node.name) nodes in
  let first_z_times =
    List.map
      (fun src -> lookup src (fun x -> String.ends_with x ~suffix:"Z") directions nodes)
      aaas
  in
  List.fold_left (fun acc elem -> lcm acc elem) 1 first_z_times
  |> Format.printf "Part2: %d\n"
;;
