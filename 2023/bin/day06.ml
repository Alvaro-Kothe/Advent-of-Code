(* Time:        40     92     97     90
   Distance:   215   1064   1505   1100 *)
(* let times = [ 7.; 15.; 30. ] *)
(* let distances = [ 9.; 40.; 200. ] *)

let times = [ 40.; 92.; 97.; 90. ]
let distances = [ 215.; 1064.; 1505.; 1100. ]

let count_wins time distance =
  let range = sqrt ((time ** 2.) -. (4. *. distance)) /. 2. in
  let center = time /. 2. in
  let minimal_time = floor (center -. range +. 1.) in
  let max_time = ceil (center +. range -. 1.) in
  int_of_float (max_time -. minimal_time +. 1.)
;;

let () =
  let rec aux acc time distance =
    match time, distance with
    | [], [] -> acc
    | tm :: rem_time, dst :: rem_dst -> aux (acc * count_wins tm dst) rem_time rem_dst
    | _ -> assert false
  in
  aux 1 times distances |> Format.printf "Part1: %d\n"
;;

(* let time = 71530. *)
(* let distance = 940200. *)

let time = 40929790.
let distance = 215106415051100.
let () = count_wins time distance |> Format.printf "Part2: %d\n"
