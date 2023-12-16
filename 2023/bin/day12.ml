let data = Advent.read_file "input/day12.txt"
let str_to_list str = String.to_seq str |> List.of_seq

let get_n n lst =
  let rec aux n acc lst' =
    match n, lst' with
    | _, [] -> List.rev acc, []
    | k, l when k < 1 -> List.rev acc, l
    | k, h :: t -> aux (k - 1) (h :: acc) t
  in
  aux n [] lst
;;

let repeat_list n lst =
  let rec aux acc n = if n < 1 then acc else aux (acc @ lst) (n - 1) in
  aux lst n
;;

let unfold_spring unfold ch_lst =
  if unfold < 1
  then ch_lst
  else repeat_list (unfold - 1) (ch_lst @ [ '?' ]) @ ch_lst
;;

let parse_data ?(unfold_times = 0) strs =
  let parse_line line =
    match String.split_on_char ' ' line with
    | [ spring; n_damaged ] ->
      ( str_to_list spring |> unfold_spring unfold_times
      , repeat_list
          unfold_times
          (List.map int_of_string (String.split_on_char ',' n_damaged)) )
    | _ -> failwith ("unexpected line " ^ line)
  in
  let rec aux = function
    | [] -> []
    | line :: rest -> parse_line line :: aux rest
  in
  aux strs
;;

let count_arrangements spring n_damaged =
  let memo = Hashtbl.create 128 in
  let rec look_spring spring' n_damaged' =
    match Hashtbl.find_opt memo (spring', n_damaged') with
    | Some d -> d
    | None ->
      let count =
        match n_damaged' with
        | [] -> if List.mem '#' spring' then 0 else 1
        | k :: rest_damaged ->
          (match spring' with
           | [] -> 0
           | '.' :: rest_spring -> look_spring rest_spring n_damaged'
           | '#' :: _ -> count_damaged k spring' rest_damaged
           | '?' :: rest_spring ->
             let damaged_count = count_damaged k spring' rest_damaged in
             let op_count = look_spring rest_spring n_damaged' in
             damaged_count + op_count
           | _ -> assert false)
      in
      Hashtbl.add memo (spring', n_damaged') count;
      count
  and count_damaged k spr dmgs =
    let dmgd_sample, rest_sample = get_n k spr in
    let is_broken =
      List.length dmgd_sample = k && not (List.mem '.' dmgd_sample)
    in
    match rest_sample with
    | [] -> if is_broken then look_spring [] dmgs else 0
    | ch :: rest ->
      if is_broken && not (Char.equal ch '#') then look_spring rest dmgs else 0
  in
  look_spring spring n_damaged
;;

let () =
  List.fold_left
    (fun acc (spring, n_damaged) -> acc + count_arrangements spring n_damaged)
    0
    (parse_data data)
  |> Format.printf "Part1: %d\n"
;;

let () =
  List.fold_left
    (fun acc (spring, n_damaged) -> acc + count_arrangements spring n_damaged)
    0
    (parse_data ~unfold_times:4 data)
  |> Format.printf "Part2: %d\n"
;;
