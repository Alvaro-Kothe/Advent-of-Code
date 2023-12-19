let data = Advent.read_file "input/day17.txt"

let parse_data strs =
  List.map
    (fun line ->
      String.to_seq line
      |> Seq.map (fun ch -> int_of_string (Char.escaped ch))
      |> Array.of_seq)
    strs
  |> Array.of_list
;;

module PriotityQueue = struct
  let rec insert pq prio value =
    match pq with
    | [] -> [ prio, value ]
    | (p, v) :: rest ->
      if prio <= p
      then (prio, value) :: pq
      else (p, v) :: insert rest prio value
  ;;

  let pop = function
    | [] -> failwith "Empty"
    | (cost, v) :: rest -> (cost, v), rest
  ;;
end

let get_moves_count (x, y) = max (abs x) (abs y)
let sign x = if x > 0 then 1 else if x < 0 then -1 else 0

let pair_sign (x, y) =
  match sign x, sign y with
  | a, b when a = b -> 0, 1
  | a, b -> a, b
;;

let get_neighbors grid (x, y) dir_acum =
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let dx, dy = pair_sign dir_acum in
  let oob x y = x >= nrow || x < 0 || y >= ncol || y < 0 in
  let rec aux = function
    | [] -> []
    | (dx, dy) :: t ->
      let nx, ny = x + dx, y + dy in
      if oob nx ny then aux t else (grid.(nx).(ny), (dx, dy), (nx, ny)) :: aux t
  in
  aux [ dx, dy; dy, dx; -dy, -dx ]
;;

module PairPairSet = Set.Make (struct
    type t = (int * int) * (int * int)

    let compare = compare
  end)

let dijkstra grid start_pos end_pos min_moves max_moves =
  let costs = Hashtbl.create 256 in
  let get_queue_hashed queue cost key =
    let stored_cost =
      match Hashtbl.find_opt costs key with
      | None -> max_int
      | Some cst -> cst
    in
    if cost < stored_cost
    then (
      Hashtbl.replace costs key cost;
      PriotityQueue.insert queue cost key)
    else queue
  in
  let rec enqueue_neighbors cost queue (dxa, dya) = function
    | [] -> queue
    | (c, (dx, dy), p) :: rest ->
      let path_cost = c + cost in
      let same_dir = pair_sign (dxa, dya) = (dx, dy) in
      let dir_acum = if same_dir then dxa + dx, dya + dy else dx, dy in
      let current_moves = get_moves_count (dxa, dya) in
      let future_move = get_moves_count dir_acum in
      (match current_moves >= min_moves, future_move > max_moves with
       | false, false ->
         if same_dir
         then get_queue_hashed queue path_cost (dir_acum, p)
         else enqueue_neighbors cost queue (dxa, dya) rest
       | false, true -> assert false
       | true, false ->
         let next_q = get_queue_hashed queue path_cost (dir_acum, p) in
         enqueue_neighbors cost next_q (dxa, dya) rest
       | true, true -> enqueue_neighbors cost queue (dxa, dya) rest)
  in
  let rec aux queue =
    let (cost, (dir_acum, pos)), pq = PriotityQueue.pop queue in
    if pos = end_pos
    then cost
    else (
      let neighbors = get_neighbors grid pos dir_acum in
      let next_queue = enqueue_neighbors cost pq dir_acum neighbors in
      aux next_queue)
  in
  let queue = [ 0, ((min_moves, min_moves), start_pos) ] in
  aux queue
;;

let () =
  let grid = parse_data data in
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let end_pos = nrow - 1, ncol - 1 in
  let start_pos = 0, 0 in
  dijkstra grid start_pos end_pos 1 3 |> Printf.printf "Part1: %d\n"
;;

let () =
  let grid = parse_data data in
  let nrow = Array.length grid in
  let ncol = Array.length grid.(0) in
  let end_pos = nrow - 1, ncol - 1 in
  let start_pos = 0, 0 in
  dijkstra grid start_pos end_pos 4 10 |> Printf.printf "Part2: %d\n"
;;
