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

(*
   Solve A x = b
   where A = [
[dvy, -dvx, 0, -dy, dx, 0]
[dvz, 0, -dvx, -dz, 0, dx]
]
   b = [
d(xvy) - d(yvx)
d(xvz) - d(zvx)
]
   x = (x, y, z, vx, vy, vz) from the rock
   x0, y0, ... represents the hailstone values from a preceding
   x1, y1, ... represents the values of the next
   find x solving:
   A x = b
*)
let computeAb ((x1, y1, z1), (vx1, vy1, vz1)) ((x2, y2, z2), (vx2, vy2, vz2)) =
  let dx = x2 -. x1 in
  let dy = y2 -. y1 in
  let dz = z2 -. z1 in
  let dvx = vx2 -. vx1 in
  let dvy = vy2 -. vy1 in
  let dvz = vz2 -. vz1 in
  let d_x_vy = (x2 *. vy2) -. (x1 *. vy1) in
  let d_y_vx = (y2 *. vx2) -. (y1 *. vx1) in
  let d_x_vz = (x2 *. vz2) -. (x1 *. vz1) in
  let d_z_vx = (z2 *. vx2) -. (z1 *. vx1) in
  let matrix_A =
    [ [| dvy; -.dvx; 0.; -.dy; dx; 0. |]; [| dvz; 0.; -.dvx; -.dz; 0.; dx |] ]
  in
  let b = [ d_x_vy -. d_y_vx; d_x_vz -. d_z_vx ] in
  matrix_A, b
;;

let generate_Ab nelements lst =
  let rec getAb_list n accA accb = function
    | _ when n = 0 -> accA, accb
    | x :: (y :: _ as t) ->
      let a, b = computeAb x y in
      getAb_list (n - 1) (a @ accA) (b @ accb) t
    | _ -> assert false
  in
  let acca, accb = getAb_list nelements [] [] lst in
  Array.of_list acca, Array.of_list accb
;;

module Array = struct
  include Array

  (* Computes: f a.(0) + f a.(1) + ... where + is 'g'. *)
  let foldmap g f a =
    let n = Array.length a in
    let rec aux acc i = if i >= n then acc else aux (g acc (f a.(i))) (succ i) in
    aux (f a.(0)) 1
  ;;
end

let foldmap_range g f (a, b) =
  let rec aux acc n =
    let n = succ n in
    if n > b then acc else aux (g acc (f n)) n
  in
  aux (f a) a
;;

let fold_range f init (a, b) =
  let rec aux acc n = if n > b then acc else aux (f acc n) (succ n) in
  aux init a
;;

let swap_elem m i j =
  let x = m.(i) in
  m.(i) <- m.(j);
  m.(j) <- x
;;

let maxtup a b = if snd a > snd b then a else b
let augmented_matrix m b = Array.(init (length m) (fun i -> append m.(i) [| b.(i) |]))

(* https://rosettacode.org/wiki/Gaussian_elimination#OCaml *)
(* Solve Ax=b for x, using gaussian elimination with scaled partial pivot,
 * and then back-substitution of the resulting row-echelon matrix. *)
let solve m b =
  let n = Array.length m in
  let n' = pred n in
  (* last index = n-1 *)
  let s = Array.(map (foldmap max abs_float) m) in
  (* scaling vector *)
  let a = augmented_matrix m b in
  for k = 0 to pred n' do
    (* Scaled partial pivot, to preserve precision *)
    let pair i = i, abs_float a.(i).(k) /. s.(i) in
    let i_max, v = foldmap_range maxtup pair (k, n') in
    if v < epsilon_float then failwith "Matrix is singular.";
    swap_elem a k i_max;
    swap_elem s k i_max;
    (* Eliminate one column *)
    for i = succ k to n' do
      let tmp = a.(i).(k) /. a.(k).(k) in
      for j = succ k to n do
        a.(i).(j) <- a.(i).(j) -. (tmp *. a.(k).(j))
      done
    done
  done;
  (* Backward substitution; 'b' is in the 'nth' column of 'a' *)
  let x = Array.copy b in
  (* just a fresh array of the right size and type *)
  for i = n' downto 0 do
    let minus_dprod t j = t -. (x.(j) *. a.(i).(j)) in
    x.(i) <- fold_range minus_dprod a.(i).(n) (i + 1, n') /. a.(i).(i)
  done;
  x
;;

let () =
  let hailstones = parse_data data in
  let a, b = generate_Ab 3 hailstones in
  let x = solve a b in
  (* let _ = *)
  (*   Array.iter (fun x -> Printf.printf "%f " x) x; *)
  (*   print_newline *)
  (* in *)
  let p2 = x.(0) +. x.(1) +. x.(2) in
  Printf.printf "Part2: %f\n" p2
;;
