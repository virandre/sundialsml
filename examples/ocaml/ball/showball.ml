
let scale = 90.0
let ball_radius = 4

let x_off = 50
let y_off = 0

let xc x = truncate (x *. scale) + x_off
let yc y = truncate (y *. scale) + y_off

let floors = ref ([| 0.0 |], [| 0.0 |])
let refresh_delay = ref (1.0 /. 60.)

let show_floors () =
  let (heights, extents) = !floors in
  let maxidx = min (Array.length heights) (Array.length extents) in
  let rec f idx =
    if (idx < maxidx) then
      (Graphics.lineto (Graphics.current_x ()) (yc heights.(idx));
       Graphics.lineto (xc extents.(idx)) (yc heights.(idx));
       f (idx + 1))
  in
  Graphics.set_color Graphics.blue;
  Graphics.moveto (xc 0.0) (yc heights.(0));
  f 0;
  Graphics.lineto (Graphics.current_x ()) (yc 0.0)

let leave_trace = ref false

let start trace dt floor_details =
  Graphics.open_graph "";
  Graphics.resize_window 800 600;
  Graphics.auto_synchronize false;
  Graphics.clear_graph ();
  floors := floor_details;
  show_floors ();
  Graphics.synchronize ();
  leave_trace := trace;
  refresh_delay := dt

let rec minisleep (sec : float) =
    try
      ignore (Unix.select [] [] [] sec)
    with Unix.Unix_error (Unix.EINTR, _, _) -> minisleep sec

let last_x = ref 0.0
let last_y = ref 0.0

let show (x, y) =
  if (not !leave_trace) then begin
    Graphics.set_color Graphics.background;
    Graphics.fill_circle (xc !last_x) (yc !last_y) ball_radius;
    show_floors ()
  end;
  Graphics.set_color Graphics.red;
  Graphics.fill_circle (xc x) (yc y) ball_radius;
  Graphics.synchronize ();
  minisleep !refresh_delay;
  last_x := x;
  last_y := y

let stop () =
  Graphics.close_graph ()

