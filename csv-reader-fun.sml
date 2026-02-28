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

functor CsvReader(Ops : CSV_READER_OPS) :>
  CSV_READER
    where type file = Ops.file =
  struct
    open Ops

    (* The CSV format is based on RFC 4180 with the following changes:
     *  1. TEXTDATA is any octet that is not LF, CR, DQUOTE nor COMMA.
     *  2. LF (unescaped) without a preceding CR starts the next record.
     * These changes allow a superset of the CSV files allowed by RFC 4180.
     *
     * To validate according to RFC 4180, define
     *
     *   fun isTextData c =
     *     "\032" <= c andalso c <= "\126" andalso c <> #"\"" andalso c <> #","
     *
     *   fun isEscapedTextData c =
     *     ("\032" <= c andalso c <= "\126" andalso c <> #"\"")
     *      orelse c = #"\r" orelse c = #"\n"
     *
     * and remove the cases marked "not RFC 4180" below, that allow LF without
     * a preceding CR.
     *)
    fun isTextData c = c <> #"\"" andalso c <> #"," andalso c <> #"\r" andalso c <> #"\n"
    fun isEscapedTextData c = c <> #"\""


    (* This failure is unreachable because `isEscapedTextData` allows any character other than #"\"". *)
    fun failUnexpectedCharInEscapedField (c, state) =
      raise Fail ("unexpected character \"" ^ Char.toString c ^ "\" in escaped field at " ^ fmtPos state)
    
    fun failEndOfInputInEscapedField state =
      raise Fail ("end of input in escaped field at " ^ fmtPos state)

    fun failExpectedNLAfterCR state =
      raise Fail ("expected \\n to follow \\r after " ^ fmtPos state)

    fun failUnexpectedCharInField (c, state) =
      raise Fail ("unexpected character \"" ^ Char.toString c ^ "\" in field at " ^ fmtPos state)


    fun readUnescapedField read src = StringCvt.splitl isTextData read src

    fun readEscapedField read state src =
      let
        fun readText ss src =
          let
            val (s, src'1) = StringCvt.splitl isEscapedTextData read src
          in
            case read src'1 of
              SOME (#"\"", src'2) => (
                case read src'2 of
                  SOME (#"\"", src'3) => readText ("\"" :: s :: ss) src'3
                | _                   => (String.concat (List.rev (s :: ss)), src'2)
              )
            | SOME (c, _)         => failUnexpectedCharInEscapedField (c, state)  (* unreachable *)
            | NONE                => failEndOfInputInEscapedField state
          end
      in
        readText [] src
      end

    fun readField read state src =
      case read src of
        SOME (#"\"", src'1) => readFieldDone read state (readEscapedField read state src'1)
      | SOME _              => readFieldDone read state (readUnescapedField read src)
      | NONE                => getFile (addFieldValue "" state)

    and readFieldDone read state (s, src) = readNextField read (addFieldValue s state) src

    and readNextField read state src =
      case read src of
        SOME (#",",  src'1) => readField read (nextField state) src'1
      | SOME (#"\n", src'1) => readRecord read (nextRecord state) src'1  (* not RFC 4180 *)
      | SOME (#"\r", src'1) => (
          case read src'1 of
            SOME (#"\n", src'2) => readRecord read (nextRecord state) src'2
          | _                   => failExpectedNLAfterCR state
        )
      | SOME (c,     _)     => failUnexpectedCharInField (c, state)
      | NONE                => getFile state

    and readRecord read state src =
      case read src of
        SOME (#"\n", src'1) => readRecord read (nextRecord state) src'1  (* not RFC 4180 *)
      | SOME (#"\r", src'1) => (
          case read src'1 of
            SOME (#"\n", src'2) => readRecord read (nextRecord state) src'2
          | _                   => failExpectedNLAfterCR state state
        )
      | SOME _              => readField read state src
      | NONE                => getFile state

    fun readFile read src = readRecord read initialState src
  end