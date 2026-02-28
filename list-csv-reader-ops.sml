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

structure ListCsvReaderOps :> CSV_READER_OPS where type file = ListCsvType.file =
  struct
    open ListCsvType

    type state =
      {
        fields : field list,  (* reversed *)
        lines  : line list,   (* reversed *)
        row    : int,
        col    : int
      }

    val initialState : state =
      {
        fields = [],
        lines  = [],
        row    = 1,
        col    = 1
      }

    fun addFieldValue s ({fields, lines, row, col} : state) : state =
      {
        fields = s :: fields,
        lines  = lines,
        row    = row,
        col    = col
      }

    fun nextField ({fields, lines, row, col} : state) : state =
      {
        fields = fields,
        lines  = lines,
        row    = row,
        col    = col + 1
      }

    fun nextRecord ({fields, lines, row, col = _} : state) : state =
      {
        fields = [],
        lines  = List.rev fields :: lines,
        row    = row + 1,
        col    = 1
      }

    fun getFile ({fields, lines, ...} : state) =
      List.rev (
        case fields of
          [] => lines
        | _  => List.rev fields :: lines
      )

    fun fmtPos ({row, col, ...} : state) =
      String.concat ["row ", Int.toString row, ", col ", Int.toString col]
  end