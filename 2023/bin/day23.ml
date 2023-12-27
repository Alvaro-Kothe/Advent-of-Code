let data = Advent.read_file "input/day23.txt"

module PairMap = Map.Make (struct
    type t = int * int

    let compare = compare
  end)

let parse_data strs =
  List.map (fun line -> Array.of_seq (String.to_seq line)) strs |> Array.of_list
;;

let ch_to_dir ~ignore_slope = function
  | '#' -> []
  | ('>' | '<' | 'v' | '^') when ignore_slope -> [ 1, 0; -1, 0; 0, 1; 0, -1 ]
  | '.' -> [ 1, 0; -1, 0; 0, 1; 0, -1 ]
  | '>' -> [ 0, 1 ]
  | '<' -> [ 0, -1 ]
  | 'v' -> [ 1, 0 ]
  | '^' -> [ -1, 0 ]
  | ch -> failwith (Printf.sprintf "Unexpected char %c\n" ch)
;;

let get_neighbors ?(ignore_slope = false) grid (x, y) =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let rec aux = function
    | [] -> []
    | (dx, dy) :: t ->
      let nx, ny = x + dx, y + dy in
      if is_valid (nx, ny) then (nx, ny) :: aux t else aux t
  and is_valid (x, y) =
    0 <= x && x < nrow && 0 <= y && y < ncol && grid.(x).(y) != '#'
  in
  aux (ch_to_dir ~ignore_slope grid.(x).(y))
;;

let dfs ?(ignore_slope = false) grid start target =
  let rec aux path pos =
    if pos = target
    then List.length path
    else if List.mem pos path
    then -1
    else (
      let nei = get_neighbors ~ignore_slope grid pos in
      let distances = List.map (aux (pos :: path)) nei in
      List.fold_left max (List.length path) distances)
  in
  aux [] start
;;

let () =
  let grid = parse_data data in
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let start = 0, 1 in
  let target = nrow - 1, ncol - 2 in
  Printf.printf "Part1: %d\n" (dfs grid start target)
;;

let matrix_indices rows cols =
  let rec loop i j acc =
    if i >= rows
    then acc
    else if j >= cols
    then loop (i + 1) 0 acc
    else loop i (j + 1) ((i, j) :: acc)
  in
  loop 0 0 []
;;

let focus_grid grid app_lst =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let idxs = matrix_indices nrow ncol in
  let vertexes =
    List.filter
      (fun pos -> List.length (get_neighbors ~ignore_slope:true grid pos) > 2)
      idxs
  in
  List.sort_uniq compare (app_lst @ vertexes)
;;

let rec add_val n = function
  | [] -> []
  | h :: t -> (h, n) :: add_val n t
;;

let explore_vertexes grid vertexes =
  let rec explore_root map = function
    | [] -> map
    | h :: t -> explore_root (explore_children map h [] [ h, 0 ]) t
  and explore_children map orig visited = function
    | [] -> map
    | (pos, dist) :: t when List.mem pos vertexes && pos != orig ->
      let nm = PairMap.add_to_list orig (pos, dist) map in
      explore_children nm orig (pos :: visited) t
    | (pos, _) :: t when List.mem pos visited -> explore_children map orig visited t
    | (pos, dist) :: t ->
      let nei = get_neighbors ~ignore_slope:true grid pos in
      let to_app = add_val (dist + 1) nei in
      explore_children map orig (pos :: visited) (to_app @ t)
  in
  explore_root PairMap.empty vertexes
;;

let dfs map start target =
  let rec aux path pos dist =
    if pos = target
    then dist
    else if List.mem pos path
    then -1
    else (
      let nei = PairMap.find pos map in
      let distances = List.map (fun (p, d) -> aux (pos :: path) p (dist + d)) nei in
      List.fold_left max (List.length path) distances)
  in
  aux [] start 0
;;

let () =
  let grid = parse_data data in
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let start = 0, 1 in
  let target = nrow - 1, ncol - 2 in
  let vertexes = focus_grid grid [ start; target ] in
  let map = explore_vertexes grid vertexes in
  Printf.printf "Part2: %d\n" (dfs map start target)
;;
