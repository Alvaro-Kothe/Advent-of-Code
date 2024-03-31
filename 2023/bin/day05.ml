let data = Advent.read_file "input/day05.txt"

type map =
  { dst : int
  ; src : int
  ; rng : int
  }

let parse_map_line str =
  let regex = Re.Perl.compile_pat "\\s+" in
  let numbers = Re.split regex str in
  let aux lst =
    match List.map int_of_string lst with
    | [ x; y; z ] -> { dst = x; src = y; rng = z }
    | _ -> failwith "Expected length 3"
  in
  aux numbers
;;

let parse_maps str_lst =
  let rec aux acc out = function
    | [] -> List.rev (acc :: out)
    | h :: t ->
      if String.ends_with ~suffix:":" h
      then aux [] (acc :: out) t
      else if String.equal "" h
      then aux acc out t
      else aux (parse_map_line h :: acc) out t
  in
  aux [] [] str_lst
;;

let parse_seeds str =
  let regex = Re.Perl.compile_pat "(\\d+)" in
  Re.all regex str |> Advent.match_to_int
;;

let get_seed_maps = function
  | h :: _ :: t -> h, t
  | _ -> failwith ""
;;

let parse_puzzle lst_str =
  let seed_str, maps = get_seed_maps lst_str in
  parse_seeds seed_str, parse_maps maps
;;

let match_map seed maps =
  let rec aux src = function
    | [] -> src
    | h :: t ->
      if h.src <= src && src <= h.src + h.rng - 1
      then h.dst - h.src + src
      else aux src t
  in
  aux seed maps
;;

let rec get_location seed maps =
  match maps with
  | [] -> seed
  | h :: t ->
    let next_pos = match_map seed h in
    get_location next_pos t
;;

let () =
  let seeds, maps = parse_puzzle data in
  let rec aux min_loc = function
    | [] -> min_loc
    | seed :: t -> aux (min min_loc (get_location seed maps)) t
  in
  Format.printf "Part1: %d\n" (aux max_int seeds)
;;

let seed_intervals seeds =
  let rec aux = function
    | [] -> []
    | start :: range :: t -> (start, start + range - 1) :: aux t
    | _ -> failwith "Expected even number of seeds"
  in
  aux seeds
;;

let merge_intervals intervals =
  let sorted_intervals = List.sort (fun (a, _) (b, _) -> compare a b) intervals in
  let rec union acc = function
    | [] -> acc
    | (a1, b1) :: (a2, b2) :: t ->
      if a2 <= b1 - 1
      then union acc ((a1, max b1 b2) :: t)
      else union ((a1, b1) :: acc) ((a2, b2) :: t)
    | h :: [] -> union (h :: acc) []
  in
  union [] sorted_intervals
;;

let rec look_seeds ?(step = 1) acc start end_ maps =
  if start = end_
  then acc
  else (
    let new_acc = min acc (get_location start maps) in
    (* if step mod 10000 = 0 then Format.printf "Seed: %d\t min: %d\n" start new_acc; *)
    look_seeds new_acc (start + 1) end_ maps ~step:(step + 1))
;;

let () =
  let seeds, maps = parse_puzzle data in
  let seed_ranges_ = seed_intervals seeds |> merge_intervals in
  let rec aux acc = function
    | [] -> acc
    | (start, end_) :: t ->
      let new_acc = look_seeds acc start end_ maps in
      aux new_acc t
  in
  Format.printf "Part2: %d\n" (aux max_int seed_ranges_)
;;
