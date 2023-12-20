let data = Advent.read_file "input/day18.txt"

let parse_line ?(hex = false) str =
  match String.split_on_char ' ' str with
  | [ dir; n; _ ] when not hex -> dir, int_of_string n
  | [ _; _; col ] when hex ->
    let string_digits = String.sub col 2 6 in
    let dir = String.sub string_digits 5 1 in
    let n = "0x" ^ String.sub string_digits 0 5 |> int_of_string in
    dir, n
  | _ -> assert false
;;

let parse_data ?(hex = false) strs = List.map (parse_line ~hex) strs

let map_direction = function
  | "U" | "3" -> -1, 0
  | "D" | "1" -> 1, 0
  | "L" | "2" -> 0, -1
  | "R" | "0" -> 0, 1
  | c -> failwith ("No match for char " ^ c)
;;

let get_area data =
  let rec aux per in_area (x, y) = function
    | [] -> in_area + (per / 2) + 1
    | (ds, n) :: t ->
      let dx, dy = map_direction ds in
      let nx, ny = x + (n * dx), y + (n * dy) in
      aux (per + n) (in_area + (ny * dx * n)) (nx, ny) t
  in
  aux 0 0 (0, 0) data
;;

let () =
  let area = parse_data data |> get_area in
  Printf.printf "Part1: %d\n" area
;;

let () =
  let area = parse_data ~hex:true data |> get_area in
  Printf.printf "Part2: %d\n" area
;;
