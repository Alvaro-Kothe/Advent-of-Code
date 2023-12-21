let data = Advent.read_file "input/day20.txt"

module ConjunctionMemory = Map.Make (String)

type module_ =
  | Flipflop of
      { name : string
      ; mutable on : bool
      ; destination : string Seq.t
      }
  | Conjunction of
      { name : string
      ; mutable pulses : bool ConjunctionMemory.t
      ; destination : string Seq.t
      }
  | Broadcaster of { destination : string Seq.t }
  | Orphan

let rec search_module search_name = function
  | [] -> Orphan
  | Flipflop h :: _ when String.equal search_name h.name -> Flipflop h
  | Conjunction h :: _ when String.equal search_name h.name -> Conjunction h
  | Broadcaster h :: _ when String.equal search_name "Broadcaster" -> Broadcaster h
  | _ :: t -> search_module search_name t
;;

let initialize_pulses modules =
  List.iter
    (function
      | Conjunction cnj ->
        List.iter
          (function
            | Orphan -> ()
            | Flipflop { name; destination; _ } ->
              if Seq.exists (String.equal cnj.name) destination
              then cnj.pulses <- ConjunctionMemory.add name false cnj.pulses
              else ()
            | Conjunction { name; destination; _ } ->
              if Seq.exists (String.equal cnj.name) destination
              then cnj.pulses <- ConjunctionMemory.add name false cnj.pulses
              else ()
            | Broadcaster { destination; _ } ->
              if Seq.exists (String.equal cnj.name) destination
              then cnj.pulses <- ConjunctionMemory.add "Broadcaster" false cnj.pulses
              else ())
          modules
      | _ -> ())
    modules
;;

let parse_data strs =
  let parse_line line =
    let regex = Re.(compile (seq [ str " -> " ])) in
    let regex_comma = Re.(compile (seq [ str ", " ])) in
    let origin, destiny =
      match Re.split regex line with
      | [ a; b ] -> a, b
      | _ -> failwith ("Unexpected line " ^ line)
    in
    let name = String.sub origin 1 (String.length origin - 1) in
    let destination = Re.Seq.split regex_comma destiny in
    match origin.[0] with
    | '%' -> Flipflop { name; on = false; destination }
    | '&' -> Conjunction { name; pulses = ConjunctionMemory.empty; destination }
    | _ -> Broadcaster { destination }
  in
  let modules = List.map parse_line strs in
  initialize_pulses modules;
  modules
;;

let int_of_bool = function
  | true -> 1
  | false -> 0
;;

let push_button modules =
  let queue = Queue.create () in
  Queue.push (false, "button", "Broadcaster") queue;
  let rec loop low_count high_count =
    if Queue.is_empty queue
    then (low_count, high_count), modules
    else (
      let node = Queue.pop queue in
      explore_node low_count high_count node)
  and explore_node low_count high_count (high_pulse, prev_mod, mod_name) =
    match search_module mod_name modules with
    | Orphan -> loop low_count high_count
    | Broadcaster m ->
      let to_explore = Seq.map (fun name -> high_pulse, mod_name, name) m.destination in
      let n = Seq.length to_explore in
      let signal_value = int_of_bool high_pulse in
      Queue.add_seq queue to_explore;
      loop (low_count + ((1 - signal_value) * n)) (high_count + (signal_value * n))
    | Flipflop m ->
      if high_pulse
      then loop low_count high_count
      else (
        m.on <- not m.on;
        let to_explore = Seq.map (fun name -> m.on, mod_name, name) m.destination in
        Queue.add_seq queue to_explore;
        let signal_value = int_of_bool m.on in
        let n = Seq.length to_explore in
        loop (low_count + ((1 - signal_value) * n)) (high_count + (signal_value * n)))
    | Conjunction m ->
      m.pulses <- ConjunctionMemory.add prev_mod high_pulse m.pulses;
      let signal = ConjunctionMemory.for_all (fun _ b -> b) m.pulses in
      let to_explore = Seq.map (fun name -> not signal, mod_name, name) m.destination in
      Queue.add_seq queue to_explore;
      let signal_value = int_of_bool (not signal) in
      let n = Seq.length to_explore in
      loop (low_count + ((1 - signal_value) * n)) (high_count + (signal_value * n))
  in
  loop 1 0
;;

let push times modules =
  let rec aux n (l, h) modules =
    if n <= 0
    then l * h
    else (
      let (l', h'), modules' = push_button modules in
      aux (n - 1) (l' + l, h' + h) modules')
  in
  aux times (0, 0) modules
;;

let () =
  let modules = parse_data data in
  let count = push 1000 modules in
  Printf.printf "Part1: %d\n" count
;;

let rec update_map map n targets =
  match targets with
  | [] -> map
  | h :: t ->
    let old_time, occourrences =
      match ConjunctionMemory.find_opt h map with
      | Some (t, c) -> t, c
      | None -> -1, 0
    in
    if occourrences > 1
    then update_map map n t
    else if occourrences = 1
    then (
      let new_map = ConjunctionMemory.add h (n - old_time, occourrences + 1) map in
      update_map new_map n t)
    else (
      let new_map = ConjunctionMemory.add h (n, occourrences + 1) map in
      update_map new_map n t)
;;

let push_button_watch_target modules to_watch =
  let queue = Queue.create () in
  Queue.push (false, "button", "Broadcaster") queue;
  let rec loop acc =
    if Queue.is_empty queue
    then acc, modules
    else (
      let node = Queue.pop queue in
      explore_node acc node)
  and explore_node acc (high_pulse, prev_mod, mod_name) =
    match search_module mod_name modules with
    | Orphan -> loop acc
    | Broadcaster m ->
      let to_explore = Seq.map (fun name -> high_pulse, mod_name, name) m.destination in
      Queue.add_seq queue to_explore;
      loop acc
    | Flipflop m ->
      if high_pulse
      then loop acc
      else (
        m.on <- not m.on;
        let to_explore = Seq.map (fun name -> m.on, mod_name, name) m.destination in
        Queue.add_seq queue to_explore;
        loop acc)
    | Conjunction m ->
      m.pulses <- ConjunctionMemory.add prev_mod high_pulse m.pulses;
      let signal = ConjunctionMemory.for_all (fun _ b -> b) m.pulses in
      let to_explore = Seq.map (fun name -> not signal, mod_name, name) m.destination in
      Queue.add_seq queue to_explore;
      if List.mem m.name to_watch && not high_pulse
      then loop (m.name :: acc)
      else loop acc
  in
  loop []
;;

let push_button_lcm modules to_watch =
  let rec aux n map modules =
    if ConjunctionMemory.cardinal map > 0
       && ConjunctionMemory.for_all (fun _ (_, c) -> c > 1) map
    then ConjunctionMemory.bindings map |> List.map (fun (_, (t, _)) -> t)
    else (
      let low_receiver, modules' = push_button_watch_target modules to_watch in
      let new_map = update_map map n low_receiver in
      aux (n + 1) new_map modules')
  in
  aux 0 ConjunctionMemory.empty modules
;;

let rec gcd x y = if y = 0 then x else gcd y (x mod y)
let lcm m n = m * n / gcd m n

let () =
  let modules = parse_data data in
  let rx_src_srcs =
    List.find_map
      (function
        | Conjunction m ->
          if Seq.exists (String.equal "rx") m.destination
          then
            Some (ConjunctionMemory.bindings m.pulses |> List.map (fun (key, _) -> key))
          else None
        | _ -> None)
      modules
    |> Option.get
  in
  let count =
    push_button_lcm modules rx_src_srcs |> List.fold_left (fun acc x -> lcm acc x) 1
  in
  Printf.printf "Part2: %d\n" count
;;
