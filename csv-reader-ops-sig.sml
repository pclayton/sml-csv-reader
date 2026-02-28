(**
 * SML CSV Reader - a Standard ML library for reading CSV files
 * Copyright 2026  Phil Clayton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see
 * <https://www.gnu.org/licenses/>.
 *)

signature CSV_READER_OPS =
  sig
    type file

    type state
    val initialState : state
    val addFieldValue : string -> state -> state
    val nextField : state -> state
    val nextRecord : state -> state
    val getFile : state -> file
    val fmtPos : state -> string
  end