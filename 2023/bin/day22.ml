let data = Advent.read_file "input/day22.txt"

module PairMap = Map.Make (struct
    type t = int * int

    let compare = compare
  end)

let parse_data strs =
  let parse_coord str =
    match String.split_on_char ',' str with
    | [ a; b; c ] -> int_of_string a, int_of_string b, int_of_string c
    | _ -> failwith ("Unexpected coord " ^ str)
  in
  let parse_line line =
    match String.split_on_char '~' line with
    | [ l; r ] -> parse_coord l, parse_coord r
    | _ -> failwith ("Unexpected line " ^ line)
  in
  let bricks = List.map parse_line strs in
  List.sort (fun ((_, _, c), (_, _, _)) ((_, _, i), (_, _, _)) -> compare c i) bricks
;;

let fall bricks =
  let rec aux height_map n_fallen acc = function
    | [] -> n_fallen, List.rev acc
    | brick :: rest ->
      let dropped = drop_brick height_map brick in
      let next_map = add_to_map height_map dropped in
      if dropped = brick
      then aux next_map n_fallen (brick :: acc) rest
      else aux next_map (n_fallen + 1) (dropped :: acc) rest
  and drop_brick height_map ((x1, y1, z1), (x2, y2, z2)) =
    let z_limit = get_limit height_map x1 y1 x2 y2 in
    let dz = max (z1 - z_limit - 1) 0 in
    (x1, y1, z1 - dz), (x2, y2, z2 - dz)
  and get_limit height_map x1 y1 x2 y2 =
    let limit = ref 0 in
    for x = x1 to x2 do
      for y = y1 to y2 do
        limit
        := max
             !limit
             (match PairMap.find_opt (x, y) height_map with
              | Some d -> d
              | None -> 0)
      done
    done;
    !limit
  and add_to_map height_map ((x1, y1, _), (x2, y2, z)) =
    let map_ = ref height_map in
    for x = x1 to x2 do
      for y = y1 to y2 do
        (* Printf.printf "%d %d\n" x y; *)
        map_ := PairMap.add (x, y) z !map_
      done
    done;
    !map_
  in
  aux PairMap.empty 0 [] bricks
;;

let remove_brick bricks =
  let rec aux acc n_safe n_falls = function
    | [] -> n_safe, n_falls
    | brick :: rest ->
      (match fall (List.rev acc @ rest) with
       | 0, _ -> aux (brick :: acc) (n_safe + 1) n_falls rest
       | d, _ -> aux (brick :: acc) n_safe (n_falls + d) rest)
  in
  aux [] 0 0 bricks
;;

let () =
  let bricks = parse_data data in
  let _, fallen = fall bricks in
  let p1, p2 = remove_brick fallen in
  Printf.printf "Part1: %d\n" p1;
  Printf.printf "Part2: %d\n" p2
;;
