let data = Advent.read_file "input/day14.txt"

module PairSet = Set.Make (struct
    type t = int * int

    let compare = compare
  end)

let parse_data strs =
  let round = ref [] in
  let cube = ref PairSet.empty in
  let bounds = -1, List.length strs, -1, String.length (List.hd strs) in
  List.iteri
    (fun i row ->
      String.iteri
        (fun j ch ->
          if Char.equal ch '#'
          then cube := PairSet.add (i, j) !cube
          else if Char.equal ch 'O'
          then round := (i, j) :: !round
          else ())
        row)
    strs;
  !round, !cube, bounds
;;

let compare_direction dir =
  match dir with
  | 0, dy when dy > 0 ->
    fun (_, a) (_, b) -> compare b a (*move right, right objects first*)
  | 0, _ -> fun (_, a) (_, b) -> compare a b
  | dx, 0 when dx > 0 ->
    fun (a, _) (b, _) -> compare b a (*move down, down objects first*)
  | _, 0 -> fun (a, _) (b, _) -> compare a b
  | dx, dy -> failwith (Format.sprintf "Unexpected pattern (%d, %d)" dx dy)
;;

let tilt movable imovable (dx, dy) (bu, bd, bl, br) =
  let sorted_movable = List.sort (compare_direction (dx, dy)) movable in
  let rec aux acc = function
    | [] -> acc
    | (x, y) :: rest -> aux (move x y acc :: acc) rest
  and move x y obstacle =
    let nx, ny = x + dx, y + dy in
    if nx <= bu
       || nx >= bd
       || ny <= bl
       || ny >= br
       || List.mem (nx, ny) obstacle
       || PairSet.mem (nx, ny) imovable
    then x, y
    else move nx ny obstacle
  in
  aux [] sorted_movable
;;

let rec compute_load bd = function
  | [] -> 0
  | (x, _) :: t -> bd - x + compute_load bd t
;;

let () =
  let round, cube, (bu, bd, bl, br) = parse_data data in
  let tilted_north_pos = tilt round cube (-1, 0) (bu, bd, bl, br) in
  Format.printf "Part1: %d\n" (compute_load bd tilted_north_pos)
;;

let cycle movable imovable bounds =
  let rec aux pos = function
    | [] -> pos
    | tilt_dir :: t ->
      let tilted = tilt pos imovable tilt_dir bounds in
      aux tilted t
  in
  aux movable [ -1, 0; 0, -1; 1, 0; 0, 1 ]
;;

let repeat_cycle n movable imovable bounds =
  let memo = Hashtbl.create 256 in
  let rec aux i movable' =
    if i >= n
    then movable'
    else (
      match Hashtbl.find_opt memo movable' with
      | Some d when d < i ->
        let cycle_len = i - d in
        let n_cycles = (n - i) / cycle_len in
        let skip = n_cycles * cycle_len in
        Hashtbl.add memo movable' (i + skip);
        aux (i + skip) movable'
      | _ ->
        let cycled = cycle movable' imovable bounds in
        Hashtbl.add memo movable' i;
        aux (i + 1) cycled)
  in
  aux 0 movable
;;

let () =
  let round, cube, (bu, bd, bl, br) = parse_data data in
  let cycled_pos = repeat_cycle 1_000_000_000 round cube (bu, bd, bl, br) in
  Format.printf "Part2: %d\n" (compute_load bd cycled_pos)
;;
