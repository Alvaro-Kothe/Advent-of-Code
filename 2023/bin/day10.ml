let data = Advent.read_file "input/day10.txt"

let parse_data strs =
  let nrow = List.length strs in
  let ncol = List.hd strs |> String.length in
  let grid = Array.make_matrix nrow ncol '.' in
  List.iteri
    (fun row str -> String.iteri (fun col ch -> grid.(row).(col) <- ch) str)
    strs;
  grid
;;

let find_start (grid : char array array) =
  let result = ref (-1, -1) in
  Array.iteri
    (fun i row -> Array.iteri (fun j ch -> if ch = 'S' then result := i, j) row)
    grid;
  !result
;;

let can_move ch move =
  match ch, move with
  | '|', (_, 0) -> true
  | '-', (0, _) -> true
  | 'L', (1, 0) | 'L', (0, -1) -> true
  | 'J', (1, 0) | 'J', (0, 1) -> true
  | '7', (-1, 0) | '7', (0, 1) -> true
  | 'F', (-1, 0) | 'F', (0, -1) -> true
  | _ -> false
;;

let get_possible_positions grid (x, y) =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let possible_moves =
    List.filter
      (fun (dx, dy) ->
        let nx, ny = x + dx, y + dy in
        nx >= 0
        && nx < nrow
        && ny >= 0
        && ny < ncol
        && can_move grid.(x + dx).(y + dy) (dx, dy))
      [ -1, 0; 1, 0; 0, -1; 0, 1 ]
  in
  List.map (fun (dx, dy) -> x + dx, y + dy) possible_moves
;;

let concat_element n lst =
  let rec aux acc = function
    | [] -> List.rev acc
    | h :: t -> aux ((h, n) :: acc) t
  in
  aux [] lst
;;

let bfs grid (x, y) =
  let _ = grid.(x).(y) <- '.' in
  let rec move last_step visited queue =
    match queue with
    | [] -> last_step, visited
    | ((x', y'), step) :: rest ->
      let _ = grid.(x').(y') <- '.' in
      let neighbors = get_possible_positions grid (x', y') in
      let new_queue = rest @ concat_element (step + 1) neighbors in
      move step ((x', y') :: visited) new_queue
  in
  move 0 [] [ (x, y), 0 ]
;;

let () =
  let grid = parse_data data in
  let start_pos = find_start grid in
  bfs grid start_pos |> fst |> Printf.printf "Part1: %d\n"
;;

let get_loop grid (x, y) =
  let rec move (x', y') (dx, dy) =
    let nx, ny = x' + dx, y' + dy in
    (nx, ny)
    ::
    (match grid.(nx).(ny) with
     | 'S' -> []
     | '|' | '-' -> move (nx, ny) (dx, dy)
     | ('7' | 'L') when dy != 0 -> move (nx, ny) (dy, 0)
     | '7' | 'L' -> move (nx, ny) (0, dx)
     | ('J' | 'F') when dy != 0 -> move (nx, ny) (-dy, 0)
     | 'J' | 'F' -> move (nx, ny) (0, -dx)
     | _ -> assert false)
  in
  let x0, y0 = get_possible_positions grid (x, y) |> List.hd in
  let dx0, dy0 = x0 - x, y0 - y in
  move (x, y) (dx0, dy0)
;;

let rec shoe_lace = function
  | [] | [ _ ] -> 0
  | (x1, y1) :: (x2, y2) :: rest ->
    ((y2 + y1) * (x2 - x1)) + shoe_lace ((x2, y2) :: rest)
;;

let () =
  let grid = parse_data data in
  let start_pos = find_start grid in
  let path = get_loop grid start_pos in
  (abs (shoe_lace path) - List.length path + 3) / 2 |> Printf.printf "Part2: %d\n"
;;
