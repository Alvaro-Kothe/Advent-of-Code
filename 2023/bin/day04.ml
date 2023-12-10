let data = Advent.read_file "input/day04.txt"

let split_list_to_tuple = function
  | [ x; y ] -> x, y
  | _ -> failwith ""
;;

let rec match_to_int = function
  | [] -> []
  | h :: t -> int_of_string (Re.Group.get h 1) :: match_to_int t
;;

let parse_card str =
  let card_numbers = String.split_on_char ':' str |> List.rev |> List.hd in
  let numbers = String.split_on_char '|' card_numbers in
  let regex = Re.Perl.compile_pat "(\\d+)" in
  let aux str = Re.all regex str |> match_to_int in
  let win_my = List.map aux numbers in
  split_list_to_tuple win_my
;;

module IntSet = Set.Make (Int)

let count_score win_numbers my_numbers =
  let win_set = IntSet.of_list win_numbers in
  let my_set = IntSet.of_list my_numbers in
  IntSet.inter my_set win_set |> IntSet.cardinal
;;

let card_score win_numbers my_numbers =
  match count_score win_numbers my_numbers with
  | 0 -> 0
  | n -> 2. ** float_of_int (n - 1) |> int_of_float
;;

let () =
  List.fold_left
    (fun acc line ->
      let win, my = parse_card line in
      acc + card_score win my)
    0
    data
  |> Format.printf "Part1: %d\n"
;;

let increment_list inc_value times lst =
  let rec aux n lst_out = function
    | [] -> List.rev lst_out
    | h :: t ->
      if n <= 0
      then aux n (h :: lst_out) t
      else aux (n - 1) ((h + inc_value) :: lst_out) t
  in
  aux times [] lst
;;

let () =
  let initial_copies = List.init (List.length data) (fun _ -> 1) in
  let rec aux acc copies lines =
    match copies, lines with
    | [], [] -> acc
    | ncopies :: other_copies, this_card :: rest_cards ->
      let win, my = parse_card this_card in
      let matches = count_score win my in
      let inc_copies = increment_list ncopies matches other_copies in
      aux (acc + ncopies) inc_copies rest_cards
    | _ -> failwith "data and initial_copies don't have same length"
  in
  aux 0 initial_copies data |> Format.printf "Part2: %d\n"
;;
