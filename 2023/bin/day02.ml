let data = Advent.read_file "input/day02.txt"

let rec match_to_int = function
  | [] -> []
  | h :: t -> int_of_string (Re.Group.get h 1) :: match_to_int t
;;

let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t
;;

let count_rgb str =
  let patterns = [ "(\\d+) red"; "(\\d+) green"; "(\\d+) blue" ] in
  let rec extract_pattern pat =
    match pat with
    | [] -> []
    | h :: rest ->
      let regex = Re.Perl.compile_pat h in
      let counts = Re.all regex str in
      match_to_int counts :: extract_pattern rest
  in
  extract_pattern patterns
;;

let rec lte l1 x =
  match l1 with
  | [] -> true
  | h :: t -> if h > x then false else lte t x
;;

let () =
  let is_list_valid il =
    let ub = [ 12; 13; 14 ] in
    List.fold_left2 (fun cond lst value -> cond && lte lst value) true il ub
  in
  let valid_games =
    List.mapi
      (fun i str ->
        let counts = count_rgb str in
        let is_valid = is_list_valid counts in
        if is_valid then i + 1 else 0)
      data
  in
  Format.printf "Part1: %d\n" (sum valid_games)
;;

let max_lst lst =
  let first_element = List.hd lst in
  List.fold_left max first_element lst
;;

let rec prod lst =
  match lst with
  | [] -> 1
  | h :: t -> h * prod t
;;

let () =
  let powers =
    List.map
      (fun str ->
        let counts = count_rgb str in
        let mins = List.map max_lst counts in
        prod mins)
      data
  in
  Format.printf "Part2: %d\n" (sum powers)
;;
