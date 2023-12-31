let data = Advent.read_file "input/day21.txt"

module PairSet = Set.Make (struct
    type t = int * int

    let compare = compare
  end)

let parse_data strs =
  let start = ref (-1, -1) in
  let rock = ref PairSet.empty in
  let upper_bounds = List.length strs, String.length (List.hd strs) in
  List.iteri
    (fun i row ->
      String.iteri
        (fun j ch ->
          if Char.equal ch '#'
          then rock := PairSet.add (i, j) !rock
          else if Char.equal ch 'S'
          then start := i, j)
        row)
    strs;
  !start, !rock, upper_bounds
;;

let move_directions = [ 1, 0; -1, 0; 0, 1; 0, -1 ]

let get_neighbors (x, y) blocked (xb, yb) =
  let match_loop x n =
    match x mod n with
    | d when d >= 0 -> d
    | d -> n + d
  in
  let rec aux = function
    | [] -> []
    | (dx, dy) :: t ->
      let nx, ny = x + dx, y + dy in
      if PairSet.mem (match_loop nx xb, match_loop ny yb) blocked
      then aux t
      else (nx, ny) :: aux t
  in
  aux move_directions
;;

let walk n start rock bounds =
  let rec loop step queue =
    if List.is_empty queue
    then failwith "Queue is empty"
    else if step >= n
    then List.length queue
    else (
      let neighbors = queued_neighbors queue in
      let dedup_neighbors = List.sort_uniq compare neighbors in
      loop (step + 1) dedup_neighbors)
  and queued_neighbors = function
    | [] -> []
    | h :: t -> get_neighbors h rock bounds @ queued_neighbors t
  in
  loop 0 [ start ]
;;

let () =
  let start, rock, bounds = parse_data data in
  walk 64 start rock bounds |> Printf.printf "Part1: %d\n"
;;

let interpolate lst x =
  match lst with
  | [ c; b; a ] -> a + (x * (b - a + ((x - 1) * (c - b - b + a) / 2)))
  | _ -> failwith "Expected length 3"
;;

let walk2 n start rock (xb, yb) =
  let rec loop step acc queue =
    if List.is_empty queue
    then failwith "Queue is empty"
    else if List.length acc > 2
    then interpolate acc (n / xb)
    else if step = n
    then List.length queue
    else (
      let next_acc = if n mod xb = step mod xb then List.length queue :: acc else acc in
      let neighbors = queued_neighbors queue in
      let dedup_neighbors = List.sort_uniq compare neighbors in
      loop (step + 1) next_acc dedup_neighbors)
  and queued_neighbors = function
    | [] -> []
    | h :: t -> get_neighbors h rock (xb, yb) @ queued_neighbors t
  in
  loop 0 [] [ start ]
;;

let () =
  let start, rock, bounds = parse_data data in
  let target = 26501365 in
  Printf.printf "Part 2: %d\n" (walk2 target start rock bounds)
;;
