open Core
module Set = Stdlib.Set

let data = Advent.read_file "input/day03.txt"

type symbol =
  { row : int
  ; col : int
  ; ch : char
  }

module Number = struct
  type t =
    { row : int
    ; col_start : int
    ; col_end : int
    ; value : int
    }

  let compare this other =
    if this.row = other.row
       && this.col_start = other.col_start
       && this.col_end = other.col_end
       && this.value = other.value
    then 0
    else 1
  ;;
end

module NumberSet = Set.Make (Number)

let get_row_symbols str row_number =
  let line_chars = String.to_list str in
  let rec aux idx = function
    | [] -> []
    | h :: t ->
      if Char.is_digit h || Char.equal h '.'
      then aux (idx + 1) t
      else { row = row_number; col = idx; ch = h } :: aux (idx + 1) t
  in
  aux 0 line_chars
;;

let get_row_numbers str row_number =
  let line_chars = String.to_list str in
  let rec aux idx prev_chars = function
    | [] ->
      if String.equal prev_chars ""
      then []
      else
        Number.
          { row = row_number
          ; col_start = idx - String.length prev_chars
          ; col_end = idx - 1
          ; value = int_of_string prev_chars
          }
        :: []
    | h :: t ->
      if (not (Char.is_digit h)) && not (String.equal prev_chars "")
      then
        Number.
          { row = row_number
          ; col_start = idx - String.length prev_chars
          ; col_end = idx - 1
          ; value = int_of_string prev_chars
          }
        :: aux (idx + 1) "" t
      else if Char.is_digit h
      then aux (idx + 1) (prev_chars ^ Char.escaped h) t
      else aux (idx + 1) "" t
  in
  aux 0 "" line_chars
;;

let is_adjacent (symbol : symbol) (number : Number.t) =
  let min_col_dst =
    min (abs (symbol.col - number.col_end)) (abs (symbol.col - number.col_start))
  in
  let row_dst = abs (symbol.row - number.row) in
  min_col_dst <= 1 && row_dst <= 1
;;

let get_adj_non_adj_numbers (symbol : symbol) (numbers : Number.t list) =
  let rec aux adj non_adj = function
    | [] -> adj, non_adj
    | h :: t ->
      if is_adjacent symbol h then aux (h :: adj) non_adj t else aux adj (h :: non_adj) t
  in
  aux [] [] numbers
;;

let get_valid_numbers (symbols : symbol list) (numbers : Number.t list) =
  let number_set = NumberSet.empty in
  let rec aux ns num = function
    | [] -> ns
    | h :: t ->
      let adj, non_adj = get_adj_non_adj_numbers h num in
      let new_set = List.fold adj ~init:ns ~f:(fun acc elem -> NumberSet.add elem acc) in
      aux new_set non_adj t
  in
  aux number_set numbers symbols
;;

let () =
  let numbers = List.concat_mapi data ~f:(fun i str -> get_row_numbers str i) in
  let symbols = List.concat_mapi data ~f:(fun i str -> get_row_symbols str i) in
  let valid_numbers = get_valid_numbers symbols numbers |> NumberSet.to_list in
  List.fold ~init:0 ~f:(fun acc ele -> acc + ele.value) valid_numbers
  |> printf "Part1: %d\n"
;;

let get_ratios (symbols : symbol list) (numbers : Number.t list) =
  let rec aux gr num = function
    | [] -> gr
    | h :: t ->
      let adj, non_adj = get_adj_non_adj_numbers h num in
      if List.length adj = 2
      then (
        let gear_rat = List.fold ~init:1 ~f:(fun acc ele -> acc * ele.value) adj in
        aux (gear_rat :: gr) non_adj t)
      else aux gr num t
  in
  aux [] numbers symbols
;;

let () =
  let numbers = List.concat_mapi data ~f:(fun i str -> get_row_numbers str i) in
  let symbols = List.concat_mapi data ~f:(fun i str -> get_row_symbols str i) in
  let star_symbols = List.filter symbols ~f:(fun sym -> Char.equal sym.ch '*') in
  let ratios = get_ratios star_symbols numbers in
  ratios |> Advent.sum |> printf "Part2: %d\n"
;;
