let data = Advent.read_file "input/day06.txt"

type hand =
  { hand : int list
  ; bid : int
  }

let card_value ?(joker = false) = function
  | 'T' -> 10
  | 'J' -> if joker then 1 else 11
  | 'Q' -> 12
  | 'K' -> 13
  | 'A' -> 14
  | ch -> int_of_string (Char.escaped ch)
;;

let get_hand ?(joker = false) str =
  let rec aux = function
    | [] -> []
    | h :: t -> card_value ~joker h :: aux t
  in
  aux (List.of_seq (String.to_seq str))
;;

let parse_line ?(joker = false) str =
  let line = String.split_on_char ' ' str in
  match line with
  | [ hand; bid ] -> { hand = get_hand ~joker hand; bid = int_of_string bid }
  | _ -> assert false
;;

let rec parse_data ?(joker = false) = function
  | [] -> []
  | h :: t -> parse_line ~joker h :: parse_data ~joker t
;;

let rec histogram lst =
  let rec count_element element = function
    | [] -> 0
    | h :: t ->
      if h = element then 1 + count_element element t else count_element element t
  in
  match lst with
  | [] -> []
  | h :: t -> (h, count_element h t + 1) :: histogram (List.filter (fun x -> x <> h) t)
;;

let increase_hist_count hand_hist =
  let rec aux acc inc lst =
    match lst with
    | [] -> List.rev acc
    | (1, 5) :: [] -> [ 1, 5 ]
    | (1, count) :: t ->
      (match acc with
       | [] -> aux [] count t
       | ac -> aux [] count (List.rev ac @ t))
    | (crd, count) :: t -> aux ((crd, count + inc) :: acc) 0 t
  in
  aux [] 0 (List.sort (fun (_, a) (_, b) -> compare b a) hand_hist)
;;

let rec intint_list_to_str = function
  | [] -> ""
  | (v1, v2) :: t ->
    "(" ^ string_of_int v1 ^ ", " ^ string_of_int v2 ^ ")" ^ intint_list_to_str t
;;

let hand_type hand_hist =
  match increase_hist_count hand_hist with
  | [ (_, 5) ] -> 7
  | [ (_, 4); (_, 1) ] -> 6
  | [ (_, 3); (_, 2) ] -> 5
  | [ (_, 3); (_, 1); (_, 1) ] -> 4
  | [ (_, 2); (_, 2); (_, 1) ] -> 3
  | [ (_, 2); (_, 1); (_, 1); (_, 1) ] -> 2
  | [ (_, 1); (_, 1); (_, 1); (_, 1); (_, 1) ] -> 1
  | p -> failwith ("Pattern not found for " ^ intint_list_to_str p)
;;

let compare_hand_ h1 h2 =
  let rec aux h1 h2 =
    match h1, h2 with
    | [], [] -> 0
    | hd1 :: tl1, hd2 :: tl2 ->
      (match compare hd1 hd2 with
       | 0 -> aux tl1 tl2
       | d -> d)
    | _ -> assert false
  in
  aux h1 h2
;;

let compare_hand hd1 hd2 =
  let hand_hist1 = histogram hd1 in
  let hand_hist2 = histogram hd2 in
  match (hand_type hand_hist1, hd1), (hand_type hand_hist2, hd2) with
  | (x, h1), (y, h2) -> if x = y then compare_hand_ h1 h2 else compare x y
;;

let () =
  let hands = parse_data data in
  let sorted_list = List.sort (fun h1 h2 -> compare_hand h1.hand h2.hand) hands in
  let rec aux rank = function
    | [] -> 0
    | h :: t -> (rank * h.bid) + aux (rank + 1) t
  in
  Format.printf "Part1: %d\n" (aux 1 sorted_list)
;;

let () =
  let hands = parse_data ~joker:true data in
  let sorted_list = List.sort (fun h1 h2 -> compare_hand h1.hand h2.hand) hands in
  let rec aux rank = function
    | [] -> 0
    | h :: t -> (rank * h.bid) + aux (rank + 1) t
  in
  Format.printf "Part2: %d\n" (aux 1 sorted_list)
;;
