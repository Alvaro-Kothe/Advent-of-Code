let data = Advent.read_file "input/day09.txt"
let parse_line str = String.split_on_char ' ' str |> List.map int_of_string

let diff lst =
  let rec aux acc = function
    | [] -> List.rev acc
    | x1 :: x2 :: t -> aux ((x2 - x1) :: acc) (x2 :: t)
    | _ :: [] -> aux acc []
  in
  aux [] lst
;;

let diff_till_zeroes lst =
  let rec aux acc lst' =
    if List.for_all (fun x -> x = 0) lst' then acc else aux (lst' :: acc) (diff lst')
  in
  aux [] lst
;;

let rec get_last_element = function
  | [] -> failwith "List is empty"
  | [ x ] -> x
  | _ :: t -> get_last_element t
;;

let extrapolate diff_lists =
  let last_elements = List.map get_last_element diff_lists in
  let rec aux acc = function
    | [] -> acc
    | line_value :: t -> aux (line_value + acc) t
  in
  aux 0 last_elements
;;

let () =
  List.fold_left
    (fun acc line ->
      let history = parse_line line in
      let diff_lists = diff_till_zeroes history in
      acc + extrapolate diff_lists)
    0
    data
  |> Format.printf "Part1: %d\n"
;;

let extrapolate_backward diff_lists =
  let first_elements = List.map List.hd diff_lists in
  let rec aux acc = function
    | [] -> acc
    | line_value :: t -> aux (line_value - acc) t
  in
  aux 0 first_elements
;;

let () =
  List.fold_left
    (fun acc line ->
      let history = parse_line line in
      let diff_lists = diff_till_zeroes history in
      acc + extrapolate_backward diff_lists)
    0
    data
  |> Format.printf "Part2: %d\n"
;;
