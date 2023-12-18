let data = Advent.read_file "input/day15.txt"
let parse_data data = String.split_on_char ',' (List.hd data)

let compute_hash str =
  Seq.fold_left
    (fun acc ch ->
      let ascii = int_of_char ch in
      (acc + ascii) * 17 mod 256)
    0
    (String.to_seq str)
;;

let () =
  List.fold_left (fun acc str -> acc + compute_hash str) 0 (parse_data data)
  |> Format.printf "Part1: %d\n"
;;

type len =
  { label : string
  ; value : int
  }

let get_operation str =
  match String.exists (Char.equal '=') str with
  | true ->
    (match String.split_on_char '=' str with
     | [ label; value ] -> { label; value = int_of_string value }
     | _ -> assert false)
  | false ->
    (match String.split_on_char '-' str with
     | [ label; _ ] -> { label; value = -1 }
     | _ -> assert false)
;;

let equal_op operation box_lenses =
  let rec aux acc replaced = function
    | [] -> if replaced then List.rev acc else List.rev (operation :: acc)
    | h :: t ->
      if h.label = operation.label
      then aux (operation :: acc) true t
      else aux (h :: acc) replaced t
  in
  aux [] false box_lenses
;;

let fill_boxes strs =
  let boxes = Array.make 256 [] in
  let rec aux = function
    | [] -> ()
    | str :: t ->
      let operation = get_operation str in
      let box = compute_hash operation.label in
      if operation.value = -1
      then (
        boxes.(box)
        <- List.filter (fun x -> x.label <> operation.label) boxes.(box);
        aux t)
      else (
        boxes.(box) <- equal_op operation boxes.(box);
        aux t)
  in
  aux strs;
  boxes
;;

let compute_power boxes =
  let power_within_box box_idx =
    let rec aux i = function
      | [] -> 0
      | h :: t -> ((box_idx + 1) * i * h.value) + aux (i + 1) t
    in
    aux 1 boxes.(box_idx)
  in
  let rec aux acc idx =
    if idx < 0 then acc else aux (acc + power_within_box idx) (idx - 1)
  in
  aux 0 (Array.length boxes - 1)
;;

let () =
  parse_data data |> fill_boxes |> compute_power |> Format.printf "Part2: %d\n"
;;
