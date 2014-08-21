(***********************************************************************)
(*                                                                     *)
(*                   OCaml interface to Sundials                       *)
(*                                                                     *)
(*  Timothy Bourke (Inria), Jun Inoue (Inria), and Marc Pouzet (LIENS) *)
(*                                                                     *)
(*  Copyright 2014 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under a BSD 2-Clause License, refer to the file LICENSE.           *)
(*                                                                     *)
(***********************************************************************)

(** Nvectors for standard arrays and one-dimensional bigarrays.

  @version VERSION()
  @author Timothy Bourke (Inria)
  @author Jun Inoue (Inria)
  @author Marc Pouzet (LIENS)
  @see <OCAML_DOC_ROOT(Array)> Array
  @see <OCAML_DOC_ROOT(Bigarray.Array1)> Bigarray.Array1
 *)

(** An abstract set of functions for working manipulating nvectors
    where the underlying data structure is an array of [float]s.  *)
module type ARRAY_NVECTOR =
  sig
    (** The type of array used within the Nvector. *)
    type t

    (** The set of nvector operations on an array.
        
        These operations can be called directly if necessary, for example:
{[let vmax_norm = Nvector_array.Bigarray.array_nvec_ops.Nvector.Mutable.nvmaxnorm in
let vn = vmax_norm u]}
     
     *)
    val array_nvec_ops  : t Nvector_custom.nvector_ops

    (** [make n x] creates an nvector containing an array
        of [n] elements, each of which is equal to [x]. *)
    val make            : int -> float -> t Nvector_custom.t

    (** Lifts an array to an nvector. *)
    val wrap            : t -> t Nvector_custom.t
  end

(** Nvector on {{:OCAML_DOC_ROOT(Array)} Array}s of [float]s. *)
include ARRAY_NVECTOR with type t = float array
 
(** Nvector on {{:OCAML_DOC_ROOT(Bigarray.Array1)} Bigarray}s
   of [float]s. *)
module Bigarray :
  ARRAY_NVECTOR
  with
    type t = (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t

