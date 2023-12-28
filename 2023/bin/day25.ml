let data = Advent.read_file "input/day25.txt"

module StringSet = Set.Make (String)
module StringMap = Map.Make (String)

let add_to_set key value map =
  StringMap.update
    key
    (function
      | None -> Some (StringSet.singleton value)
      | Some set -> Some (StringSet.add value set))
    map
;;

let parse_data strs =
  let parse_line acc line =
    let vert, verts =
      match String.split_on_char ':' line with
      | [ a; b ] -> a, String.sub b 1 (String.length b - 1)
      | _ -> assert false
    in
    let rec aux map = function
      | [] -> map
      | h :: t ->
        let new_map = add_to_set vert h map |> add_to_set h vert in
        aux new_map t
    in
    aux acc (String.split_on_char ' ' verts)
  in
  List.fold_left parse_line StringMap.empty strs
;;

let key_to_set map =
  StringMap.fold (fun key _ acc -> key :: acc) map [] |> StringSet.of_list
;;

let cut map =
  let rec aux cutted_map =
    let count_outside v =
      StringSet.diff (StringMap.find v map) cutted_map |> StringSet.cardinal
    in
    let connections =
      StringSet.fold (fun component acc -> acc + count_outside component) cutted_map 0
    in
    if connections = 3
    then cutted_map
    else if StringSet.cardinal cutted_map = 0
    then failwith "Empty graph"
    else (
      let _, rm_vert =
        StringSet.fold
          (fun key (v, s) ->
            let cn = count_outside key in
            if cn > v then cn, key else v, s)
          cutted_map
          (-1, String.empty)
      in
      aux (StringSet.remove rm_vert cutted_map))
  in
  aux (key_to_set map)
;;

let () =
  let map = parse_data data in
  let ori_size = StringMap.cardinal map in
  let cutted_map = cut map in
  let cut_size = StringSet.cardinal cutted_map in
  Printf.printf "Part1: %d\n" (cut_size * (ori_size - cut_size))
;;
