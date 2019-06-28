!
!  SCAM/TEXT. Operations on texts.
!
!  Copyright © 2012 James B. Moen.
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

!  TEXT. A TEXT represents a string. FIRST is a linear linked chain of TEXTLETs
!  that hold characters. LIMIT is an INT with two nonnegative fields, START and
!  END. START is the index of the the string's first character in FIRST and END
!  is the index of its last character, in a TEXTLET later in the chain.

  inj textTag :− makeTag()

  text :−
   disp(
    (tuple
      var ref textlet first,
      var int         limit))

!  TEXTLET. A TEXTLET holds a string of TEXTLET LENGTH characters in CHARS. The
!  pointer NEXT references the next TEXTLET in a linear chain, or else NIL.

  int textletLength :− 8
  inj textletTag    :− makeTag()

  textlet :−
   disp(
    (tuple
      [textletLength] var char0 chars,
      var ref textlet           next))

!  ".". Return the START and END fields of a TEXT. The mask and shift constants
!  defined below depend on TEXTLET LENGTH.

  int endMask    :− 2#0000_0111_1111_1111_1111_1111_1111_1111
  int startMask  :− 2#0111_0000_0000_0000_0000_0000_0000_0000
  inj startShift :− 28

  "." :−
   (alt
    (form (text l, type $start) int:
     (l.limit & startMask) >> startShift),
    (form (text l, type $end) int:
      l.limit & endMask))

!  COMPARE TEXTS. Search two TEXTs, one character at a time, until a difference
!  is found, or until the end of either text is reached. Subtract characters at
!  the point where the search ended, and return their difference.

  compareTexts :−
   (proc (ref text left, ref text right) int:
    (with
      var int         leftCount  :− length(left)
      var int         leftIndex  :− left↑.start
      var ref textlet leftlet    :− left↑.first
      var int         rightCount :− length(right)
      var int         rightIndex :− right↑.start
      var ref textlet rightlet   :− right↑.first
      var int         Δ          :− (leftCount > 0) − (rightCount > 0)
     do (while Δ = 0 ∧ leftCount > 0 ∧ rightCount > 0
         do (if leftIndex = textletLength
             then leftlet := leftlet↑.next
                  leftIndex := 0)
            (if rightIndex = textletLength
             then rightlet := rightlet↑.next
                  rightIndex := 0)
            Δ := leftlet↑.chars[leftIndex] − rightlet↑.chars[rightIndex]
            leftCount  −= 1
            leftIndex  += 1
            rightCount −= 1
            rightIndex += 1)
        Δ))

!  COUNT. Return the number of CHAR1s in SELF. We count the CHAR0s that are not
!  continuation bytes.

  count :−
   (form (ref text self) int:
    (with var int total :− 0
     do (for char0 ch in elements(self)
         do total += (2#11000000 & ch ≠ 2#10000000))
        total))

!  ELEMENTS. Iterator. Visit each CHAR0 in SELF.

  elements :−
   (form (ref text self) foj:
    (form (form (char0) obj body) obj:
     (with
       var char0       ch
       ref text        self  :− (past self)
       var int         index :− self↑.start
       var ref textlet next  :− self↑.first
      do (in self↑.end − self↑.start
          do (if index = textletLength
              then next := next↑.next
                   index := 0)
             ch := next↑.chars[index]
             body(ch)
             index += 1))))

!  LENGTH. Return the number of CHAR0s in SELF.

  length :−
   (form (ref text self) int:
    (with ref text self :− (past self)
     do self↑.end − self↑.start))

!  MAKE LIMIT. Return a LIMIT slot with the fields START and END.

  makeLimit :−
   (form (int start, int end) int:
     start << startShift | end)

!  MAKE TEXT. Return a TEXT with given START, END, and FIRST fields. Or, return
!  a TEXT that contains the characters in CHARS.

  makeText :−
   (alt
    (form (int start, int end, ref textlet first) ref object:
      makeTextFromTextlets(start, end, first)),
    (form (string chars) ref object:
      makeTextFromString(chars)))

!  MAKE TEXT FROM STRING. Return a TEXT that contains the characters in CHARS.

  makeTextFromString :−
   (proc (string chars) ref object:
    (in deferred(interrupt)
     do (with
          var int         count :− 0
          var int         end   :− 0
          var ref textlet last  :− nil
          ref text        self  :− fromDump(text, 1, textTag)
         do (if chars↑
             then last := makeTextlet()
                  self↑.first := last
                  (for char0 ch in elements(chars)
                   do (if count = textletLength
                       then last↑.next := makeTextlet()
                            last := last↑.next
                            count := 0)
                      last↑.chars[count] := ch
                      count += 1
                      end += 1))
            self↑.limit := makeLimit(0, end)
            self{ref object})))

!  MAKE TEXT FROM TEXTLETS. Return a TEXT given its START, END, and TEXT slots.

  makeTextFromTextlets :−
   (proc (int start, int end, ref textlet first) ref object:
    (in deferred(interrupt)
     do (with var ref text self  :− fromDump(text, 1, textTag)
         do self↑.first := first
            self↑.limit := makeLimit(start, end)
            self{ref object})))

!  MAKE TEXTLET. Return a new TEXTLET.

  makeTextlet :−
   (proc () ref textlet:
    (in deferred(interrupt)
     do fromDump(textlet, 0, textletTag)))
)
