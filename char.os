!
!  SCAM/CHAR. Operations on characters.
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

!  Character constants. Some confuse EMACS if they appear as literals, so we'll
!  give them names just to be safe.

  char backslashChar    :− '\\'
  char blankChar        :− ' '
  char closeBracketChar :− ']'
  char closeParenChar   :− ')'
  char closeQuoteChar   :− '\''
  char colonChar        :− ':'
  char dashChar         :− '-'
  char dotChar          :− '.'
  char doubleQuoteChar  :− '"'
  char eofChar          :− '\#FF'
  char eolChar          :− eol
  char openBracketChar  :− '['
  char openParenChar    :− '('
  char openQuoteChar    :− '`'
  char semicolonChar    :− ';'

!  IS CONTROL CHAR. Test if CH is a control char.

  isControlChar :−
   (proc (char ch) bool:
     '\#00' ≤ ch ≤ '\#1F' ∨
     ch = '\#7F'          ∨
     '\#80' ≤ ch ≤ '\#9F' ∨
     ch = '\#2028'        ∨
     ch = '\#2029')

!  IS NAME CHAR. Test if CH can be part of a name.

  isNameChar :−
   (proc (char ch) bool:
     ch ≠ closeBracketChar ∧
     ch ≠ closeParenChar   ∧
     ch ≠ dotChar          ∧
     ch ≠ openBracketChar  ∧
     ch ≠ openParenChar    ∧
     ¬ isWhitespace(ch))

!  STRIDE. Return the number of bytes in a UTF-8 encoded CHAR1 whose first byte
!  is CH.

  stride :−
   (proc (char0 ch) int:
     byByte(ch, 1, 1, 2, 3, 4, 5, 6, 1))

)
