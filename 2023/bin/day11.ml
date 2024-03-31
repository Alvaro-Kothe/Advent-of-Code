let data = Advent.read_file "input/day11.txt"
let manhattan_distance (x1, y1) (x2, y2) = abs (x1 - x2) + abs (y1 - y2)

let compute_distances lst =
  let rec distance_one_rest cur = function
    | [] -> 0
    | h :: t -> manhattan_distance cur h + distance_one_rest cur t
  in
  let rec sum_all_distances = function
    | [] | [ _ ] -> 0
    | h :: t -> distance_one_rest h t + sum_all_distances t
  in
  sum_all_distances lst
;;

let parse_data strs =
  let nrow = List.length strs in
  let ncol = List.hd strs |> String.length in
  let grid = Array.make_matrix nrow ncol '.' in
  let galaxy_pos = ref [] in
  List.iteri
    (fun row str ->
      String.iteri
        (fun col ch ->
          if ch = '#' then galaxy_pos := (row, col) :: !galaxy_pos;
          grid.(row).(col) <- ch)
        str)
    strs;
  grid, !galaxy_pos
;;

let get_empty_rows grid =
  let empty_rows = ref [] in
  Array.iteri
    (fun i row ->
      if Array.for_all (fun ch -> ch = '.') row then empty_rows := i :: !empty_rows)
    grid;
  List.rev !empty_rows
;;

let get_empty_cols grid =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let rec check_col row_idx col_idx =
    if row_idx >= nrow
    then true
    else if grid.(row_idx).(col_idx) = '.'
    then check_col (row_idx + 1) col_idx
    else false
  in
  let rec check_all acc col_idx =
    if col_idx >= ncol
    then List.rev acc
    else if check_col 0 col_idx
    then check_all (col_idx :: acc) (col_idx + 1)
    else check_all acc (col_idx + 1)
  in
  check_all [] 0
;;

let count_pred predicate lst =
  let rec aux acc = function
    | [] -> acc
    | h :: t -> if predicate h then aux (acc + 1) t else acc
  in
  aux 0 lst
;;

let expand_universe ?(times = 2) galaxy_pos empty_rows empty_cols =
  let fix_galaxy_pos (x, y) =
    let row_shift = count_pred (fun x' -> x' < x) empty_rows in
    let col_shift = count_pred (fun y' -> y' < y) empty_cols in
    x + ((times - 1) * row_shift), y + ((times - 1) * col_shift)
  in
  let rec aux = function
    | [] -> []
    | pos :: rest -> fix_galaxy_pos pos :: aux rest
  in
  aux galaxy_pos
;;

let () =
  let grid, galaxies = parse_data data in
  let empty_rows = get_empty_rows grid in
  let empty_cols = get_empty_cols grid in
  let new_galaxies_pos = expand_universe galaxies empty_rows empty_cols in
  compute_distances new_galaxies_pos |> Format.printf "Part1: %d\n"
;;

let () =
  let grid, galaxies = parse_data data in
  let empty_rows = get_empty_rows grid in
  let empty_cols = get_empty_cols grid in
  let new_galaxies_pos =
    expand_universe galaxies empty_rows empty_cols ~times:1_000_000
  in
  compute_distances new_galaxies_pos |> Format.printf "Part2: %d\n"
;;
