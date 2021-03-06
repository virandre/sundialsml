(***********************************************************************)
(*                                                                     *)
(*                   OCaml interface to Sundials                       *)
(*                                                                     *)
(*             Timothy Bourke, Jun Inoue, and Marc Pouzet              *)
(*             (Inria/ENS)     (Inria/ENS)    (UPMC/ENS/Inria)         *)
(*                                                                     *)
(*  Copyright 2014 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under a New BSD License, refer to the file LICENSE.                *)
(*                                                                     *)
(***********************************************************************)

(** Generic definitions, arrays, and utility functions.

 @version VERSION()
 @author Timothy Bourke (Inria/ENS)
 @author Jun Inoue (Inria/ENS)
 @author Marc Pouzet (UPMC/ENS/Inria)
 *)

(** {2:consts Constants} *)

(** The [major], [minor], [patch], and [binding] version numbers of
    Sundials/ML.
    The first three elements correspond to the underlying Sundials/C library.
    The [binding] number distinguishes updates to the binding (restarting
    from 0 for each increment of the other elements). *)
val version : int * int * int * int

(** Indicates whether the interface was compiled with BLAS/LAPACK support. *)
val lapack_enabled : bool

(** The largest value representable as a real.

    @cvode <node5#s:types> Data Types *)
val big_real : float

(** The smallest value representable as a real.

    @cvode <node5#s:types> Data Types *)
val small_real : float

(** The difference bewteen 1.0 and the minimum real greater than 1.0.

    @cvode <node5#s:types> Data Types *)
val unit_roundoff : float

(** {2:exceptions Exceptions} *)

(** Indicates a recoverable failure within a callback function.
    Any other exception normally indicates an unrecoverable failure. *)
exception RecoverableFailure

(** Raised by error-weight functions on non-positive error weights. See
    {{!Cvode.tolerance}[Cvode.WFtolerances]} or
    {{!Ida.tolerance}[Ida.WFtolerances]}. *)
exception NonPositiveEwt

(** Raised on invalid use of linear solver functions. For instance,
    initializing a session with {!Cvode.Diag} and then calling
    {!Cvode.Spils.get_num_lin_iters}, which rather requires a
    linear solver from {!Cvode.Spils}. *)
exception InvalidLinearSolver

(** {2:arrays Arrays} *)

(** Vectors of floats (one-dimensional bigarrays). *)
module RealArray :
  sig
    (** A {{:OCAML_DOC_ROOT(Bigarray.Array1.html)} Bigarray} of floats. *)
    type t = (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

    (** [make n x] returns an array with [n] elements each set to [x]. *)
    val make : int -> float -> t

    (** [create n] returns an uninitialized array with [n] elements. *)
    val create : int -> t

    (** [init n f] returns an array with [n] elements, with element [i]
        set to [f i]. *)
    val init : int -> (int -> float) -> t

    (** Creates an array by copying the contents of a
        {{:OCAML_DOC_ROOT(Array.html)} [float array]}. *)
    val of_array : float array -> t

    (** Creates an array by copying the contents of a
        {{:OCAML_DOC_ROOT(List.html)} [float list]}. *)
    val of_list : float list -> t

    (** Copies into a new {{:OCAML_DOC_ROOT(Array.html)} [float array]}. *)
    val to_array : t -> float array

    (** Copies into an existing
        {{:OCAML_DOC_ROOT(Array.html)} [float array]}. *)
    val into_array : t -> float array -> unit

    (** Copies into a {{:OCAML_DOC_ROOT(List.html)} [float list]}. *)
    val to_list : t -> float list

    (** Creates a new array with the same contents as an existing one. *)
    val copy : t -> t

    (** Access a sub-array of the given array without copying. *)
    val sub : t -> int -> int -> t

    (** [blit_some src isrc dst idst len] copies [len] elements of [src] at
        offset [isrc] to [dst] at offset [idst].

        @raise Invalid_argument "RealArray.blit_some" if [isrc], [idst], and
        [len] do not specify valid subarrays of [src] and [dst]. *)
    val blit_some : t -> int -> t -> int -> int -> unit

    (** Copy the first array into the second one.
        See {{:OCAML_DOC_ROOT(Bigarray.Genarray.html#VALblit)}
        [Bigarray.Genarray.blit]} for more details. *)
    val blit : t -> t -> unit

    (** [fill a c] sets all elements of [a] to the constant [c]. *)
    val fill : t -> float -> unit

    (** Returns the length of an array. *)
    val length : t -> int

    (** [fold_left f b a] returns [f (f (f b a.{0}) a.{1}) ...)]. *)
    val fold_left : ('a -> float -> 'a) -> 'a -> t -> 'a

    (** [fold_right f b a] returns [(f ... (f a.{n-2} (f a.{n-1} b)))]. *)
    val fold_right : (float -> 'a -> 'a) -> t -> 'a -> 'a

    (** [iter f a] successively applies [f] to the elements of [a]. *)
    val iter : (float -> unit) -> t -> unit

    (** [iteri f a] successively applies [f] to the indexes and values
        of [a]. *)
    val iteri : (int -> float -> unit) -> t -> unit

    (** [map f a] replaces each element [a.{i}] with [f a.{i}]. *)
    val map : (float -> float) -> t -> unit

    (** [map f a] replaces each element [a.{i}] with [f i a.{i}]. *)
    val mapi : (int -> float -> float) -> t -> unit
  end

(** Matrices of floats (wrappers around two-dimensional bigarrays). *)
module RealArray2 :
  sig
    (** A two-dimensional matrix. The underlying data can be accessed as
        a {{:OCAML_DOC_ROOT(Bigarray.Array2.html)}Bigarray} via {!unwrap},
        but note that the first index specifies the column. *)
    type t

    (** An alias for the underlying
        {{:OCAML_DOC_ROOT(Bigarray.Array2.html)}Bigarray}. *)
    type data = (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array2.t

    (** [make nr nc v] returns an array with [nr] rows and [nc] columns, and
        with elements set to [v]. *)
    val make : int -> int -> float -> t

    (** [create nr nc] returns an uninitialized array with [nr] rows and [nc]
        columns. *)
    val create : int -> int -> t

    (** [get a i j] returns the value at row [i] and column [j] of [a]. *)
    val get : t -> int -> int -> float

    (** [col a j] returns the [j]th column of [a]. The slice shares storage
        with [a]. *)
    val col : t -> int -> RealArray.t

    (** [set a i j v] sets the value at row [i] and column [j] of [a] to [v]. *)
    val set : t -> int -> int -> float -> unit

    (** [nr, nc = size a] returns the numbers of rows [nr] and columns [nc]
        of [a] *)
    val size : t -> int * int

    (** Creates a new array with the same contents as an existing one. *)
    val copy : t -> t

    (** Copy the first array into the second one.
        See {{:OCAML_DOC_ROOT(Bigarray.Genarray.html#VALblit)}
        [Bigarray.Genarray.blit]} for more details. *)
    val blit : t -> t -> unit

    (** [make m n] returns an uninitialized [m] by [n] array. *)
    val make_data : int -> int -> data

    (** Creates a new matrix from an existing {!data} array. Changes to one
        affect the other since they share the same underlying storage. *)
    val wrap : data -> t

    (** Returns the {!data} array behind a matrix. Changes to one affect the
        other since they share the same underlying storage. Note that the
        array is accessed column-first, that is,
        [get a i j = (unwrap a).{j, i}]. *)
    val unwrap : t -> data
  end

(** Vectors of integers (one-dimensional bigarrays). *)
module LintArray :
  sig
    (** A {{:OCAML_DOC_ROOT(Bigarray.Array1.html)} Bigarray} of integers. *)
    type t = (int, Bigarray.int_elt, Bigarray.c_layout) Bigarray.Array1.t

    (** [make n x] returns an array with [n] elements each set to [v]. *)
    val make  : int -> int -> t

    (** [create n] returns an uninitialized array with [n] elements. *)
    val create  : int -> t
  end

(** {2:roots Arrays of roots (zero-crossings)} *)

(** Vectors of root (zero-crossing) statuses. *)
module Roots :
  sig
    (** Arrays that communicate the occurrence of zero-crossings. The
        underlying representation is hidden to isolate compatability
        issues related to integers. *)
    type t

    (** Values indicating the status of root functions.
        @cvode <node5#sss:optout_root> CVodeGetRootInfo
        @ida <node5#sss:optout_root> IdaGetRootInfo *)
    type r =
      | NoRoot      (** No root was found on the corresponding function (0). *)
      | Rising      (** The corresponding root function is increasing (1). *)
      | Falling     (** The corresponding root function is decreasing (-1). *)

    (** [create n] returns an array with [n] elements each set to [NoRoot]. *)
    val create : int -> t

    (** [make n x] returns an array with [n] elements each set to [x]. *)
    val make : int -> r -> t

    (** Returns the length of an array. *)
    val length : t -> int

    (** Returns [true] only if the specified element is either [Rising] or
        [Falling]. *)
    val detected : t -> int -> bool

    (** Returns [true] only if the specified element is [Rising]. *)
    val rising : t -> int -> bool

    (** Returns [true] only if the specified element is [Falling]. *)
    val falling : t -> int -> bool

    (** [get r i] returns the [i]th element of [r]. *)
    val get : t -> int -> r

    (** [set r i v] sets the [i]th element of [r] to [v]. *)
    val set : t -> int -> r -> unit

    (** [set_noroot r i] sets the [i]th element of [r] to [NoRoot]. *)
    val set_noroot : t -> int -> unit

    (** [set_rising r i] sets the [i]th element of [r] to [Rising]. *)
    val set_rising : t -> int -> unit

    (** [set_falling r i] sets the [i]th element of [r] to [Falling]. *)
    val set_falling : t -> int -> unit

    (** [fill a x] sets all elements in [a] to [x]. *)
    val fill : t -> r -> unit

    (** Creates a new array with the same contents as an existing one. *)
    val copy : t -> t

    (** Returns [0] for [NoRoot], [1] for [Rising], and [-1] for [Falling]. *)
    val int_of_root : r -> int

    (** Resets all elements to [NoRoot]. *)
    val reset : t -> unit

    (** [true] if any elements are equal to [Rising] or [Falling]. *)
    val exists : t -> bool

    (** [iter f r] successively applies [f] to each element in [r]. *)
    val iter : (r -> unit) -> t -> unit

    (** [iteri f r] successively applies [f] to the indexes and
        elements of [r]. *)
    val iteri : (int -> r -> unit) -> t -> unit

    (** Creates an array by copying the contents of a [r list]. *)
    val of_list : r list -> t

    (** Copies into a list. *)
    val to_list : t -> r list

    (** Creates a new value from the contents of an
        {{:OCAML_DOC_ROOT(Array.html)} array}. *)
    val of_array : r array -> t

    (** Creates a new array from the contents of a given value. *)
    val to_array : t -> r array
  end

(** Vectors of root (zero-crossing) directions. *)
module RootDirs :
  sig
    type t
    (** Arrays that communicate which zero-crossings are sought. The
        underlying representation is hidden to isolate compatability
        issues related to integers. *)

    (** Values indicating which types of roots are sought.

        @cvode <node5#sss:optin_root> CVodeSetRootDirection
        @ida <node5#sss:optin_root> IdaSetRootDirection *)
    type d =
      | Increasing              (** Only look for rising zero-crossings. *)
      | Decreasing              (** Only look for falling zero-crossings. *)
      | IncreasingOrDecreasing  (** Look for any zero-crossing. *)

    (** [make n x] returns an array with [n] elements each set to [x]. *)
    val make : int -> d -> t

    (** [create n] returns an array with [n] elements each set to
        [IncreasingOrDecreasing]. *)
    val create : int -> t

    (** [init n f] returns an array with [n] elements, with element [i] set
        to [f i]. *)
    val init : int -> (int -> d) -> t

    (** [copy n a] returns an array with [n] elements, initialized from
        the contents of a. If [n > Array.length a] then the extra space is
        initialized to [IncreasingOrDecreasing]. *)
    val copy : int -> d array -> t

    (** Returns the length of an array *)
    val length : t -> int

    (** [get r i] returns the [i]th element of [r]. *)
    val get : t -> int -> d

    (** [set r i v] sets the [i]th element of [r] to [v]. *)
    val set : t -> int -> d -> unit

    (** [fill_all a x] sets the values of [a] to [x] everywhere. *)
    val fill : t -> d -> unit

    (** [blit_some src isrc dst idst len] copies [len] elements of [src] at
        offset [isrc] to [dst] at offset [idst].

        @raise Invalid_argument "RootDirs.blit_some" if [isrc], [idst], and
        [len] do not specify valid subarrays of [src] and [dst]. *)
    val blit_some : t -> int -> t -> int -> int -> unit

    (** Copy the first array into the second one.
        See {{:OCAML_DOC_ROOT(Bigarray.Genarray.html#VALblit)}
        [Bigarray.Genarray.blit]} for more details. *)
    val blit : t -> t -> unit

    (** Creates an array by copying the contents of a [d list]. *)
    val of_list : d list -> t

    (** Copies into a list. *)
    val to_list : t -> d list

    (** Creates a new value from the contents of an
        {{:OCAML_DOC_ROOT(Array.html)} array}. *)
    val of_array : d array -> t

    (** Creates a new array from the contents of a given value. *)
    val to_array : t -> d array
  end

(** {2:constraints Constraints} *)

(** Symbolic names for variable constraints. These names describe
    the constants passed to {!Ida.set_constraints} and
    {!Kinsol.set_constraints}.

    @ida <node5#sss:optin_main> IDASetConstraints
    @kinsol <node5#ss:optin_main> KINSetConstraints *)
module Constraint :
  sig
    (** The constant [0.0]. *)
    val unconstrained : float

    (** The constant [1.0]. *)
    val geq_zero : float

    (** The constant [-1.0]. *)
    val leq_zero : float

    (** The constant [2.0]. *)
    val gt_zero : float

    (** The constant [-2.0]. *)
    val lt_zero : float

    (** For pattern-matching on constraints. See {!of_float}. *)
    type t =
    | Unconstrained   (** [true] *)
    | GeqZero         (** [>= 0] *)
    | LeqZero         (** [<= 0] *)
    | GtZero          (** [> 0]  *)
    | LtZero          (** [< 0]  *)

    (** Map constraint values to floating-point constants. *)
    val to_float : t -> float

    (** Map floating-point constants to constraint values.
        
        @raise Invalid_argument The given value is not a legal constraint. *)
    val of_float : float -> t
  end

(** {2:results Solver results and error reporting} *)

(** Information passed to registered error handler functions.
    See {!Cvode.set_err_handler_fn}, {!Ida.set_err_handler_fn}, and
    {!Kinsol.set_err_handler_fn}.

 @cvode <node5#ss:ehFn> CVodeErrHandlerFn
 @ida <node5#ss:ehFn> IDAErrHandlerFn
 @kinsol <node5#ss:ehFn> KINErrHandlerFn *)
type error_details = {
    error_code : int;
    module_name : string;        (** IDA, CVODE, CVSPGMR, etc. *)
    function_name : string;
    error_message : string;
  }

(** {2:misc Miscellaneous utility functions} *)

(** [format_float fmt f] formats [f] according to the format string [fmt].
    It uses the low-level [caml_format_float] function. *)
val format_float : string -> float -> string

(** Returns the bit-level representation of a float in hexadecimal as a string.
    Equivalent to [format_float "%a"]. *)
val floata : float -> string

