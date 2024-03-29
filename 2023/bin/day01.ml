open Core

let data = Advent.read_file "input/day01.txt"

let rec get_first_digit char_list =
  match char_list with
  | [] -> ""
  | ch :: lst -> if Char.is_digit ch then Char.escaped ch else get_first_digit lst
;;

let get_first_last_digit str =
  let ch_lst = String.to_list str in
  let first_digit = get_first_digit ch_lst in
  let last_digit = get_first_digit (List.rev ch_lst) in
  let first_last_digit = first_digit ^ last_digit in
  int_of_string first_last_digit
;;

let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t
;;

let () =
  let numbers = List.map data ~f:get_first_last_digit in
  printf "Part 1: %d\n" (sum numbers)
;;

let rec _replace_cases cases str =
  match cases with
  | [] -> str
  | (case, repl) :: rest ->
    String.substr_replace_all ~pattern:case ~with_:repl (_replace_cases rest str)
;;

let replace_cases str =
  let cases_replacements =
    [ "one", "one1one"
    ; "two", "two2two"
    ; "three", "three3three"
    ; "four", "four4four"
    ; "five", "five5five"
    ; "six", "six6six"
    ; "seven", "seven7seven"
    ; "eight", "eight8eight"
    ; "nine", "nine9nine"
    ]
  in
  _replace_cases cases_replacements str
;;

let () =
  let numbers =
    List.map data ~f:(fun line -> replace_cases line |> get_first_last_digit)
  in
  printf "Part 2: %d\n" (sum numbers)
;;
