let data = Advent.read_file "input/day13.txt"
let str_to_array str = String.to_seq str |> Array.of_seq

(** Store patterns into a list of char matrix*)
let parse_data strs =
  let rec aux acc out = function
    | [] -> Array.of_list (List.rev acc) :: out
    | "" :: t -> aux [] (Array.of_list (List.rev acc) :: out) t
    | line :: rest -> aux (str_to_array line :: acc) out rest
  in
  aux [] [] strs
;;

let transpose matrix =
  let nrow = Array.length matrix in
  let ncol = Array.length matrix.(0) in
  let transposed = Array.make_matrix ncol nrow matrix.(0).(0) in
  for i = 0 to nrow - 1 do
    for j = 0 to ncol - 1 do
      transposed.(j).(i) <- matrix.(i).(j)
    done
  done;
  transposed
;;

let split_matrix idx matrix =
  let nrow = Array.length matrix in
  if idx < 1 || idx >= nrow
  then None
  else (
    let ncol = Array.length matrix.(0) in
    let nrow_split = min idx (nrow - idx) in
    let upper = Array.make_matrix nrow_split ncol matrix.(0).(0) in
    let lower = Array.make_matrix nrow_split ncol matrix.(0).(0) in
    for i = 0 to nrow_split - 1 do
      lower.(i) <- matrix.(idx + i);
      upper.(i) <- matrix.(idx - i - 1)
    done;
    Some (upper, lower))
;;

let count_diffs a b =
  let len = Array.length a in
  let _ = assert (Array.length b = len) in
  let rec aux i acc =
    if i >= len then acc else aux (i + 1) (if a.(i) = b.(i) then acc else acc + 1)
  in
  aux 0 0
;;

let matrix_smudge a b =
  let nrow = Array.length a in
  let _ = assert (Array.length b = nrow) in
  let rec aux i acc =
    if i >= nrow then acc else aux (i + 1) (acc + count_diffs a.(i) b.(i))
  in
  aux 0 0
;;

let get_split ?(smudge = 0) matrix =
  let rec aux i =
    match split_matrix i matrix with
    | None -> 0
    | Some (upper, lower) ->
      if matrix_smudge upper lower = smudge then i else aux (i + 1)
  in
  aux 1
;;

let () =
  let grids = parse_data data in
  let row_score = List.fold_left (fun acc matrix -> acc + get_split matrix) 0 grids in
  let col_score =
    List.fold_left (fun acc matrix -> acc + get_split (transpose matrix)) 0 grids
  in
  Format.printf "Part1: %d\n" ((100 * row_score) + col_score)
;;

let () =
  let grids = parse_data data in
  let row_score =
    List.fold_left (fun acc matrix -> acc + get_split ~smudge:1 matrix) 0 grids
  in
  let col_score =
    List.fold_left
      (fun acc matrix -> acc + get_split ~smudge:1 (transpose matrix))
      0
      grids
  in
  Format.printf "Part2: %d\n" ((100 * row_score) + col_score)
;;
