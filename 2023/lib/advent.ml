let read_file file_name =
  let input_channel = open_in file_name in
  let rec read_lines lines =
    try
      let line = input_line input_channel in
      read_lines (line :: lines)
    with
    | End_of_file ->
      close_in input_channel;
      List.rev lines
  in
  read_lines []
;;

let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t
;;

let rec match_to_int = function
  | [] -> []
  | h :: t -> int_of_string (Re.Group.get h 1) :: match_to_int t
;;
