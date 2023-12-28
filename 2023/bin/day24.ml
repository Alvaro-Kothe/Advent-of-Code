let data = Advent.read_file "input/day24.txt"

let parse_data strs =
  let parse_line str =
    Scanf.sscanf str "%f, %f, %f @ %f, %f, %f" (fun a b c d e f -> (a, b, c), (d, e, f))
  in
  List.map parse_line strs
;;

let intersect_pos ((px1, py1, _), (vx1, vy1, _)) ((px2, py2, _), (vx2, vy2, _)) =
  let compute_slope vx vy = vy /. vx in
  let compute_pos px py slope = py -. (slope *. px) in
  let slope1 = compute_slope vx1 vy1
  and slope2 = compute_slope vx2 vy2 in
  if Float.equal slope1 slope2
  then None
  else (
    let p1 = compute_pos px1 py1 slope1
    and p2 = compute_pos px2 py2 slope2 in
    let x = (p1 -. p2) /. (slope2 -. slope1) in
    let y = p1 +. (slope1 *. x) in
    if (x -. px1) *. vx1 < 0.
    then None
    else if (x -. px2) *. vx2 < 0.
    then None
    else Some (x, y))
;;

let chech_inter (xmin, xmax) (ymin, ymax) lst =
  let rec aux = function
    | [] -> 0
    | h :: t -> compare_one_rest h t + aux t
  and compare_one_rest cur = function
    | [] -> 0
    | h :: t ->
      (match intersect_pos cur h with
       | None -> compare_one_rest cur t
       | Some (x, y) ->
         if xmin <= x && x <= xmax && ymin <= y && y <= ymax
         then 1 + compare_one_rest cur t
         else compare_one_rest cur t)
  in
  aux lst
;;

let () =
  let min_ = 200000000000000. in
  let max_ = 400000000000000. in
  let range = min_, max_ in
  let pv = parse_data data in
  chech_inter range range pv |> Printf.printf "Part1: %d\n"
;;
