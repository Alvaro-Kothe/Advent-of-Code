let data = Advent.read_file "input/day16.txt"

let parse_data strs =
  List.map (fun line -> Array.of_seq (String.to_seq line)) strs |> Array.of_list
;;

module PairSet = Set.Make (struct
    type t = int * int

    let compare = compare
  end)

module PairPairSet = Set.Make (struct
    type t = (int * int) * (int * int)

    let compare = compare
  end)

(** [start] contains the starting position and start moving direction*)
let bfs grid start =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let oob x y = x >= nrow || x < 0 || y >= ncol || y < 0 in
  let rec move visited queue =
    match queue with
    | [] -> visited
    | pos_dir :: rest when PairPairSet.mem pos_dir visited -> move visited rest
    | ((x, y), (dx, dy)) :: rest ->
      let next_visited = PairPairSet.add ((x, y), (dx, dy)) visited in
      let nx, ny = x + dx, y + dy in
      if oob nx ny
      then move next_visited rest
      else (
        match grid.(nx).(ny), (dx, dy) with
        | '.', dir -> move next_visited (((nx, ny), dir) :: rest)
        | '/', (dx, dy) -> move next_visited (((nx, ny), (-dy, -dx)) :: rest)
        | '\\', (dx, dy) -> move next_visited (((nx, ny), (dy, dx)) :: rest)
        | '|', (0, _) ->
          move next_visited (((nx, ny), (-1, 0)) :: ((nx, ny), (1, 0)) :: rest)
        | '|', dir -> move next_visited (((nx, ny), dir) :: rest)
        | '-', (_, 0) ->
          move next_visited (((nx, ny), (0, -1)) :: ((nx, ny), (0, 1)) :: rest)
        | '-', dir -> move next_visited (((nx, ny), dir) :: rest)
        | _ -> assert false)
  in
  move PairPairSet.empty start
;;

let count_energized ppset =
  let rec aux pset = function
    | [] -> PairSet.cardinal pset - 1
    | (pos, _) :: rest -> aux (PairSet.add pos pset) rest
  in
  aux PairSet.empty (PairPairSet.to_list ppset)
;;

let () =
  let grid = parse_data data in
  let start = [ (0, -1), (0, 1) ] in
  bfs grid start |> count_energized |> Printf.printf "Part1: %d\n"
;;

let get_starts grid =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  List.init nrow (fun i -> (i, -1), (0, 1))
  @ List.init nrow (fun i -> (i, ncol), (0, -1))
  @ List.init ncol (fun i -> (-1, i), (1, 0))
  @ List.init ncol (fun i -> (nrow, i), (-1, 0))
  |> List.sort_uniq compare
;;

let () =
  let grid = parse_data data in
  let starts = get_starts grid in
  List.fold_left
    (fun acc start ->
      let en_count = bfs grid [ start ] |> count_energized in
      max acc en_count)
    min_int
    starts
  |> Printf.printf "Part2: %d\n"
;;
