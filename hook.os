!
!  SCAM/HOOK. Operations on hooks.
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

!  HOOK. An object representing a function defined by code inside the evaluator
!  (see SCAM/EVALUATE). CHARS is the name of this function, and CODE identifies
!  it internally.

  inj hookTag :− makeTag()

  hook :−
   disp(
    (tuple
      var string chars,
      var int    code))

!  MAKE HOOK. Return a new HOOK whose CHARS slot contains CHARS, and whose CODE
!  slot contains CODE.

  makeHook :−
   (proc (string chars, int code) ref object:
    (with ref hook self :− fromHeap(hook, 0, hookTag)
     do self↑.chars := chars
        self↑.code  := code
        self{ref object}))

!  Make codes that identify functions implemented as HOOKs.

  makeCode :− enum()

  inj andCode      :− makeCode()  !  Logical conjunction.
  inj carCode      :− makeCode()  !  CAR of a cons.
  inj catchCode    :− makeCode()  !  Receive control from a THROW.
  inj cdrCode      :− makeCode()  !  CDR of a cons.
  inj consCode     :− makeCode()  !  Make a new cons.
  inj cxrCode      :− makeCode()  !  Compositions of CAR and CDR.
  inj defineCode   :− makeCode()  !  Bind name globally.
  inj firstCode    :− makeCode()  !  Value of 1st term in sequence.
  inj ifCode       :− makeCode()  !  If then else.
  inj implyCode    :− makeCode()  !  Logical implication.
  inj includeCode  :− makeCode()  !  Load a unloaded file.
  inj intAddCode   :− makeCode()  !  Add zero or more integers.
  inj intAndCode   :− makeCode()  !  Bit AND of zero or more integers.
  inj intDivCode   :− makeCode()  !  Divide two integers.
  inj intEqCode    :− makeCode()  !  Integer equal test.
  inj intGeCode    :− makeCode()  !  Integer greater or equal test.
  inj intGtCode    :− makeCode()  !  Integer greater test.
  inj intLeCode    :− makeCode()  !  Integer less or equal test.
  inj intLtCode    :− makeCode()  !  Integer less test.
  inj intModCode   :− makeCode()  !  Modulus of two integers.
  inj intMulCode   :− makeCode()  !  Multiply zero or more integers.
  inj intNeCode    :− makeCode()  !  Integer not equal test.
  inj intNegCode   :− makeCode()  !  Integer sign change.
  inj intNotCode   :− makeCode()  !  Bitwise integer NOT.
  inj intOrCode    :− makeCode()  !  Logical disjunction.
  inj intSubCode   :− makeCode()  !  Subtract two integers.
  inj intXorCode   :− makeCode()  !  Bitwise XOR of zero or more integers.
  inj isConsCode   :− makeCode()  !  Test for cons.
  inj isEofCode    :− makeCode()  !  Test for EOF.
  inj isHookCode   :− makeCode()  !  Test for hook.
  inj isIntCode    :− makeCode()  !  Test for integer.
  inj isLambdaCode :− makeCode()  !  Test for lambda.
  inj isNameCode   :− makeCode()  !  Test for name.
  inj isNilCode    :− makeCode()  !  Test for NIL.
  inj isStringCode :− makeCode()  !  Test for string.
  inj lambdaCode   :− makeCode()  !  Make a new lambda.
  inj lastCode     :− makeCode()  !  Value of last term in a series of terms.
  inj letCode      :− makeCode()  !  Bind local names and evaluate.
  inj listCode     :− makeCode()  !  Make a new list.
  inj loadCode     :− makeCode()  !  Evaluate terms from a file.
  inj nameStrCode  :− makeCode()  !  Convert a name to a string.
  inj objEqCode    :− makeCode()  !  Test if two objects are identical.
  inj objLenCode   :− makeCode()  !  Object length.
  inj objNeCode    :− makeCode()  !  Test if two objects are different.
  inj objWriteCode :− makeCode()  !  Write an object.
  inj orCode       :− makeCode()  !  Logical disjunction.
  inj quitCode     :− makeCode()  !  Halt Scam.
  inj quoteCode    :− makeCode()  !  Return an object without evaluating it.
  inj setCode      :− makeCode()  !  Rebind a bound name.
  inj setCarCode   :− makeCode()  !  Reset the CAR of a cons.
  inj setCdrCode   :− makeCode()  !  Reset the CDR of a cons.
  inj strAddCode   :− makeCode()  !  Concatenate zero or more strings.
  inj strDateCode  :− makeCode()  !  Current date as a string.
  inj strEqCode    :− makeCode()  !  String equal test.
  inj strGeCode    :− makeCode()  !  String greater or equal test.
  inj strGtCode    :− makeCode()  !  String greater test.
  inj strLeCode    :− makeCode()  !  String less or equal test.
  inj strLenCode   :− makeCode()  !  String length.
  inj strLowCode   :− makeCode()  !  String letters to lower case.
  inj strLtCode    :− makeCode()  !  String less than test.
  inj strNameCode  :− makeCode()  !  Convert a string to a name.
  inj strNeCode    :− makeCode()  !  String not equal test.
  inj strReadCode  :− makeCode()  !  Read a string.
  inj strSubCode   :− makeCode()  !  String substring (not subtract).
  inj strUpCode    :− makeCode()  !  String letters to upper case.
  inj strWriteCode :− makeCode()  !  Write a string.
  inj throwCode    :− makeCode()  !  Pass control to deepest CATCH.
)
