!
!  SCAM/READ. Read an object from a text file.
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
  inj maxLineLength :− 1024  !  Max length of a source line.

!  READ OBJECT. Read an object from SOURCE and return it. Names that start with
!  colons receive a PREFIX.

  readObject :−
   (proc (stream source, string prefix) ref object:
    (with
      var char ch                              !  Most recently read character.
      var buffer(maxLineLength, char0) chars   !  INTEGER or NAME buffer.
      var buffer(maxLineLength, char0) digits  !  Character code buffer.
      var buffer(maxLineLength, char)  line    !  Source line buffer.

!  READING CHAR. Read the next char into CH. We buffer characters using LINE so
!  we can discard the most recently read line after a syntax error.

      readingChar :−
       (proc () void:
        (if atEnd(line)
         then empty(line)
              (while
                ch := read(source)
                (if ch = eos
                 then append(line, eofChar)
                      false
                 else if ch = eolChar
                      then append(line, eolChar)
                           false
                      else if isControlChar(ch)
                           then append(line, blankChar)
                                true
                           else append(line, ch)
                                true))
              append(line, blankChar))
        ch := start(line)
        advance(line))

!  READING CLOSE IN PARENS. Read a close parenthesis. Stop reading the list.

      readingCloseInParens :−
       (form () bool:
         readingChar()
         false)

!  READING CONSTITUENT. Read a character that is part of a name or a string. It
!  may be prefixed by a backslash.

      readingConstituent :−
       (proc () void:
        (with

!  READING BACKSLASHED. Read a character following a backslash.

          readingBackslashed :−
           (proc (char ch) void:
             append(chars, ch)
             readingChar())

!  READING HEXADECIMAL. Read a series of hexadecimal digits after an '#', which
!  turns into the CHAR with that hexadecimal CODE.

          readingHexadecimal :−
           (form () void:
             empty(digits)
             (while
               readingChar()
               isDigit(ch, 16)
              do append(digits, ch{char0}))
             (for bool ok, int code in convert(int, digits{string}, 16)
              do (if ok ∧ low(char) ≤ code ≤ high(char)
                  then append(chars, code{char})
                  else error(''Illegal \\# character code''))))

!  This is READING CONSTITUENT's body. Dispatch to an appropriate parser.

         do (if ch = backslashChar
             then readingChar()
                  (case ch
                   of 'A', 'a': readingBackslashed('\A')
                      'B', 'b': readingBackslashed('\B')
                      'E', 'e': readingBackslashed('\E')
                      'F', 'f': readingBackslashed('\F')
                      'N', 'n': readingBackslashed('\N')
                      'R', 'r': readingBackslashed('\R')
                      'T', 't': readingBackslashed('\T')
                      'V', 'v': readingBackslashed('\V')
                           '#': readingHexadecimal()
                           '_': readingChar()
                       eofChar: error(''Missing backslashed character'')
                       eolChar: readingBackslashed(' ')
                          none: error(''Unknown backslashed character''))
             else append(chars, ch)
                  readingChar())))

!  READING DASH. Read a negative INTEGER, or a NAME that starts with a dash.

      readingDash :−
       (form (var ref object first) void:
         empty(chars)
         readingChar()
         (if isDigit(ch)
          then readingDigits()
               (if isNameChar(ch)
                then readingOthers()
                     first := makeName(chars{string})
                else (for bool ok, int number in convert(int, chars{string})
                      do first := makeInteger(− number)))
          else append(chars, dashChar)
               readingOthers()
               first := makeName(chars{string})))

!  READING DIGIT. Read a positive INTEGER, or a NAME that starts with a digit.

      readingDigit :−
       (proc (var ref object first) void:
         empty(chars)
         readingDigits()
         (if isNameChar(ch)
          then readingOthers()
               first := makeName(chars{string})
          else (for bool ok, int number in convert(int, chars{string})
                do first := makeInteger(number))))

!  READING DIGITS. Read one or more digits, part of an INTEGER.

      readingDigits :−
       (form () void:
        (while
          append(chars, ch)
          readingChar()
          isDigit(ch)))

!  READING DOT IN PARENS. Read a dot, followed by an object, and a close paren.
!  Then stop reading the enclosing list.

      readingDotInParens :−
       (form (var ref object last) bool:
         readingChar()
         last↑.cdr := readingObject()
         readingWhitespace()
         (if ch = closeParenChar
          then readingChar()
          else error(''Close parenthesis expected''))
         false)

!  READING DOUBLE QUOTE. Read a series of characters surrounded by double quote
!  marks. It turns into a TEXT.

      readingDoubleQuote :−
       (form (var ref object first) void:
         empty(chars)
         readingChar()
         (while ch ≠ doubleQuoteChar ∧ ch ≠ eofChar ∧ ch ≠ eolChar
          do readingConstituent())
         (if ch = doubleQuoteChar
          then readingChar()
               first := makeText(chars{string})
          else error(''Missing closing double quote'')))

!  READING EOF. Read an end of file character. It turns into an EOF.

      readingEof :−
       (form (var ref object first) void:
         first := makeEof())

!  READING EOF IN PARENS. Read an unexpected end of file inside parens.

      readingEofInParens :−
       (form () bool:
         error(''End of file inside a list'')
         false)

!  READING OBJECT. Do all the work for READ OBJECT. We simply dispatch on CH to
!  the relevant parser.

      readingObject :−
       (proc () ref object:
        (with var ref object first :− nil
         do readingWhitespace()
            (case ch
             of closeBracketChar: error(''Unexpected close bracket'')
                  closeParenChar: error(''Unexpected close parenthesis'')
                  closeQuoteChar: readingSingleQuote(first)
                        dashChar: readingDash(first)
                         dotChar: error(''Unexpected dot'')
                         eofChar: readingEof(first)
                 openBracketChar: error(''Unexpected open bracket'')
                   openParenChar: readingOpenParen(first)
                   openQuoteChar: readingSingleQuote(first)
                 doubleQuoteChar: readingDoubleQuote(first)
                             '0': readingDigit(first)
                             '1': readingDigit(first)
                             '2': readingDigit(first)
                             '3': readingDigit(first)
                             '4': readingDigit(first)
                             '5': readingDigit(first)
                             '6': readingDigit(first)
                             '7': readingDigit(first)
                             '8': readingDigit(first)
                             '9': readingDigit(first)
                            none: readingOther(first))
            first))

!  READING OPEN PAREN. Read NIL NAME or a list. Forms in the CASE clause return
!  Booleans that tell whether to keep reading.

      readingOpenParen :−
       (form (var ref object first) void:
         readingChar()
         readingWhitespace()
         (if ch = closeParenChar
          then readingChar()
               first := nilName
          else (with var ref object last :− makeCons(readingObject(), nilName)
                do first := last
                   (while
                     readingWhitespace()
                     (case ch
                      of closeParenChar: readingCloseInParens()
                                dotChar: readingDotInParens(last)
                                eofChar: readingEofInParens()
                                   none: readingOtherInParens(last))))))

!  READING OTHER. Read a name. If it begins with a colon, then add PREFIX.

      readingOther :−
       (form (var ref object first) void:
         empty(chars)
         (if ch = colonChar
          then append(chars, prefix))
         readingOthers()
         first := makeName(chars{string}))

!  READING OTHERS. Read a series of zero or more characters, part of a NAME.

      readingOthers :−
       (form () void:
        (while isNameChar(ch)
         do readingConstituent()))

!  READING OTHER IN PARENS. Read an object in a list. Keep reading the list.

      readingOtherInParens :−
       (form (var ref object last) bool:
         last↑.cdr := makeCons(readingObject(), nilName)
         last := last↑.cdr
         true)

!  READING SINGLE QUOTE. Read a quote character followed by an object. It turns
!  into a call to QUOTE.

      readingSingleQuote :−
       (form (var ref object first) void:
         readingChar()
         first := makeCons(quoteHook, makeCons(readingObject(), nilName)))

!  READING WHITESPACE. Skip zero or more invisible characters and comments. The
!  latter begin with semicolons and continue until ends of lines.

      readingWhitespace :−
       (proc () void:
        (while
         (if ch = semicolonChar
          then (while
                 readingChar()
                 ch ≠ eolChar ∧ ch ≠ eofChar)
               true
          else if ch = blankChar ∨ ch = eolChar
               then readingChar()
                    true
               else false)))

!  This is READ OBJECT's body. Initialize LINE and CH, then read an object.

     do empty(line)
        readingChar()
        readingObject()))
)
