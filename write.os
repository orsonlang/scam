!
!  SCAM/WRITE. Write an object to a text file.
!
!  Copyright © 2018 James B. Moen.
!
!  This  program is free  software: you  can redistribute  it and/or  modify it
!  under the terms  of the GNU General Public License as  published by the Free
!  Software Foundation,  either version 3 of  the License, or  (at your option)
!  any later version.
!
!  This program is distributed in the  hope that it will be useful, but WITHOUT
!  ANY  WARRANTY;  without even  the  implied  warranty  of MERCHANTABILITY  or
!  FITNESS FOR  A PARTICULAR PURPOSE.  See  the GNU General  Public License for
!  more details.
!
!  You should have received a copy of the GNU General Public License along with
!  this program.  If not, see <http://www.gnu.org/licenses/>.
!

(prog

!  WRITE OBJECT. Write a symbolic representation of OBJECT to OUTPUT, which can
!  be read back in again (see SCAM/READ) in most cases. We detect circularities
!  and refuse to be trapped in them.

  writeObject :−
   (proc (ref object first) void:
    (with

!  UNMARK OBJECT. Starting from FIRST, visit each CONS whose TAG slot is MARKED
!  TAG, and set it back to CONS TAG.

      unmarkObject :−
       (proc (ref object first) void:
        (with var ref object next :− first
         do (while next↑.tag = markedTag
             do next↑.tag := consTag
                unmarkObject(next↑.car)
                next := next↑.cdr)))

!  This is WRITE OBJECT's body. Write FIRST and then unmark its CONSes.

     do writingObject(first)
        unmarkObject(first)))

!  WRITING OBJECT. Do most of the work for WRITE OBJECT.

  writingObject :−
   (proc (ref object first) void:
    (with

!  WRITING BRACKETS. Write an object without an obvious written representation.
!  WHAT tells us what kind of object it is.

      writingBrackets :−
       (form (string what) void:
        (if isString(what)
         then write('[' & what & '' %08X]'': first)
         else write(''[%s %08X]'': what, first)))

!  WRITING CONS. Write a CONS as a list. We change the TAG slots of CONSes from
!  CONS TAG to MARKED TAG as we go. If we encounter an object whose TAG slot is
!  MARKED TAG, then we're in a circular list, so we write "...". The MARKED TAG
!  slots get changed back to CONS TAG slots in WRITE OBJECT.

      writingCons :−
       (form () void:
        (with var ref object next :− first
         do write(openParenChar)
            next↑.tag := markedTag
            writingObject(next↑.car)
            next := next↑.cdr
            (while next↑.tag = consTag
             do write(blankChar)
                next↑.tag := markedTag
                writingObject(next↑.car)
                next := next↑.cdr)
            (if next↑.tag = markedTag
             then write('' [...]'')
             else if next ≠ nilName
                  then write(blankChar)
                       write(dotChar)
                       write(blankChar)
                       writingObject(next))
            write(closeParenChar)))

!  WRITING MARKED. Write a CONS whose TAG slot is MARKED TAG, meaning it's in a
!  circular list and has been written before.

      writingMarked :−
       (form () void:
         write(''[...]''))

!  WRITING NAME. Write a NAME.

      writingName :−
       (form () void:
        (for char ch in elements(first{ref name}↑.chars)
         do (if isNameChar(ch)
             then write(ch)
             else write(''\\%c'': ch))))

!  WRITING NIL. Write Orson's NIL. This isn't NIL NAME, and we should never see
!  it unless there's a bug. Probably, a NIL can't get this far without crashing
!  something.

      writingNil :−
       (form () void:
         write(''[nil]''))

!  WRITING INTEGER. Write an INTEGER.

      writingInteger :−
       (form () void:
         write(first{ref integer}↑.self))

!  WRITING TEXT. Write a TEXT.

      writingText :−
       (form () void:
         write(doubleQuoteChar)
         (for char0 ch in elements(first{ref text})
          do (if ch = doubleQuoteChar
              then write(backslashChar)
                   write(doubleQuoteChar)
              else if isControlChar(ch)
                   then write(backslashChar)
                        write(''#%02X'': ch)
                   else write(ch)))
         write(doubleQuoteChar))

!  WRITING TEXTLET. Write a TEXTLET. We shouldn't see one of these unless there
!  is a bug.

      writingTextlet :−
       (form () void:
         write(''[textlet %08X "'': first)
         (for int index in textletLength
          do (with char ch :− first{ref textlet}↑.chars[index]
              do (if ch = doubleQuoteChar
                  then write(backslashChar)
                       write(doubleQuoteChar)
                  else if isControlChar(ch)
                       then write(backslashChar)
                            write(''#%02X'': ch)
                       else write(ch))))
         write(''"]''))

!  WRITING UNKNOWN. Write an object with an unknown tag.

      writingUnknown :−
       (form () void:
         write(''[unknown%i %08X]'': first↑.tag, first))

!  This is WRITING OBJECT's body. Dispatch on FIRST's TAG slot. Note that we'll
!  never see a BINDER unless there's a bug.

     do (if first = nil
         then writingNil()
         else (case first↑.tag
               of consTag:        writingCons()
                  evenBinderTag:  writingBrackets(''even'')
                  hookTag:        writingBrackets(first{ref hook}↑.chars)
                  integerTag:     writingInteger()
                  lambdaTag:      writingBrackets(''closure'')
                  leftBinderTag:  writingBrackets(''left'')
                  markedTag:      writingMarked()
                  nameTag:        writingName()
                  rightBinderTag: writingBrackets(''right'')
                  textTag:        writingText()
                  textletTag:     writingTextlet()
                  none:           writingUnknown()))))
)
